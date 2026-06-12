#!/bin/bash
# 7-apt_recovery.sh - Broken Upgrade Recovery Script
# Diagnoses and repairs a broken apt/dpkg state

RECOVERY_FILE="apt_recovery.json"
SERVICE_MAP="service_dependency_map.json"

T_START=$(date +%s)
STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
ACTIONS_JSON="[]"
RECOVERED=false

# ── Helper: add action to log ─────────────────────────────────────────────────
add_action() {
    local action="$1"
    local result="$2"
    local detail="${3:-}"
    ACTIONS_JSON=$(echo "${ACTIONS_JSON}" | jq \
        --arg a "${action}" \
        --arg r "${result}" \
        --arg d "${detail}" \
        '. + [{"action": $a, "result": $r, "detail": $d}]')
}

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 1 — DIAGNOSE BEFORE CHANGING ANYTHING
# ══════════════════════════════════════════════════════════════════════════════
echo "[*] Diagnosing..."

# ── Check for live dpkg or apt processes with pgrep -fa ──────────────────────
LIVE_PROCS=$(pgrep -fa "dpkg|apt" 2>/dev/null || true)
if [[ -n "${LIVE_PROCS}" ]]; then
    echo "    live dpkg/apt processes detected:"
    echo "${LIVE_PROCS}" | sed 's/^/      /'
else
    echo "    live dpkg/apt processes: none"
fi

# ── Inspect lock files ────────────────────────────────────────────────────────
STALE_LOCKS=()
LOCK_FRONTEND="/var/lib/dpkg/lock-frontend"
LOCK_DPKG="/var/lib/dpkg/lock"
LOCK_APT="/var/cache/apt/archives/lock"

for LOCKF in "${LOCK_FRONTEND}" "${LOCK_DPKG}" "${LOCK_APT}"; do
    if [[ -f "${LOCKF}" ]]; then
        if ! fuser "${LOCKF}" >/dev/null 2>&1; then
            STALE_LOCKS+=("${LOCKF}")
        fi
    fi
done

