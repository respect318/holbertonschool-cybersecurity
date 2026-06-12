#!/bin/bash
# 4-patch_execute.sh - Safe Patch Execution Script
# Consumes patch_plan.json and executes patches with full logging

LOCK_FILE="/var/lock/meddefense-patch.lock"
PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"
LOCK_FD=9
DPKG_LOCK_TIMEOUT=120

STARTED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME_VAL=$(hostname)

# ── Acquire advisory lock ──────────────────────────────────────────────────────
echo "[*] Acquiring lock ${LOCK_FILE}..."
exec 9>"${LOCK_FILE}"
if ! flock -n ${LOCK_FD}; then
    echo "[-] Could not acquire lock. Another instance may be running." >&2
    exit 2
fi
echo "    OK"

# ── Trap: release lock on any exit ────────────────────────────────────────────
cleanup() {
    flock -u ${LOCK_FD} 2>/dev/null
    exec 9>&-
}
trap cleanup EXIT INT TERM

# ── If patch_plan.json missing, create a demo one ─────────────────────────────
if [[ ! -f "${PLAN_FILE}" ]]; then
    echo "[*] patch_plan.json not found, generating demo plan..."
    cat > "${PLAN_FILE}" << 'DEMOPLAN'
[
  {
    "package": "curl",
    "priority": "urgent",
    "affected_services": [],
    "requires_restart": false
  },
  {
    "package": "tzdata",
    "priority": "scheduled",
    "affected_services": [],
    "requires_restart": false
  }
]
DEMOPLAN
fi

# ── Load plan ─────────────────────────────────────────────────────────────────
PLAN_SOURCE_HASH=$(sha256sum "${PLAN_FILE}" | awk '{print $1}')
TOTAL=$(jq 'length' "${PLAN_FILE}")
echo "[*] Loading plan: ${PLAN_FILE} (${TOTAL} entries)"

# ── Helper: get installed version ─────────────────────────────────────────────
get_installed_version() {
    local pkg="$1"
    dpkg-query -W -f='${Version}' "${pkg}" 2>/dev/null || echo "not-installed"
}

# ── Helper: get service states ────────────────────────────────────────────────
# Records service states for linked services
get_service_states() {
    local services_json="$1"
    local states="{}"
    local svc_count
    svc_count=$(echo "${services_json}" | jq 'length')
    for i in $(seq 0 $((svc_count - 1))); do
        local svc
        svc=$(echo "${services_json}" | jq -r ".[${i}]")
        local state
        state=$(systemctl is-active "${svc}" 2>/dev/null || echo "unknown")
        states=$(echo "${states}" | jq --arg s "${svc}" --arg v "${state}" '. + {($s): $v}')
    done
    echo "${states}"
}

# ── Helper: dpkg lock backoff ─────────────────────────────────────────────────
wait_for_dpkg_lock() {
    local elapsed=0
    local wait=1
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 || \
          fuser /var/lib/apt/lists/lock >/dev/null 2>&1; do
        if [[ ${elapsed} -ge ${DPKG_LOCK_TIMEOUT} ]]; then
            echo "TIMEOUT"
            return 1
        fi
        echo "    [!] E: Could not get lock — backoff ${wait}s (elapsed ${elapsed}/${DPKG_LOCK_TIMEOUT}s)..." >&2
        sleep "${wait}"
        elapsed=$((elapsed + wait))
        wait=$((wait * 2))
        [[ ${wait} -gt 30 ]] && wait=30
    done
    return 0
}

# ── Main loop ─────────────────────────────────────────────────────────────────
ENTRIES_JSON="[]"
SUCCEEDED=0
FAILED=0
ANY_FAILED=0

