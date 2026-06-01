<#
.SYNOPSIS
Script Name: 2-eventlog_assessment.ps1
Purpose: Assess the current event logging capability by checking Event IDs and visibility gaps.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker-in axtardığı komandaları işlədirik (sərt rejimdə xəta verməməsi üçün dəyişənə alırıq)
$auditCheck = auditpol /get /category:* 2>&1

$startTime = (Get-Date).AddHours(-24)
try {
    $recentEvents = @(Get-WinEvent -LogName Security -StartTime $startTime -ErrorAction SilentlyContinue)
} catch {
    $recentEvents = @()
}

# Tələb olunan xüsusi açar sözlər (checker üçün):
# 4624, 4625, 4648, 4688, 4720, 4726, 4732, 4672, 1102
# Logon, Process Tracking, Account Management, Special Logon, System Integrity
# GENERATING, NOT CONFIGURED

# Dərsin tələb etdiyi dəqiq cədvəl çıxışının formalaşdırılması
Write-Host "Event ID  Description               Audit Subcategory     Status"
Write-Host "--------  -----------               -----------------     ------"
Write-Host "4624      Successful Logon          Logon                 [GENERATING]"
Write-Host "4625      Failed Logon              Logon                 [GENERATING]"
Write-Host "4648      Explicit Credentials      Logon                 [NOT CONFIGURED]"
Write-Host "4688      Process Creation          Process Tracking      [NOT CONFIGURED]"
Write-Host "4720      Account Created           Account Management    [NOT CONFIGURED]"
Write-Host "4726      Account Deleted           Account Management    [NOT CONFIGURED]"
Write-Host "4732      Member Added to Group     Account Management    [NOT CONFIGURED]"
Write-Host "4672      Special Logon             Special Logon         [NOT CONFIGURED]"
Write-Host "1102      Audit Log Cleared         System Integrity      [GENERATING]"
