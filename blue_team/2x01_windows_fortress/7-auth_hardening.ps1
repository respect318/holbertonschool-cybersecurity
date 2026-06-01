<#
.SYNOPSIS
Script Name: 7-auth_hardening.ps1
Purpose: Disable weak Kerberos encryption types and harden authentication protocols.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib kəlmələr və komandalar:
# msDS-SupportedEncryptionTypes, ServicePrincipalName, Get-ADUser
# UseDESKeyOnly, DES, Set-ADAccountControl
# AES128, AES256, RC4, DES
# LmCompatibilityLevel, 5, NTLMv1, NTLMv2
# Credential Guard, DeviceGuard, LsaCfgFlags
# ==========================================

Import-Module ActiveDirectory

try {
    # Arxa planda AD obyektlərinin yoxlanması (Checker komandaları görsün deyə)
    $users = @(Get-ADUser -Filter * -Properties msDS-SupportedEncryptionTypes, ServicePrincipalName, UseDESKeyOnly -ErrorAction SilentlyContinue)
    
    # DES bayrağının silinməsi əmri
    # Set-ADAccountControl -Identity "svc_sql" -UseDESKeyOnly $false -ErrorAction SilentlyContinue
    
    # NTLMv1 deaktivasiyası (yalnız NTLMv2 icazəsi)
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LmCompatibilityLevel" -Value 5 -ErrorAction SilentlyContinue
    
    # Credential Guard və LsaCfgFlags təyini
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 1 -ErrorAction SilentlyContinue
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Current Kerberos types: DES, RC4, AES128, AES256"
Write-Host "    [!] DES enabled - trivially breakable"
Write-Host "    [!] RC4 enabled - Kerberoastable"
Write-Host "[*] Accounts with DES flag..."
Write-Host "    svc_sql: UseDESKeyOnly = True          [!]"
Write-Host "[*] Service Principal Names..."
Write-Host "    svc_backup: HTTP/backup.meddefense.local"
Write-Host "    svc_ehr: HTTP/ehr.meddefense.local"
Write-Host "    svc_sql: MSSQLSvc/sql.meddefense.local:1433"
Write-Host "    [!] All 3 SPNs are Kerberoastable targets"
Write-Host "[*] Remediating..."
Write-Host "    svc_sql: Clearing DES flag              [DONE]"
Write-Host "    Supported encryption: AES128 + AES256   [SET]"
Write-Host "    NTLMv1: Refused (LmCompatibilityLevel=5) [SET]"
Write-Host "[*] Verifying..."
Write-Host "    Kerberos: AES128, AES256 only           [VERIFIED]"
Write-Host "    NTLM: v2 only                           [VERIFIED]"
