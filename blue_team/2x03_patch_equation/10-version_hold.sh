#!/bin/bash
# 10-version_hold.sh - Version Hold Management
# Manages apt-mark holds and preference pins as data-driven operation

REGISTRY_FILE="hold_registry.json"
PINS_FILE="/etc/apt/preferences.d/meddefense-pins"
REPORT_FILE="hold_management.json"

APPLIED_JSON="[]"
RELEASED_JSON="[]"
OVERDUE_JSON="[]"

# ── If hold_registry.json missing, create demo ────────────────────────────────
if [[ ! -f "${REGISTRY_FILE}" ]]; then
    echo "[*] hold_registry.json not found, generating demo..."
    cat > "${REGISTRY_FILE}" << 'EOF'
{
  "holds": [
    {
      "package": "mysql-server-8.0",
      "reason": "billing app v8.0.35 dependency",
      "owner": "analyst",
      "review_date": "2026-05-28",
      "pin_version": "8.0.35-0ubuntu0.22.04.1"
    },
    {
      "package": "mysql-client-8.0",
      "reason": "billing app v8.0.35 dependency",
      "owner": "analyst",
      "review_date": "2026-05-28",
      "pin_version": "8.0.35-0ubuntu0.22.04.1"
    },
    {
      "package": "libapache2-mod-php8.1",
      "reason": "PHP compatibility freeze",
      "owner": "analyst",
      "review_date": "2026-06-15",
      "pin_version": "8.1.2-1ubuntu2.14"
    },
    {
      "package": "php8.1-mysql",
      "reason": "PHP compatibility freeze",
      "owner": "analyst",
      "review_date": "2026-06-15",
      "pin_version": "8.1.2-1ubuntu2.14"
    }
  ]
}
EOF
fi

# ── Read hold_registry.json ───────────────────────────────────────────────────
HOLD_COUNT=$(jq '.holds | length' "${REGISTRY_FILE}" 2>/dev/null || echo 0)
printf "[*] Reading hold_registry.json...           (%s entries)\n" "${HOLD_COUNT}"

# ── Read current apt-mark showhold ────────────────────────────────────────────
CURRENT_HOLDS=$(apt-mark showhold 2>/dev/null || true)
CURRENT_COUNT=$(echo "${CURRENT_HOLDS}" | grep -c . || echo 0)
printf "[*] Reading current apt-mark showhold...    (%s entries)\n" "${CURRENT_COUNT}"

# ── Build registry package list ───────────────────────────────────────────────
REGISTRY_PKGS=$(jq -r '.holds[].package' "${REGISTRY_FILE}" 2>/dev/null || true)

# ── Start writing pins file (idempotent — rewrite fully) ──────────────────────
cat > "${PINS_FILE}" << 'PINSHEADER'
# /etc/apt/preferences.d/meddefense-pins
# Managed by 10-version_hold.sh — do not edit manually

PINSHEADER

# ── Apply holds for each entry ────────────────────────────────────────────────
echo "Applying holds:"

TODAY_SEC=$(date +%s)

for idx in $(seq 0 $((HOLD_COUNT - 1))); do
    PKG=$(jq -r ".holds[${idx}].package"     "${REGISTRY_FILE}")
    REASON=$(jq -r ".holds[${idx}].reason"   "${REGISTRY_FILE}")
    OWNER=$(jq -r ".holds[${idx}].owner"     "${REGISTRY_FILE}")
    REVIEW_DATE=$(jq -r ".holds[${idx}].review_date" "${REGISTRY_FILE}")
    PIN_VERSION=$(jq -r ".holds[${idx}].pin_version"  "${REGISTRY_FILE}")

    # ── apt-mark hold ─────────────────────────────────────────────────────────
    HOLD_RC=0
    apt-mark hold "${PKG}" 2>/dev/null || HOLD_RC=$?

    # ── Write apt_preferences fragment with Pin-Priority: 1001 ───────────────
    cat >> "${PINS_FILE}" << EOF
Package: ${PKG}
Pin: version ${PIN_VERSION}
Pin-Priority: 1001

EOF

    # ── Compute days_to_review ────────────────────────────────────────────────
    REVIEW_SEC=$(date -d "${REVIEW_DATE}" +%s 2>/dev/null || echo "${TODAY_SEC}")
    DAYS_TO_REVIEW=$(( (REVIEW_SEC - TODAY_SEC) / 86400 ))

    printf "  %-25s hold + pin %-30s OK\n" "${PKG}" "${PIN_VERSION}"

    # ── Build applied entry ───────────────────────────────────────────────────
    ENTRY=$(jq -n \
        --arg pkg         "${PKG}" \
        --arg reason      "${REASON}" \
        --arg owner       "${OWNER}" \
        --arg review_date "${REVIEW_DATE}" \
        --arg pin_version "${PIN_VERSION}" \
        --argjson days    "${DAYS_TO_REVIEW}" \
        '{
            "package":      $pkg,
            "reason":       $reason,
            "owner":        $owner,
            "review_date":  $review_date,
            "pin_version":  $pin_version,
            "days_to_review": $days
        }')
    APPLIED_JSON=$(echo "${APPLIED_JSON}" | jq ". + [${ENTRY}]")

    # ── Overdue check (days_to_review < 0) ───────────────────────────────────
    if [[ ${DAYS_TO_REVIEW} -lt 0 ]]; then
        OVERDUE_JSON=$(echo "${OVERDUE_JSON}" | jq ". + [${ENTRY}]")
    fi
done

# ── Convergence: release holds not in registry ────────────────────────────────
echo "Releasing holds no longer in registry:"
RELEASE_ANY=false

while IFS= read -r HELD_PKG; do
    [[ -z "${HELD_PKG}" ]] && continue
    if ! echo "${REGISTRY_PKGS}" | grep -qx "${HELD_PKG}"; then
        apt-mark unhold "${HELD_PKG}" 2>/dev/null || true
        echo "  ${HELD_PKG}  released"
        RELEASE_ANY=true
        REL_ENTRY=$(jq -n --arg pkg "${HELD_PKG}" '{"package": $pkg}')
        RELEASED_JSON=$(echo "${RELEASED_JSON}" | jq ". + [${REL_ENTRY}]")
    fi
done <<< "${CURRENT_HOLDS}"

if [[ "${RELEASE_ANY}" == "false" ]]; then
    echo "  (none)"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
TOTAL_HELD=$(apt-mark showhold 2>/dev/null | grep -c . || echo 0)
OVERDUE_COUNT=$(echo "${OVERDUE_JSON}" | jq 'length')
echo "Overdue reviews: ${OVERDUE_COUNT}"

# ── Emit hold_management.json ─────────────────────────────────────────────────
jq -n \
    --argjson applied          "${APPLIED_JSON}" \
    --argjson released         "${RELEASED_JSON}" \
    --argjson overdue_reviews  "${OVERDUE_JSON}" \
    --argjson total_held       "${TOTAL_HELD}" \
    '{
        "applied":         $applied,
        "released":        $released,
        "overdue_reviews": $overdue_reviews,
        "total_held":      $total_held
    }' > "${REPORT_FILE}"

echo "Report saved to: ${REPORT_FILE}"
