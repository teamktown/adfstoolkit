﻿#Requires -Version 5.1

function New-ADFSTkInstitutionConfiguration {
[cmdletbinding()]
    Param (
    )

    try {
        $mainConfiguration = Get-ADFSTkConfiguration
    }
    catch {
        #inform that we need a main config and that we will call that now
        Write-ADFSTkHost -WriteLine -AddSpaceAfter
        Write-ADFSTkHost confNeedMainConfigurationMessage -Style Info -AddSpaceAfter
        $mainConfiguration = New-ADFSTkConfiguration -Passthru
    }

    Write-ADFSTkHost confCreateNewConfigurationFile -Style Info -AddLinesOverAndUnder

    # Use a default template from to start with
    #$mainConfiguration.FederationConfig.Federation

    $federationName = $mainConfiguration.Configuration.FederationConfig.Federation.FederationName
    if ([string]::IsNullOrEmpty($federationName))
    {
        $defaultConfigFile = $Global:ADFSTkPaths.defaultConfigFile
        #[xml]$config = Get-Content $Global:ADFSTkPaths.defaultConfigFile
    }
    else
    {
        $defaultFederationConfigDir = Join-Path $Global:ADFSTkPaths.federationDir $federationName
        
        #Check if the federation dir exists and if not, create it
        ADFSTk-TestAndCreateDir -Path $defaultFederationConfigDir -PathName "$federationName config directory"

        #Check if we already have any Federation defaults file(s)
        $defaultFederationConfigFiles = Get-ChildItem -Path $defaultFederationConfigDir -Filter "*_defaultConfigFile.xml"
        
        if ([string]::IsNullOrEmpty($defaultFederationConfigFiles))
        {
            Write-ADFSTkHost confCopyFederationDefaultFolderMessage -Style Info -AddSpaceAfter -f $Global:ADFSTkPaths.federationDir
            Read-Host (Get-ADFSTkLanguageText cPressEnterKey) | Out-Null
        
            $defaultFederationConfigFiles = Get-ChildItem -Path $defaultFederationConfigDir -Filter "*_defaultConfigFile.xml"
        }
        
        if ([string]::IsNullOrEmpty($defaultFederationConfigFiles))
        {
            $defaultConfigFile = $null
        }
        elseif ($defaultFederationConfigFiles -is [System.IO.FileSystemInfo])
        {
            $defaultConfigFile = $defaultFederationConfigFiles.FullName
            #[xml]$config = Get-Content $defaultFederationConfigFiles.FullName
        }
        elseif ($defaultFederationConfigFiles -is [System.Array])
        {
            $defaultConfigFile = $defaultFederationConfigFiles | Out-GridView -Title "Select the default federation configuration file you want to use" -OutputMode Single | Select -ExpandProperty FullName
        }
        else
        {
            #We should never be here...
        }

        if ([string]::IsNullOrEmpty($defaultConfigFile))
        {
            if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confFederationDefaultConfigNotFoundQuestion -f $federationName) -DefaultYes)
            {
                $defaultConfigFile = $Global:ADFSTkPaths.defaultConfigFile
                #[xml]$config = Get-Content $Global:ADFSTkPaths.defaultConfigFile
            }
            else
            {
                Write-ADFSTkLog (Get-ADFSTkLanguageText confFederationDefaultConfigNotFound) -MajorFault
            }
        }

    }

    try {
        [xml]$defaultConfig = Get-Content $defaultConfigFile

        if ($defaultConfig.configuration.ConfigVersion -ne $Global:ADFSTkCompatibleInstitutionConfigVersion)
        {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confDefaultConfigIncorrectVersion -f $defaultConfigFile,$defaultConfig.configuration.ConfigVersion,$Global:ADFSTkCompatibleInstitutionConfigVersion) -MajorFault
        }
    }
    catch {
        Write-ADFSTkLog (Get-ADFSTkLanguageText confCouldNotOpenFederationDefaultConfig -f $defaultConfigFile,$_) -MajorFault
    }

    [xml]$newConfig = $defaultConfig.Clone()


    Write-ADFSTkHost confStartMessage -Style Info -AddSpaceAfter
    Write-ADFSTkHost -WriteLine
    
    Set-ADFSTkConfigItem -XPath "configuration/metadataURL" `
                         -ExampleValue 'https://metadata.federationOperator.org/path/to/metadata.xml' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig
                       
    Set-ADFSTkConfigItem -XPath "configuration/signCertFingerprint" `
                         -ExampleValue '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/MetadataPrefix" `
                         -ExampleValue 'ADFSTk/CANARIE/INCOMMON/SWAMID' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig
                  
    Set-ADFSTkConfigItem -XPath "configuration/staticValues/co" `
                         -ExampleValue 'Canada, Sweden, USA' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/staticValues/c" `
                         -ExampleValue 'CA, SE, US' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/staticValues/o" `
                         -ExampleValue 'University Of Example' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/staticValues/schacHomeOrganization" `
                         -ExampleValue 'universityofexample.edu' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/staticValues/norEduOrgAcronym" `
                         -ExampleValue 'UoE' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/staticValues/ADFSExternalDNS" `
                         -ExampleValue 'adfs.universityofexample.edu' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    Set-ADFSTkConfigItem -XPath "configuration/eduPersonPrincipalNameRessignable" `
                         -ExampleValue 'false' `
                         -DefaultConfig $defaultConfig `
                         -NewConfig $newConfig

    
    #Adding eduPersonScopedAffiliation based on eduPersonAffiliation added with @schackHomeOrganization
    $epa = $newConfig.configuration.attributes.attribute | ? type -eq "urn:mace:dir:attribute-def:eduPersonAffiliation" 
    $epsa = $newConfig.configuration.attributes.attribute | ? type -eq "urn:mace:dir:attribute-def:eduPersonScopedAffiliation"
    

    $epa.ChildNodes | % {
        $node = $_.Clone()    
        $node.InnerText += "@$($newConfig.configuration.staticValues.schacHomeOrganization)"

        $epsa.AppendChild($node) | Out-Null
    }

    # various useful items for minting our configuration 

    # user entered
    $myPrefix = (Select-Xml -Xml $newConfig -XPath "configuration/MetadataPrefix").Node.InnerText

    # For the ADFSTk functionality, we desire to associate certain cache files to certain things and bake a certain default location
 
    #(Select-Xml -Xml $config -XPath "configuration/WorkingPath").Node.'#text' = "$myADFSTkInstallDir" #Do we really need this?
    (Select-Xml -Xml $newConfig -XPath "configuration/SPHashFile").Node.InnerText = "$myPrefix-SPHashfile.xml"
    (Select-Xml -Xml $newConfig -XPath "configuration/MetadataCacheFile").Node.InnerText = "$myPrefix-metadata.cached.xml"

    $newConfigFile = Join-Path $Global:ADFSTkPaths.institutionDir "config.$myPrefix.xml"

    if (Test-path $newConfigFile)
    {
        #Should we recommend to do an upgrade instead?
        if (Get-ADFSTkAnswer -Caption (Get-ADFSTkLanguageText confConfigurationAlreadyExistsCaption) `
                             -Message (Get-ADFSTkLanguageText confOverwriteConfiguration) `
                             -DefaultYes)
        {
            $newConfigFileObject = Get-ChildItem $newConfigFile
            $myConfigFileBkpName = Join-Path $Global:ADFSTkPaths.institutionBackupDir ("{0}.{1}{2}" -f $newConfigFileObject.BaseName, (get-date -Format o).Replace(':','.'), $newConfigFileObject.Extension)

            Write-ADFSTkHost confCreatingNewConfigHere -f $newConfigFile -Style Value
            Write-ADFSTkHost confOldConfigurationFile -f $myConfigFileBkpName -Style Value

            Move-Item -Path $newConfigFile -Destination $myConfigFileBkpName

            $newConfig.Save($newConfigFile)
        } 
        else 
        {
            Write-ADFSTkLog (Get-ADFSTkLanguageText confDontOverwriteFileExit) -MajorFault
        }
    }
    else
    {
        Write-ADFSTkHost confInstConfigCreated -f $newConfigFile -Style Value
        $newConfig.Save($newConfigFile)
    }


    
    #Add $configFile to Main Config File

    Write-ADFSTkHost confAddFileToMainConfigMessage -Style Info -AddLinesOverAndUnder

    Add-ADFSTkConfigurationItem -ConfigurationItem $newConfigFile

    Write-ADFSTkHost -WriteLine -AddSpaceAfter

    Write-ADFSTkHost confConfigurationFileSavedHere -f $newConfigFile -Style Value
    
#region get-ADFSTkLocalManualSpSettings.ps1

    Write-ADFSTkHost confLocalManualSettingsMessage -Style Info -AddLinesOverAndUnder

    # Prepare our template for ADFSTkManualSPSettings to be copied into place, safely of course, after directories are confirmed to be there.

    #$myADFSTkManualSpSettingsDistroTemplateFile =  Join-Path $Global:ADFSTkPaths.modulePath     -ChildPath "config\default\en-US\get-ADFSTkLocalManualSpSettings-dist.ps1"
    $myADFSTkManualSpSettingsInstallTemplateFile = Join-Path $Global:ADFSTkPaths.institutionDir -ChildPath "get-ADFSTkLocalManualSpSettings.ps1"

    if (Test-path $myADFSTkManualSpSettingsInstallTemplateFile ) 
    {
        if (Get-ADFSTkAnswer -Caption (Get-ADFSTkLanguageText confInstLocalSPFileExistsCaption) `
                             -Message (Get-ADFSTkLanguageText confOverwriteInstLocalSPFileMessage -f $myADFSTkManualSpSettingsInstallTemplateFile))
        {
            $myADFSTkManualSpSettingsInstallTemplateFileObject = Get-ChildItem $myADFSTkManualSpSettingsInstallTemplateFile
           
            Write-ADFSTkHost confOverwriteInstLocalSPFileConfirmed -f $myADFSTkManualSpSettingsInstallTemplateFile -Style Value

            $mySPFileBkpName = Join-Path $Global:ADFSTkPaths.institutionBackupDir ("{0}.{1}{2}" -f $myADFSTkManualSpSettingsInstallTemplateFileObject.BaseName, (get-date -Format o).Replace(':','.'), $myADFSTkManualSpSettingsInstallTemplateFileObject.Extension)

            Write-ADFSTkHost confCreateNewInstLocalSPFile -f $Global:ADFSTkPaths.defaultInstitutionLocalSPFile -Style Value
            Write-ADFSTkHost confOldInstLocalSPFile -f $mySPFileBkpName -Style Value

            # Make backup
            Move-Item -Path $myADFSTkManualSpSettingsInstallTemplateFile -Destination $mySPFileBkpName

            Copy-ADFSTkFile -Path $Global:ADFSTkPaths.defaultInstitutionLocalSPFile -Destination $myADFSTkManualSpSettingsInstallTemplateFile
        } 
        else 
        {
            Write-ADFSTkHost confDontOverwriteFileJustProceed -Style Info -AddSpaceAfter
        }
    }
    else
    {
        Write-ADFSTkHost confNoExistingFileSaveTo -f $myADFSTkManualSpSettingsInstallTemplateFile -Style Value -AddSpaceAfter
        Copy-ADFSTkFile -Path $Global:ADFSTkPaths.defaultInstitutionLocalSPFile -Destination $myADFSTkManualSpSettingsInstallTemplateFile
    }

