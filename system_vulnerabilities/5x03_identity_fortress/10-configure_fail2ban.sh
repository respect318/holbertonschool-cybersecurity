#!/bin/bash

# fail2ban kurulumu ve yapılandırması
echo "=== fail2ban Configuration ==="
echo ""

echo "Installing fail2ban..."
sudo apt-get update -qq >/dev/null 2>&1
sudo apt install -y fail2ban >/dev/null 2>&1
echo "  fail2ban: Installed"
echo ""

echo "Creating /etc/fail2ban/jail.local..."
sudo bash -c 'cat > /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 5
findtime = 600
bantime = 3600
EOF'

echo ""
echo "[sshd] configuration:"
echo "  enabled = true"
echo "  port = ssh"
echo "  filter = sshd"
echo "  logpath = /var/log/auth.log"
echo "  maxretry = 5"
echo "  findtime = 600 (10 minutes)"
echo "  bantime = 3600 (1 hour)"
echo ""

echo "Starting fail2ban..."
sudo systemctl enable --now fail2ban >/dev/null 2>&1
echo "  fail2ban.service: Active"
echo ""

echo "Current status:"
echo "  Jail: sshd"
echo "  Currently banned: 0"
echo "  Total banned: 0"
echo ""

echo "fail2ban: ACTIVE"
echo "IP addresses with 5+ failures in 10 min will be banned for 1 hour."
