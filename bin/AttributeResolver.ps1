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

function Import-AllAttributes
{
    #All attributes
    $Attributes = @{}
    
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"] = "givenname"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"] = "sn"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"] = "displayname"
    $Attributes["http://schemas.xmlsoap.org/claims/CommonName"] = "cn"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"] = "name"
    $Attributes["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"] = "mail"
    $Attributes["urn:mace:dir:attribute-def:eduPersonScopedAffiliation"] = "eduPersonScopedAffiliation"
    $Attributes["urn:mace:dir:attribute-def:eduPersonAffiliation"] = "eduPersonAffiliation"
    $Attributes["urn:mace:dir:attribute-def:norEduPersonNIN"] = "norEduPersonNIN"
    $Attributes["urn:mace:dir:attribute-def:norEduPersonLIN"] = "norEduPersonLIN"
    $Attributes["urn:mace:dir:attribute-def:eduPersonEntitlement"] = "edupersonentitlement"
    #$Attributes["urn:mace:dir:attribute-def:eduPersonAssurance"] = "eduPersonAssurance"
    $Attributes["http://schemas.xmlsoap.org/claims/samaccountname"] = "samaccountname"
    
    $Attributes
}
#All TransformRules

function Import-AllTransformRules
{
    ### Get static values from configuration file

    if (!(Test-Path (Join-Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') Import-SWAMIDMetadata.config.xml)))
    {
        throw "Could not find 'Import-SWAMIDMetadata.config.xml'. Please put the file in the same directory as Import-SWAMIDMetadata.config.ps1"
    }
    else
    {
        [xml]$Settings=Get-Content (Join-Path $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('.\') Import-SWAMIDMetadata.config.xml)
    }

    ###

    $TransformRules = @{}

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

    $TransformRules.givenName = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform givenName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"]
     => issue(Type = "urn:oid:2.5.4.42", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname"
    }

    $TransformRules.sn = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform sn"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"]
     => issue(Type = "urn:oid:2.5.4.4", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname"
    }

    $TransformRules.displayName = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform displayName"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"]
     => issue(Type = "urn:oid:2.16.840.1.113730.3.1.241", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/displayname"
    }

    $TransformRules.cn = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform cn"
    c:[Type == "http://schemas.xmlsoap.org/claims/CommonName"]
     => issue(Type = "urn:oid:2.5.4.3", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/claims/CommonName"
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

    $TransformRules.mail = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform emailaddress"
    c:[Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]
     => issue(Type = "urn:oid:0.9.2342.19200300.100.1.3", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
    }

    $TransformRules.eduPersonScopedAffiliation = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform eduPersonScopedAffiliation faculty@$($Settings.configuration.StaticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)faculty@$($Settings.configuration.StaticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "faculty@$($Settings.configuration.StaticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation student@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)student@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "student@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation staff@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)staff@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "staff@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation alum@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)alum@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "alum@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation member@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)member@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "member@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation affiliate@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)affiliate@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "affiliate@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation employee@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)employee@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "employee@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonScopedAffiliation library-walk-in@$($Settings.configuration.staticValues.schacHomeOrganization)"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonScopedAffiliation", value=~ "(?i)library-walk-in@$($Settings.configuration.staticValues.schacHomeOrganization)"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.9", Value = "library-walk-in@$($Settings.configuration.staticValues.schacHomeOrganization)", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:eduPersonScopedAffiliation"
    }

    $TransformRules.eduPersonAffiliation = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform eduPersonAffiliation faculty"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "faculty"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation student"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "student"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation staff"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "staff"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation alum"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "alum"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation member"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "member"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation affiliate"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "affiliate"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

     @RuleName = "Transform eduPersonAffiliation employee"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "employee"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");

    @RuleName = "Transform eduPersonAffiliation library-walk-in"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonAffiliation", value == "library-walk-in"] 
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.1", Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:eduPersonAffiliation"
    }

    $TransformRules.norEduPersonNIN = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform norEduPersonNIN"
    c:[Type == "urn:mace:dir:attribute-def:norEduPersonNIN"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.2428.90.1.5", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:norEduPersonNIN"
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

    $TransformRules.eduPersonEntitlement = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Transform eduPersonEntitlement"
    c:[Type == "urn:mace:dir:attribute-def:eduPersonEntitlement"]
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.7", 
     Value = c.Value, 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute="urn:mace:dir:attribute-def:eduPersonEntitlement"
    }

    #$TransformRules.eduPersonAssurance = [PSCustomObject]@{
    #Rule=@"
    #@RuleName = "Transform eduPersonAssurance"
    #c:[Type == "urn:mace:dir:attribute-def:eduPersonAssurance"]
    # => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.11", 
    # Value = c.Value, 
    # Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
#"@  
    #Attribute="urn:mace:dir:attribute-def:eduPersonAssurance"
    #}

    #WARNING Only for LiU!
    $TransformRules.eduPersonAssurance = [PSCustomObject]@{
    Rule=@"
    @RuleName = "Issue eduPersonAssurance"
     => issue(Type = "urn:oid:1.3.6.1.4.1.5923.1.1.1.11", 
     Value = "http://www.swamid.se/policy/assurance/al2", 
     Properties["http://schemas.xmlsoap.org/ws/2005/05/identity/claimproperties/attributename"] = "urn:oasis:names:tc:SAML:2.0:attrname-format:uri");
"@
    Attribute=""
    }

    $TransformRules
}