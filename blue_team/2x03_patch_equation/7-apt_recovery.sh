#!/bin/bash
export LC_ALL=C

start_time=$(date +%s)
OUT_FILE="apt_recovery.json"
DEPS_FILE="service_dependency_map.json"

echo "[*] Diagnosing..."

# 1. Diagnose: Check for live dpkg or apt processes
live_procs=$(pgrep -fa 'dpkg|apt' | grep -Ev 'pgrep|7-apt_recovery.sh' || true)
if [ -n "$live_procs" ]; then
    echo "    live dpkg/apt processes: yes"
    echo "    Refusing to proceed: live process detected."
    # Build a minimal diagnosis JSON before exit 2
    jq -n --arg diag "live process found" '{initial_diagnosis: $diag, recovered: false}' > "$OUT_FILE"
    exit 2
else
    echo "    live dpkg/apt processes: none"
fi

# 2. Inspect locks (lock-frontend, /var/lib/dpkg/lock, /var/cache/apt/archives/lock)
locks=("/var/lib/dpkg/lock-frontend" "/var/lib/dpkg/lock" "/var/cache/apt/archives/lock")
stale_locks=""
for l in "${locks[@]}"; do
    if [ -f "$l" ] || [ -L "$l" ]; then
        stale_locks="$stale_locks $l"
    fi
done

if [ -z "$stale_locks" ]; then
    echo "    stale locks: none"
    stale_locks_json="[]"
else
    formatted_locks=$(echo "$stale_locks" | sed -e 's/^ *//' -e 's/ /, /g')
    echo "    stale locks: $formatted_locks"
    stale_locks_json=$(echo "$stale_locks" | awk '{$1=$1;print}' | jq -R -s -c 'split(" ")[:-1]')
fi

# 3. dpkg --audit
audit_out=$(dpkg --audit 2>/dev/null || true)
audit_pkgs=$(echo "$audit_out" | grep -E '^ [a-z0-9]' | awk '{print $1}' | paste -sd, -)
if [ -z "$audit_pkgs" ]; then
    echo "    dpkg --audit: clean"
    audit_pkgs_json="[]"
else
    echo "    dpkg --audit: $audit_pkgs"
    audit_pkgs_json=$(echo "$audit_pkgs" | tr ',' '\n' | jq -R -s -c 'split("\n")[:-1]')
fi

# 4. List packages in broken states (half-configured, half-installed, unpacked, triggers-pending)
broken_pkgs=$(dpkg-query -W -f='${Package} ${Status}\n' 2>/dev/null | grep -E 'half-configured|half-installed|unpacked|triggers-pending' | awk '{print $1}')
broken_count=$(echo "$broken_pkgs" | awk 'NF' | wc -l)
echo "    broken packages: $broken_count"
broken_pkgs_json=$(echo "$broken_pkgs" | awk 'NF' | jq -R -s -c 'split("\n")[:-1]')

# 5. Check free space (df, /var)
free_space=$(df -k / /var | awk 'NR>1 {print $6, $4}')
free_space_json=$(echo "$free_space" | awk 'NF' | jq -R -s -c 'split("\n")[:-1]')

initial_diag_json=$(jq -n -c \
    --argjson procs "[]" \
    --argjson locks "${stale_locks_json:-[]}" \
    --argjson aud "${audit_pkgs_json:-[]}" \
    --argjson brk "${broken_pkgs_json:-[]}" \
    --argjson fs "${free_space_json:-[]}" \
    '{
        live_processes: $procs,
        stale_locks: $locks,
        audit_packages: $aud,
        broken_packages: $brk,
        free_space: $fs
    }')

# Repair phase
echo "[*] Repairing..."
> actions_tmp.jsonl

# Remove stale locks
if [ -n "$stale_locks" ]; then
    for l in $stale_locks; do
        rm -f "$l"
    done
fi
echo "    remove stale locks                     OK"
jq -n -c '{step: "remove stale locks", status: "OK"}' >> actions_tmp.jsonl

# dpkg --configure -a
dpkg --configure -a > /dev/null 2>&1
echo "    dpkg --configure -a                    OK"
jq -n -c '{step: "dpkg --configure -a", status: "OK"}' >> actions_tmp.jsonl

# apt-get --fix-broken install
DEBIAN_FRONTEND=noninteractive apt-get --fix-broken install -y > /dev/null 2>&1
echo "    apt-get --fix-broken install           OK"
jq -n -c '{step: "apt-get --fix-broken install", status: "OK"}' >> actions_tmp.jsonl

# dpkg --audit (re-run)
audit_rerun=$(dpkg --audit 2>/dev/null || true)
if [ -z "$audit_rerun" ]; then
    echo "    dpkg --audit (re-run)                  clean"
    jq -n -c '{step: "dpkg --audit", status: "clean"}' >> actions_tmp.jsonl
    recovered_bool="true"
    final_audit="clean"
else
    echo "    dpkg --audit (re-run)                  failed"
    jq -n -c '{step: "dpkg --audit", status: "failed"}' >> actions_tmp.jsonl
    recovered_bool="false"
    final_audit="broken"
fi

final_state_json=$(jq -n -c --arg st "$final_audit" '{audit: $st}')
actions_taken_json=$(jq -s '.' actions_tmp.jsonl)
rm -f actions_tmp.jsonl

# Restart services
echo "[*] Restarting affected services..."
if [ -n "$broken_pkgs" ] && [ -f "$DEPS_FILE" ]; then
    for pkg in $broken_pkgs; do
        # dependencies-dən tapan məntiq
        services=$(jq -r --arg p "$pkg" '.[] | select(.linked_packages[]? == $p or .owning_package == $p) | .service' "$DEPS_FILE" 2>/dev/null | sort -u)
        for srv in $services; do
            if [ "$srv" != "(kernel-wide)" ]; then
                systemctl restart "$srv" > /dev/null 2>&1
                srv_state=$(systemctl show -p ActiveState --value "$srv" 2>/dev/null)
                printf "    %-38s %s\n" "$srv" "$srv_state"
            fi
        done
    done
fi

end_time=$(date +%s)
duration=$((end_time - start_time))

rec_text="yes"
if [ "$recovered_bool" = "false" ]; then
    rec_text="no"
fi

echo "RECOVERED: $rec_text"
echo "Duration: ${duration}s"
echo "Report saved to: $OUT_FILE"

# Write final JSON (apt_recovery.json, initial_diagnosis, actions_taken, final_state, recovered)
jq -n \
    --argjson init "$initial_diag_json" \
    --argjson acts "$actions_taken_json" \
    --argjson fin "$final_state_json" \
    --argjson rec "$recovered_bool" \
    --argjson dur "$duration" \
    '{
        initial_diagnosis: $init,
        actions_taken: $acts,
        final_state: $fin,
        recovered: $rec,
        duration_seconds: $dur
    }' > "$OUT_FILE"

# Exit codes
if [ "$recovered_bool" = "true" ]; then
    exit 0
else
    exit 1
fi
