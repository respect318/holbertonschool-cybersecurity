# name: 1-sysmon_coverage_matrix.ps1
# purpose: Parse sysmonconfig.xml and generate an ATT&CK-aligned coverage matrix (sysmon_coverage_matrix.json)
# author: MedDefense Blue Team

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Sysmon Event IDs evaluated in this script:
# "1" ProcessCreate, "3" NetworkConnect, "7" ImageLoad, "8" CreateRemoteThread,
# "10" ProcessAccess, "11" FileCreate, "13" RegistryEvent SetValue,
# "15" FileCreateStreamHash, "22" DnsQuery

# ── Configuration ──────────────────────────────────────────────────────────────
$ConfigFile  = "sysmonconfig.xml"
$OutputFile  = "sysmon_coverage_matrix.json"

# ── ATT&CK → Sysmon Event ID mapping ──────────────────────────────────────────
$Techniques = @(
    @{
        technique_id        = "T1059"
        technique_name      = "Command and Scripting Interpreter"
        required_event_ids  = @(1)
        evidence_fields_expected = @("CommandLine","ParentCommandLine","Image","User","ProcessGuid")
        recommendation_base  = "Ensure EID 1 is enabled and CommandLine logging is not excluded for common interpreters (cmd.exe, powershell.exe, wscript.exe, cscript.exe)."
    },
    @{
        technique_id        = "T1053"
        technique_name      = "Scheduled Task/Job"
        required_event_ids  = @(1)
        evidence_fields_expected = @("CommandLine","ParentImage","Image","ProcessGuid","User")
        recommendation_base  = "Ensure EID 1 captures schtasks.exe and at.exe executions; verify no exclude rule suppresses these process names."
    },
    @{
        technique_id        = "T1547"
        technique_name      = "Boot or Logon Autostart Execution"
        required_event_ids  = @(13)
        evidence_fields_expected = @("TargetObject","Details","Image","ProcessGuid","EventType")
        recommendation_base  = "Ensure EID 13 (RegistryEvent SetValue) is enabled and covers Run/RunOnce keys; check for broad exclude rules on HKLM/HKCU paths."
    },
    @{
        technique_id        = "T1055"
        technique_name      = "Process Injection"
        required_event_ids  = @(8, 10)
        evidence_fields_expected = @("SourceImage","TargetImage","GrantedAccess","CallTrace","StartAddress")
        recommendation_base  = "Ensure EID 8 (CreateRemoteThread) and EID 10 (ProcessAccess) are both enabled; remove or narrow any exclude rules on lsass.exe or common injection targets."
    },
    @{
        technique_id        = "T1071"
        technique_name      = "Application Layer Protocol"
        required_event_ids  = @(3, 22)
        evidence_fields_expected = @("DestinationIp","DestinationPort","Image","QueryName","QueryResults")
        recommendation_base  = "Ensure EID 3 (NetworkConnect) and EID 22 (DNSEvent) are enabled; avoid broad exclude rules on port 80/443 that hide beaconing."
    },
    @{
        technique_id        = "T1574.002"
        technique_name      = "DLL Side-Loading"
        required_event_ids  = @(7)
        evidence_fields_expected = @("ImageLoaded","Signed","Signature","Image","Hashes")
        recommendation_base  = "Ensure EID 7 (ImageLoad) is enabled and signature checking is active; exclude rules should not suppress unsigned DLL loads from user-writable paths."
    },
    @{
        technique_id        = "T1027"
        technique_name      = "Obfuscated or Compressed Files"
        required_event_ids  = @(11, 15)
        evidence_fields_expected = @("TargetFilename","Hashes","Image","CreationUtcTime","Contents")
        recommendation_base  = "Ensure EID 11 (FileCreate) and EID 15 (FileCreateStreamHash) are enabled; check for exclude rules on temp directories used by droppers."
    }
)

# ── Parse sysmonconfig.xml ─────────────────────────────────────────────────────
Write-Host "[*] Parsing Sysmon config: $ConfigFile"

