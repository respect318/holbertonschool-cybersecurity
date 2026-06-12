#!/bin/bash
# 12-change_log.sh
# Produces a canonical, structured change log for every patching activity.
# Parses apt history logs, groups change events, enriches with maintenance window,
# execution log, and CVE resolution data, then emits patch_change_log.json.

set -euo pipefail

OUTPUT_FILE="patch_change_log.json"
EXEC_LOG="patch_execution_log.json"
VULN_INV="vulnerability_inventory.json"
MAINTENANCE_SCRIPT="./11-maintenance_window.sh"

# Collect all apt history log files (including rotated .gz files)
APT_LOG_FILES=()
for f in /var/log/apt/history.log /var/log/apt/history.log.*; do
    [[ -e "$f" ]] && APT_LOG_FILES+=("$f")
done

# Parse /var/log/apt/history.log* - extract every apt transaction
# Fields: Start-Date, Commandline, Requested-By, Upgrade, Install, Remove
parse_apt_history() {
    local tmpfile
    tmpfile=$(mktemp)

    for f in "${APT_LOG_FILES[@]}"; do
        if [[ "$f" == *.gz ]]; then
            zcat "$f"
        else
            cat "$f"
        fi
    done | awk '
    BEGIN {
        start_date=""; commandline=""; requested_by="";
        upgrade=""; install_pkg=""; remove_pkg="";
    }
    /^Start-Date:/ {
        start_date = substr($0, index($0,$2))
    }
    /^Commandline:/ {
        commandline = substr($0, index($0,$2))
    }
    /^Requested-By:/ {
        requested_by = substr($0, index($0,$2))
    }
    /^Upgrade:/ {
        upgrade = substr($0, index($0,$2))
    }
    /^Install:/ {
        install_pkg = substr($0, index($0,$2))
    }
    /^Remove:/ {
        remove_pkg = substr($0, index($0,$2))
    }
    /^End-Date:/ {
        if (start_date != "") {
            print start_date "|" commandline "|" requested_by "|" upgrade "|" install_pkg "|" remove_pkg
        }
        start_date=""; commandline=""; requested_by="";
        upgrade=""; install_pkg=""; remove_pkg="";
    }
    ' > "$tmpfile"

    echo "$tmpfile"
}

# Convert date string from apt history to epoch seconds
date_to_epoch() {
    local d="$1"
    date -d "$d" +%s 2>/dev/null || echo "0"
}

# Count packages in a field (comma-separated list)
count_packages() {
    local field="$1"
    if [[ -z "$field" ]]; then
        echo 0
        return
    fi
    # Each package entry is separated by ", " and has format "name:arch (ver)"
    echo "$field" | tr ',' '\n' | grep -c '\S' || echo 0
}

# Check maintenance window for a given timestamp
check_maintenance_window() {
    local ts="$1"
    if [[ -x "$MAINTENANCE_SCRIPT" ]]; then
        local result
        result=$("$MAINTENANCE_SCRIPT" --report "$ts" 2>/dev/null || echo "unknown")
        echo "$result"
    else
        echo "unknown"
    fi
}

# Get linked execution log if timestamps overlap
get_linked_execution_log() {
    local event_start_epoch="$1"
    local event_end_epoch="$2"

    if [[ ! -f "$EXEC_LOG" ]]; then
        echo ""
        return
    fi

    # Check if patch_execution_log.json timestamps overlap with the change event
    local exec_start exec_end
    exec_start=$(jq -r '.started // .start_time // .period_start // empty' "$EXEC_LOG" 2>/dev/null | head -1)
    exec_end=$(jq -r '.ended // .end_time // .period_end // empty' "$EXEC_LOG" 2>/dev/null | head -1)

    if [[ -z "$exec_start" ]]; then
        echo ""
        return
    fi

    local exec_start_epoch exec_end_epoch
    exec_start_epoch=$(date_to_epoch "$exec_start")
    exec_end_epoch=$(date_to_epoch "${exec_end:-$exec_start}")

    # Overlap check
    if [[ "$event_start_epoch" -le "$exec_end_epoch" && "$event_end_epoch" -ge "$exec_start_epoch" ]]; then
        echo "$EXEC_LOG"
    else
        echo ""
    fi
}

# Get CVEs resolved by cross-referencing vulnerability_inventory.json
get_cves_resolved() {
    local event_start_epoch="$1"

    if [[ ! -f "$VULN_INV" ]]; then
        echo "[]"
        return
    fi

    # Extract CVEs that were resolved (patched) around or before this event
    # cves_resolved: entries in vulnerability_inventory.json that are no longer present after the event
    local cves
    cves=$(jq -r '[
        .vulnerabilities[]?
        | select(.status == "patched" or .status == "resolved" or .status == "fixed")
        | .cve_id // .id // empty
    ] // []' "$VULN_INV" 2>/dev/null || echo "[]")

    echo "$cves"
}

# ── Main logic ─────────────────────────────────────────────────────────────────

tmpfile=$(parse_apt_history)

# Group transactions into "change events"
# Transactions within 15 minutes of each other are one change event
declare -a events_json=()
declare -a current_group_dates=()
declare -a current_group_lines=()
prev_epoch=0
group_start=""
group_end=""
group_user=""
group_cmd=""
group_packages=0

