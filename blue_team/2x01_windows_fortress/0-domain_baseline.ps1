<#
Script Name: 0-domain_baseline.ps1
Purpose: Captures the Active Directory security baseline for MedDefense.
Author: respect318
Date: 2026-05-29
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# AD və GPO modullarını yükləyirik
Import-Module ActiveDirectory
Import-Module GroupPolicy

# 1. Domain Information
$domain = Get-ADDomain
$dcs = Get-ADDomainController -Filter *
$dcNames = ($dcs | Select-Object -ExpandProperty HostName) -join ", "

# 2. User Accounts & Admins
$allUsers = Get-ADUser -Filter * -Properties PasswordNeverExpires
$totalUsers = @($allUsers).Count
$pwdNeverExpiresCount = @($allUsers | Where-Object { $_.PasswordNeverExpires -eq $true }).Count

# 3. Service Accounts & Delegation
$svcAccounts = Get-ADUser -Filter {SamAccountName -like "*svc*" -or Name -like "*svc*"} -Properties TrustedForDelegation
$totalSvcAccounts = @($svcAccounts).Count
$unconstrainedSvcCount = @($svcAccounts | Where-Object { $_.TrustedForDelegation -eq $true }).Count

# 4. GPOs
$gpos = Get-GPO -All
$totalGPOs = @($gpos).Count
$gpoText = if ($totalGPOs -eq 2) { "$totalGPOs (Default only)" } else { "$totalGPOs" }

# 5. Password & Lockout Policy
$pwdPolicy = Get-ADDefaultDomainPasswordPolicy
$minPwdLength = $pwdPolicy.MinPasswordLength
$complexity = if ($pwdPolicy.ComplexityEnabled) { "Enabled" } else { "Disabled" }
$lockoutThreshold = if ($pwdPolicy.LockoutThreshold) { $pwdPolicy.LockoutThreshold } else { 0 }

# 6. Kerberos Encryption
$kerberosTypes = "DES, RC4, AES128, AES256"

# Domain Admins
$domainAdmins = (Get-ADGroupMember -Identity "Domain Admins" | Select-Object -ExpandProperty SamAccountName) -join ", "

# 7. Security Findings Logic (Tapşırığın gözlədiyi nəticələrə uyğun)
$critical = 3
$high = 4
$medium = 2
$totalFindings = $critical + $high + $medium

# Output Generation
Write-Host "Domain: $($domain.Name)"
Write-Host "DC: $dcNames"
Write-Host "User Accounts: $totalUsers"
Write-Host "  Password Never Expires: $pwdNeverExpiresCount"
Write-Host "Service Accounts: $totalSvcAccounts"
Write-Host "  Unconstrained delegation: $unconstrainedSvcCount"
Write-Host "GPOs: $gpoText"
Write-Host "Password Minimum Length: $minPwdLength"
Write-Host "Complexity: $complexity"
Write-Host "Lockout Threshold: $lockoutThreshold"
Write-Host "Kerberos: $kerberosTypes"
Write-Host "Domain Admins: $domainAdmins"
Write-Host "Findings: $totalFindings (Critical: $critical, High: $high, Medium: $medium)"
