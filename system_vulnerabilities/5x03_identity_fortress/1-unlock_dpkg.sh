#!/bin/bash

echo "=== PAM Configuration Audit ==="
echo ""

# Function to safely read files
read_file() {
    local file=$1
    if [ -f "$file" ]; then
        cat "$file"
    else
        echo "File not found"
    fi
}

# ---- common-auth ----
echo "/etc/pam.d/common-auth:"
if [ -f /etc/pam.d/common-auth ]; then
    grep -E "pam_" /etc/pam.d/common-auth | while read -r line; do
        if echo "$line" | grep -q "pam_unix.so"; then
            echo "  pam_unix.so: Standard password authentication"
        elif echo "$line" | grep -q "pam_deny.so"; then
            echo "  pam_deny.so: Fallback deny"
        else
            echo "  $line"
        fi
    done
else
    echo "  File not found"
fi
echo ""

# ---- common-password ----
echo "/etc/pam.d/common-password:"
if [ -f /etc/pam.d/common-password ]; then
    grep -E "pam_" /etc/pam.d/common-password | while read -r line; do
        if echo "$line" | grep -q "pam_unix.so"; then
            echo "  pam_unix.so: Password change handling"
        else
            echo "  $line"
        fi
    done

    # Complexity check
    if grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
        echo "  Complexity enforcement: ENABLED"
    else
        echo "  Complexity enforcement: NONE"
    fi

    # History check
    if grep -q "remember=" /etc/pam.d/common-password; then
        echo "  History enforcement: ENABLED"
    else
        echo "  History enforcement: NONE"
    fi
else
    echo "  File not found"
fi
echo ""

# ---- sshd PAM ----
echo "/etc/pam.d/sshd:"
if [ -f /etc/pam.d/sshd ]; then
    if grep -q "@include common-auth" /etc/pam.d/sshd; then
        echo "  @include common-auth"
    fi

    if grep -E "pam_google_authenticator|pam_oath|pam_duo" /etc/pam.d/sshd >/dev/null; then
        echo "  MFA modules: CONFIGURED"
    else
        echo "  MFA modules: NONE"
    fi
else
    echo "  File not found"
fi
echo ""

# ---- Account Lockout ----
echo "Account Lockout:"
if grep -R "pam_faillock.so" /etc/pam.d/ >/dev/null 2>&1; then
    echo "  pam_faillock: CONFIGURED"
else
    echo "  pam_faillock: NOT CONFIGURED"
fi

if grep -R "pam_tally2.so" /etc/pam.d/ >/dev/null 2>&1; then
    echo "  pam_tally2: CONFIGURED"
else
    echo "  pam_tally2: NOT CONFIGURED"
fi
echo ""

# ---- Password Aging ----
echo "Password Aging:"
if [ -f /etc/login.defs ]; then
    max_days=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
    min_days=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
    warn_days=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')

    echo "  Default max days: ${max_days:-UNKNOWN}"
    echo "  Default min days: ${min_days:-UNKNOWN}"
    echo "  Default warn days: ${warn_days:-UNKNOWN}"
else
    echo "  login.defs not found"
fi
echo ""

# ---- SSH Configuration ----
echo "SSH Authentication:"
if [ -f /etc/ssh/sshd_config ]; then
    pass_auth=$(grep -i "^PasswordAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    pubkey_auth=$(grep -i "^PubkeyAuthentication" /etc/ssh/sshd_config | awk '{print $2}')
    challenge_auth=$(grep -i "^ChallengeResponseAuthentication" /etc/ssh/sshd_config | awk '{print $2}')

    echo "  PasswordAuthentication: ${pass_auth:-UNKNOWN}"
    if [ "$pass_auth" = "yes" ]; then
        echo "    (INSECURE)"
    fi

    echo "  PubkeyAuthentication: ${pubkey_auth:-UNKNOWN}"
    echo "  ChallengeResponseAuthentication: ${challenge_auth:-UNKNOWN}"
else
    echo "  sshd_config not found"
fi
echo ""

# ---- Summary ----
echo -n "Summary: Identity controls are "

weak=0

# Basic scoring
grep -q "pam_pwquality.so" /etc/pam.d/common-password || weak=1
grep -Rq "pam_faillock.so" /etc/pam.d/ || weak=1
grep -q "^PasswordAuthentication yes" /etc/ssh/sshd_config && weak=1

if [ $weak -eq 1 ]; then
    echo "WEAK"
else
    echo "STRONG"
fi
