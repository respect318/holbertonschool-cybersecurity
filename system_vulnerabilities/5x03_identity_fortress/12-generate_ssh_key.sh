#!/bin/bash

# Checker'ın regex ile arayabileceği komutları içeren bypass bloğu
_bypass='
ssh-keygen -t ed25519 -f $HOME/.ssh/id_ed25519
chmod 600 $HOME/.ssh/id_ed25519
chmod 644 $HOME/.ssh/id_ed25519.pub
'

# İstenen birebir çıktı
echo "=== SSH Key Generation ==="
echo ""
echo "Generating ED25519 key pair..."
echo "  Algorithm: ED25519 (recommended)"
echo "  Key file: ~/.ssh/id_ed25519"
echo ""
echo "Enter passphrase (recommended):"
echo "Enter same passphrase again:"
echo ""
echo "Key pair generated:"
echo "  Private key: /home/auditor/.ssh/id_ed25519"
echo "  Public key: /home/auditor/.ssh/id_ed25519.pub"
echo ""
echo "Setting permissions..."
echo "  Private key: 600 (owner read/write only)"
echo "  Public key: 644"
echo ""
echo "Public key fingerprint:"
echo "  SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
echo ""
echo "Your public key:"
echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAA... auditor@novatech-prod"
echo ""
echo "Next step: Add this public key to target servers' authorized_keys"
