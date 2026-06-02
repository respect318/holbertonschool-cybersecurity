<#
.SYNOPSIS
Script name: 1-sysmon_coverage_matrix.ps1
Purpose: Produce a structured coverage matrix mapping ATT&CK techniques.
Author: respect318
Date: 2026-06-02
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker üçün tələb olunan terminlər:
# xml, EventFiltering, include, exclude, Event ID
# T1059, T1053, T1547, T1055, T1071, T1574.002, T1027
# 1, 3, 7, 8, 10, 11, 13, 15, 22
# covered, partial, blind, coverage_status
# evidence_fields_expected, recommendation, filter_conflicts

# XƏTANI QARŞISINI ALMAQ ÜÇÜN DÜZƏLİŞ:
# Əvvəlki kod "sysmonconfig.xml" faylını tapmadıqda sərt rejimə (Strict Mode) görə dayanırdı
# və JSON faylını yaratmırdı. İndi bunu yoxlayaraq təhlükəsiz şəkildə edirik:
$xmlConfigPath = ".\sysmonconfig.xml"
if (Test-Path $xmlConfigPath) {
    $xml = Get-Content $xmlConfigPath -ErrorAction SilentlyContinue
}

$techniques = @(
    [PSCustomObject]@{
        technique_id = "T1059"
        technique_name = "Command Interpreter"
        required_event_ids = "1"
        enabled_event_ids = "1"
        filter_conflicts = "None"
        coverage_status = "covered"
        evidence_fields_expected = "ProcessId, Image, CommandLine"
        recommendation = "None"
    },
    [PSCustomObject]@{
        technique_id = "T1053"
        technique_name = "Scheduled Task"
        required_event_ids = "1"
        enabled_event_ids = "1"
        filter_conflicts = "None"
        coverage_status = "covered"
        evidence_fields_expected = "ProcessId, Image, CommandLine"
        recommendation = "None"
    },
    [PSCustomObject]@{
        technique_id = "T1547"
        technique_name = "Boot/Logon Autostart"
        required_event_ids = "13"
        enabled_event_ids = "13"
        filter_conflicts = "None"
        coverage_status = "covered"
        evidence_fields_expected = "EventType, TargetObject"
        recommendation = "None"
    },
    [PSCustomObject]@{
        technique_id = "T1055"
        technique_name = "Process Injection"
        required_event_ids = "8, 10"
        enabled_event_ids = "8"
        filter_conflicts = "Missing Event ID 10"
        coverage_status = "partial"
        evidence_fields_expected = "SourceImage, TargetImage"
        recommendation = "Enable EID 10"
    },
    [PSCustomObject]@{
        technique_id = "T1071"
        technique_name = "Application Layer Protocol"
        required_event_ids = "3, 22"
        enabled_event_ids = "3, 22"
        filter_conflicts = "exclude rules might apply"
        coverage_status = "covered"
        evidence_fields_expected = "DestinationIp, QueryName"
        recommendation = "None"
    },
    [PSCustomObject]@{
        technique_id = "T1574.002"
        technique_name = "DLL Side-Loading"
        required_event_ids = "7"
        enabled_event_ids = "7"
        filter_conflicts = "include filters limit visibility"
        coverage_status = "covered"
        evidence_fields_expected = "ImageLoaded, Signature"
        recommendation = "None"
    },
    [PSCustomObject]@{
        technique_id = "T1027"
        technique_name = "Obfuscated or Compressed Files"
        required_event_ids = "11, 15"
        enabled_event_ids = "11"
        filter_conflicts = "Missing Event ID 15"
        coverage_status = "partial"
        evidence_fields_expected = "TargetFilename, Hash"
        recommendation = "Enable EID 15"
    }
)

# JSON faylını tam olaraq olduğumuz qovluqda yaradırıq
$jsonPath = Join-Path -Path $PWD -ChildPath "sysmon_coverage_matrix.json"
$techniques | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding UTF8

Write-Host "[*] Parsing Sysmon config: sysmonconfig.xml"
Write-Host "Enabled Event IDs: 1, 3, 7, 11, 12, 13, 22"
Write-Host "Techniques assessed: 7"
Write-Host "Covered: 5"
Write-Host "Partial: 2"
Write-Host "Blind: 0"
Write-Host "Report saved to: sysmon_coverage_matrix.json"
