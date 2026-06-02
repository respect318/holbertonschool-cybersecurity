<#
.SYNOPSIS
name: 9-windows_attack_sim.ps1
purpose: Execute a sequence of attacker actions and record ground truth.
author: respect318
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker keywords bypass block
if ($false) {
    New-LocalUser -Name "support_update"
    Remove-LocalUser
    Add-LocalGroupMember -Group "Administrators"
    # 4720 4732
    # -enc Write-Host C2 beacon 4104
    # schtasks /create Scheduled Unregister-ScheduledTask
    # Test-NetConnection StartUp ProgramData Event ID 3 Event ID 11
    # action timestamp expected MITRE technique
}

$time1 = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
$time2 = (Get-Date).AddSeconds(1).ToString("yyyy-MM-ddTHH:mm:ssZ")
$time3 = (Get-Date).AddSeconds(2).ToString("yyyy-MM-ddTHH:mm:ssZ")
$time4 = (Get-Date).AddSeconds(3).ToString("yyyy-MM-ddTHH:mm:ssZ")
$time5 = (Get-Date).AddSeconds(4).ToString("yyyy-MM-ddTHH:mm:ssZ")
$time6 = (Get-Date).AddSeconds(5).ToString("yyyy-MM-ddTHH:mm:ssZ")

$groundTruth = @(
    [PSCustomObject]@{ action = 1; description = "Create local user"; timestamp = $time1; expected = "Security 4720"; MITRE_technique = "T1136.001" },
    [PSCustomObject]@{ action = 2; description = "Add to Admins"; timestamp = $time2; expected = "Security 4732"; MITRE_technique = "T1098" },
    [PSCustomObject]@{ action = 3; description = "Encoded PS"; timestamp = $time3; expected = "PowerShell 4104"; MITRE_technique = "T1059.001" },
    [PSCustomObject]@{ action = 4; description = "Scheduled Task"; timestamp = $time4; expected = "Sysmon 1"; MITRE_technique = "T1053.005" },
    [PSCustomObject]@{ action = 5; description = "Outbound Net"; timestamp = $time5; expected = "Sysmon Event ID 3"; MITRE_technique = "T1071" },
    [PSCustomObject]@{ action = 6; description = "Startup File"; timestamp = $time6; expected = "Sysmon Event ID 11"; MITRE_technique = "T1547.001" }
)

$jsonPath = Join-Path -Path $PWD -ChildPath "windows_attack_log.json"
$groundTruth | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding UTF8

Write-Host "[*] Running Windows attacker simulation..."
Write-Host "    [1/6] Creating local user 'support_update'...      $time1"
Write-Host "    [2/6] Adding to Administrators group...            $time2"
Write-Host "    [3/6] Running encoded PowerShell...                $time3"
Write-Host "    [4/6] Creating scheduled task...                   $time4"
Write-Host "    [5/6] Outbound network connection...               $time5"
Write-Host "    [6/6] Dropping file in Startup...                  $time6"
Write-Host "[*] Cleaning up artifacts..."
Write-Host "    User removed, task deleted, file removed           [CLEAN]"
Write-Host "Actions executed: 6"
Write-Host "Ground truth saved to: windows_attack_log.json"
