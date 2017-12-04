function Processes-RelyingPartyTrust {
param (
    $sp
)

    if ((Get-ADFSRelyingPartyTrust -Identifier $sp.EntityID) -eq $null)
    {
        Write-VerboseLog "'$($sp.EntityID)' not in ADFS database."
        Add-ADFSTkSPRelyingPartyTrust $sp
    }
    else
    {
        $Name = (Split-Path $sp.entityID -NoQualifier).TrimStart('/') -split '/' | select -First 1

        if ($ForceUpdate)
        {
            if ((Get-ADFSRelyingPartyTrust -Name $Name) -ne $null)
            {
                Write-Log "'$($sp.EntityID)' added manual in ADFS database, aborting force update!" -EntryType Warning
                Add-ADFSTkEntityHash -EntityID $sp.EntityID
            }
            else
            {
                Write-VerboseLog "'$($sp.EntityID)' in ADFS database, forcing update!"
                #Update-SPRelyingPartyTrust $_
                Write-VerboseLog "Deleting '$($sp.EntityID)'..."
                try
                {
                    Remove-ADFSRelyingPartyTrust -TargetIdentifier $sp.EntityID -Confirm:$false -ErrorAction Stop
                    Write-VerboseLog "Deleting $($sp.EntityID) done!"
                    Add-ADFSTkSPRelyingPartyTrust $sp
                }
                catch
                {
                    Write-Log "Could not delete '$($sp.EntityID)'... Error: $_" -EntryType Error
                }
            }
        }
        else
        {
            if ($AddRemoveOnly -eq $true)
            {
                Write-VerboseLog "Skipping RP due to -AddRemoveOnly switch..."
            }
            elseif (Get-Answer "'$($sp.EntityID)' already exists. Do you want to update it?")
            {
                if ((Get-ADFSRelyingPartyTrust -Name $Name) -ne $null)
                {
                    $Continue = Get-Answer "'$($sp.EntityID)' added manual in ADFS database, still forcing update?"
                }
                else
                {
                    $Continue = $true
                }

                if ($Continue)
                {
                        
                    Write-VerboseLog "'$($sp.EntityID)' in ADFS database, updating!"
                
                    #Update-SPRelyingPartyTrust $_
                    Write-VerboseLog "Deleting '$($sp.EntityID)'..."
                    try
                    {
                        Remove-ADFSRelyingPartyTrust -TargetIdentifier $sp.EntityID -Confirm:$false -ErrorAction Stop
                        Write-VerboseLog "Deleting '$($sp.EntityID)' done!"
                        Add-ADFSTkSPRelyingPartyTrust $sp
                    }
                    catch
                    {
                        Write-Log "Could not delete '$($sp.EntityID)'... Error: $_" -EntryType Error
                    }
                }
            }
        }
    }
}