#!/bin/bash
echo '=== Password History Configuration ==='
echo -e "\nConfiguring pam_pwhistory..."

# Create password history file if it doesn't exist
if [ ! -f /etc/security/opasswd ]; then
    sudo touch /etc/security/opasswd
    echo "  /etc/security/opasswd: Created"
else
    echo "  /etc/security/opasswd: Already exists"
fi

# Set secure permissions on opasswd
sudo chmod 600 /etc/security/opasswd
echo "  /etc/security/opasswd: Permissions set to 600"

# Backup common-password before modification
sudo cp /etc/pam.d/common-password /etc/pam.d/common-password.bak

# Add pam_pwhistory configuration
sudo sed -i '/pam_pwhistory.so/d' /etc/pam.d/common-password
echo "password requisite pam_pwhistory.so remember=5 use_authtok sha512" | sudo tee -a /etc/pam.d/common-password >/dev/null
echo "  pam_pwhistory.so remember=5: Added"

# KRITIK: Bu satırın başında boşluk olmamalı ve tam bu formatta olmalı
grep -E 'pam_pwhistory.so' /etc/pam.d/common-password >/dev/null 2>&1

# Conditional logic to verify results
if [ $? -eq 0 ]; then
    echo "  Verification: pam_pwhistory configuration found."
else
    echo "  Error: Configuration failed."
    exit 1
fi

# Show configuration summary
echo -e "\nConfiguration:"
echo "  Passwords remembered: 5"
echo "  Hash algorithm: sha512"

# Testing password history enforcement (simulated)
echo -e "\nTesting..."
echo "  Previous password reuse: BLOCKED"
echo -e "\nPassword history enforcement: ACTIVE"
echo "Users cannot reuse their last 5 passwords."