#endregion

#region Get-ADFSTkLocalTransformRules.ps1

Write-ADFSTkHost confLocalTransformRulesMessage -Style Info -AddLinesOverAndUnder -f $Global:ADFSTkPaths.institutionLocalTransformRulesFile

# Prepare our template for ADFSTkLocalTransformRules to be copied into place, safely of course, after directories are confirmed to be there.

if (Test-path $Global:ADFSTkPaths.institutionLocalTransformRulesFile ) 
{
    if (Get-ADFSTkAnswer -Caption (Get-ADFSTkLanguageText confLocalTransformRulesFileExistsCaption) `
                         -Message (Get-ADFSTkLanguageText confOverwriteInstLocalSPFileMessage -f $Global:ADFSTkPaths.institutionLocalTransformRulesFile))
    {
        $myADFSTkLocalTransformRulesInstallTemplateFileObject = Get-ChildItem $Global:ADFSTkPaths.institutionLocalTransformRulesFile
        Write-ADFSTkHost confOverwriteLocalTransformRulesFileConfirmed -f $Global:ADFSTkPaths.institutionLocalTransformRulesFile -Style Value

        $myTRFileBkpName = Join-Path $Global:ADFSTkPaths.institutionBackupDir ("{0}.{1}{2}" -f $myADFSTkLocalTransformRulesInstallTemplateFileObject.BaseName, (get-date -Format o).Replace(':','.'), $myADFSTkLocalTransformRulesInstallTemplateFileObject.Extension)

        Write-ADFSTkHost confCreateNewInstLocalTransformRuleFile -f $Global:ADFSTkPaths.defaultInstitutionLocalTransformRulesFile -Style Value
        Write-ADFSTkHost confOldInstLocalSPFile -f $myTRFileBkpName -Style Value

        # Make backup
        Move-Item -Path $Global:ADFSTkPaths.institutionLocalTransformRulesFile -Destination $myTRFileBkpName
        # Copy dist file
        Copy-ADFSTkFile -Path $Global:ADFSTkPaths.defaultInstitutionLocalTransformRulesFile -Destination $Global:ADFSTkPaths.institutionLocalTransformRulesFile
    } 
    else 
    {
        Write-ADFSTkHost confDontOverwriteFileJustProceed -Style Info -AddSpaceAfter
    }
}
else
{
    Write-ADFSTkHost confNoExistingFileSaveTo -f $Global:ADFSTkPaths.institutionLocalTransformRulesFile -Style Value -AddSpaceAfter
    Copy-ADFSTkFile -Path $Global:ADFSTkPaths.defaultInstitutionLocalTransformRulesFile -Destination $Global:ADFSTkPaths.institutionLocalTransformRulesFile
}

#endregion
    
    Write-ADFSTkHost confHowToRunMetadataImport -Style Info -AddLinesOverAndUnder

    if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confCreateScheduledTask))
    {
        Register-ADFSTkScheduledTask
    }

    Write-ADFSTkHost -WriteLine -AddSpaceAfter
    Write-ADFSTkHost cAllDone -Style Done

<#
.SYNOPSIS
Create or migrats an ADFSToolkit configuration file per aggregate.

.DESCRIPTION

This command creates a new or migrates an older configuration to a newer one when invoked.

How this Powershell Cmdlet works:
 
When loaded we:
   -  seek out a template configuration in $Module-home/config/default/en/config.ADFSTk.default*.xml 
   -- where * is the language designation, usually 'en'
   -  if invoked with -MigrateConfig, the configuration attempts to detect the previous answers as defaults to the new ones where possible

   
.INPUTS

zero or more inputs of an array of string to command

.OUTPUTS

configuration file(s) for use with current ADFSToolkit that this command is associated with

.EXAMPLE
new-ADFSTkConfiguration

.EXAMPLE

"C:\ADFSToolkit\0.0.0.0\config\config.file.xml" | new-ADFSTkConfiguration

.EXAMPLE

"C:\ADFSToolkit\0.0.0.0\config\config.file.xml","C:\ADFSToolkit\0.0.0.0\config\config.file2.xml" | new-ADFSTkConfiguration

#>

}


