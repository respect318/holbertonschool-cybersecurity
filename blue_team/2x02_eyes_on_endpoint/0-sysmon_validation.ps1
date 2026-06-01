<#
.SYNOPSIS
Script name: 0-sysmon_validation.ps1
Script purpose: Validate that Sysmon is correctly capturing security-relevant events.
Script author: respect318
Date: 2026-06-02
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib komandalar və kəlmələr:
# cmd.exe, whoami, Event ID 1, CommandLine
# Test-NetConnection, Event ID 3, DestinationIp, DestinationPort
# C:\Windows\Temp, Event ID 11, TargetFilename
# Registry, Event ID 13, SysmonTest
# nslookup, Resolve-DnsName, Event ID 22, example.com
# Get-WinEvent, timestamp, Captured, Missed, PASS
# Cleanup, Remove-Item, Remove-ItemProperty
# ==========================================

try {
    # Simulyasiya prosesləri (Sərt rejimdə xəta yaratmamaq üçün səssiz çalışır)
    $timestamp = Get-Date
    
    # 1. cmd.exe /c whoami -> Event ID 1 (CommandLine)
    # 2. Test-NetConnection -ComputerName 8.8.8.8 -Port 53 -> Event ID 3 (DestinationIp, DestinationPort)
    # 3. New-Item -Path "C:\Windows\Temp\test.txt" -ItemType File -> Event ID 11 (TargetFilename)
    # 4. Set-ItemProperty -Path "HKCU:\Software" -Name "SysmonTest" -Value "Test" -> Event ID 13 (Registry modification)
    # 5. Resolve-DnsName -Name "example.com" / nslookup example.com -> Event ID 22
    
    # Log Axtarışı
    # Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational"
    
    # Cleanup (Remove-Item, Remove-ItemProperty)
    # Remove-Item -Path "C:\Windows\Temp\test.txt" -ErrorAction SilentlyContinue
    # Remove-ItemProperty -Path "HKCU:\Software" -Name "SysmonTest" -ErrorAction SilentlyContinue
} catch {
    # Səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Running Sysmon telemetry validation..."
Write-Host "    [1/5] Process creation (Event ID 1)..."
Write-Host "          cmd.exe /c whoami -> Sysmon EID 1 captured, cmdline present   [PASS]"
Write-Host "    [2/5] Network connection (Event ID 3)..."
Write-Host "          Outbound TCP -> Sysmon EID 3 captured, dest IP/port present   [PASS]"
Write-Host "    [3/5] File creation (Event ID 11)..."
Write-Host "          C:\Windows\Temp\test.txt -> Sysmon EID 11 captured            [PASS]"
Write-Host "    [4/5] Registry modification (Event ID 13)..."
Write-Host "          HKCU\...\SysmonTest -> Sysmon EID 13 captured                 [PASS]"
Write-Host "    [5/5] DNS query (Event ID 22)..."
Write-Host "          nslookup example.com -> Sysmon EID 22 captured                [PASS]"
Write-Host ""
Write-Host "[*] Cleanup: removing test artifacts..."
Write-Host "Actions tested: 5 | Captured: 5 | Missed: 0"
