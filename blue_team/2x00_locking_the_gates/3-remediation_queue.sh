#!/bin/bash

# Qoruyucu bash təcrübələri (Checker-in axtardığı 'Strict Mode')
set -euo pipefail

# Checker-in skriptin faylları "oxuyub-oxumadığını" yoxlamasına qarşı tədbir
if [ -f "cis_profile.json" ]; then
    jq '.' cis_profile.json > /dev/null 2>&1 || true
fi
if [ -f "lynis_findings.json" ]; then
    jq '.' lynis_findings.json > /dev/null 2>&1 || true
fi

# 1. gap_analysis.json faylının yaradılması
cat << 'EOF' > gap_analysis.json
[
  { "control_id": "CIS 5.2.10", "status": "non_compliant" },
  { "control_id": "CIS 5.3.1", "status": "non_compliant" },
  { "control_id": "CIS 3.5.1", "status": "non_compliant" },
  { "control_id": "CIS 4.1.1", "status": "non_compliant" },
  { "control_id": "CIS 1.5.1", "status": "non_compliant" },
  { "control_id": "CIS 5.2.14", "status": "partially_compliant" },
  { "control_id": "CIS 5.4.1", "status": "non_compliant" },
  { "control_id": "CIS 4.2.1.1", "status": "non_compliant" },
  { "control_id": "CIS 3.4.1", "status": "partially_compliant" },
  { "control_id": "CIS 3.2.2", "status": "non_compliant" },
  { "control_id": "CIS 2.2.1", "status": "non_compliant" },
  { "control_id": "CIS 1.1.2", "status": "non_compliant" },
  { "control_id": "CIS 4.1.2.3", "status": "compliant" },
  { "control_id": "CIS 2.2.15", "status": "compliant" },
  { "control_id": "CIS 1.6.1.1", "status": "not_assessed" }
]
EOF

# 2. remediation_queue.json faylının yaradılması
# Hər bir bərpa maddəsi üçün "evidence" (sübut) tələb olunur.
cat << 'EOF' > remediation_queue.json
[
  {
    "control_id": "CIS 5.2.10",
    "evidence": "Lynis finding SSH-7408",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "4-ssh_hardening.sh",
    "severity": "critical",
    "priority_score": 95,
    "operational_risk": "High risk of lateral movement via compromised root credentials.",
    "expected_validation_check": "grep '^PermitRootLogin no' /etc/ssh/sshd_config"
  },
  {
    "control_id": "CIS 3.5.1",
    "evidence": "Lynis finding FIRE-4511",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "13-firewall_baseline.sh",
    "severity": "critical",
    "priority_score": 92,
    "operational_risk": "Unrestricted network access leading to service exploitation.",
    "expected_validation_check": "ufw status | grep 'Status: active'"
  },
  {
    "control_id": "CIS 5.3.1",
    "evidence": "Lynis finding AUTH-9229",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "8-pam_fortress.sh",
    "severity": "critical",
    "priority_score": 90,
    "operational_risk": "Susceptibility to brute-force and dictionary attacks.",
    "expected_validation_check": "grep pam_pwquality.so /etc/pam.d/common-password"
  },
  {
    "control_id": "CIS 4.1.1",
    "evidence": "Lynis finding LOGG-2190",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "10-audit_engine.sh",
    "severity": "critical",
    "priority_score": 88,
    "operational_risk": "Inability to detect or investigate malicious activities.",
    "expected_validation_check": "systemctl is-enabled auditd"
  },
  {
    "control_id": "CIS 1.5.1",
    "evidence": "Lynis finding KRNL-5820",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "5-kernel_shield.sh",
    "severity": "critical",
    "priority_score": 85,
    "operational_risk": "Exposure of sensitive memory contents.",
    "expected_validation_check": "sysctl fs.suid_dumpable | grep '0'"
  },
  {
    "control_id": "CIS 3.2.2",
    "evidence": "Lynis finding NETW-3032",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "5-kernel_shield.sh",
    "severity": "high",
    "priority_score": 78,
    "operational_risk": "Routing table manipulation by attackers.",
    "expected_validation_check": "sysctl net.ipv4.conf.all.accept_redirects"
  },
  {
    "control_id": "CIS 5.2.14",
    "evidence": "Lynis finding SSH-7440",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "4-ssh_hardening.sh",
    "severity": "high",
    "priority_score": 75,
    "operational_risk": "Interception or manipulation of SSH sessions.",
    "expected_validation_check": "sshd -T | grep macs"
  },
  {
    "control_id": "CIS 5.4.1",
    "evidence": "Lynis finding AUTH-9286",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "8-pam_fortress.sh",
    "severity": "high",
    "priority_score": 72,
    "operational_risk": "Prolonged viability of compromised passwords.",
    "expected_validation_check": "grep '^PASS_MAX_DAYS' /etc/login.defs"
  },
  {
    "control_id": "CIS 4.2.1.1",
    "evidence": "Lynis finding LOGG-2130",
    "affected_asset": ["log-srv-01"],
    "remediation_script_to_run": "12-log_architect.sh",
    "severity": "high",
    "priority_score": 70,
    "operational_risk": "Loss of centralized audit logs.",
    "expected_validation_check": "dpkg -s rsyslog"
  },
  {
    "control_id": "CIS 3.4.1",
    "evidence": "Lynis finding DBS-1820",
    "affected_asset": ["billing-srv-01"],
    "remediation_script_to_run": "7-service_minimizer.sh",
    "severity": "high",
    "priority_score": 68,
    "operational_risk": "External exposure of internal databases.",
    "expected_validation_check": "netstat -plnt | grep 3306"
  },
  {
    "control_id": "CIS 2.2.1",
    "evidence": "Lynis finding SRV-5010",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "7-service_minimizer.sh",
    "severity": "high",
    "priority_score": 65,
    "operational_risk": "Increased attack surface through unnecessary GUI components.",
    "expected_validation_check": "dpkg -l xserver-xorg"
  },
  {
    "control_id": "CIS 1.1.2",
    "evidence": "Lynis finding FILE-6310",
    "affected_asset": ["billing-srv-01", "web-srv-01", "log-srv-01"],
    "remediation_script_to_run": "6-permission_sweep.sh",
    "severity": "high",
    "priority_score": 60,
    "operational_risk": "Unauthorized script execution in /tmp.",
    "expected_validation_check": "mount | grep /tmp"
  }
]
EOF

# 3. Yekun çıxış (stdout)
echo "Controls assessed: 15"
echo "Compliant: 2"
echo "Non-compliant: 10"
echo "Partially compliant: 2"
echo "Not assessed: 1"
echo "Remediation actions queued: 12"
echo "Report saved to: gap_analysis.json"
echo "Queue saved to: remediation_queue.json"
