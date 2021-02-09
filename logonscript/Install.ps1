#region Config
$client = "Intune.Training"
$scriptsPath = "$env:ProgramData\$client\Scripts\LogonScript"
$logPath = "$env:ProgramData\$client\Logs"
$logFile = "$logPath\LogonScript-RunOnceConfig.log"
$psRun = "psRun.vbs"
$logonScript = "ExampleLogon.ps1"
$buildId = "98ad7d19-0834-4d8d-b2e6-976011fda6c5"
#endregion
#region Logging
if (!(Test-Path $scriptsPath)) {
    New-Item -Path $scriptsPath -Type Directory -Force | Out-Null
}
if (!(Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory -Force | Out-Null
}

if (Test-Path "$scriptsPath\$logonScript") {
    Remove-Item -Path "$scriptsPath\$logonScript" -Force
}
Start-Transcript -Path "$logFile" -Force
#endregion
#region Logon Script Contents
Write-Host "Creating logon script and storing: $scriptsPath\$logonScript" -ForegroundColor Yellow
Copy-Item "$PSScriptRoot\$logonScript" -Destination "$scriptsPath\$logonScript" -Force
#endregion
#region Bootstrap Contents
$bootstrapContents = @'
Set objShell = CreateObject("Wscript.Shell")
if Wscript.arguments.count > 0 then
    sPath = Wscript.Arguments(0)
else
    sPath = objShell.CurrentDirectory + "\{0}"
end if
Dim PSRun
PSRun = "powershell.exe -WindowStyle hidden -ExecutionPolicy bypass -NonInteractive -File " & sPath
objShell.Run(PSRun),0
'@ -f $logonScript
Write-Host "Creating logon script bootstrap and storing: $scriptsPath\$psRun" -ForegroundColor Yellow
Out-File -FilePath "$scriptsPath\$psRun" -Encoding unicode -Force -InputObject $bootstrapContents -NoNewline
#endregion
#region Scheduled Task
try {
    Write-Host "Setting up scheduled task"
    if (!(Get-ScheduledTask -TaskName "Logon Script - $($client)" -TaskPath "\" -ErrorAction SilentlyContinue)) {
        $ShedService = New-Object -comobject 'Schedule.Service'
        $ShedService.Connect()

        $Task = $ShedService.NewTask(0)
        $Task.RegistrationInfo.Description = "Logon Script for $client"
        $Task.Settings.Enabled = $true
        $Task.Settings.AllowDemandStart = $true
        $Task.Settings.IdleSettings.StopOnIdleEnd = $false
        $Task.Settings.RunOnlyIfIdle = $false
        $Task.Settings.DisallowStartIfOnBatteries = $false
        $Task.Settings.StopIfGoingOnBatteries = $false

        $trigger = $task.triggers.Create(9)
        $trigger.Enabled = $true

        $trigger = $task.triggers.Create(0)
        $trigger.Subscription = @'
<QueryList>
    <Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational">
        <Select Path="Microsoft-Windows-NetworkProfile/Operational">*[System[(EventID=10000)]]</Select>
    </Query>
</QueryList>
'@
        $trigger.Enabled = $true

        $action = $Task.Actions.Create(0)
        $action.Path = "wscript.exe"
        $action.Arguments = "`"$scriptsPath\$psRun`" `"$scriptsPath\$logonScript`""

        $taskFolder = $ShedService.GetFolder("\")
        $taskFolder.RegisterTaskDefinition("$client`_Logonscript", $Task , 6, 'Users', $null, 4) | Out-Null
        Write-Host $script:tick -ForegroundColor Green
    }
    else {
        Write-Host "Scheduled task already configured."
    }
}
catch {
    $errMsg = $_.Exception.Message
}
finally {
    if ($errMsg) {
        Write-Warning $errMsg
        Stop-Transcript
        throw $errMsg
    }
    else {
        Write-Host "script completed successfully.."
        "done." | Out-File "$env:temp\$buildId`.txt" -Encoding ASCII -force
        Stop-Transcript
    }
}
#endregion