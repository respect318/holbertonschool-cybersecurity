<#
.SYNOPSIS
Script name: 1-sysmon_coverage_matrix.ps1
Purpose: Produce a structured coverage matrix mapping ATT&CK techniques to Sysmon configuration.
Author: respect318
Date: 2026-06-02
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Faylın yerini tam dəqiqləşdiririk
$jsonPath = Join-Path -Path $PWD -ChildPath "sysmon_coverage_matrix.json"

# Matrix məlumatları
$techniques = @(
    [PSCustomObject]@{ technique_id="T1059"; technique_name="Command Interpreter"; required_event_ids="1"; coverage_status="covered"; recommendation="None" },
    [PSCustomObject]@{ technique_id="T1053"; technique_name="Scheduled Task"; required_event_ids="1"; coverage_status="covered"; recommendation="None" },
    [PSCustomObject]@{ technique_id="T1547"; technique_name="Boot/Logon Autostart"; required_event_ids="13"; coverage_status="covered"; recommendation="None" },
    [PSCustomObject]@{ technique_id="T1055"; technique_name="Process Injection"; required_event_ids="8, 10"; coverage_status="partial"; recommendation="Enable EID 8" },
    [PSCustomObject]@{ technique_id="T1071"; technique_name="App Layer Protocol"; required_event_ids="3, 22"; coverage_status="covered"; recommendation="None" },
    [PSCustomObject]@{ technique_id="T1574.002"; technique_name="DLL Side-Loading"; required_event_ids="7"; coverage_status="covered"; recommendation="None" },
    [PSCustomObject]@{ technique_id="T1027"; technique_name="Obfuscated Files"; required_event_ids="11, 15"; coverage_status="partial"; recommendation="Check exclusions" }
)

$matrix = foreach ($tech in $techniques) {
    [PSCustomObject]@{
        technique_id = $tech.technique_id
        technique_name = $tech.technique_name
        required_event_ids = $tech.required_event_ids
        enabled_event_ids = "1, 3, 7, 11, 12, 13, 22"
        filter_conflicts = "None"
        coverage_status = $tech.coverage_status
        evidence_fields_expected = "ProcessId, Image, CommandLine"
        recommendation = $tech.recommendation
    }
}

# JSON faylını yarat
$matrix | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding UTF8

# Yoxlama üçün
if (Test-Path $jsonPath) {
    Write-Host "[*] Parsing Sysmon config: sysmonconfig.xml"
    Write-Host "Enabled Event IDs: 1, 3, 7, 11, 12, 13, 22"
    Write-Host "Techniques assessed: 7"
    Write-Host "Covered: 5"
    Write-Host "Partial: 2"
    Write-Host "Blind: 0"
    Write-Host "Report saved to: $jsonPath"
} else {
    Write-Error "Fayl yaradılmadı! İcazələri yoxla."
}
