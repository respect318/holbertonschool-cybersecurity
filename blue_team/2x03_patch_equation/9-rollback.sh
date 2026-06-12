#!/bin/bash
# 9-rollback.sh - Package Rollback to Pre-Patch Version
# Downgrades a package to its pre-patch version from pre_patch_state.json

PRE_STATE_FILE="pre_patch_state.json"
SERVICE_MAP="service_dependency_map.json"
SERVICE_PROBES="service_probes.json"
RESULT_FILE="rollback_result.json"

# ── Accept single positional argument: package name ───────────────────────────
if [[ -z "${1:-}" ]]; then
    echo "[-] Usage: $0 <package>" >&2
    echo "    package argument is required." >&2
    exit 1
fi
PACKAGE="$1"

SUCCESS=false
HOLD_APPLIED=false
FROM_VERSION=""
TO_VERSION=""
PROBES_JSON="[]"

# ── Load pre_patch_state.json ─────────────────────────────────────────────────
if [[ ! -f "${PRE_STATE_FILE}" ]]; then
    echo "[-] ${PRE_STATE_FILE} not found." >&2
    cat > "${RESULT_FILE}" << EOF
{
  "package": "${PACKAGE}",
  "from_version": "",
  "to_version": "",
  "hold_applied": false,
  "probes": [],
  "success": false,
  "error": "${PRE_STATE_FILE} not found"
}
EOF
    exit 1
fi

# Load target version from pre_patch_state.json packages block
TARGET_VERSION=$(jq -r --arg pkg "${PACKAGE}" \
    '.packages[$pkg].version // .packages[$pkg] // empty' \
    "${PRE_STATE_FILE}" 2>/dev/null || true)

if [[ -z "${TARGET_VERSION}" || "${TARGET_VERSION}" == "null" ]]; then
    echo "[-] Package '${PACKAGE}' not found in ${PRE_STATE_FILE} packages block." >&2
    cat > "${RESULT_FILE}" << EOF
{
  "package": "${PACKAGE}",
  "from_version": "",
  "to_version": "",
  "hold_applied": false,
  "probes": [],
  "success": false,
  "error": "package not found in pre_patch_state.json packages"
}
EOF
    exit 1
fi

echo "[*] Target version from pre_patch_state.json: ${TARGET_VERSION}"

# ── Get current installed version ────────────────────────────────────────────
FROM_VERSION=$(dpkg-query -W -f='${Version}' "${PACKAGE}" 2>/dev/null || echo "not-installed")

# ── Confirm target version is available via apt-cache madison ─────────────────
printf "[*] Version available in cache: "
MADISON_OUT=$(apt-cache madison "${PACKAGE}" 2>/dev/null || true)
if echo "${MADISON_OUT}" | grep -q "${TARGET_VERSION}"; then
    echo "yes"
    VERSION_AVAILABLE=true
else
    echo "no — checking if already installed at target version"
    if [[ "${FROM_VERSION}" == "${TARGET_VERSION}" ]]; then
        echo "    already at target version ${TARGET_VERSION}, nothing to do."
        VERSION_AVAILABLE=true
    else
        VERSION_AVAILABLE=false
        echo "[-] Target version ${TARGET_VERSION} not available in repository." >&2
    fi
fi

if [[ "${VERSION_AVAILABLE}" == "false" ]]; then
    cat > "${RESULT_FILE}" << EOF
{
  "package": "${PACKAGE}",
  "from_version": "${FROM_VERSION}",
  "to_version": "${TARGET_VERSION}",
  "hold_applied": false,
  "probes": [],
  "success": false,
  "error": "target version not available in cache or repository"
}
EOF
    exit 1
fi

# ── Execute apt-get install --allow-downgrades ────────────────────────────────
printf "[*] Downgrading %s...                                 " "${PACKAGE}"
DOWNGRADE_RC=0
DOWNGRADE_OUT=$(DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --allow-downgrades "${PACKAGE}=${TARGET_VERSION}" 2>&1) || DOWNGRADE_RC=$?

if [[ ${DOWNGRADE_RC} -eq 0 ]]; then
    echo "OK"
    TO_VERSION=$(dpkg-query -W -f='${Version}' "${PACKAGE}" 2>/dev/null || echo "${TARGET_VERSION}")
else
    echo "FAILED (exit ${DOWNGRADE_RC})"
    echo "    ${DOWNGRADE_OUT}" | tail -3
    cat > "${RESULT_FILE}" << EOF
{
  "package": "${PACKAGE}",
  "from_version": "${FROM_VERSION}",
  "to_version": "${TARGET_VERSION}",
  "hold_applied": false,
  "probes": [],
  "success": false,
  "error": "apt-get install --allow-downgrades failed with exit ${DOWNGRADE_RC}"
}
EOF
    exit 1
fi

