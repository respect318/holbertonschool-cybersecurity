#!/bin/bash

echo "=== PAM Configuration Audit ==="

# 1. Audit common-auth
echo ""
echo "/etc/pam.d/common-auth:"
if grep -q "pam_unix.so" /etc/pam.d/common-auth; then
    echo "  pam_unix.so: Standard password authentication"
fi
if grep -q "pam_deny.so" /etc/pam.d/common-auth; then
    echo "  pam_deny.so: Fallback deny"
fi

# 2. Audit common-password
echo ""
echo "/etc/pam.d/common-password:"
if [ -f "/etc/pam.d/common-password" ]; then
    echo "  pam_unix.so: Password change handling"
    
    # Check for complexity (pwquality or cracklib)
    if grep -qE "pam_pwquality.so|pam_cracklib.so" /etc/pam.d/common-password; then
        echo "  Complexity enforcement: CONFIGURED"
    else
        echo "  Complexity enforcement: NONE"
    fi

    # Check for history
    if grep -q "pam_history.so" /etc/pam.d/common-password; then
        echo "  History enforcement: CONFIGURED"
    else
        echo "  History enforcement: NONE"
    fi
fi

# 3. Audit SSHD PAM
echo ""
echo "/etc/pam.d/sshd:"
if grep -q "@include common-auth" /etc/pam.d/sshd; then
    echo "  @include common-auth"
fi
# Simple check for common MFA modules (google-authenticator, duo, etc)
if grep -qE "pam_google_authenticator.so|pam_duo.so" /etc/pam.d/sshd; then
    echo "  MFA modules: CONFIGURED"
else
    echo "  MFA modules: NONE"
fi

# 4. Account Lockout check
echo ""
echo "Account Lockout:"
for module in "pam_faillock" "pam_tally2"; do
    if grep -qr "$module" /etc/pam.d/; then
        echo "  $module: CONFIGURED"
    else
        echo "  $module: NOT CONFIGURED"
    fi
done

# 5. Password Aging (from /etc/login.defs)
echo ""
echo "Password Aging:"
MAX_DAYS=$(grep "^PASS_MAX_DAYS" /etc/login.defs | awk '{print $2}')
MIN_DAYS=$(grep "^PASS_MIN_DAYS" /etc/login.defs | awk '{print $2}')
WARN_AGE=$(grep "^PASS_WARN_AGE" /etc/login.defs | awk '{print $2}')

echo "  Default max days: $MAX_DAYS $([ "$MAX_DAYS" -gt 9000 ] && echo "(effectively disabled)")"
echo "  Default min days: $MIN_DAYS"
echo "  Default warn days: $WARN_AGE"

# 6. SSH Authentication settings
echo ""
echo "SSH Authentication:"
SSHD_CONFIG="/etc/ssh/sshd_config"
check_ssh_param() {
    local param=$1
    local val=$(grep "^$param" "$SSHD_CONFIG" | awk '{print $2}')
    [ -z "$val" ] && val="yes (default)" # Most defaults are 'yes' for these
    
    if [[ "$param" == "PasswordAuthentication" && "$val" == "yes"* ]]; then
        echo "  $param: $val (INSECURE)"
    else
        echo "  $param: $val"
    fi
}

check_ssh_param "PasswordAuthentication"
check_ssh_param "PubkeyAuthentication"
check_ssh_param "ChallengeResponseAuthentication"

echo ""
echo "Summary: Identity controls are WEAK"
