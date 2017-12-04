#========================================================================== 
# NAME: Import-SWAMIDAttributeResolver.ps1
#
# DESCRIPTION: Defines all SAML2.0 attributes and AD attributes that are
#              used to create TransformRules and Claims
#
# 
# AUTHOR: Johan Peterson (Linköping University)
# DATE  : 2014-03-18
#
# PUBLISH LOCATION: C:\Published Powershell Scripts\ADFS
#
#=========================================================================
#  Version     Date      	Author              	Note 
#  ----------------------------------------------------------------- 
#   1.0        2014-03-18	Johan Peterson (Linköping University)	Initial Release
#   1.1        2014-03-18	Johan Peterson (adm)	First Publish
#   1.2        2014-03-18	Johan Peterson (adm)	Fixed bug in Static release 
#   1.3        2014-03-18	Johan Peterson (adm)	Added ADFSExternalDNS as static variable to make Transient-Id easier
#   1.4        2014-12-15	Johan Peterson (adm)	Change all eduPersonScopedAffiliation to lowercases
#   1.5        2015-03-05	Johan Peterson (adm)	Added eduPersonTargetedID
#   1.6        2015-04-24	Johan Peterson (adm)	entity-id don't have sp.swamid.se hardcoded anymore
#   1.7        2015-05-13	Johan Peterson (adm)	Added Loginname for Amadeus
#   1.8        2015-05-22	Johan Peterson (adm)	Added samaccountname as attribute
#=========================================================================

# function Import-ADFSTkAllAttributes
# {
#     #All attributes
#     $Attributes = @{}
    
#      $Attributes = @{}

#     foreach ($store in $Settings.configuration.storeConfig.stores.store)
#     {
#         foreach ($attribute in ($Settings.configuration.storeConfig.attributes.attribute | ? store -eq $store.name))
#         {
#             $Attributes.($attribute.type) = $attribute
#         }
#     }
   
#     $Attributes
# }
#All TransformRules