flush_group() {
    if [[ "${#current_group_lines[@]}" -eq 0 ]]; then
        return
    fi

    local started="$group_start"
    local ended="$group_end"
    local user="$group_user"
    local pkg_count="$group_packages"
    local started_epoch
    started_epoch=$(date_to_epoch "$started")
    local ended_epoch
    ended_epoch=$(date_to_epoch "$ended")

    # Check maintenance window
    local within_window
    within_window=$(check_maintenance_window "$started")

    # Linked execution log
    local linked_exec
    linked_exec=$(get_linked_execution_log "$started_epoch" "$ended_epoch")

    # CVEs resolved
    local cves_resolved_arr
    cves_resolved_arr=$(get_cves_resolved "$started_epoch")

    # Build JSON for this change event
    local event_json
    event_json=$(jq -n \
        --arg started "$started" \
        --arg ended "$ended" \
        --arg user "$user" \
        --arg within_window "$within_window" \
        --argjson packages "$pkg_count" \
        --arg linked_exec "$linked_exec" \
        --argjson cves_resolved "${cves_resolved_arr:-[]}" \
        '{
            started: $started,
            ended: $ended,
            user: $user,
            within_window: $within_window,
            packages: $packages,
            linked_execution_log: (if $linked_exec == "" then null else $linked_exec end),
            cves_resolved: $cves_resolved
        }')

    events_json+=("$event_json")

    # Reset group
    current_group_lines=()
    current_group_dates=()
    prev_epoch=0
    group_start=""
    group_end=""
    group_user=""
    group_cmd=""
    group_packages=0
}

# 15-minute threshold in seconds (used for grouping change events)
WINDOW_SECONDS=$((15 * 60))

while IFS='|' read -r start_date commandline requested_by upgrade install_pkg remove_pkg; do
    [[ -z "$start_date" ]] && continue

    current_epoch=$(date_to_epoch "$start_date")
    [[ "$current_epoch" -eq 0 ]] && continue

    # Count packages in this transaction
    local_pkg_count=0
    for field in "$upgrade" "$install_pkg" "$remove_pkg"; do
        if [[ -n "$field" ]]; then
            c=$(count_packages "$field")
            local_pkg_count=$((local_pkg_count + c))
        fi
    done

    # Extract user from Requested-By field
    local_user=""
    if [[ -n "$requested_by" ]]; then
        local_user=$(echo "$requested_by" | awk '{print $1}')
    fi
    [[ -z "$local_user" ]] && local_user="root"

    # Check if this transaction should start a new change event
    if [[ "$prev_epoch" -eq 0 ]]; then
        # First transaction
        group_start="$start_date"
        group_end="$start_date"
        group_user="$local_user"
        group_cmd="$commandline"
        group_packages=$local_pkg_count
        prev_epoch=$current_epoch
        current_group_lines=("$start_date")
    else
        diff=$(( current_epoch - prev_epoch ))
        if [[ "$diff" -le "$WINDOW_SECONDS" ]]; then
            # Within 15 minutes — same change event
            group_end="$start_date"
            group_packages=$((group_packages + local_pkg_count))
            current_group_lines+=("$start_date")
            # Keep first user unless empty
            [[ -z "$group_user" || "$group_user" == "root" ]] && group_user="$local_user"
        else
            # More than 15 minutes gap — flush current group, start new one
            flush_group
            group_start="$start_date"
            group_end="$start_date"
            group_user="$local_user"
            group_cmd="$commandline"
            group_packages=$local_pkg_count
            prev_epoch=$current_epoch
            current_group_lines=("$start_date")
        fi
    fi
    prev_epoch=$current_epoch

done < "$tmpfile"

# Flush last group
flush_group

rm -f "$tmpfile"

# ── Build final patch_change_log.json ─────────────────────────────────────────

total_events=${#events_json[@]}
inside_window=0
outside_window=0
total_cves=0

# Determine period_start and period_end
period_start=""
period_end=""

events_array="[]"
for ev in "${events_json[@]}"; do
    events_array=$(echo "$events_array" | jq --argjson e "$ev" '. + [$e]')

    # Count inside/outside
    ww=$(echo "$ev" | jq -r '.within_window')
    if [[ "$ww" == "inside" ]]; then
        inside_window=$((inside_window + 1))
    else
        outside_window=$((outside_window + 1))
    fi

    # Count CVEs
    cv=$(echo "$ev" | jq '.cves_resolved | length')
    total_cves=$((total_cves + cv))
done

# Get period boundaries from first and last events
if [[ "$total_events" -gt 0 ]]; then
    period_start=$(echo "${events_json[0]}" | jq -r '.started')
    period_end=$(echo "${events_json[$((total_events - 1))]}" | jq -r '.ended')
fi

# If no events found, use current date range as period
if [[ -z "$period_start" ]]; then
    period_start=$(date -d "30 days ago" --iso-8601=seconds)
    period_end=$(date --iso-8601=seconds)
fi

# Emit patch_change_log.json — idempotent (deterministic from same input)
jq -n \
    --arg period_start "$period_start" \
    --arg period_end "$period_end" \
    --argjson events "$events_array" \
    --argjson total_events "$total_events" \
    --argjson inside_window "$inside_window" \
    --argjson outside_window "$outside_window" \
    --argjson cves_resolved "$total_cves" \
    '{
        period_start: $period_start,
        period_end: $period_end,
        events: $events,
        summary: {
            total_events: $total_events,
            inside_window: $inside_window,
            outside_window: $outside_window,
            cves_resolved: $cves_resolved
        }
    }' > "$OUTPUT_FILE"

echo "[+] patch_change_log.json generated with $total_events change event(s)."
echo "    inside_window=$inside_window  outside_window=$outside_window  cves_resolved=$total_cves"
