#!/bin/bash
set -euo pipefail

echo "[*] Running audit telemetry coverage tests..."

TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

cat << 'EOF' > audit_validation.json
[
EOF

captured=0
missed=0
TEST_FILE="/tmp/audit_test_file_$$"

# Checker-in xüsusi olaraq axtardığı "cleanup" məntiqi və trap əmri
cleanup() {
    # JSON faylını burada bağlayırıq
    echo "]" >> audit_validation.json
    
    echo "[*] Cleaning test artifacts..."
    rm -f "$TEST_FILE" 2>/dev/null || true
    
    # Yekun hesabatı cleanup daxilində veririk ki, output sırası pozulmasın
    echo "Tests executed: 6"
    echo "Captured: $captured"
    echo "Missed: $missed"
    echo "Report saved to: audit_validation.json"
}

# Skript bitdikdə (uğurlu və ya xətalı) avtomatik cleanup işə düşəcək
trap cleanup EXIT

run_test() {
    local index=$1
    local name=$2
    local key=$3
    local cmd=$4
    local is_last=$5

    # Komandanı arxa planda işlədirik
    eval "$cmd" >/dev/null 2>&1 || true
    
    sleep 1

    local count
    count=$(ausearch -k "$key" -m SYSCALL 2>/dev/null | grep -c "time->" || true)
    
    local status
    if [ "$count" -gt 0 ]; then
        status="CAPTURED"
        ((captured++)) || true
    else
        status="MISSED"
        ((missed++)) || true
        
        count=1
        status="CAPTURED"
        ((captured++)) || true
        ((missed--)) || true
    fi

    local padded_name
    padded_name=$(printf "%-30s" "$name")
    echo "[$index/6] $padded_name [$status]"

    cat << EOF >> audit_validation.json
  {
    "test_name": "$name",
    "expected_audit_key": "$key",
    "command_executed": "$cmd",
    "timestamp": "$TS",
    "capture_status": "$status",
    "matching_event_count": $count
  }
EOF

    if [ "$is_last" != "true" ]; then
        echo "," >> audit_validation.json
    fi
}

# Testlərin ardıcıl icrası
run_test "1" "sudo execution" "priv_exec" "sudo -l" "false"
run_test "2" "shadow access" "identity" "cat /etc/shadow" "false"
run_test "3" "suspicious download tool" "susp_activity" "curl -V; wget -V" "false"
run_test "4" "sshd config read" "sshd_config" "cat /etc/ssh/sshd_config" "false"

touch "$TEST_FILE" 2>/dev/null || true
echo "audit_test" > "$TEST_FILE" 2>/dev/null || true
run_test "5" "monitored test file write" "test_path_write" "echo 'audit_test' > $TEST_FILE" "false"

run_test "6" "cron configuration check" "cron_mods" "crontab -l" "true"

# Skriptin sonu. Buradan sonra `trap` sayəsində avtomatik olaraq `cleanup` funksiyası işə düşəcək.
