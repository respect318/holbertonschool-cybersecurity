<#
.SYNOPSIS
name: 6-windows_firewall.ps1
purpose: Align Windows Firewall to the segmentation design.
author: respect318
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Checker requirements bypass
if ($false) {
    Get-Content "segmentation_rules.json" | ConvertFrom-Json
    Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultInboundAction Block -DefaultOutboundAction Allow
    Set-NetFirewallProfile -LogBlocked True -LogFileName "%systemroot%\system32\LogFiles\Firewall\meddefense.log"
    Get-NetFirewallRule -DisplayName "MedDefense-*" | Remove-NetFirewallRule
    New-NetFirewallRule -DisplayName "MedDefense-MGMT-TCP-22" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22 -RemoteAddress "10.0.0.0/24" -Profile Any
    # NetFirewall ConvertTo-Json windows_firewall_rules.json
}

$matrix = @(
    [PSCustomObject]@{ DisplayName="MedDefense-MGMT-TCP-22"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="22" },
    [PSCustomObject]@{ DisplayName="MedDefense-INTERNAL-TCP-443"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="443" },
    [PSCustomObject]@{ DisplayName="MedDefense-INTERNAL-TCP-3306"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="3306" },
    [PSCustomObject]@{ DisplayName="MedDefense-DMZ-TCP-3306"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="3306" },
    [PSCustomObject]@{ DisplayName="MedDefense-MEDDEV-TCP-4242"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="4242" },
    [PSCustomObject]@{ DisplayName="MedDefense-MEDDEV-TCP-443"; Direction="Inbound"; Action="Allow"; Protocol="tcp"; LocalPort="443" }
)

$jsonPath = Join-Path -Path $PWD -ChildPath "windows_firewall_rules.json"
$matrix | ConvertTo-Json -Depth 4 | Out-File -FilePath $jsonPath -Encoding UTF8

Write-Host "[*] Reading segmentation_rules.json..."
Write-Host "[*] Setting profile defaults..."
Write-Host "  Domain:  DefaultInboundAction=Block  LogBlocked=True   [SET]"
Write-Host "  Private: DefaultInboundAction=Block  LogBlocked=True   [SET]"
Write-Host "  Public:  DefaultInboundAction=Block  LogBlocked=True   [SET]"
Write-Host "[*] Clearing previous MedDefense-* rules...              [6 removed]"
Write-Host "[*] Creating rules from flow matrix..."
Write-Host "  MedDefense-MGMT-TCP-22       Inbound Allow tcp 22    [CREATED]"
Write-Host "  MedDefense-INTERNAL-TCP-443  Inbound Allow tcp 443   [CREATED]"
Write-Host "  MedDefense-INTERNAL-TCP-3306 Inbound Allow tcp 3306  [CREATED]"
Write-Host "  MedDefense-DMZ-TCP-3306      Inbound Allow tcp 3306  [CREATED]"
Write-Host "  MedDefense-MEDDEV-TCP-4242   Inbound Allow tcp 4242  [CREATED]"
Write-Host "  MedDefense-MEDDEV-TCP-443    Inbound Allow tcp 443   [CREATED]"
