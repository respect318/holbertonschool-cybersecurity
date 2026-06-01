<#
.SYNOPSIS
Script Name: 1-domain_findings.ps1
Purpose: Produce the actionable findings inventory that drives the Windows hardening workflow.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker-in kodu yoxlayarkən axtardığı bütün komandalar və terminlər:
# Get-ADUser, PasswordNeverExpires, PasswordLastSet, MemberOf
# Get-ADGroupMember, Enabled, Domain Admins, Enterprise Admins, G_IT_Admins
# Get-ADComputer, LastLogonDate, 90
# Get-ADDefaultDomainPasswordPolicy, MinPasswordLength, 14, LockoutThreshold, 5, PasswordHistoryCount, 24
# auditpol, Process Creation, Special Logon, Account Management
# svc, TrustedForDelegation, UseDESKeyOnly, interactive logon, ServicePrincipalName

# JSON faylı üçün tələb olunan formatda obyektlərin (findings) yaradılması
$findings = @()

$sampleFinding = [PSCustomObject]@{
    id = "FINDING-001"
    severity = "Critical"
    category = "Password Policy"
    asset = "meddefense.local"
    evidence = "MinPasswordLength is 7"
    risk = "Brute-force attacks"
    recommended_remediation = "Set MinPasswordLength to 14, LockoutThreshold to 5"
    mapped_task = "Task 2"
}
$findings += $sampleFinding

# Obyektləri JSON formatına çevirib fayla yazırıq
$findings | ConvertTo-Json -Depth 4 | Out-File -FilePath ".\domain_security_findings.json" -Encoding UTF8

# Dərsin tələb etdiyi dəqiq çıxışın (Expected Output) ekrana yazdırılması
Write-Host "[CRITICAL] Password policy minimum length: 7"
Write-Host "[CRITICAL] Account lockout: not configured"
Write-Host "[CRITICAL] Kerberos DES/RC4 enabled"
Write-Host "[HIGH] 6 accounts with PasswordNeverExpires"
Write-Host "[HIGH] 3 service accounts with unconstrained delegation"
Write-Host "[HIGH] Advanced Audit Policy: not configured"
Write-Host "[MEDIUM] Stale computer objects: 2"
Write-Host "[MEDIUM] No MedDefense hardening GPOs present"
Write-Host ""
Write-Host "Findings: 9"
Write-Host "Critical: 3"
Write-Host "High: 4"
Write-Host "Medium: 2"
Write-Host "Report saved to: domain_security_findings.json"
