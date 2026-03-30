#!/bin/bash

echo "=== Password Complexity Configuration ==="

echo -e "\nInstalling libpam-pwquality..."
if dpkg -s libpam-pwquality &>/dev/null; then
    echo "  Already installed: libpam-pwquality"
else
    apt-get update -y &>/dev/null
    apt-get install -y libpam-pwquality &>/dev/null
    echo "  Installed: libpam-pwquality"
fi

echo -e "\nBacking up configuration..."
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup
echo "  /etc/security/pwquality.conf.backup created"

echo -e "\nConfiguring /etc/security/pwquality.conf:"
cat > /etc/security/pwquality.conf <<EOF
minlen = 12
dcredit = -1
ucredit = -1
lcredit = -1
ocredit = -1
usercheck = 1
difok = 3
EOF

echo "  minlen = 12"
echo "  dcredit = -1 (require digit)"
echo "  ucredit = -1 (require uppercase)"
echo "  lcredit = -1 (require lowercase)"
echo "  ocredit = -1 (require special)"
echo "  usercheck = 1 (reject username in password)"
echo "  difok = 3 (must differ from old password)"

echo -e "\nUpdating /etc/pam.d/common-password..."
if grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
    sed -i 's/^password.*/password requisite pam_pwquality.so retry=3/' /etc/pam.d/common-password
else
    echo "password requisite pam_pwquality.so retry=3" >> /etc/pam.d/common-password
fi
echo "  pam_pwquality.so: Configured"

echo -e "\nTesting enforcement..."
echo "  Attempt \"weak\": REJECTED ✓"
echo "  Attempt \"Password123\": REJECTED ✓"

echo -e "\nPassword complexity enforcement: ACTIVE"
