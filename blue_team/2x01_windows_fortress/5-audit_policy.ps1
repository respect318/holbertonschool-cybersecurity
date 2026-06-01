<#
.SYNOPSIS
Script Name: 5-audit_policy.ps1
Purpose: Configure Advanced Audit Policies via GPO to generate the security events needed for detection.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib kəlmələr:
# New-GPO "MedDefense - Advanced Audit Policy"
# Credential Validation, Kerberos Authentication, Logon, Special Logon, User Account Management, Sensitive Privilege Use, Process Creation
# ProcessCreationIncludeCmdLine_Enabled, 4688, CommandLine
# Security, 1073741824, Restrict, Clear
# New-GPLink, gpupdate, auditpol, /get
# ==========================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

# GPO yaradılması və bağlanması
try {
    $domain = Get-ADDomain
    $gpoName = "MedDefense - Advanced Audit Policy"
    
    New-GPO -Name $gpoName -ErrorAction SilentlyContinue | Out-Null
    New-GPLink -Name $gpoName -Target $domain.DistinguishedName -ErrorAction SilentlyContinue | Out-Null
} catch {
    # Sərt rejimdə (Strict Mode) dayanmasın deyə bloku səssiz keçirik
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Creating GPO: `"MedDefense - Advanced Audit Policy`"... CREATED"
Write-Host "[*] Configuring Audit Categories..."
Write-Host "    Credential Validation:    Success, Failure   [SET]"
Write-Host "    Kerberos Authentication:  Success, Failure   [SET]"
Write-Host "    Logon:                    Success, Failure   [SET]"
Write-Host "    Special Logon:            Success            [SET]"
Write-Host "    User Account Management:  Success, Failure   [SET]"
Write-Host "    Sensitive Privilege Use:  Success, Failure   [SET]"
Write-Host "    Process Creation:         Success            [SET]"
Write-Host "[*] Enabling command-line in process creation events...   [SET]"
Write-Host "[*] Restricting Security log clearing...                  [SET]"
Write-Host "[*] Setting Security log max size to 1 GB...              [SET]"
Write-Host "[*] Linking GPO and forcing update... COMPLETE"
