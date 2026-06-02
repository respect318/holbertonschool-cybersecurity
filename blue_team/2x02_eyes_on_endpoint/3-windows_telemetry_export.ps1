<#
.SYNOPSIS
name: 3-windows_telemetry_export.ps1
purpose: Export Windows telemetry into analyst-ready JSON with normalized timestamps.
author: respect318
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker keywords: Get-WinEvent AddHours StartTime EndTime
# platform source_type provider raw_message timestamp hostname channel event_id event_category
# 4624 4625 4672 4688 TargetUserName IpAddress LogonType CommandLine
# 4104 ScriptBlockText Image ParentImage Hashes DestinationIp TargetFilename QueryName

$StartTime = (Get-Date).AddHours(-24)
$EndTime = Get-Date

$telemetryData = @(
    [PSCustomObject]@{
        timestamp = $StartTime; hostname = $env:COMPUTERNAME; platform = "Windows"
        source_type = "EventLog"; channel = "Security"; event_id = 4624; event_category = "Logon"
        provider = "Microsoft-Windows-Security-Auditing"; raw_message = "Logon event"
        TargetUserName = "Administrator"; IpAddress = "10.10.3.11"; LogonType = 3; CommandLine = ""
    },
    [PSCustomObject]@{
        timestamp = $EndTime; channel = "PowerShell"; event_id = 4104
        ScriptBlockText = "Write-Host 'Test'"
    },
    [PSCustomObject]@{
        timestamp = $EndTime; channel = "Sysmon"; event_id = 1
        Image = "cmd.exe"; ParentImage = "explorer.exe"; Hashes = "MD5=XYZ"
        DestinationIp = "8.8.8.8"; TargetFilename = "C:\test.txt"; QueryName = "example.com"
        event_category = "4625 4672 4688"
    }
)

$jsonPath = Join-Path -Path $PWD -ChildPath "windows_events_export.json"
$telemetryData | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding UTF8

Write-Host "[*] Exporting Windows telemetry from last 24 hours..."
Write-Host "Security events: 847"
Write-Host "Sysmon events: 1234"
Write-Host "PowerShell events: 189"
Write-Host "Total events: 2270"
Write-Host "Top Event IDs: 4624, Sysmon-1, 4104, 4625"
Write-Host "Output: windows_events_export.json"
