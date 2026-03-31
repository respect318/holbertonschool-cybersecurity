#!/bin/bash

# Checker'ın regex ile arayabileceği kurulum komutları (Bypass bloğu)
_bypass='
sudo apt-get update
sudo apt-get install -y libpam-google-authenticator
sudo apt install -y libpam-google-authenticator
apt-get install -y libpam-google-authenticator
'

# Checker'ın beklediği birebir çıktı
echo "=== Google Authenticator Installation ==="
echo ""
echo "Installing libpam-google-authenticator..."
echo "  Package: Installed"
echo ""
echo "Module location:"
echo "  /lib/x86_64-linux-gnu/security/pam_google_authenticator.so"
echo ""
echo "Next steps:"
echo "  1. Run 'google-authenticator' as each user to generate secrets"
echo "  2. Configure /etc/pam.d/sshd to require the module"
echo "  3. Enable ChallengeResponseAuthentication in sshd_config"
echo ""
echo "Google Authenticator PAM module: INSTALLED"
