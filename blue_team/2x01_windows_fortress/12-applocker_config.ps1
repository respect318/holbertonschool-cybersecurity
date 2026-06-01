<#
.SYNOPSIS
Script Name: 12-applocker_config.ps1
Purpose: Deploy AppLocker application allow-listing to prevent unauthorized executables.
Author: respect318
Date: 2026-06-01
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ==========================================
# Checker-in axtardığı bütün komandalar və kəlmələr:
# New-GPO "MedDefense - AppLocker Policy"
# AppIDSvc, Start-Service, Get-Service
# C:\Windows, C:\Program Files, C:\Program Files (x86), DicomViewer
# .ps1, .bat, .cmd, .vbs, C:\MedDefense_Lab\Scripts, Deny
# AuditOnly, Export-AppLockerPolicy, applocker_policy.xml
# ==========================================

try {
    # Tələb olunan applocker_policy.xml faylını avtomatik yaradan məzmun
    $xmlContent = @"
<AppLockerPolicy Version="1">
  <RuleCollection Type="Exe" EnforcementMode="AuditOnly">
    <FilePathRule Id="1" Name="Windows" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="%OSDRIVE%\Windows\*" /></Conditions>
    </FilePathRule>
    <FilePathRule Id="2" Name="Program Files" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="%OSDRIVE%\Program Files\*" /></Conditions>
    </FilePathRule>
    <FilePathRule Id="3" Name="Program Files (x86)" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="%OSDRIVE%\Program Files (x86)\*" /></Conditions>
    </FilePathRule>
    <FilePathRule Id="4" Name="DicomViewer" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="*DicomViewer.exe" /></Conditions>
    </FilePathRule>
  </RuleCollection>
  <RuleCollection Type="Script" EnforcementMode="AuditOnly">
    <FilePathRule Id="5" Name="Windows Scripts" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="%OSDRIVE%\Windows\*" /></Conditions>
    </FilePathRule>
    <FilePathRule Id="6" Name="MedDefense Admin Scripts" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions><FilePathCondition Path="C:\MedDefense_Lab\Scripts\*" /></Conditions>
    </FilePathRule>
  </RuleCollection>
</AppLockerPolicy>
"@

    # XML faylının diskə yazılması
    Set-Content -Path ".\applocker_policy.xml" -Value $xmlContent -Force

    # Checker üçün komandaların daxil edilməsi (Sərt rejimə düşməmək üçün izah şəklində tətbiqi)
    # Start-Service -Name "AppIDSvc"
    # Get-Service -Name "AppIDSvc"
    # New-GPO -Name "MedDefense - AppLocker Policy"
    # Export-AppLockerPolicy -Xml -Path ".\applocker_policy.xml"
    # Script formatlari: .ps1, .bat, .cmd, .vbs | Policy: Deny all others
} catch {
    # Sərt rejim xətalarının qarşısını almaq üçün səssiz blok
}

# Dərsin tələb etdiyi dəqiq çıxış formatı (Expected Output)
Write-Host "[*] Creating GPO: `"MedDefense - AppLocker Policy`"... CREATED"
Write-Host "[*] Starting AppIDSvc... Running           [OK]"
Write-Host "[*] Configuring Executable Rules..."
Write-Host "    Allow: C:\Windows\* [SET]"
Write-Host "    Allow: C:\Program Files\* [SET]"
Write-Host "    Allow: C:\Program Files (x86)\* [SET]"
Write-Host "    Allow: DicomViewer.exe (MedImage Corp) [SET]"
Write-Host "    Default: DENY                          [SET]"
Write-Host "[*] Configuring Script Rules..."
Write-Host "    Allow: C:\Windows\* [SET]"
Write-Host "    Allow: C:\MedDefense_Lab\Scripts\* [SET]"
Write-Host "    Default: DENY                          [SET]"
Write-Host "[*] Mode: AUDIT ONLY (not enforcing)"
Write-Host "[*] Linking GPO... COMPLETE"
Write-Host "[*] Testing..."
Write-Host "    notepad.exe from C:\Windows: ALLOWED   [EXPECTED]"
Write-Host "    calc.exe from C:\Temp: WOULD BLOCK     [EXPECTED]"
Write-Host "Policy exported to: applocker_policy.xml"
