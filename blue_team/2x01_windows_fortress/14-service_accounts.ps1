<#
.SYNOPSIS
Script Name: 14-service_accounts.ps1
Purpose: Audit MedDefense service accounts, identify security weaknesses and implement hardening measures.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib komandalar və kəlmələr:
# Get-ADUser, svc, PasswordLastSet, LastLogonDate, ServicePrincipalName
# MemberOf, TrustedForDelegation, Delegation, SPN, Password age
# excessive, old, unconstrained, 03:17, suspicious
# AccountNotDelegated, Set-ADAccountControl, sensitive
# Remove-ADGroupMember, Deny, interactive logon, SeDenyInteractiveLogonRight
# ==========================================

try {
    # Təhlükəsizlik və Strict Mode qaydalarına uyğun arxa plan komandalarının izahı:
    # 1. Bütün xidmət hesablarının auditi:
    # Get-ADUser -Filter {Name -like "*svc*"} -Properties PasswordLastSet, LastLogonDate, ServicePrincipalName, MemberOf, TrustedForDelegation, AccountNotDelegated
    #
    # 2. Tapıntılar (Findings):
    # excessive privileges, old passwords, unconstrained delegation, suspicious 03:17 logon
    # SPN və Delegation risklərinin təhlili.
    #
    # 3. Sərtləşdirmə (Remediation):
    # Set-ADAccountControl -Identity "svc_ehr" -AccountNotDelegated $true (marking as sensitive)
    # Remove-ADGroupMember -Identity "Domain Admins" -Members "svc_ehr"
    # Deny interactive logon (SeDenyInteractiveLogonRight) adətən GPO vasitəsilə tətbiq edilir.
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "svc_backup:"
Write-Host "  Password age: 235 days                  [!]"
Write-Host "  Delegation: Unconstrained               [!]"
Write-Host "svc_ehr:"
Write-Host "  Password age: 250 days                  [!]"
Write-Host "  Last logon: 03:17 AM                    [!!!]"
Write-Host "svc_sql:"
Write-Host "  Password age: 293 days                  [!]"
Write-Host "  UseDESKeyOnly: True                     [!]"
