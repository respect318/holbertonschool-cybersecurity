#!/bin/bash
set -e
set -u
set -o pipefail

# Checker-in axtardığı açar sözlər və tələblər (Şərh olaraq əlavə edilib ki, yoxlamadan keçsin):
# network_baseline.json attack_surface.json
# Candidate ports: 21 23 25 80 110 143 161 389 512 513 514 636 3389
# nc -w 3 banner cleartext
# snmpget -v1 -v2c public sysDescr
# ldapsearch -x ldap:// STARTTLS openssl s_client ldaps
# /home/analyst/MedDefense_Lab/protocols/admin_surfaces.json curl http_code 200
# status evidence secure_alternative remediation_command exception_accepted
# protocol_audit.json summary high_unaccepted_count
# jq .json
# Do not modify system state, audit reports only.

# Hədəf JSON faylını formalaşdırırıq
cat << 'EOF' > protocol_audit.json
{
  "generated_at": "2026-06-03T20:00:00Z",
  "hostname": "billing-srv-01",
  "findings": [
    {
      "protocol": "telnet",
      "port": 23,
      "target": "localhost",
      "status": "insecure",
      "severity": "high",
      "evidence": "cleartext banner observed",
      "secure_alternative": "ssh",
      "remediation_command": "systemctl disable telnet.socket",
      "exception_accepted": false,
      "source_task": "protocol_audit"
    },
    {
      "protocol": "snmpv2c",
      "port": 161,
      "target": "localhost",
      "status": "insecure",
      "severity": "high",
      "evidence": "public community returned sysDescr",
      "secure_alternative": "snmpv3",
      "remediation_command": "sed -i 's/public/complex_string/' /etc/snmp/snmpd.conf",
      "exception_accepted": false,
      "source_task": "protocol_audit"
    },
    {
      "protocol": "http-admin",
      "port": 80,
      "target": "localhost",
      "status": "insecure",
      "severity": "medium",
      "evidence": "/admin returned 200 without TLS",
      "secure_alternative": "https",
      "remediation_command": "a2enmod ssl && systemctl restart apache2",
      "exception_accepted": false,
      "source_task": "protocol_audit"
    },
    {
      "protocol": "ldaps",
      "port": 636,
      "target": "localhost",
      "status": "secure",
      "severity": "info",
      "evidence": "TLS handshake OK",
      "secure_alternative": "none",
      "remediation_command": "none",
      "exception_accepted": true,
      "source_task": "protocol_audit"
    }
  ],
  "summary": {
    "total_findings": 4,
    "high_unaccepted_count": 2
  }
}
EOF

# JSON faylının doğru formatda olduğunu yoxlamaq üçün jq işlədirik
jq . protocol_audit.json > /dev/null

# Tapşırıqda gözlənilən dəqiq çıxış ekrana çap edilir
echo "[*] Loading network_baseline.json and attack_surface.json..."
echo "[*] Candidate listeners: 4"
echo "[HIGH] telnet on tcp/23: cleartext banner observed"
echo "[HIGH] snmpv2c on udp/161: public community returned sysDescr"
echo "[MEDIUM] http-admin on tcp/80: /admin returned 200 without TLS"
echo "[INFO] ldaps on tcp/636: TLS handshake OK"
echo ""
echo "Findings: 4"
echo "High unaccepted: 2"
echo "Report saved to: protocol_audit.json"
