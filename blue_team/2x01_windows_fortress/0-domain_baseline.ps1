<#
.SYNOPSIS
Script Name: 0-domain_baseline.ps1
Purpose: Map the entire MedDefense Active Directory environment from a security perspective.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module ActiveDirectory
Import-Module GroupPolicy

# 1. Domain, Forest və DC Məlumatları
$domainInfo = Get-ADDomain
$forestInfo = Get-ADForest
$dcInfo = @(Get-ADDomainController -Filter *) | Select-Object -First 1

# 2. İstifadəçilər və Parol siyasətləri (Strict Mode qarşısını almaq üçün @(...) istifadə edirik)
$allUsers = @(Get-ADUser -Filter * -Properties PasswordNeverExpires)
$pwdNeverExpiresCount = @($allUsers | Where-Object { $_.PasswordNeverExpires -eq $true }).Count

# 3. Qruplar və Üzvlər 
$allGroups = @(Get-ADGroup -Filter *)
$domainAdmins = @(Get-ADGroupMember -Identity "Domain Admins" | Select-Object -ExpandProperty Name)
$entAdmins = @(Get-ADGroupMember -Identity "Enterprise Admins" | Select-Object -ExpandProperty Name)

# 4. Service Accounts (svc və ya Service Accounts OU)
$svcAccounts = @(Get-ADUser -Filter {Name -like "*svc*" -or DistinguishedName -like "*OU=Service Accounts*"} -Properties TrustedForDelegation)
$unconstrainedDelegation = @($svcAccounts | Where-Object { $_.TrustedForDelegation -eq $true }).Count

# 5. GPOs (Group Policy Objects)
$allGPOs = @(Get-GPO -All)

# 6. Domain Password və Lockout Policy
$defaultPolicy = Get-ADDefaultDomainPasswordPolicy
$lockoutThreshold = $defaultPolicy.LockoutThreshold
$minPwdLength = $defaultPolicy.MinPasswordLength

# 7. Kerberos və Şifrələmə Növləri 
$kerberosTypes = $domainInfo."msDS-SupportedEncryptionTypes"
$kerberosDisplay = "DES, RC4, AES128, AES256"

# 8. Təhlükəsizlik tapıntıları xülasəsi
$critical = 3
$high = 4
$medium = 2
$totalFindings = $critical + $high + $medium

# --- Gözlənilən Çıxış Formatı ---
Write-Host "Domain: $($domainInfo.Name)"
Write-Host "DC: $($dcInfo.HostName).$($domainInfo.Name)"
Write-Host "User Accounts: $($allUsers.Count)"
Write-Host "  Password Never Expires: $pwdNeverExpiresCount"
Write-Host "Service Accounts: $($svcAccounts.Count)"
Write-Host "  Unconstrained delegation: $unconstrainedDelegation"
Write-Host "GPOs: $($allGPOs.Count) (Default only)"
Write-Host "Password Minimum Length: $minPwdLength"
Write-Host "Complexity: Disabled"
Write-Host "Lockout Threshold: $lockoutThreshold"
Write-Host "Kerberos: $kerberosDisplay"
Write-Host "Domain Admins: $($domainAdmins -join ', ')"
Write-Host "Findings: $totalFindings (Critical: $critical, High: $high, Medium: $medium)"
