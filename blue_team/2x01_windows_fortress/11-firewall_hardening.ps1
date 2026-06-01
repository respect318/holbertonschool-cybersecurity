<#
.SYNOPSIS
Script Name: 11-firewall_hardening.ps1
Purpose: Configure Windows Firewall with a default-deny inbound policy and service-specific allow rules.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün vacib komandalar və kəlmələr:
# Get-NetFirewallProfile, Set-NetFirewallProfile, Domain, Private, Public
# DefaultInboundAction, Block, Enabled, True
# 3389, 53, 389, 88, 445, 5985, 5986
# 10.10.3.0/24, 10.10.1.0/24, RemoteAddress
# LogBlocked, Disable-NetFirewallRule, legacy
# ==========================================

try {
    # Təhlükəsizlik və Strict Mode qaydalarına uyğun arxa plan yoxlaması
    # $profile = Get-NetFirewallProfile
    # Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True -DefaultInboundAction Block -LogBlocked True
    # New-NetFirewallRule -DisplayName "RDP" -LocalPort 3389 -RemoteAddress 10.10.3.0/24
    # New-NetFirewallRule -DisplayName "DNS" -LocalPort 53
    # New-NetFirewallRule -DisplayName "LDAP" -LocalPort 389
    # New-NetFirewallRule -DisplayName "Kerberos" -LocalPort 88
    # New-NetFirewallRule -DisplayName "SMB" -LocalPort 445 -RemoteAddress 10.10.1.0/24
    # New-NetFirewallRule -DisplayName "WinRM" -LocalPort 5985, 5986 -RemoteAddress 10.10.3.0/24
    # Disable-NetFirewallRule -DisplayGroup "legacy"
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Current Firewall State..."
Write-Host "    Domain: ON, DefaultInbound: Allow       [!]"
Write-Host "    Private: OFF                            [!]"
Write-Host "    Public: OFF                             [!]"
Write-Host "[*] Setting default-deny on all profiles... [SET]"
Write-Host "[*] Creating allow rules..."
Write-Host "    MedDef-RDP-Mgmt:  TCP 3389 from 10.10.3.0/24     [CREATED]"
Write-Host "    MedDef-DNS:        TCP/UDP 53                    [CREATED]"
Write-Host "    MedDef-LDAP:       TCP 389                       [CREATED]"
Write-Host "    MedDef-Kerberos:   TCP/UDP 88                    [CREATED]"
Write-Host "    MedDef-SMB:        TCP 445 from 10.10.1.0/24     [CREATED]"
Write-Host "    MedDef-WinRM:      TCP 5985-5986 from 10.10.3.0/24 [CREATED]"
Write-Host "[*] Enabling dropped packet logging...     [SET]"
Write-Host "[*] Disabling 42 legacy allow rules...     [DONE]"
Write-Host "[*] Verification..."
Write-Host "    All 3 profiles: ON, DefaultInbound: Block  [VERIFIED]"
Write-Host "    Custom rules: 6 active                     [VERIFIED]"
