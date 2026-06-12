#!/bin/bash
# 8-unattended_config.sh - Unattended Upgrades Configuration for MedDefense
# Configures unattended-upgrades with security-only origins and package blacklist

CONF_50="/etc/apt/apt.conf.d/50unattended-upgrades"
CONF_20="/etc/apt/apt.conf.d/20auto-upgrades"
REPORT_FILE="unattended_config.json"

# ── Install unattended-upgrades if not present ────────────────────────────────
printf "[*] unattended-upgrades: "
if dpkg -l unattended-upgrades 2>/dev/null | grep -q "^ii"; then
    echo "already installed"
    UU_INSTALLED="already_installed"
else
    echo "installing..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y unattended-upgrades 2>/dev/null
    echo "    installed"
    UU_INSTALLED="installed_now"
fi

# ── Write /etc/apt/apt.conf.d/50unattended-upgrades (idempotent) ──────────────
printf "[*] Writing %s... " "${CONF_50}"
cat > "${CONF_50}" << 'EOF'
// MedDefense unattended-upgrades configuration
// Managed by 8-unattended_config.sh — do not edit manually

Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};

Unattended-Upgrade::Package-Blacklist {
    "linux-image*";
    "linux-headers*";
    "mysql-server*";
    "apache2*";
    "libapache2-mod-php*";
};

Unattended-Upgrade::Automatic-Reboot "false";

Unattended-Upgrade::Remove-Unused-Kernel-Packages "false";

Unattended-Upgrade::Mail "";

Unattended-Upgrade::MailReport "never";
EOF
echo "  OK"

# ── Write /etc/apt/apt.conf.d/20auto-upgrades (idempotent) ───────────────────
printf "[*] Writing %s... " "${CONF_20}"
cat > "${CONF_20}" << 'EOF'
// MedDefense auto-upgrades — daily timer
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
echo "        OK"

# ── Enable and start apt-daily.timer and apt-daily-upgrade.timer ──────────────
printf "[*] Enabling timers... "
TIMER1_STATE="unknown"
TIMER2_STATE="unknown"

systemctl enable apt-daily.timer         2>/dev/null && \
systemctl start  apt-daily.timer         2>/dev/null || true
systemctl enable apt-daily-upgrade.timer 2>/dev/null && \
systemctl start  apt-daily-upgrade.timer 2>/dev/null || true

TIMER1_STATE=$(systemctl is-active apt-daily.timer         2>/dev/null || echo "inactive")
TIMER2_STATE=$(systemctl is-active apt-daily-upgrade.timer 2>/dev/null || echo "inactive")
echo "                                    OK"
echo "    apt-daily.timer:         ${TIMER1_STATE}"
echo "    apt-daily-upgrade.timer: ${TIMER2_STATE}"

# ── Execute unattended-upgrades --dry-run --debug and parse output ────────────
echo "[*] Dry run..."
DRY_RUN_OUT=$(unattended-upgrades --dry-run --debug 2>&1 || true)

# Parse counts from dry-run output
WOULD_UPGRADE=$(echo "${DRY_RUN_OUT}" | \
    grep -c "Checking.*can be upgraded" 2>/dev/null || echo 0)

# Count skipped_blacklisted packages
SKIPPED_BLACKLISTED=0
SKIPPED_BL_PKGS=()
while IFS= read -r line; do
    PKG=$(echo "${line}" | grep -oP '(?<=blacklisted: )\S+' || \
          echo "${line}" | grep -oP '(?<=Skipping )\S+' || true)
    if [[ -n "${PKG}" ]]; then
        SKIPPED_BLACKLISTED=$((SKIPPED_BLACKLISTED + 1))
        SKIPPED_BL_PKGS+=("${PKG}")
    fi
done < <(echo "${DRY_RUN_OUT}" | grep -i "blacklist\|Package.*blacklisted\|Skipping.*blacklist" || true)

# Also count via "Not upgrading" lines matching our blacklist patterns
BL_MATCH=$(echo "${DRY_RUN_OUT}" | \
    grep -iE "linux-image|linux-headers|mysql-server|apache2|libapache2-mod-php" | \
    grep -ic "skip\|blacklist\|not.upgrad" 2>/dev/null || echo 0)
[[ ${BL_MATCH} -gt ${SKIPPED_BLACKLISTED} ]] && SKIPPED_BLACKLISTED=${BL_MATCH}

SKIPPED_HELD=$(echo "${DRY_RUN_OUT}" | \
    grep -c "held back\|on hold" 2>/dev/null || echo 0)

WOULD_UPGRADE=$(echo "${DRY_RUN_OUT}" | \
    grep -c "Packages.*will be upgraded\|Inst " 2>/dev/null || echo 0)

BL_PKG_LIST=$(printf '%s\n' "${SKIPPED_BL_PKGS[@]+"${SKIPPED_BL_PKGS[@]}"}" | \
    grep -v '^$' | head -5 | paste -sd ',' || echo "")

echo "would upgrade:       ${WOULD_UPGRADE}"
echo "skipped (blacklist): ${SKIPPED_BLACKLISTED}$([ -n "${BL_PKG_LIST}" ] && echo " (${BL_PKG_LIST})")"
echo "skipped (held):      ${SKIPPED_HELD}"

# ── Emit unattended_config.json ───────────────────────────────────────────────
BLACKLIST_JSON='["linux-image*","linux-headers*","mysql-server*","apache2*","libapache2-mod-php*"]'

TIMER_STATE=$(jq -n \
    --arg t1 "${TIMER1_STATE}" \
    --arg t2 "${TIMER2_STATE}" \
    '{"apt-daily.timer": $t1, "apt-daily-upgrade.timer": $t2}')

DRY_RUN_SUMMARY=$(jq -n \
    --argjson would     "${WOULD_UPGRADE}" \
    --argjson blacklist "${SKIPPED_BLACKLISTED}" \
    --argjson held      "${SKIPPED_HELD}" \
    '{
        "would_upgrade":       $would,
        "skipped_blacklisted": $blacklist,
        "skipped_held":        $held
    }')

jq -n \
    --arg     installed   "${UU_INSTALLED}" \
    --argjson config_paths '["'"${CONF_50}"'","'"${CONF_20}"'"]' \
    --argjson blacklist    "${BLACKLIST_JSON}" \
    --argjson timer_state  "${TIMER_STATE}" \
    --argjson dry_run_summary "${DRY_RUN_SUMMARY}" \
    '{
        "installed":       $installed,
        "config_paths":    $config_paths,
        "blacklist":       $blacklist,
        "timer_state":     $timer_state,
        "dry_run_summary": $dry_run_summary
    }' > "${REPORT_FILE}"

echo "Report saved to: ${REPORT_FILE}"
