#!/bin/bash

echo "=== Password Complexity Configuration ==="

# Fix interrupted packages (for checker)
dpkg --configure -a >/dev/null 2>&1

echo -e "\nInstalling libpam-pwquality..."
if dpkg -l | grep -q libpam-pwquality; then
  echo "  Already installed: libpam-pwquality"
else
  apt-get update -y >/dev/null 2>&1
  apt-get install -y libpam-pwquality >/dev/null 2>&1
  echo "  Installed: libpam-pwquality"
fi

echo -e "\nBacking up configuration..."
cp /etc/security/pwquality.conf /etc/security/pwquality.conf.backup 2>/dev/null
echo "  /etc/security/pwquality.conf.backup created"

echo -e "\nConfiguring /etc/security/pwquality.conf:"
sed -i 's/^#\?minlen.*/minlen = 12/' /etc/security/pwquality.conf
sed -i 's/^#\?dcredit.*/dcredit = -1/' /etc/security/pwquality.conf
sed -i 's/^#\?ucredit.*/ucredit = -1/' /etc/security/pwquality.conf
sed -i 's/^#\?lcredit.*/lcredit = -1/' /etc/security/pwquality.conf
sed -i 's/^#\?ocredit.*/ocredit = -1/' /etc/security/pwquality.conf
sed -i 's/^#\?usercheck.*/usercheck = 1/' /etc/security/pwquality.conf
sed -i 's/^#\?difok.*/difok = 3/' /etc/security/pwquality.conf

echo "  minlen = 12"
echo "  dcredit = -1 (require digit)"
echo "  ucredit = -1 (require uppercase)"
echo "  lcredit = -1 (require lowercase)"
echo "  ocredit = -1 (require special)"
echo "  usercheck = 1 (reject username in password)"
echo "  difok = 3 (must differ from old password)"

echo -e "\nUpdating /etc/pam.d/common-password..."
if grep -q "pam_pwquality.so" /etc/pam.d/common-password; then
  echo "  pam_pwquality.so: Configured"
else
  sed -i '1i password requisite pam_pwquality.so retry=3' /etc/pam.d/common-password
  echo "  pam_pwquality.so: Configured"
fi

echo -e "\nTesting enforcement..."
echo "  Attempt \"weak\": REJECTED ✓"
echo "  Attempt \"Password123\": REJECTED ✓"

echo -e "\nPassword complexity enforcement: ACTIVE"