# ── apt-mark hold after successful downgrade ──────────────────────────────────
printf "[*] apt-mark hold %s                                  " "${PACKAGE}"
HOLD_RC=0
apt-mark hold "${PACKAGE}" 2>/dev/null || HOLD_RC=$?
if [[ ${HOLD_RC} -eq 0 ]]; then
    echo "OK"
    HOLD_APPLIED=true
else
    echo "FAILED"
    HOLD_APPLIED=false
fi

# ── Re-run probes for affected services ───────────────────────────────────────
echo "[*] Re-running probes for affected services..."

# Load service_dependency_map.json to find services linked to this package
if [[ -f "${SERVICE_MAP}" ]]; then
    SVC_COUNT=$(jq 'length' "${SERVICE_MAP}" 2>/dev/null || echo 0)
    for idx in $(seq 0 $((SVC_COUNT - 1))); do
        SVC_NAME=$(jq -r ".[${idx}].service // empty" "${SERVICE_MAP}" 2>/dev/null)
        [[ -z "${SVC_NAME}" ]] && continue

        # Check if this service's linked_packages contains our package
        HAS_PKG=$(jq -r --arg pkg "${PACKAGE}" \
            ".[${idx}].linked_packages // [] | index(\$pkg) != null" \
            "${SERVICE_MAP}" 2>/dev/null || echo "false")
        [[ "${HAS_PKG}" != "true" ]] && continue

        # Load probe details from service_probes.json if available
        PROBE_CMD=""
        PROBE_TYPE="systemctl"
        if [[ -f "${SERVICE_PROBES}" ]]; then
            PROBE_CMD=$(jq -r --arg svc "${SVC_NAME}" \
                '.[$svc].probe_cmd // empty' "${SERVICE_PROBES}" 2>/dev/null || true)
            PROBE_TYPE=$(jq -r --arg svc "${SVC_NAME}" \
                '.[$svc].type // "systemctl"' "${SERVICE_PROBES}" 2>/dev/null || echo "systemctl")
        fi

        # Run probe
        PROBE_RESULT="FAIL"
        PROBE_DETAIL=""
        if [[ -n "${PROBE_CMD}" ]]; then
            PROBE_OUT=$(eval "${PROBE_CMD}" 2>&1) && PROBE_RESULT="PASS" || PROBE_RESULT="FAIL"
            PROBE_DETAIL="${PROBE_OUT}"
        else
            # Default: check systemctl is-active
            SVC_STATE=$(systemctl is-active "${SVC_NAME}" 2>/dev/null || echo "inactive")
            if [[ "${SVC_STATE}" == "active" ]]; then
                PROBE_RESULT="PASS"
            else
                PROBE_RESULT="FAIL"
                # Try restarting
                systemctl try-restart "${SVC_NAME}" 2>/dev/null || true
                SVC_STATE=$(systemctl is-active "${SVC_NAME}" 2>/dev/null || echo "inactive")
                [[ "${SVC_STATE}" == "active" ]] && PROBE_RESULT="PASS"
            fi
            PROBE_DETAIL="systemctl is-active: ${SVC_STATE}"
        fi

        printf "    %-40s %s\n" "${SVC_NAME} probe (${PROBE_TYPE})" "${PROBE_RESULT}"

        PROBE_OBJ=$(jq -n \
            --arg svc    "${SVC_NAME}" \
            --arg type   "${PROBE_TYPE}" \
            --arg result "${PROBE_RESULT}" \
            --arg detail "${PROBE_DETAIL}" \
            '{"service": $svc, "probe_type": $type, "result": $result, "detail": $detail}')
        PROBES_JSON=$(echo "${PROBES_JSON}" | jq ". + [${PROBE_OBJ}]")
    done
else
    echo "    service_dependency_map.json not found — skipping service probes"
fi

# ── Determine overall success ─────────────────────────────────────────────────
FAILED_PROBES=$(echo "${PROBES_JSON}" | jq '[.[] | select(.result == "FAIL")] | length')
if [[ ${FAILED_PROBES} -eq 0 ]]; then
    SUCCESS=true
else
    SUCCESS=false
fi

# ── Emit rollback_result.json ─────────────────────────────────────────────────
PROBES_STR=$(echo "${PROBES_JSON}")

cat > "${RESULT_FILE}" << EOF
{
  "package": "${PACKAGE}",
  "from_version": "${FROM_VERSION}",
  "to_version": "${TO_VERSION}",
  "hold_applied": ${HOLD_APPLIED},
  "probes": ${PROBES_STR},
  "success": ${SUCCESS}
}
EOF

echo ""
if [[ "${SUCCESS}" == "true" ]]; then
    echo "ROLLBACK: success"
else
    echo "ROLLBACK: failed (${FAILED_PROBES} probe(s) failed)"
fi
echo "from ${FROM_VERSION} to ${TO_VERSION}"
echo "Report saved to: ${RESULT_FILE}"

if [[ "${SUCCESS}" == "true" ]]; then
    exit 0
else
    exit 1
fi
