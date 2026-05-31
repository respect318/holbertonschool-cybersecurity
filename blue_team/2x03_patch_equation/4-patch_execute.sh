#!/bin/bash
export LC_NUMERIC=C

# Fayl yolları
LOCKFILE="/var/lock/meddefense-patch.lock"
PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"

# 1. Acquire an advisory lock
exec 9> "$LOCKFILE"
if ! flock -n 9; then
    echo "Failed to acquire lock."
    exit 2
fi
echo "[*] Acquiring lock /var/lock/meddefense-patch.lock...  OK"

# use trap to ensure the lock is released even on abort
trap 'rm -f "$LOCKFILE"' EXIT INT TERM

if [ ! -f "$PLAN_FILE" ]; then
    echo "Plan faylı tapılmadı."
    exit 1
fi

pkg_count=$(jq '.plan | length' "$PLAN_FILE")
echo "[*] Loading plan: $PLAN_FILE ($pkg_count entries)"

started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
plan_source_hash=$(sha256sum "$PLAN_FILE" | awk '{print $1}')

succeeded=0
failed=0
any_failed=0

> exec_tmp.jsonl

for (( i=0; i<$pkg_count; i++ )); do
    idx=$((i + 1))
    pkg=$(jq -r ".plan[$i].package" "$PLAN_FILE")
    bucket=$(jq -r ".plan[$i].bucket" "$PLAN_FILE")
    req_restart=$(jq -r ".plan[$i].requires_restart" "$PLAN_FILE")
    req_reboot=$(jq -r ".plan[$i].requires_reboot" "$PLAN_FILE")
    
    # Terminal output formatı
    printf "[%d/%d] %-21s %-13s apt-get ... " "$idx" "$pkg_count" "$pkg" "$bucket"

    # Record pre block and service states
    pre_ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo "none")

    start_time=$(date +%s.%N)
    
    # dpkg lock backoff settings
    max_wait=120
    wait_time=1
    total_waited=0
    apt_status=1
    
    while [ $total_waited -le $max_wait ]; do
        # Run noninteractive apt-get
        DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y "$pkg" > apt_out.log 2> apt_err.log
        apt_status=$?
        
        # Handle a busy dpkg lock gracefully
        if grep -q "Could not get lock" apt_err.log; then
            sleep $wait_time
            total_waited=$((total_waited + wait_time))
            wait_time=$((wait_time * 2))
            [ $wait_time -gt 30 ] && wait_time=30
        else
            break
        fi
    done

    end_time=$(date +%s.%N)
    duration_seconds=$(awk "BEGIN {printf \"%.1f\", $end_time - $start_time}")

    stdout_tail=$(tail -n 10 apt_out.log | jq -R -s -c '.')
    stderr_tail=$(tail -n 10 apt_err.log | jq -R -s -c '.')

    # Record post block and service states
    post_ver=$(dpkg-query -W -f='${Version}' "$pkg" 2>/dev/null || echo "none")
    
    status_str="failed"
    if [ $apt_status -eq 0 ]; then
        status_str="succeeded"
        ((succeeded++))
        echo "OK (${duration_seconds}s)"
    else
        ((failed++))
        any_failed=1
        echo "FAIL (${duration_seconds}s)"
    fi

    # Record entry to temp file
    jq -n -c \
        --arg p "$pkg" \
        --arg pre "$pre_ver" \
        --arg post "$post_ver" \
        --arg st "$status_str" \
        --argjson ds "$duration_seconds" \
        --argjson out "${stdout_tail:-[]}" \
        --argjson err "${stderr_tail:-[]}" \
        '{
            package: $p,
            pre: { installed_version: $pre },
            post: { installed_version: $post },
            status: $st,
            duration_seconds: $ds,
            stdout_tail: $out,
            stderr_tail: $err
        }' >> exec_tmp.jsonl

    # Try-restart
    if [ "$status_str" = "succeeded" ] && [ "$req_restart" = "true" ] && [ "$req_reboot" = "false" ]; then
        services=$(jq -r ".plan[$i].affected_services[]" "$PLAN_FILE" 2>/dev/null)
        for srv in $services; do
            if [ "$srv" != "(kernel-wide)" ]; then
                systemctl try-restart "$srv" >/dev/null 2>&1
                echo "      try-restart $srv          OK"
            fi
        done
    fi

    # Fail olarsa dövrü qırırıq (stop the loop), ancaq scripti abort etmirik
    if [ "$status_str" = "failed" ]; then
        break
    fi
done

finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -s exec_tmp.jsonl ]; then
    entries_json=$(jq -s '.' exec_tmp.jsonl)
else
    entries_json="[]"
fi
rm -f exec_tmp.jsonl apt_out.log apt_err.log

# Final JSON log
jq -n \
    --arg st "$started_at" \
    --arg fn "$finished_at" \
    --arg hn "$hostname" \
    --arg hash "$plan_source_hash" \
    --argjson ent "$entries_json" \
    '{
        started_at: $st,
        finished_at: $fn,
        hostname: $hn,
        plan_source_hash: $hash,
        entries: $ent
    }' > "$LOG_FILE"

echo "Succeeded: $succeeded  Failed: $failed"
echo "Log saved to: $LOG_FILE"

# Proper exit codes
if [ $any_failed -eq 1 ]; then
    exit 1
else
    exit 0
fi
