#!/bin/bash
# Description: Captures the full state of the system before any patch operation.
# Idempotent and safe: read-only operations.

OUTPUT_FILE="pre_patch_state.json"

# Məlumatların toplanması
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
KERNEL=$(uname -r)
REBOOT_REQUIRED=$( [ -f /var/run/reboot-required ] && echo "true" || echo "false" )

# Paket versiyaları (Key-Value şəklində)
PACKAGES=$(dpkg-query -W -f='${Package} ${Version}\n' | jq -R -s -c 'split("\n")[:-1] | map(split(" ")) | map({(.[0]): .[1]}) | add')

# Aktiv servislərin vəziyyəti
SERVICES=$(systemctl list-units --type=service --state=active --no-pager --no-legend | awk '{print $1}' | while read -r svc; do
    systemctl show -p Id,ActiveState,SubState,MainPID "$svc" | awk -F= '
        /^Id=/ {id=$2}
        /^ActiveState=/ {act=$2}
        /^SubState=/ {sub=$2}
        /^MainPID=/ {pid=$2}
        END { printf "{\"service\":\"%s\",\"ActiveState\":\"%s\",\"SubState\":\"%s\",\"MainPID\":%s}", id, act, sub, pid }'
done | jq -s -c '.')

# Dinləyən portlar (ss -tulnp)
LISTENING=$(ss -tulnp 2>/dev/null | tail -n +2 | jq -R -s -c 'split("\n")[:-1]')

# /etc altındakı config fayllarının SHA-256 hashləri
# Çox vaxt aparmaması üçün xargs və sha256sum istifadə edirik
CONFFILES=$(dpkg-query -W -f='${Conffiles}\n' | awk '{print $1}' | grep '^/etc/' | xargs -r sha256sum 2>/dev/null | awk '{print "{\"" $2 "\":\"" $1 "\"}"}' | jq -s -c 'add')

# JSON faylının yaradılması
jq -n --arg ts "$TIMESTAMP" \
      --arg hn "$HOSTNAME" \
      --arg kr "$KERNEL" \
      --argjson pkgs "${PACKAGES:-{}}" \
      --argjson svcs "${SERVICES:-[]}" \
      --argjson lst "${LISTENING:-[]}" \
      --argjson conf "${CONFFILES:-{}}" \
      --argjson rb "$REBOOT_REQUIRED" \
      '{
          timestamp: $ts,
          hostname: $hn,
          kernel: $kr,
          packages: $pkgs,
          services: $svcs,
          listening: $lst,
          conffile_hashes: $conf,
          reboot_required: $rb
      }' > "$OUTPUT_FILE"

# Şərtdəki Terminal Çıxışını (Stdout) ekrana çap etmək
SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
echo "Snapshot: $OUTPUT_FILE"
echo "Size: $SIZE"
echo "Kernel: $KERNEL"
echo "Reboot required: $REBOOT_REQUIRED"
