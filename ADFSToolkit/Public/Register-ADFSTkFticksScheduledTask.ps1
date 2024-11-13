function Register-ADFSTkFTicksScheduledTask {
    [cmdletbinding()]
    param ([switch]$Force)
    
    Verify-ADFSTkEventLogUsage -LogName ADFSToolkit -Source 'Invoke-ADFSTkFticks' | Out-Null
    
    #Check for Audit Policy
    Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confIsAuditPolicyEnabled)
    $auditPolicy = (auditpol.exe /get /category:'Object Access' /r | ConvertFrom-Csv | ? Subcategory -eq 'Application Generated')
    if ($auditPolicy.'Inclusion Setting' -ne 'Success and Failure') {
        Write-ADFSTkLog -Message (Get-ADFSTkLanguageText confAuditPolicyNeeded) -EventID 311 -EntryType Warning

        if (Get-ADFSTkAnswer (Get-ADFSTkLanguageText confEnableAuditPolicyNow) -DefaultYes) {
            auditpol.exe /set /subcategory:"Application Generated" /failure:enable /success:enable 
            Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confAuditPolicyHasBeenEnabled)
        }
        else {
            Write-ADFSTkLog -Message (Get-ADFSTkLanguageText confAuditPolicyAborted) -EventID 320 -MajorFault
        }
    }
    else {
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confAuditPolicyIsEnabled)
    }
    
    Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText confCheckIfScheduledTaskIsPresent)
    $schedTask = Get-ScheduledTask -TaskName (Get-ADFSTkLanguageText confProcessLoginEvents) -TaskPath "\ADFSToolkit\" -ErrorAction SilentlyContinue

    if (($PSBoundParameters.ContainsKey('Force') -and $Force -ne $false) `
            -and -not [string]::IsNullOrEmpty($schedTask)) {
        
        Write-ADFSTkLog (Get-ADFSTkLanguageText confRemoveScheduledTask)
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText cRemoving -f $schedTask.TaskName)

        $schedTask | Unregister-ScheduledTask -Confirm:$false
                
        Write-ADFSTkVerboseLog (Get-ADFSTkLanguageText cDone)
        $schedTask = $null
    }

    if ([string]::IsNullOrEmpty($schedTask)) {
        Write-ADFSTkLog (Get-ADFSTkLanguageText cCreating -f "F-Ticks Scheduled Task")

        $stAction = New-ScheduledTaskAction -Execute 'Powershell.exe' `
            -Argument "-NoProfile -WindowStyle Hidden -Command &{Invoke-ADFSTkFticks}"

        $stTrigger = New-ScheduledTaskTrigger -Daily -DaysInterval 1 -At (Get-Date)
        $stSettings = New-ScheduledTaskSettingsSet -Disable -MultipleInstances IgnoreNew -ExecutionTimeLimit ([timespan]::FromHours(12))

        $Task = Register-ScheduledTask -Action $stAction `
            -Trigger $stTrigger `
            -TaskName (Get-ADFSTkLanguageText confProcessLoginEvents) `
            -Description (Get-ADFSTkLanguageText confThisSchedTaskGetsLoginEventsAndSendAsFticks) `
            -RunLevel Highest `
            -Settings $stSettings `
            -TaskPath "\ADFSToolkit\"

        $Task.Triggers.Repetition.Duration = ""
        $Task.Triggers.Repetition.Interval = "PT10M"
        $Task | Set-ScheduledTask -User "$env:USERDOMAIN\$env:USERNAME"

        Write-Host " "
        
        Write-ADFSTkLog (Get-ADFSTkLanguageText cDone)
        Write-Host (Get-ADFSTkLanguageText confFticksScheduledTaskInfo)
    }
    else {
        Write-Host (Get-ADFSTkLanguageText cAlreadyPresent -f "F-Ticks Scheduled Task")
    }
}