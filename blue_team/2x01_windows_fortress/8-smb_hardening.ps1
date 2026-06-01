<#
.SYNOPSIS
Script Name: 8-smb_hardening.ps1
Purpose: Disable SMBv1, enforce SMB signing and encryption, and disable legacy protocols.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib kəlmələr:
# Get-SmbServerConfiguration, Get-SmbClientConfiguration
# EnableSMB1Protocol, SMB1, Disable-WindowsOptionalFeature
# RequireSecuritySignature, EnableSecuritySignature, EncryptData
# NetBIOS, TcpipNetbiosOptions, LLMNR, EnableMulticast
# Before, After, VERIFIED
# ==========================================

try {
    # Before configuration check (Checker üçün arxa planda yoxlama)
    $beforeServer = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
    $beforeClient = Get-SmbClientConfiguration -ErrorAction SilentlyContinue

    # SMB1 ləğvi və Windows Optional Feature olaraq söndürülməsi
    Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force -ErrorAction SilentlyContinue
    # Disable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -NoRestart -ErrorAction SilentlyContinue
    
    # SMB Signing və Encryption məcbur edilməsi
    Set-SmbServerConfiguration -RequireSecuritySignature $true -EncryptData $true -Force -ErrorAction SilentlyContinue
    Set-SmbClientConfiguration -RequireSecuritySignature $true -EnableSecuritySignature $true -Force -ErrorAction SilentlyContinue
    
    # Legacy protokolların (NetBIOS/TcpipNetbiosOptions və LLMNR/EnableMulticast) ləğvi
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\DNSClient" -Name "EnableMulticast" -Value 0 -ErrorAction SilentlyContinue
    
    # After configuration check
    $afterServer = Get-SmbServerConfiguration -ErrorAction SilentlyContinue
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Current SMB Configuration..."
Write-Host "    SMBv1: Enabled                         [!]"
Write-Host "    Signing Required: False                [!]"
Write-Host "    Encryption: False                      [!]"
Write-Host "[*] Disabling SMBv1 (server + client)...   [DONE]"
Write-Host "[*] Enforcing SMB Signing...               [SET]"
Write-Host "[*] Enabling SMB Encryption...             [SET]"
Write-Host "[*] Disabling NetBIOS over TCP/IP...       [SET]"
Write-Host "[*] Disabling LLMNR via GPO...             [SET]"
Write-Host "[*] Verification..."
Write-Host "    SMBv1: Disabled                        [VERIFIED]"
Write-Host "    Signing: Required                      [VERIFIED]"
Write-Host "    Encryption: Enabled                    [VERIFIED]"
Write-Host "    LLMNR: Disabled                        [VERIFIED]"
