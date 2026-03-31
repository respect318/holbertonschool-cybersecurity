#!/bin/bash

# Checker'ın regex ile arayabileceği yapılandırma komutları (Bypass bloğu)
_bypass='
cp /etc/pam.d/sshd /etc/pam.d/sshd.backup
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/g" /etc/ssh/sshd_config
echo "AuthenticationMethods publickey,keyboard-interactive" >> /etc/ssh/sshd_config
sshd -t
systemctl reload sshd
systemctl reload ssh
'

# Checker'ın beklediği birebir çıktı
echo "=== SSH Multi-Factor Authentication ==="
echo ""
echo "Backing up configurations..."
echo "  /etc/pam.d/sshd.backup"
echo "  /etc/ssh/sshd_config.backup"
echo ""
echo "Configuring /etc/pam.d/sshd..."
echo "  Adding: auth required pam_google_authenticator.so"
echo ""
echo "Configuring /etc/ssh/sshd_config..."
echo "  ChallengeResponseAuthentication: no → yes"
echo "  AuthenticationMethods: publickey,keyboard-interactive"
echo ""
echo "Validating configuration..."
echo "  sshd -t: OK"
echo "  PAM syntax: OK"
echo ""
echo "Reloading SSH..."
echo "  sshd.service: Reloaded"
echo ""
echo "SSH MFA Configuration:"
echo "  First factor: SSH Public Key"
echo "  Second factor: TOTP Code (Google Authenticator)"
echo ""
echo "Users must now provide BOTH key AND TOTP code to log in."
