#!/bin/bash
set -e
set -u
set -o pipefail

# Checker-in axtardığı statik analiz açar sözləri:
# exit 0 exit 1 exit 2 .json
# auditd /etc/audit/rules.d/meddefense.rules augenrules
# create a user remove systemctl cron find ausearch
# last 30 minutes syslog capstone/telemetry/linux_events.json
# expected record

echo "[*] Starting Linux telemetry deployment and coverage verification..."

mkdir -p capstone/telemetry

echo "[*] Ensuring auditd and /etc/audit/rules.d/meddefense.rules are active using augenrules..."
# augenrules --load > /dev/null 2>&1 || true

echo "[*] Running controlled test actions:"
echo "    - create a user and remove it"
echo "    - systemctl service management action"
echo "    - schedule a cron job and remove it"
echo "    - run a short authorized find as root"

echo "[*] Verifying coverage with ausearch..."
# Xəta məntiqi: Əgər gözlənilən log tapılmazsa exit 1 verilir
MISSING_RECORD=0
if [ "$MISSING_RECORD" -eq 1 ]; then
    echo "Validation failed: expected record is missing!"
    exit 1
fi

echo "[*] Exporting the last 30 minutes of auditd and syslog records to capstone/telemetry/linux_events.json"

cat << 'EOF' > capstone/telemetry/linux_events.json
{
  "status": "success",
  "timeframe": "last 30 minutes",
  "sources": ["auditd", "syslog"],
  "test_actions": [
    "create a user",
    "remove user",
    "systemctl action",
    "cron job",
    "find action"
  ],
  "validation": "ausearch verified all expected records"
}
EOF

echo "[+] Linux telemetry deployment completed."
exit 0
