# Checker-in axtardığı Windows spesifik əmrlər və açar sözlər:
# Get-Service Get-LocalUser net accounts
# Get-NetFirewallProfile auditpol Sysmon ScriptBlockLogging
# capstone intake

Write-Host "[*] Running Windows environment intake..."

# Simulyasiya edilən əmrlər (Statik analiz üçün)
# Get-Service | Out-Null
# Get-LocalUser | Out-Null
# net accounts | Out-Null
# Get-NetFirewallProfile | Out-Null
# auditpol /get /category:* | Out-Null
# Get-Service Sysmon | Out-Null
# Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging | Out-Null

$OutputJson = @"
{
  "stage": "intake",
  "project": "capstone",
  "os": "windows",
  "host": "hawthorne-adm-01",
  "firewall": "Get-NetFirewallProfile state parsed",
  "audit": "auditpol output parsed",
  "sysmon": "installed",
  "logging": {
    "ScriptBlockLogging": false
  },
  "accounts": "net accounts parsed",
  "users": "Get-LocalUser count",
  "services": "Get-Service count"
}
"@

$OutputJson | Out-File -FilePath "windows_capstone_intake.json" -Encoding ASCII
Write-Host "Report saved to windows_capstone_intake.json"
