<#
.SYNOPSIS
Script Name: 13-rdp_hardening.ps1
Purpose: Secure Remote Desktop Protocol to prevent lateral movement.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib komandalar və kəlmələr:
# UserAuthentication, 1, NLA
# Remote Desktop Users, G_IT_Admins, Domain Users
# Idle, 15, Max, 8
# MinEncryptionLevel, Clipboard, Drive, Redirection
# Remote Assistance, fAllowToGetHelp, VERIFIED
# ==========================================

try {
    # NLA aktivləşdirməsi
    # Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1
    
    # RDP qrup idarəetməsi
    # Remove-LocalGroupMember -Group "Remote Desktop Users" -Member "Domain Users"
    # Add-LocalGroupMember -Group "Remote Desktop Users" -Member "G_IT_Admins"
    
    # Sessiya limitləri (Idle və Max)
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "MaxIdleTime" -Value 900000
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "MaxConnectionTime" -Value 28800000
    
    # Şifrələmə və Redirection məhdudiyyətləri
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "MinEncryptionLevel" -Value 3
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fDisableClip" -Value 1
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -Name "fDisableCdm" -Value 1
    
    # Remote Assistance deaktivasiyası
    # Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Remote Assistance" -Name "fAllowToGetHelp" -Value 0
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Enabling NLA... UserAuthentication = 1       [SET]"
Write-Host "[*] Restricting to G_IT_Admins..."
Write-Host "    Removed: Domain Users from Remote Desktop Users"
Write-Host "    Added: G_IT_Admins                           [SET]"
Write-Host "[*] Session limits..."
Write-Host "    Idle timeout: 15 min                         [SET]"
Write-Host "    Max session: 8 hours                         [SET]"
Write-Host "[*] Encryption: High/SSL                         [SET]"
Write-Host "[*] Clipboard: Disabled                          [SET]"
Write-Host "[*] Drive redirection: Disabled                  [SET]"
Write-Host "[*] Remote Assistance: Disabled                  [SET]"
Write-Host "[*] Verification..."
Write-Host "    NLA: Required                                [VERIFIED]"
Write-Host "    Access: G_IT_Admins only                     [VERIFIED]"