function Import-ADFSTkAllTransformRules
{
    ### Get static values from configuration file

# settings are global, this section will be removed when things are running as expected

 #   if (!(Test-Path (Join-Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') Import-SWAMIDMetadata.config.xml)))
 #   {
 #       throw "Could not find 'Import-SWAMIDMetadata.config.xml'. Please put the file in the same directory as Import-SWAMIDMetadata.config.ps1"
 #   }
 #   else
 #   {
 #       [xml]$Settings=Get-Content (Join-Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') Import-SWAMIDMetadata.config.xml)
#  }

    ###

    $TransformRules = @{}
 #region Static values from config
    $TransformRules.o = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [o]"
    => issue(type = "urn:oid:2.5.4.10", 
    value = "$($Settings.configuration.StaticValues.o)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules.norEduOrgAcronym = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [norEduOrgAcronym]"
    => issue(type = "urn:oid:1.3.6.1.4.1.2428.90.1.6", 
    value = "$($Settings.configuration.StaticValues.norEduOrgAcronym)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules.c = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [c]"
    => issue(type = "urn:oid:2.5.4.6", 
    value = "$($Settings.configuration.StaticValues.c)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules.co = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [co]"
    => issue(type = "urn:oid:0.9.2342.19200300.100.1.43", 
    value = "$($Settings.configuration.StaticValues.co)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules.schacHomeOrganization = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [schacHomeOrganization]"
    => issue(type = "urn:oid:1.3.6.1.4.1.25178.1.2.9", 
    value = "$($Settings.configuration.StaticValues.schacHomeOrganization)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules.schacHomeOrganizationType = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Send static [schacHomeOrganizationType]"
    => issue(type = "urn:oid:1.3.6.1.4.1.25178.1.2.10", 
    value = "$($Settings.configuration.StaticValues.schacHomeOrganizationType)",
    Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }
    #endregion

    #region ID's
    $TransformRules."transient-id" = [PSCustomObject]@{
    Rule=@"
    @RuleName = "synthesize transient-id"
    c1:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/primarysid"]
     && 
     c2:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/authenticationinstant"]
     => add(store = "_OpaqueIdStore", 
     types = ("http://$($Settings.configuration.StaticValues.ADFSExternalDNS)/internal/tpid"),
     query = "{0};{1};{2};{3};{4}", 
     param = "useEntropy", 
     param = "http://$($Settings.configuration.StaticValues.ADFSExternalDNS)/adfs/services/trust![ReplaceWithSPNameQualifier]!" + c1.Value, 
     param = c1.OriginalIssuer, 
     param = "", 
     param = c2.Value);

    @RuleName = "issue transient-id"
    c:[Type == "http://$($Settings.configuration.StaticValues.ADFSExternalDNS)/internal/tpid"]
     => issue(Type = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/format"] = "urn:oasis:names:tc:SAML:2.0:nameid-format:transient", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/spnamequalifier"] = "[ReplaceWithSPNameQualifier]", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/namequalifier"] = "http://$($Settings.configuration.StaticValues.ADFSExternalDNS)/adfs/services/trust");
"@
    Attribute=""
    }

   

    $TransformRules.eduPersonPrincipalName = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose eduPersonPrincipalName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", 
    Value !~ "^.+\\"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.6", 
     Value = c.Value + "@$($Settings.configuration.StaticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    }

    $TransformRules.eduPersonTargetedID = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose eduPersonTargetedID"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name", 
    Value !~ "^.+\\"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.10", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    }

    $TransformRules.eduPersonUniqueID = [PSCustomObject]@{
    Rule=@"
    @RuleName = "compose eduPersonUniqueID"
    c:[Type == "urn:mace:dir:attribute-def:norEduPersonLIN" 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.13", 
     Value = RegExReplace(c.Value, "-", "") + "@$($Settings.configuration.StaticValues.schacHomeOrganization)",
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:norEduPersonLIN"
    }

 $TransformRules["LoginName"] = [PSCustomObject]@{
    Rule=@"

    @RuleName = "Transform LoginName"
    c:[Type == "http://schemas.xmlsoap.org/claims/samaccountname"]
     => issue(Type = "LOGINNAME", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:assertion");
"@

    Attribute="http://schemas.xmlsoap.org/claims/samaccountname"
    }

    #endregion
    #region Personal attributes
    $TransformRules.givenName = Get-ADFSTkTransformRule -Type "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname" `
                                                  -Oid "urn:oid:2.5.4.42" `
                                                  -AttributeName givenName

    $TransformRules.sn = Get-ADFSTkTransformRule -Type "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname" `
                                           -Oid "urn:oid:2.5.4.4" `
                                           -AttributeName sn

    $TransformRules.displayName = Get-ADFSTkTransformRule -Type "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname" `
                                           -Oid "urn:oid:2.16.840.1.113730.3.1.241" `
                                           -AttributeName displayName

    $TransformRules.cn = Get-ADFSTkTransformRule -Type "http://schemas.xmlsoap.org/claims/CommonName" `
                                           -Oid "urn:oid:2.5.4.3" `
                                           -AttributeName cn

    $TransformRules.mail = Get-ADFSTkTransformRule -Type "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" `
                                             -Oid "urn:oid:0.9.2342.19200300.100.1.3" `
                                             -AttributeName mail
    #endregion

 #region eduPerson Attributes

    $TransformRules.eduPersonScopedAffiliation = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:eduPersonScopedAffiliation" `
                                                        -Oid "urn:oid:1.3.6.1.4.1.5923.1.1.1.9" `
                                                        -AttributeName eduPersonScopedAffiliation

    $TransformRules.eduPersonAffiliation = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:eduPersonAffiliation" `
                                                        -Oid "urn:oid:1.3.6.1.4.1.5923.1.1.1.1" `
                                                        -AttributeName eduPersonAffiliation

    $TransformRules.norEduPersonNIN = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:norEduPersonNIN" `
                                                        -Oid "urn:oid:1.3.6.1.4.1.2428.90.1.5" `
                                                        -AttributeName norEduPersonNIN

    $TransformRules.eduPersonEntitlement = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:eduPersonEntitlement" `
                                                             -Oid "urn:oid:1.3.6.1.4.1.5923.1.1.1.7" `
                                                             -AttributeName eduPersonEntitlement

    $TransformRules.eduPersonAssurance = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:eduPersonAssurance" `
                                                           -Oid "urn:oid:1.3.6.1.4.1.5923.1.1.1.11" `
                                                           -AttributeName eduPersonAssurance

    $TransformRules.norEduPersonLIN = Get-ADFSTkTransformRule -Type "urn:mace:dir:attribute-def:norEduPersonLIN" `
                                                        -Oid "urn:oid:1.3.6.1.4.1.2428.90.1.4" `
                                                        -AttributeName norEduPersonLIN

    #endregion

    $TransformRules
}