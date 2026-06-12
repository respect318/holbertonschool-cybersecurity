#!/bin/bash
# 6-config_drift.sh - Configuration Drift Detector
# Compares pre_patch_state.json conffile hashes against current hashes

PRE_STATE_FILE="pre_patch_state.json"
EXEC_LOG_FILE="patch_execution_log.json"
DRIFT_FILE="config_drift.json"

# ── Validate inputs ───────────────────────────────────────────────────────────
if [[ ! -f "${PRE_STATE_FILE}" ]]; then
    echo "[-] ${PRE_STATE_FILE} not found. Generating demo file..." >&2
    cat > "${PRE_STATE_FILE}" << 'DEMOPRE'
{
  "conffile_hashes": {
    "/etc/ssh/sshd_config": {
      "hash": "abc123demo0000000000000000000000000000000000000000000000000000",
      "owning_package": "openssh-server"
    },
    "/etc/ssl/openssl.cnf": {
      "hash": "def456demo0000000000000000000000000000000000000000000000000000",
      "owning_package": "openssl"
    },
    "/etc/pam.conf": {
      "hash": "ghi789demo0000000000000000000000000000000000000000000000000000",
      "owning_package": "libpam-modules"
    }
  }
}
DEMOPRE
fi

if [[ ! -f "${EXEC_LOG_FILE}" ]]; then
    echo "[-] ${EXEC_LOG_FILE} not found. Generating demo file..." >&2
    cat > "${EXEC_LOG_FILE}" << 'DEMOLOG'
{
  "started_at": "2025-06-10T14:00:00Z",
  "finished_at": "2025-06-10T14:01:24Z",
  "hostname": "meddefense-host",
  "plan_source_hash": "a3f1c2e4b5d6789012345678901234567890abcdef1234567890abcdef123456",
  "entries": [
    {"package": "openssh-server", "status": "success"},
    {"package": "openssl",        "status": "success"},
    {"package": "curl",           "status": "success"}
  ]
}
DEMOLOG
fi

# ── Load conffile_hashes from pre_patch_state.json ────────────────────────────
echo "[*] Loading pre-patch conffile_hashes from ${PRE_STATE_FILE}..."
CONFFILE_HASHES=$(jq -r '.conffile_hashes' "${PRE_STATE_FILE}")
if [[ "${CONFFILE_HASHES}" == "null" || -z "${CONFFILE_HASHES}" ]]; then
    echo "[-] No conffile_hashes block found in ${PRE_STATE_FILE}." >&2
    exit 1
fi

# ── Build list of upgraded packages from patch_execution_log.json ─────────────
UPGRADED_PKGS=$(jq -r '.entries[] | select(.status == "success") | .package' \
    "${EXEC_LOG_FILE}" 2>/dev/null | tr '\n' ' ')
echo "[*] Packages upgraded this run: ${UPGRADED_PKGS}"

# ── Counters ──────────────────────────────────────────────────────────────────
COUNT_UNCHANGED=0
COUNT_MODIFIED=0
COUNT_MISSING=0
COUNT_NEW=0
COUNT_UNEXPECTED=0
FILES_JSON="[]"
HAS_UNEXPECTED=0

# ── Recompute hashes and classify each file ───────────────────────────────────
echo "[*] Recomputing SHA-256 hashes and classifying files..."

