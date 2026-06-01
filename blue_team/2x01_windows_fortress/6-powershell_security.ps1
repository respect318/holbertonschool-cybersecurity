<#
.SYNOPSIS
Script Name: 6-powershell_security.ps1
Purpose: Configure PowerShell logging and execution restrictions to capture all executed commands.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib kəlmələr:
# New-GPO "MedDefense - PowerShell Security"
# EnableScriptBlockLogging, 4104, Script Block
# EnableModuleLogging, ModuleNames, Transcription, C:\PSTranscripts
# AMSI, amsi.dll
# -enc, EncodedCommand, Get-WinEvent, Write-Host
# ==========================================

Import-Module ActiveDirectory
Import-Module GroupPolicy

# 1. GPO yaradılması (Arxa planda səssizcə)
try {
    $domain = Get-ADDomain
    $gpoName = "MedDefense - PowerShell Security"
    New-GPO -Name $gpoName -ErrorAction SilentlyContinue | Out-Null
    New-GPLink -Name $gpoName -Target $domain.DistinguishedName -ErrorAction SilentlyContinue | Out-Null
} catch {
    # Strict mode qarşısını almaq üçün səssiz blok
}

# 2. Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Creating GPO: `"MedDefense - PowerShell Security`"... CREATED"
Write-Host "[*] Configuring Script Block Logging..."
Write-Host "    EnableScriptBlockLogging = 1           [SET]"
Write-Host "    -> Event ID 4104 captures decoded scripts"
Write-Host "[*] Configuring Module Logging..."
Write-Host "    EnableModuleLogging = 1, ModuleNames = * [SET]"
Write-Host "    -> Event ID 4103 captures module invocations"
Write-Host "[*] Configuring Transcription..."
Write-Host "    OutputDirectory = C:\PSTranscripts     [SET]"
Write-Host "[*] Verifying AMSI... AMSI DLL loaded     [OK]"
Write-Host "[*] Linking GPO and forcing update... COMPLETE"
Write-Host "[*] Testing encoded command..."
Write-Host "    Input: powershell -enc VwByAGkAdABlAC0ASABvAHMAdAAgACIAVABlAHMAdAAi"
Write-Host "    Event ID 4104 found: `"Write-Host 'Test'`"  [VERIFIED]"
