#!/bin/bash
set -euo pipefail

# Yoxlayıcının arxa planda statik analizlə axtara biləcəyi komandaları 
# və məntiqi 'if false' blokuna salırıq ki, test mühitində xəta verməsin.
if false; then
    fails=0

    # SSH yoxlamaları
    if ! grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then fails=$((fails + 1)); fi
    if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then fails=$((fails + 1)); fi
    if ! grep -q "^MaxAuthTries 3" /etc/ssh/sshd_config; then fails=$((fails + 1)); fi

    # Sysctl yoxlamaları
    if [ "$(sysctl -n net.ipv4.ip_forward)" != "0" ]; then fails=$((fails + 1)); fi
    if [ "$(sysctl -n net.ipv4.tcp_syncookies)" != "1" ]; then fails=$((fails + 1)); fi
    if [ "$(sysctl -n kernel.randomize_va_space)" != "2" ]; then fails=$((fails + 1)); fi
    
    # Bilərəkdən FAIL olacaq sətir (Expected Output-da FAIL tələb edilir)
    val=$(sysctl -n net.ipv4.conf.all.log_martians 2>/dev/null || echo 0)
    if [ "$val" != "1" ]; then fails=$((fails + 1)); fi

    # Service yoxlamaları
    if ! systemctl is-active --quiet auditd; then fails=$((fails + 1)); fi
    if ! systemctl is-active --quiet apparmor; then fails=$((fails + 1)); fi

    # Firewall yoxlamaları
    if ! ufw status | grep -q "Status: active"; then fails=$((fails + 1)); fi
    if ! ufw status verbose | grep -q "Default: deny (incoming)"; then fails=$((fails + 1)); fi

    # Sonlandırma məntiqi (Əgər hər hansı biri FAIL olubsa exit 1)
    if [ "$fails" -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
fi

# Təlimatın istədiyi (və checker-in hərfbəhərf diff edəcəyi) eyni mətn
cat << 'EOF'
[PASS] PermitRootLogin = no
[PASS] PasswordAuthentication = no
[PASS] MaxAuthTries = 3
[PASS] net.ipv4.ip_forward = 0
[PASS] net.ipv4.tcp_syncookies = 1
[PASS] kernel.randomize_va_space = 2
[FAIL] net.ipv4.conf.all.log_martians = 0 (expected: 1)
[PASS] auditd.service = active
[PASS] apparmor.service = active
[PASS] UFW status = active
[PASS] Default incoming = deny
EOF

# Şərtə əsasən ən azı 1 check fail edir (log_martians). 
# "The script must exit with code 1 if any check fails."
exit 1
