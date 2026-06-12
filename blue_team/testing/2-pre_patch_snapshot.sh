#!/bin/bash
# 2-pre_patch_snapshot.sh
# Captures full system state before any patch operation.

OUTPUT_FILE="pre_patch_state.json"
# jq is used when available for JSON validation of .json output files

# ── Collect data ──────────────────────────────────────────────────────────────

TIMESTAMP=$(date --iso-8601=seconds 2>/dev/null || date -u +"%Y-%m-%dT%H:%M:%S+00:00")
HOSTNAME=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "unknown")
KERNEL=$(uname -r 2>/dev/null || echo "unknown")

# reboot_required: check /var/run/reboot-required presence
REBOOT_REQUIRED=false
[[ -f /var/run/reboot-required ]] && REBOOT_REQUIRED=true

# ── packages: record package versions via dpkg-query ─────────────────────────
echo "[*] Collecting package versions (dpkg-query)..."
PACKAGES_JSON=$(dpkg-query -W -f='{"name":"${Package}","version":"${Version}","status":"${db:Status-Abbrev}"},\n' 2>/dev/null \
    | sed 's/,$//' \
    | python3 -c "
import sys, json
lines = sys.stdin.read().strip()
lines = lines.rstrip(',')
try:
    arr = json.loads('[' + lines + ']')
    # Build dict: name -> version (for 9-rollback.sh compatibility)
    d = {p['name']: p['version'] for p in arr if p.get('name')}
    print(json.dumps(d))
except Exception as e:
    print('{}')
" 2>/dev/null || echo "{}")

PKG_COUNT=$(echo "$PACKAGES_JSON" | python3 -c "import json,sys; d=json.load(sys.stdin); print(len(d))" 2>/dev/null || echo 0)

# ── services: ActiveState, SubState, MainPID for every active systemd service ─
echo "[*] Collecting service states (systemctl show)..."
SERVICES_JSON=$(systemctl list-units --type=service --state=active --no-legend --plain 2>/dev/null \
    | awk '{print $1}' \
    | while read -r svc; do
        [[ -z "$svc" ]] && continue
        info=$(systemctl show "$svc" --property=ActiveState,SubState,MainPID 2>/dev/null)
        active=$(echo "$info" | grep '^ActiveState=' | cut -d= -f2)
        sub=$(echo   "$info" | grep '^SubState='    | cut -d= -f2)
        pid=$(echo   "$info" | grep '^MainPID='     | cut -d= -f2)
        printf '{"service":"%s","ActiveState":"%s","SubState":"%s","MainPID":%s},\n' \
            "$svc" "$active" "$sub" "${pid:-0}"
    done \
    | python3 -c "
import sys, json
lines = sys.stdin.read().strip().rstrip(',')
try:
    arr = json.loads('[' + lines + ']')
    print(json.dumps(arr))
except:
    print('[]')
" 2>/dev/null || echo "[]")

SVC_COUNT=$(echo "$SERVICES_JSON" | python3 -c "import json,sys; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)

# ── listening: ss -tulnp ──────────────────────────────────────────────────────
echo "[*] Collecting listening sockets (ss -tulnp)..."
LISTENING_JSON=$(ss -tulnp 2>/dev/null \
    | tail -n +2 \
    | python3 -c "
import sys, json, re
rows = []
for line in sys.stdin:
    parts = line.split()
    if len(parts) < 5: continue
    rows.append({
        'netid':   parts[0] if len(parts) > 0 else '',
        'state':   parts[1] if len(parts) > 1 else '',
        'local':   parts[4] if len(parts) > 4 else '',
        'process': parts[-1] if len(parts) > 5 else ''
    })
print(json.dumps(rows))
" 2>/dev/null || echo "[]")

# ── conffile_hashes: SHA-256 of /etc files tracked by dpkg ───────────────────
echo "[*] Hashing tracked /etc config files (sha256sum)..."
CONFFILE_HASHES_JSON=$(dpkg-query -W -f='${Conffiles}\n' 2>/dev/null \
    | grep '^ /etc/' \
    | awk '{print $1}' \
    | while read -r f; do
        [[ -f "$f" ]] || continue
        hash=$(sha256sum "$f" 2>/dev/null | awk '{print $1}')
        [[ -n "$hash" ]] && printf '"%s":"%s",' "$f" "$hash"
    done \
    | python3 -c "
import sys, json
raw = sys.stdin.read().strip().rstrip(',')
try:
    d = json.loads('{' + raw + '}')
    print(json.dumps(d))
except:
    print('{}')
" 2>/dev/null || echo "{}")

# ── Emit pre_patch_state.json ─────────────────────────────────────────────────
echo "[*] Writing pre_patch_state.json..."

python3 - << PYEOF
import json

timestamp    = """$TIMESTAMP"""
hostname     = """$HOSTNAME"""
kernel       = """$KERNEL"""
reboot_req   = $REBOOT_REQUIRED

packages_raw     = """$PACKAGES_JSON"""
services_raw     = """$SERVICES_JSON"""
listening_raw    = """$LISTENING_JSON"""
confhashes_raw   = """$CONFFILE_HASHES_JSON"""

try: packages     = json.loads(packages_raw)
except: packages  = {}
try: services     = json.loads(services_raw)
except: services  = []
try: listening    = json.loads(listening_raw)
except: listening = []
try: conffile_hashes = json.loads(confhashes_raw)
except: conffile_hashes = {}

doc = {
    "timestamp":       timestamp,
    "hostname":        hostname,
    "kernel":          kernel,
    "reboot_required": reboot_req,
    "packages":        packages,
    "services":        services,
    "listening":       listening,
    "conffile_hashes": conffile_hashes
}

with open("$OUTPUT_FILE", "w") as f:
    json.dump(doc, f, indent=2)

print("Snapshot: $OUTPUT_FILE")
import os
size_kb = os.path.getsize("$OUTPUT_FILE") // 1024
print(f"Size: {size_kb} KB")
print(f"Kernel: {kernel}")
print(f"Reboot required: {str(reboot_req).lower()}")
PYEOF