if (-not (Test-Path $ConfigFile)) {
    Write-Warning "sysmonconfig.xml not found in current directory. Generating matrix with assumed-disabled Event IDs."
    $EnabledEventIDs = @()
    $ExcludeRules    = @()
    $IncludeRules    = @()
} else {
    [xml]$xml = Get-Content $ConfigFile -Raw

    # Collect enabled event types by looking for non-empty filter sections under EventFiltering
    $EnabledEventIDs = @()
    $ExcludeRules    = @()
    $IncludeRules    = @()

    # Event ID mapping: Sysmon XML element name → numeric Event ID
    $EventNameToID = @{
        "ProcessCreate"          = 1
        "FileCreateTime"         = 2
        "NetworkConnect"         = 3
        "ProcessTerminate"       = 5
        "DriverLoad"             = 6
        "ImageLoad"              = 7
        "CreateRemoteThread"     = 8
        "RawAccessRead"          = 9
        "ProcessAccess"          = 10
        "FileCreate"             = 11
        "RegistryEvent"          = 12  # covers 12, 13, 14
        "RegistryEventSetValue"  = 13
        "FileCreateStreamHash"   = 15
        "PipeEvent"              = 17
        "WmiEvent"               = 19
        "DnsQuery"               = 22
    }

    $filterNode = $xml.Sysmon.EventFiltering
    if ($null -ne $filterNode) {
        foreach ($child in $filterNode.ChildNodes) {
            $nodeName = $child.LocalName
            if ($EventNameToID.ContainsKey($nodeName)) {
                $eid = $EventNameToID[$nodeName]
                if ($eid -notin $EnabledEventIDs) { $EnabledEventIDs += $eid }
            }
            # Collect include/exclude rules
            $onmatch = $child.GetAttribute("onmatch")
            foreach ($rule in $child.ChildNodes) {
                $entry = @{
                    EventElement = $nodeName
                    Field        = $rule.LocalName
                    Condition    = $rule.GetAttribute("condition")
                    Value        = $rule.InnerText
                    OnMatch      = $onmatch
                }
                if ($onmatch -eq "exclude") { $ExcludeRules += $entry }
                else { $IncludeRules += $entry }
            }
        }
        # RegistryEvent node covers EID 12 and 13; ensure both are listed if present
        if (12 -in $EnabledEventIDs -and 13 -notin $EnabledEventIDs) { $EnabledEventIDs += 13 }
    }
}

$EnabledEventIDs = $EnabledEventIDs | Sort-Object -Unique
Write-Host "Enabled Event IDs: $($EnabledEventIDs -join ', ')"

# ── Evaluate coverage for each technique ──────────────────────────────────────
$Matrix   = @()
$Covered  = 0
$Partial  = 0
$Blind    = 0

foreach ($t in $Techniques) {
    $required = $t.required_event_ids
    $enabled  = $required | Where-Object { $_ -in $EnabledEventIDs }
    $missing  = $required | Where-Object { $_ -notin $EnabledEventIDs }

    # Check filter_conflicts: look for exclude rules that target key fields for this technique
    $conflicts = @()
    foreach ($ex in $ExcludeRules) {
        foreach ($field in $t.evidence_fields_expected) {
            if ($ex.Field -ieq $field -or $ex.Value -match "(?i)(all|\*)") {
                $conflicts += "exclude rule on '$($ex.Field)' = '$($ex.Value)' in $($ex.EventElement)"
            }
        }
    }

    # Determine coverage_status
    if ($missing.Count -eq 0 -and $conflicts.Count -eq 0) {
        $status = "covered"
        $reason = "All required Event IDs ($($required -join ', ')) are enabled and no conflicting exclude rules detected."
        $rec    = "No action required. Review periodically."
        $Covered++
    } elseif ($missing.Count -eq 0 -and $conflicts.Count -gt 0) {
        $status = "partial"
        $reason = "Required Event IDs are enabled but exclude rules may suppress relevant events: $($conflicts -join '; ')."
        $rec    = $t.recommendation_base
        $Partial++
    } elseif ($missing.Count -lt $required.Count) {
        $status = "partial"
        $reason = "Some required Event IDs are missing: EID $($missing -join ', '). Enabled: EID $($enabled -join ', ')."
        $rec    = $t.recommendation_base
        $Partial++
    } else {
        $status = "blind"
        $reason = "No required Event IDs ($($required -join ', ')) are enabled."
        $rec    = $t.recommendation_base
        $Blind++
    }

    $row = [ordered]@{
        technique_id             = $t.technique_id
        technique_name           = $t.technique_name
        required_event_ids       = $required
        enabled_event_ids        = @($enabled)
        filter_conflicts         = $conflicts
        coverage_status          = $status
        reason                   = $reason
        evidence_fields_expected = $t.evidence_fields_expected
        recommendation           = $rec
    }
    $Matrix += $row
}

# ── Write output ───────────────────────────────────────────────────────────────
$Report = [ordered]@{
    generated_at      = (Get-Date -Format "yyyy-MM-ddTHH:mm:ss")
    config_parsed     = $ConfigFile
    enabled_event_ids = $EnabledEventIDs
    summary           = [ordered]@{
        techniques_assessed = $Matrix.Count
        covered             = $Covered
        partial             = $Partial
        blind               = $Blind
    }
    matrix            = $Matrix
}

$Report | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $OutputFile

# ── Print summary ──────────────────────────────────────────────────────────────
Write-Host "Techniques assessed: $($Matrix.Count)"
Write-Host "Covered: $Covered"
Write-Host "Partial: $Partial"
Write-Host "Blind:   $Blind"
Write-Host "Report saved to: $OutputFile"
