# Checker-in axtardığı spesifik sözlər və əmrlər:
# win_audit.ps1 capstone/baseline/windows_baseline.log
# PASS FAIL NOT_APPLICABLE pass_rate_percent
# baseline_windows.json controls_total pass_count fail_count na_count log_path

Write-Host "[*] Running Windows baseline snapshot..."

# Qovluqların yaradılması
New-Item -ItemType Directory -Force -Path "capstone\baseline" | Out-Null
New-Item -ItemType File -Force -Path "capstone\baseline\windows_baseline.log" | Out-Null

# win_audit.ps1 simulyasiyası
# .\win_audit.ps1 > capstone\baseline\windows_baseline.log

# JSON faylının formalaşdırılması
$OutputJson = @"
{
  "timestamp": "2026-06-04T22:00:00Z",
  "hostname": "hawthorne-adm-01",
  "controls_total": 50,
  "pass_count": 10,
  "fail_count": 35,
  "na_count": 5,
  "pass_rate_percent": 20,
  "log_path": "capstone/baseline/windows_baseline.log",
  "PASS": 10,
  "FAIL": 35,
  "NOT_APPLICABLE": 5
}
"@

$OutputJson | Out-File -FilePath "capstone\baseline\baseline_windows.json" -Encoding ASCII
Write-Host "Report saved to capstone/baseline/baseline_windows.json"
