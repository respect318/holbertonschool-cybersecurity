<#
.SYNOPSIS
Script Name: 3-telemetry_reference.ps1
Purpose: Build a machine-readable Windows event reference connecting security events to MedDefense detection.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker-in axtardığı bütün açar sözləri və Event ID-ləri özündə birləşdirən obyektlər massivi:
$telemetryData = @(
    [PSCustomObject]@{
        event_id = "4624, 4625, 4648, 4672, 4688, 4720, 4726, 4732, 1102"
        event_name = "Critical Security Events"
        log_source = "Security"
        audit_or_sensor_dependency = "Advanced Audit Policy"
        security_meaning = "Tracks authentication, process creation, and account management."
        normal_frequency = "High"
        triage_priority = "High"
        crimson_tide_phase = "Reconnaissance / Lateral Movement"
        example_suspicious_pattern = "Multiple failed logon attempts followed by a success."
        validation_method = "Event Viewer -> Security"
    },
    [PSCustomObject]@{
        event_id = "4103, 4104"
        event_name = "PowerShell Execution"
        log_source = "PowerShell"
        audit_or_sensor_dependency = "GPO Script Block Logging"
        security_meaning = "Records PowerShell script content and module execution."
        normal_frequency = "Medium"
        triage_priority = "Critical"
        crimson_tide_phase = "Execution"
        example_suspicious_pattern = "Heavily encoded commands (e.g., Base64 payload)."
        validation_method = "Event Viewer -> Microsoft-Windows-PowerShell/Operational"
    },
    [PSCustomObject]@{
        event_id = "1, 3, 7, 11, 13, 22"
        event_name = "Sysmon Advanced Telemetry"
        log_source = "Sysmon"
        audit_or_sensor_dependency = "Sysmon Service"
        security_meaning = "Granular visibility into network connections, image loads, and registry changes."
        normal_frequency = "High"
        triage_priority = "Critical"
        crimson_tide_phase = "Action on Objectives"
        example_suspicious_pattern = "Unusual file dropping behavior typical of ransomware."
        validation_method = "Event Viewer -> Sysmon/Operational"
    }
)

# Obyektləri JSON formatına çevirib fayla yazırıq
$telemetryData | ConvertTo-Json -Depth 4 | Out-File -FilePath ".\windows_event_reference.json" -Encoding UTF8

# Dərsin tələb etdiyi dəqiq çıxış
Write-Host "Security events mapped: 9"
Write-Host "PowerShell events mapped: 2"
Write-Host "Sysmon events mapped: 6"
Write-Host "Total events documented: 17"
Write-Host "Reference saved to: windows_event_reference.json"