while IFS= read -r FPATH; do
    OLD_HASH=$(echo "${CONFFILE_HASHES}" | jq -r --arg p "${FPATH}" '.[$p].hash // ""')
    OWNING_PKG=$(echo "${CONFFILE_HASHES}" | jq -r --arg p "${FPATH}" '.[$p].owning_package // "unknown"')

    CLASSIFICATION=""
    DIFF_OUTPUT=""
    IS_EXPECTED="false"
    CURRENT_HASH=""

    if [[ ! -f "${FPATH}" ]]; then
        # File is missing
        CLASSIFICATION="missing"
        COUNT_MISSING=$((COUNT_MISSING + 1))
    else
        # Recompute sha256sum
        CURRENT_HASH=$(sha256sum "${FPATH}" 2>/dev/null | awk '{print $1}')

        if [[ "${CURRENT_HASH}" == "${OLD_HASH}" ]]; then
            CLASSIFICATION="unchanged"
            COUNT_UNCHANGED=$((COUNT_UNCHANGED + 1))
        else
            CLASSIFICATION="modified"
            COUNT_MODIFIED=$((COUNT_MODIFIED + 1))

            # Capture unified diff truncated to 40 lines via diff -u
            DIFF_OUTPUT=$(diff -u \
                <(echo "# pre-patch hash: ${OLD_HASH}") \
                <(cat "${FPATH}") 2>/dev/null | head -40 || true)
        fi
    fi

    # ── Cross-reference with patch_execution_log.json ─────────────────────────
    # Mark as expected if owning_package was upgraded during this run
    # Mark as unexpected if drifted without an owning upgrade
    if [[ "${CLASSIFICATION}" == "modified" || "${CLASSIFICATION}" == "missing" ]]; then
        if echo "${UPGRADED_PKGS}" | grep -qw "${OWNING_PKG}"; then
            IS_EXPECTED="true"
        else
            IS_EXPECTED="false"
            COUNT_UNEXPECTED=$((COUNT_UNEXPECTED + 1))
            HAS_UNEXPECTED=1
            echo "  [!] unexpected drift: ${FPATH} (owning_package: ${OWNING_PKG})"
        fi
    fi

    # ── Build per-file object ─────────────────────────────────────────────────
    FILE_OBJ=$(jq -n \
        --arg path          "${FPATH}" \
        --arg owning_package "${OWNING_PKG}" \
        --arg classification "${CLASSIFICATION}" \
        --arg old_hash      "${OLD_HASH}" \
        --arg new_hash      "${CURRENT_HASH}" \
        --arg expected      "${IS_EXPECTED}" \
        --arg diff          "${DIFF_OUTPUT}" \
        '{
            "path":           $path,
            "owning_package": $owning_package,
            "classification": $classification,
            "old_hash":       $old_hash,
            "new_hash":       $new_hash,
            "expected":       ($expected == "true"),
            "diff":           $diff
        }')

    FILES_JSON=$(echo "${FILES_JSON}" | jq ". + [${FILE_OBJ}]")

done < <(echo "${CONFFILE_HASHES}" | jq -r 'keys[]')

# ── Detect new conffiles added by patches (tracked but not in pre-state) ──────
# For each upgraded package, check dpkg conffiles not in pre_patch_state.json
for PKG in ${UPGRADED_PKGS}; do
    while IFS= read -r CONFFILE; do
        [[ -z "${CONFFILE}" ]] && continue
        ALREADY=$(echo "${CONFFILE_HASHES}" | jq -r --arg p "${CONFFILE}" 'has($p)')
        if [[ "${ALREADY}" == "false" && -f "${CONFFILE}" ]]; then
            COUNT_NEW=$((COUNT_NEW + 1))
            CURRENT_HASH=$(sha256sum "${CONFFILE}" 2>/dev/null | awk '{print $1}')
            FILE_OBJ=$(jq -n \
                --arg path          "${CONFFILE}" \
                --arg owning_package "${PKG}" \
                --arg classification "new" \
                --arg new_hash      "${CURRENT_HASH}" \
                '{
                    "path":           $path,
                    "owning_package": $owning_package,
                    "classification": $classification,
                    "old_hash":       "",
                    "new_hash":       $new_hash,
                    "expected":       true,
                    "diff":           ""
                }')
            FILES_JSON=$(echo "${FILES_JSON}" | jq ". + [${FILE_OBJ}]")
        fi
    done < <(dpkg-query -W -f='${Conffiles}\n' "${PKG}" 2>/dev/null \
        | awk '{print $1}' | grep '^/')
done

# ── Emit config_drift.json with summary and files ─────────────────────────────
SUMMARY=$(jq -n \
    --argjson unchanged  "${COUNT_UNCHANGED}" \
    --argjson modified   "${COUNT_MODIFIED}" \
    --argjson missing    "${COUNT_MISSING}" \
    --argjson new        "${COUNT_NEW}" \
    --argjson unexpected "${COUNT_UNEXPECTED}" \
    '{
        "unchanged":  $unchanged,
        "modified":   $modified,
        "missing":    $missing,
        "new":        $new,
        "unexpected": $unexpected
    }')

jq -n \
    --argjson summary "${SUMMARY}" \
    --argjson files   "${FILES_JSON}" \
    '{"summary": $summary, "files": $files}' > "${DRIFT_FILE}"

echo ""
echo "Summary: unchanged=${COUNT_UNCHANGED} modified=${COUNT_MODIFIED} missing=${COUNT_MISSING} new=${COUNT_NEW} unexpected=${COUNT_UNEXPECTED}"
echo "Log saved to: ${DRIFT_FILE}"

# ── Print modified files (expected output format) ─────────────────────────────
jq -c '.files[] | select(.classification == "modified") | {path, owning_package, expected}' \
    "${DRIFT_FILE}"

# ── Exit 0 if no unexpected drift, 1 otherwise ────────────────────────────────
if [[ ${HAS_UNEXPECTED} -eq 1 ]]; then
    exit 1
else
    exit 0
fi
