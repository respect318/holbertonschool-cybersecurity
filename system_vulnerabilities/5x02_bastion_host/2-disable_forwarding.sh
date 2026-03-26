#!/bin/bash

echo "=== Disabling IP Forwarding ==="

# Cari vəziyyəti göstəririk
echo ""
echo "Current state:"
IPV4_CUR=$(sysctl -n net.ipv4.ip_forward)
IPV6_CUR=$(sysctl -n net.ipv6.conf.all.forwarding)
echo "  net.ipv4.ip_forward = $IPV4_CUR"
echo "  net.ipv6.conf.all.forwarding = $IPV6_CUR"

echo ""
echo "Applying changes..."

# Canlı sistemdə dərhal söndürürük
sudo sysctl -w net.ipv4.ip_forward=0 > /dev/null
sudo sysctl -w net.ipv6.conf.all.forwarding=0 > /dev/null

echo "  net.ipv4.ip_forward = 0"
echo "  net.ipv6.conf.all.forwarding = 0"

# Dəyişikliyi qalıcı (persistent) edirik
echo ""
echo "Making persistent in /etc/sysctl.d/99-hardening.conf..."
CONF_FILE="/etc/sysctl.d/99-hardening.conf"

# Faylı yaradırıq və ya üzərinə yazırıq
{
    echo "# Hardening: Disable IP Forwarding"
    echo "net.ipv4.ip_forward = 0"
    echo "net.ipv6.conf.all.forwarding = 0"
} | sudo tee $CONF_FILE > /dev/null

# Konfiqurasiyanı yenidən yükləyirik
sudo sysctl -p $CONF_FILE > /dev/null

# Yoxlama (Verification)
echo ""
echo "Verification:"

# IPv4 yoxlanışı
if [ "$(sysctl -n net.ipv4.ip_forward)" -eq 0 ]; then
    echo "  IPv4 forwarding: DISABLED"
else
    echo "  IPv4 forwarding: ENABLED (Error)"
fi

# IPv6 yoxlanışı
if [ "$(sysctl -n net.ipv6.conf.all.forwarding)" -eq 0 ]; then
    echo "  IPv6 forwarding: DISABLED"
else
    echo "  IPv6 forwarding: ENABLED (Error)"
fi
