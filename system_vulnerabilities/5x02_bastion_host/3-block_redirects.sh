#!/bin/bash

echo "=== Blocking ICMP Redirects ==="

CONF_FILE="/etc/sysctl.d/99-hardening.conf"

# 1. ICMP Redirect Acceptance (Qəbul etməni söndürürük)
echo ""
echo "Disabling redirect acceptance..."
sudo sysctl -w net.ipv4.conf.all.accept_redirects=0 > /dev/null
sudo sysctl -w net.ipv4.conf.default.accept_redirects=0 > /dev/null
sudo sysctl -w net.ipv6.conf.all.accept_redirects=0 > /dev/null
sudo sysctl -w net.ipv6.conf.default.accept_redirects=0 > /dev/null

echo "  net.ipv4.conf.all.accept_redirects = 0"
echo "  net.ipv4.conf.default.accept_redirects = 0"
echo "  net.ipv6.conf.all.accept_redirects = 0"
echo "  net.ipv6.conf.default.accept_redirects = 0"

# 2. ICMP Redirect Sending (Göndərməni söndürürük)
echo ""
echo "Disabling redirect sending..."
sudo sysctl -w net.ipv4.conf.all.send_redirects=0 > /dev/null
sudo sysctl -w net.ipv4.conf.default.send_redirects=0 > /dev/null

echo "  net.ipv4.conf.all.send_redirects = 0"
echo "  net.ipv4.conf.default.send_redirects = 0"

# 3. Dəyişiklikləri qalıcı (persistent) edirik
# 'tee -a' istifadə edirik ki, əvvəlki tapşırıqdakı (forwarding) ayarlar silinməsin
{
    echo ""
    echo "# Hardening: Block ICMP Redirects"
    echo "net.ipv4.conf.all.accept_redirects = 0"
    echo "net.ipv4.conf.default.accept_redirects = 0"
    echo "net.ipv6.conf.all.accept_redirects = 0"
    echo "net.ipv6.conf.default.accept_redirects = 0"
    echo "net.ipv4.conf.all.send_redirects = 0"
    echo "net.ipv4.conf.default.send_redirects = 0"
} | sudo tee -a $CONF_FILE > /dev/null

# Konfiqurasiyanı yenidən yükləyirik
sudo sysctl -p $CONF_FILE > /dev/null

echo ""
echo "Configuration saved to $CONF_FILE"
echo ""
echo "ICMP redirects: BLOCKED"
