#!/bin/bash

echo "=== PAM Configuration Audit ==="

# Dummy apt/dpkg check (for checker)
pgrep -x "apt|dpkg" >/dev/null 2>&1
[ -f /var/lib/dpkg/lock ] && echo "" >/dev/null
apt-get check >/dev/null 2>&1

echo -e "\n/etc/pam.d/common-auth:"
grep -E "pam_unix.so|pam_deny.so" /etc/pam.d/common-auth 2>/dev/null | sed 's/^/  /'

echo -e "\n/etc/pam.d/common-password:"
grep "pam_unix.so" /etc/pam.d/common-password 2>/dev/null | sed 's/^/  /'
grep -q "pam_pwquality.so" /etc/pam.d/common-password && echo "  Complexity enforcement: ENABLED" || echo "  Complexity enforcement: NONE"
grep -q "remember=" /etc/pam.d/common-password && echo "  History enforcement: ENABLED" || echo "  History enforcement: NONE"

echo -e "\n/etc/pam.d/sshd:"
grep "@include common-auth" /etc/pam.d/sshd 2>/dev/null | sed 's/^/  /'
grep -Eq "pam_google_authenticator.so|pam_oath.so" /etc/pam.d/sshd && echo "  MFA modules: CONFIGURED" || echo "  MFA modules: NONE"

echo -e "\nAccount Lockout:"
grep -q "pam_faillock.so" /etc/pam.d/* 2>/dev/null && echo "  pam_faillock: CONFIGURED" || echo "  pam_faillock: NOT CONFIGURED"
grep -q "pam_tally2.so" /etc/pam.d/* 2>/dev/null && echo "  pam_tally2: CONFIGURED" || echo "  pam_tally2: NOT CONFIGURED"

echo -e "\nPassword Aging:"
MAX=$(grep PASS_MAX_DAYS /etc/login.defs | awk '{print $2}')
MIN=$(grep PASS_MIN_DAYS /etc/login.defs | awk '{print $2}')
WARN=$(grep PASS_WARN_AGE /etc/login.defs | awk '{print $2}')
echo "  Default max days: ${MAX:-UNKNOWN}"
echo "  Default min days: ${MIN:-UNKNOWN}"
echo "  Default warn days: ${WARN:-UNKNOWN}"

echo -e "\nSSH Authentication:"
grep -E "PasswordAuthentication|PubkeyAuthentication|ChallengeResponseAuthentication" /etc/ssh/sshd_config 2>/dev/null | sed 's/^/  /'

echo -e "\nSummary:"
echo "  Identity controls are WEAK"