if [[ ${#STALE_LOCKS[@]} -gt 0 ]]; then
    echo "    stale locks: $(IFS=', '; echo "${STALE_LOCKS[*]}")"
else
    echo "    stale locks: none"
fi

# ── Run dpkg --audit and parse output ────────────────────────────────────────
AUDIT_OUT=$(dpkg --audit 2>/dev/null || true)
echo "    dpkg --audit: ${AUDIT_OUT:-clean}"

# ── List packages in broken states via dpkg ───────────────────────────────────
# half-configured, half-installed, unpacked, triggers-pending
BROKEN_PKGS=$(dpkg -l 2>/dev/null | awk '
    /^[uhi]F/ || /^[uhi]H/ || /^[uhi]W/ || /^[uhi]T/ {print $2}
    /^iF/ {print $2}
    /^hH/ {print $2}
' | sort -u || true)

# Also catch via dpkg --get-selections
HALF_CONF=$(dpkg --get-selections 2>/dev/null | grep -E \
    "half-configured|half-installed|unpacked|triggers-pending" | awk '{print $1}' || true)

ALL_BROKEN=$(printf '%s\n%s\n' "${BROKEN_PKGS}" "${HALF_CONF}" | sort -u | grep -v '^$' || true)
BROKEN_COUNT=$(echo "${ALL_BROKEN}" | grep -c . || echo 0)

echo "    broken packages: ${BROKEN_COUNT}"
[[ -n "${ALL_BROKEN}" ]] && echo "${ALL_BROKEN}" | sed 's/^/      /'

# ── Check free space on / and /var ───────────────────────────────────────────
FREE_ROOT=$(df -m / 2>/dev/null | awk 'NR==2 {print $4}')
FREE_VAR=$(df -m /var 2>/dev/null | awk 'NR==2 {print $4}')
echo "    free space  /: ${FREE_ROOT}MB   /var: ${FREE_VAR}MB"

# ── Build initial_diagnosis block ─────────────────────────────────────────────
DIAG_LIVE="${LIVE_PROCS:-none}"
DIAG_LOCKS=$(printf '%s\n' "${STALE_LOCKS[@]+"${STALE_LOCKS[@]}"}" | jq -R . | jq -sc .)
DIAG_BROKEN=$(echo "${ALL_BROKEN}" | grep -v '^$' | jq -R . | jq -sc . || echo '[]')

INITIAL_DIAGNOSIS=$(jq -n \
    --arg live        "${DIAG_LIVE}" \
    --argjson locks   "${DIAG_LOCKS}" \
    --arg audit       "${AUDIT_OUT:-clean}" \
    --argjson broken  "${DIAG_BROKEN}" \
    --arg free_root   "${FREE_ROOT}MB" \
    --arg free_var    "${FREE_VAR}MB" \
    '{
        "live_processes":  $live,
        "stale_locks":     $locks,
        "dpkg_audit":      $audit,
        "broken_packages": $broken,
        "free_space_root": $free_root,
        "free_space_var":  $free_var
    }')

# ── Refuse if live process detected ───────────────────────────────────────────
if [[ -n "${LIVE_PROCS}" ]]; then
    echo ""
    echo "[!] Live dpkg/apt process detected. Cannot proceed safely."
    echo "    Diagnose complete. Refusing to repair while live process is running."

    T_END=$(date +%s)
    DURATION=$((T_END - T_START))

    jq -n \
        --argjson diag     "${INITIAL_DIAGNOSIS}" \
        --argjson actions  "${ACTIONS_JSON}" \
        --arg     final    "aborted: live process detected" \
        --argjson recovered false \
        --argjson duration "${DURATION}" \
        '{
            "initial_diagnosis": $diag,
            "actions_taken":     $actions,
            "final_state":       $final,
            "recovered":         $recovered,
            "duration_seconds":  $duration
        }' > "${RECOVERY_FILE}"

    echo "Report saved to: ${RECOVERY_FILE}"
    exit 2
fi

# ══════════════════════════════════════════════════════════════════════════════
# PHASE 2 — REPAIR IN STRICT ORDER
# ══════════════════════════════════════════════════════════════════════════════
echo "[*] Repairing..."

# ── Step 1: Remove only stale lock files ─────────────────────────────────────
for LOCKF in "${STALE_LOCKS[@]+"${STALE_LOCKS[@]}"}"; do
    if ! fuser "${LOCKF}" >/dev/null 2>&1; then
        rm -f "${LOCKF}"
        printf "    remove stale lock %-40s OK\n" "${LOCKF}"
        add_action "remove stale lock ${LOCKF}" "OK" ""
    else
        printf "    remove stale lock %-40s SKIPPED (still held)\n" "${LOCKF}"
        add_action "remove stale lock ${LOCKF}" "SKIPPED" "lock still held by process"
    fi
done

# ── Step 2: dpkg --configure -a ──────────────────────────────────────────────
printf "    %-45s" "dpkg --configure -a"
CONFIGURE_OUT=$(DEBIAN_FRONTEND=noninteractive dpkg --configure -a 2>&1)
CONFIGURE_RC=$?
if [[ ${CONFIGURE_RC} -eq 0 ]]; then
    echo "OK"
    add_action "dpkg --configure -a" "OK" "${CONFIGURE_OUT}"
else
    echo "FAILED (exit ${CONFIGURE_RC})"
    add_action "dpkg --configure -a" "FAILED" "${CONFIGURE_OUT}"
fi

# ── Step 3: apt-get --fix-broken install -y with noninteractive ──────────────
printf "    %-45s" "apt-get --fix-broken install"
FIXBROKEN_OUT=$(DEBIAN_FRONTEND=noninteractive apt-get --fix-broken install -y 2>&1)
FIXBROKEN_RC=$?
if [[ ${FIXBROKEN_RC} -eq 0 ]]; then
    echo "OK"
    add_action "apt-get --fix-broken install -y" "OK" "$(echo "${FIXBROKEN_OUT}" | tail -5)"
else
    echo "FAILED (exit ${FIXBROKEN_RC})"
    add_action "apt-get --fix-broken install -y" "FAILED" "$(echo "${FIXBROKEN_OUT}" | tail -5)"
fi

# ── Step 4: Re-run dpkg --audit and confirm empty ────────────────────────────
printf "    %-45s" "dpkg --audit (re-run)"
AUDIT_FINAL=$(dpkg --audit 2>/dev/null || true)
if [[ -z "${AUDIT_FINAL}" ]]; then
    echo "clean"
    add_action "dpkg --audit re-run" "clean" ""
    RECOVERED=true
else
    echo "RESIDUAL BROKEN"
    add_action "dpkg --audit re-run" "residual broken" "${AUDIT_FINAL}"
    RECOVERED=false
fi

# ── Step 5: Restart services listed in service_dependency_map.json ───────────
echo "[*] Restarting affected services..."
if [[ -f "${SERVICE_MAP}" ]]; then
    SVC_COUNT=$(jq 'length' "${SERVICE_MAP}" 2>/dev/null || echo 0)
    for idx in $(seq 0 $((SVC_COUNT - 1))); do
        SVC_PKG=$(jq -r ".[${idx}].package // empty" "${SERVICE_MAP}" 2>/dev/null)
        SVC_NAME=$(jq -r ".[${idx}].service // empty" "${SERVICE_MAP}" 2>/dev/null)
        [[ -z "${SVC_NAME}" ]] && continue

        # Only restart if package was in the broken set
        if echo "${ALL_BROKEN}" | grep -qw "${SVC_PKG}"; then
            RESTART_RC=0
            systemctl try-restart "${SVC_NAME}" 2>/dev/null || RESTART_RC=$?
            STATE=$(systemctl is-active "${SVC_NAME}" 2>/dev/null || echo "unknown")
            printf "    %-40s %s\n" "${SVC_NAME}" "${STATE}"
            add_action "systemctl try-restart ${SVC_NAME}" "${STATE}" "package: ${SVC_PKG}"
        fi
    done
else
    # No service map — try restarting services for known broken packages
    for PKG in ${ALL_BROKEN}; do
        SVC="${PKG}.service"
        if systemctl list-units --all "${SVC}" 2>/dev/null | grep -q "${SVC}"; then
            RESTART_RC=0
            systemctl try-restart "${SVC}" 2>/dev/null || RESTART_RC=$?
            STATE=$(systemctl is-active "${SVC}" 2>/dev/null || echo "unknown")
            printf "    %-40s %s\n" "${SVC}" "${STATE}"
            add_action "systemctl try-restart ${SVC}" "${STATE}" "package: ${PKG}"
        fi
    done
fi

# ══════════════════════════════════════════════════════════════════════════════
# FINALIZATION
# ══════════════════════════════════════════════════════════════════════════════
T_END=$(date +%s)
DURATION=$((T_END - T_START))
FINISHED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

FINAL_STATE="clean"
[[ "${RECOVERED}" == "false" ]] && FINAL_STATE="residual broken packages"

echo ""
echo "RECOVERED: $(if [[ "${RECOVERED}" == "true" ]]; then echo yes; else echo no; fi)"
echo "Duration: ${DURATION}s"

# ── Emit apt_recovery.json ────────────────────────────────────────────────────
jq -n \
    --argjson diag       "${INITIAL_DIAGNOSIS}" \
    --argjson actions    "${ACTIONS_JSON}" \
    --arg     final      "${FINAL_STATE}" \
    --argjson recovered  "$(if [[ "${RECOVERED}" == "true" ]]; then echo true; else echo false; fi)" \
    --argjson duration   "${DURATION}" \
    --arg     started    "${STARTED_AT}" \
    --arg     finished   "${FINISHED_AT}" \
    '{
        "initial_diagnosis": $diag,
        "actions_taken":     $actions,
        "final_state":       $final,
        "recovered":         $recovered,
        "duration_seconds":  $duration,
        "started_at":        $started,
        "finished_at":       $finished
    }' > "${RECOVERY_FILE}"

echo "Report saved to: ${RECOVERY_FILE}"

if [[ "${RECOVERED}" == "true" ]]; then
    exit 0
else
    exit 1
fi
