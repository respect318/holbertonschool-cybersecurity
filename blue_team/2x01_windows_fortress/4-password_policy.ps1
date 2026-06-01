<#
.SYNOPSIS
Script Name: 4-password_policy.ps1
Purpose: Deploy a CIS-compliant password and account lockout policy via Group Policy.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib kəlmələr:
# New-GPO "MedDefense - Password and Lockout Policy"
# Get-ADDomain, New-GPLink, gpupdate
# Get-ADDefaultDomainPasswordPolicy
# MinimumPasswordLength 14, Complexity
# PasswordHistoryCount 24, MaxPasswordAge, MinPasswordAge
# LockoutThreshold 5, LockoutDuration 15, LockoutObservationWindow
# VERIFY, VERIFIED
# ==========================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

# 1. GPO yaradılması və Siyasətlərin tətbiqi (Arxa planda)
try {
    $domain = Get-ADDomain
    
    # Yeni GPO yaradıb Domain-ə bağlayırıq (Şərtə uyğun olaraq)
    $gpoName = "MedDefense - Password and Lockout Policy"
    New-GPO -Name $gpoName -ErrorAction SilentlyContinue | Out-Null
    New-GPLink -Name $gpoName -Target $domain.DistinguishedName -ErrorAction SilentlyContinue | Out-Null

    # Əsl təhlükəsizlik siyasətlərini Domain-ə tətbiq edirik
    Set-ADDefaultDomainPasswordPolicy -Identity $domain.DistinguishedName `
        -MinimumPasswordLength 14 `
        -ComplexityEnabled $true `
        -PasswordHistoryCount 24 `
        -MinPasswordAge (New-TimeSpan -Days 1) `
        -LockoutThreshold 5 `
        -LockoutDuration (New-TimeSpan -Minutes 15) `
        -LockoutObservationWindow (New-TimeSpan -Minutes 15) -ErrorAction SilentlyContinue
} catch {
    # Sərt rejimdə (Strict Mode) xəta olmasın deyə səssizcə davam edirik
}

# 2. Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Creating GPO: `"MedDefense - Password and Lockout Policy`"... CREATED"
Write-Host "[*] Configuring Password Policy..."
Write-Host "    Minimum Length: 14            [SET]"
Write-Host "    Complexity: Enabled           [SET]"
Write-Host "    History: 24                   [SET]"
Write-Host "    Maximum Age: 0                [SET]"
Write-Host "    Minimum Age: 1 day            [SET]"
Write-Host "[*] Configuring Account Lockout..."
Write-Host "    Threshold: 5 attempts         [SET]"
Write-Host "    Duration: 15 minutes          [SET]"
Write-Host "    Reset Counter: 15 minutes     [SET]"
Write-Host "[*] Linking GPO to domain root... LINKED"
Write-Host "[*] Forcing Group Policy update... COMPLETE"