for i in $(seq 0 $((TOTAL - 1))); do
    ENTRY=$(jq ".[${i}]" "${PLAN_FILE}")
    PKG=$(echo "${ENTRY}" | jq -r '.package')
    PRIORITY=$(echo "${ENTRY}" | jq -r '.priority // "unknown"')
    SERVICES=$(echo "${ENTRY}" | jq -c '.affected_services // []')
    REQUIRES_RESTART=$(echo "${ENTRY}" | jq -r '.requires_restart // false')

    IDX=$((i + 1))
    printf "[%d/%d] %-25s %-12s apt-get ... " "${IDX}" "${TOTAL}" "${PKG}" "${PRIORITY}"

    # ── pre block: installed version + service states for linked services ─────
    PRE_VERSION=$(get_installed_version "${PKG}")
    PRE_STATES=$(get_service_states "${SERVICES}")
    PRE_BLOCK=$(jq -n \
        --arg ver "${PRE_VERSION}" \
        --argjson svc "${PRE_STATES}" \
        '{"installed_version": $ver, "service_states": $svc}')

    ENTRY_STATUS="success"
    APT_EXIT=0
    APT_STDOUT=""
    APT_STDERR=""
    RESTART_RESULTS="{}"
    DURATION="0.0"

    # ── dpkg lock check with backoff ──────────────────────────────────────────
    LOCK_ERR=""
    if ! wait_for_dpkg_lock; then
        LOCK_ERR="E: Could not get lock — dpkg lock held over ${DPKG_LOCK_TIMEOUT}s, backoff exhausted"
    fi

    if [[ -n "${LOCK_ERR}" ]]; then
        ENTRY_STATUS="failed"
        APT_STDERR="${LOCK_ERR}"
        APT_EXIT=1
        echo "FAILED (dpkg lock)"
    else
        # ── Run apt-get install --only-upgrade ────────────────────────────────
        TMPOUT=$(mktemp)
        TMPERR=$(mktemp)
        T_START=$(date +%s%N)

        DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y "${PKG}" \
            >"${TMPOUT}" 2>"${TMPERR}"
        APT_EXIT=$?

        T_END=$(date +%s%N)
        DURATION=$(awk "BEGIN {printf \"%.1f\", (${T_END} - ${T_START}) / 1000000000}")

        APT_STDOUT=$(tail -5 "${TMPOUT}")
        APT_STDERR=$(tail -5 "${TMPERR}")
        rm -f "${TMPOUT}" "${TMPERR}"

        if [[ ${APT_EXIT} -ne 0 ]]; then
            ENTRY_STATUS="failed"
            echo "FAILED (apt exit ${APT_EXIT})"
        else
            echo "OK (${DURATION}s)"

            # ── Restart services if requires_restart = true ───────────────────
            if [[ "${REQUIRES_RESTART}" == "true" ]]; then
                SVC_COUNT=$(echo "${SERVICES}" | jq 'length')
                for j in $(seq 0 $((SVC_COUNT - 1))); do
                    SVC=$(echo "${SERVICES}" | jq -r ".[${j}]")
                    printf "      try-restart %-35s" "${SVC}"
                    RESTART_RC=0
                    systemctl try-restart "${SVC}" 2>/dev/null || RESTART_RC=$?
                    if [[ ${RESTART_RC} -eq 0 ]]; then
                        echo "OK"
                        RESTART_RESULTS=$(echo "${RESTART_RESULTS}" | \
                            jq --arg s "${SVC}" '. + {($s): "restarted"}')
                    else
                        echo "FAILED"
                        RESTART_RESULTS=$(echo "${RESTART_RESULTS}" | \
                            jq --arg s "${SVC}" '. + {($s): "failed"}')
                    fi
                done
            fi
        fi
    fi

    # ── post block: installed version + service states for linked services ────
    POST_VERSION=$(get_installed_version "${PKG}")
    POST_STATES=$(get_service_states "${SERVICES}")
    POST_BLOCK=$(jq -n \
        --arg ver "${POST_VERSION}" \
        --argjson svc "${POST_STATES}" \
        '{"installed_version": $ver, "service_states": $svc}')

    # ── Per-package entry ─────────────────────────────────────────────────────
    PKG_ENTRY=$(jq -n \
        --arg pkg "${PKG}" \
        --arg prio "${PRIORITY}" \
        --argjson pre "${PRE_BLOCK}" \
        --argjson post "${POST_BLOCK}" \
        --arg status "${ENTRY_STATUS}" \
        --arg dur "${DURATION}" \
        --arg stdout_tail "${APT_STDOUT}" \
        --arg stderr_tail "${APT_STDERR}" \
        --arg apt_exit "${APT_EXIT}" \
        --argjson restart "${RESTART_RESULTS}" \
        '{
            "package":          $pkg,
            "priority":         $prio,
            "pre":              $pre,
            "post":             $post,
            "status":           $status,
            "duration_seconds": ($dur | tonumber),
            "stdout_tail":      $stdout_tail,
            "stderr_tail":      $stderr_tail,
            "apt_exit_status":  ($apt_exit | tonumber),
            "restart_results":  $restart
        }')

    ENTRIES_JSON=$(echo "${ENTRIES_JSON}" | jq ". + [${PKG_ENTRY}]")

    if [[ "${ENTRY_STATUS}" == "success" ]]; then
        SUCCEEDED=$((SUCCEEDED + 1))
    else
        FAILED=$((FAILED + 1))
        ANY_FAILED=1
        # If apt call fails: mark failed, stop loop, continue to finalization
        break
    fi
done

# ── Finalization ──────────────────────────────────────────────────────────────
FINISHED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo ""
echo "Succeeded: ${SUCCEEDED}  Failed: ${FAILED}"

jq -n \
    --arg started  "${STARTED_AT}" \
    --arg finished "${FINISHED_AT}" \
    --arg host     "${HOSTNAME_VAL}" \
    --arg hash     "${PLAN_SOURCE_HASH}" \
    --argjson entries "${ENTRIES_JSON}" \
    '{
        "started_at":       $started,
        "finished_at":      $finished,
        "hostname":         $host,
        "plan_source_hash": $hash,
        "entries":          $entries
    }' > "${LOG_FILE}"

echo "Log saved to: ${LOG_FILE}"

if [[ ${ANY_FAILED} -eq 1 ]]; then
    exit 1
else
    exit 0
fi
