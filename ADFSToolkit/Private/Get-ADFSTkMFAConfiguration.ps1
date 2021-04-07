﻿function Get-ADFSTkMFAConfiguration {
    param (

        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [string]$EntityId
    )


    if ([string]::IsNullOrEmpty($Global:ADFSTkManualSPSettings)) {
        if ([string]::IsNullOrEmpty($Global:ADFSTkAllTransformRules) -or $Global:ADFSTkAllTransformRules.Count -eq 0) {
            $Global:ADFSTkAllTransformRules = Import-ADFSTkAllTransformRules
            $AllTransformRules = $Global:ADFSTkAllTransformRules #So we don't need to change anything in the Get-ADFSTkManualSPSettings files
        }
        $Global:ADFSTkManualSPSettings = Get-ADFSTkManualSPSettings
    }

    $ApplyMFAConfiguration = $null

    #AllSPs
    if ($Global:ADFSTkManualSPSettings.ContainsKey('urn:adfstk:allsps') -and `
            $Global:ADFSTkManualSPSettings.'urn:adfstk:allsps' -is [System.Collections.Hashtable] -and `
            $Global:ADFSTkManualSPSettings.'urn:adfstk:allsps'.ContainsKey('ApplyMFAConfiguration')) {
        $ApplyMFAConfiguration = $Global:ADFSTkManualSPSettings.'urn:adfstk:allsps'.ApplyMFAConfiguration
    }

    #AllEduSPs

    if ($EntityId -ne $null) {
    
        #First remove http:// or https://
        $entityDNS = $EntityId.ToLower().Replace('http://', '').Replace('https://', '')

        #Second get rid of all ending sub paths
        $entityDNS = $entityDNS -split '/' | select -First 1

        #Last fetch the last two words and join them with a .
        #$entityDNS = ($entityDNS -split '\.' | select -Last 2) -join '.'

        $settingsDNS = $null

        foreach ($setting in $Global:ADFSTkManualSPSettings.Keys) {
            if ($setting.StartsWith('urn:adfstk:entityiddnsendswith:')) {
                $settingsDNS = $setting -split ':' | select -Last 1
            }
        }

        if ($entityDNS.EndsWith($settingsDNS) -and `
                $Global:ADFSTkManualSPSettings."urn:adfstk:entityiddnsendswith:$settingsDNS" -is [System.Collections.Hashtable] -and `
                $Global:ADFSTkManualSPSettings."urn:adfstk:entityiddnsendswith:$settingsDNS".ContainsKey('ApplyMFAConfiguration')) {
            $ApplyMFAConfiguration = $Global:ADFSTkManualSPSettings."urn:adfstk:entityiddnsendswith:$settingsDNS".ApplyMFAConfiguration
        }

        #Manual SP
        if ($EntityId -ne $null -and `
                $Global:ADFSTkManualSPSettings.ContainsKey($EntityId) -and `
                $Global:ADFSTkManualSPSettings.$EntityId -is [System.Collections.Hashtable] -and `
                $Global:ADFSTkManualSPSettings.$EntityId.ContainsKey('ApplyMFAConfiguration')) {
            $ApplyMFAConfiguration = $Global:ADFSTkManualSPSettings.$EntityId.ApplyMFAConfiguration
        }
    }

    if ($ApplyMFAConfiguration -ne $null -and $ApplyMFAConfiguration.ToLower() -eq 'azuremfa') {
        ### DO WE NEED THIS HERE TO?
        #region Add Access Control Policy if needed
        if ((Get-AdfsAccessControlPolicy -Identifier ADFSToolkitPermitEveryoneAndRequireMFA) -eq $null) {
            $ACPMetadata = @"
        <PolicyMetadata xmlns:i="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://schemas.datacontract.org/2012/04/ADFS">
        <RequireFreshAuthentication>false</RequireFreshAuthentication>
        <IssuanceAuthorizationRules>
        <Rule>
            <Conditions>
            <Condition i:type="MultiFactorAuthenticationCondition">
                <Operator>IsPresent</Operator>
                <Values />
            </Condition>
            </Conditions>
        </Rule>
        </IssuanceAuthorizationRules>
    </PolicyMetadata>  
"@
            New-AdfsAccessControlPolicy -Name "ADFSToolkit - Permit everyone and force MFA" `
                -Identifier ADFSToolkitPermitEveryoneAndRequireMFA `
                -Description "Grant access to everyone and require MFA for everyone." `
                -PolicyMetadata $ACPMetadata | Out-Null
        }
        #endregion
    
        $mfaRules = @()
        $mfaRules += @"
@RuleName = "Check RefedsMFA context class after successful Azure MFA with TOTP"
c:[Type == "http://schemas.microsoft.com/claims/authnmethodsreferences", Value == "http://schemas.microsoft.com/ws/2012/12/authmethod/otp"]
=> add(Type = "urn:adfstk:mfalogon", Value = "true");
"@
        
        $mfaRules += @"
@RuleName = "Exists RefedsMFA context class after successful Azure MFA with TOTP"
NOT EXISTS([Type == "urn:adfstk:mfalogon"])
=> issue(Type = "http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationmethod", Value = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport");
"@
        
        $mfaRules
    }
    else {
        $null
    }    

}