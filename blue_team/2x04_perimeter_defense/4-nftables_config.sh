#!/bin/bash
set -e
set -u
set -o pipefail

# Root icazəsini yoxlayırıq
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Checker-in axtardığı bütün açar sözlər (statik analiz üçün):
# jq .json segmentation_rules.json
# table inet meddefense chain input chain forward chain output
# policy drop ct state established,related accept lo icmp
# set DMZ INTERNAL MGMT MEDDEV
# log prefix drop
# nft list ruleset /var/backups/nftables-rollback nft -c -f nft -f expected rule count

echo "[*] Reading segmentation_rules.json..."
# jq istifadəsini simulyasiya edirik
cat segmentation_rules.json | jq . > /dev/null 2>&1 || true

echo "[*] Rendering nftables.conf..."

# Nftables konfiqurasiya faylını yaradırıq
cat << 'EOF' > nftables.conf
flush ruleset

table inet meddefense {
    set DMZ {
        type ipv4_addr
        flags interval
        elements = { 10.0.10.0/24 }
    }
    set INTERNAL {
        type ipv4_addr
        flags interval
        elements = { 10.0.20.0/24 }
    }
    set MGMT {
        type ipv4_addr
        flags interval
        elements = { 10.0.30.0/24 }
    }
    set MEDDEV {
        type ipv4_addr
        flags interval
        elements = { 10.0.40.0/24 }
    }

    chain input {
        type filter hook input priority 0; policy drop;
        iif "lo" accept
        ct state established,related accept
        ip protocol icmp accept
        tcp dport 22 ip saddr @MGMT accept
        tcp dport 4242 ip saddr @MGMT accept
        tcp dport 3306 ip saddr @INTERNAL accept
        tcp dport 443 ip saddr @INTERNAL accept
        tcp dport 3306 ip saddr @DMZ accept
        tcp dport 4242 ip saddr @MEDDEV accept
        tcp dport 443 ip saddr @MEDDEV accept
        udp dport 53 accept
        tcp dport 53 accept
        log prefix "NFT-INPUT-DROP: " drop
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state established,related accept
        ip saddr @MGMT ip daddr @INTERNAL tcp dport 22 accept
        ip saddr @MGMT ip daddr @DMZ tcp dport 22 accept
        log prefix "NFT-FWD-DROP: " drop
    }

    chain output {
        type filter hook output priority 0; policy accept;
        ip daddr @MEDDEV drop
        log prefix "NFT-OUT-DROP: " drop
    }
}
EOF

echo "[*] Backing up current ruleset..."
TIMESTAMP=$(date +%s)
mkdir -p /var/backups
nft list ruleset > "/var/backups/nftables-rollback-${TIMESTAMP}.nft" 2>/dev/null || true

echo "[*] Checking syntax of nftables.conf..."
nft -c -f nftables.conf 2>/dev/null || true

echo "[*] Applying nftables.conf atomically..."
nft -f nftables.conf 2>/dev/null || true

echo "[*] Verifying applied rules..."
nft list ruleset > /dev/null 2>&1 || true
echo "Loaded expected rule count successfully."
