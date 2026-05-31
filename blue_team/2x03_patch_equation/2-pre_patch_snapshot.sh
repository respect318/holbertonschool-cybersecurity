#!/bin/bash

# Faylın adı
OUTPUT_FILE="pre_patch_state.json"

# 1. Təməl məlumatlar
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
kernel=$(uname -r)

if [ -f /var/run/reboot-required ]; then
    reboot_required="true"
else
    reboot_required="false"
fi

# 2. Package version snapshot (dpkg-query və packages axtarılır)
packages_json=$(dpkg-query -W -f='${binary:Package}\t${Version}\n' | jq -R -s -c 'split("\n")[:-1] | map(split("\t")) | map({"package": .[0], "version": .[1]})')

# 3. Service state snapshot (systemctl show, ActiveState, SubState, MainPID axtarılır)
services_json=$(systemctl list-units --type=service --state=active --no-legend | awk '{print $1}' | while read srv; do
    state=$(systemctl show -p ActiveState -p SubState -p MainPID "$srv")
    active=$(echo "$state" | awk -F= '/^ActiveState=/ {print $2}')
    sub=$(echo "$state" | awk -F= '/^SubState=/ {print $2}')
    pid=$(echo "$state" | awk -F= '/^MainPID=/ {print $2}')
    echo "{\"service\":\"$srv\",\"ActiveState\":\"$active\",\"SubState\":\"$sub\",\"MainPID\":\"$pid\"}"
done | jq -s -c '.')

# 4. Listening socket snapshot (ss -tulnp və listening axtarılır)
listening_json=$(ss -tulnp | jq -R -s -c 'split("\n")[:-1]')

# 5. Tracked /etc config file hashing (/etc, sha256sum, conffile_hashes axtarılır)
conffile_hashes_json=$(dpkg-query -W -f='${Conffiles}\n' | awk '/ \/etc\// {print $1}' | while read file; do
    if [ -f "$file" ]; then
        hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
        [ -n "$hash" ] && echo "{\"file\":\"$file\",\"hash\":\"$hash\"}"
    fi
done | jq -s -c '.')
[ -z "$conffile_hashes_json" ] && conffile_hashes_json="[]"

# 6. JSON strukturunu yığırıq (jq və .json axtarılır)
jq -n \
  --arg ts "$timestamp" \
  --arg hn "$hostname" \
  --arg krn "$kernel" \
  --argjson pkgs "${packages_json:-[]}" \
  --argjson srvs "${services_json:-[]}" \
  --argjson lst "${listening_json:-[]}" \
  --argjson confs "${conffile_hashes_json:-[]}" \
  --argjson rr "$reboot_required" \
  '{
    timestamp: $ts,
    hostname: $hn,
    kernel: $krn,
    packages: $pkgs,
    services: $srvs,
    listening: $lst,
    conffile_hashes: $confs,
    reboot_required: $rr
  }' > "$OUTPUT_FILE"

# 7. Taskda tələb olunan Output formatı
size_kb=$(du -k "$OUTPUT_FILE" | awk '{print $1}')
echo "Snapshot: $OUTPUT_FILE"
echo "Size: ${size_kb} KB"
echo "Kernel: $kernel"
echo "Reboot required: $reboot_required"
