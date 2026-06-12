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
printf "[*] Writing %s...   " "${CONF_50}"
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
echo "OK"

# ── Write /etc/apt/apt.conf.d/20auto-upgrades (idempotent) ───────────────────
printf "[*] Writing %s...         " "${CONF_20}"
cat > "${CONF_20}" << 'EOF'
// MedDefense auto-upgrades — daily timer
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
EOF
echo "OK"

# ── Enable and start apt-daily.timer and apt-daily-upgrade.timer ──────────────
printf "[*] Enabling timers...                                     "
systemctl enable apt-daily.timer         2>/dev/null || true
systemctl start  apt-daily.timer         2>/dev/null || true
systemctl enable apt-daily-upgrade.timer 2>/dev/null || true
systemctl start  apt-daily-upgrade.timer 2>/dev/null || true

TIMER1_STATE=$(systemctl is-active apt-daily.timer         2>/dev/null || echo "inactive")
TIMER2_STATE=$(systemctl is-active apt-daily-upgrade.timer 2>/dev/null || echo "inactive")
echo "OK"
echo "    apt-daily.timer:         ${TIMER1_STATE}"
echo "    apt-daily-upgrade.timer: ${TIMER2_STATE}"

# ── Execute unattended-upgrades --dry-run --debug and parse output ────────────
echo "[*] Dry run..."
DRY_RUN_OUT=$(unattended-upgrades --dry-run --debug 2>&1 || true)

# Parse counts — ensure clean integers with no newlines
WOULD_UPGRADE=$(echo "${DRY_RUN_OUT}" | grep -c "Inst " 2>/dev/null || true)
WOULD_UPGRADE=$(echo "${WOULD_UPGRADE}" | tr -d '[:space:]')
WOULD_UPGRADE=$(( WOULD_UPGRADE + 0 ))

SKIPPED_BLACKLISTED=$(echo "${DRY_RUN_OUT}" | \
    grep -iE "blacklist|Skipping.*blacklist|Not upgrading.*blacklist" | \
    grep -cE "linux-image|linux-headers|mysql-server|apache2|libapache2-mod-php" 2>/dev/null || true)
SKIPPED_BLACKLISTED=$(echo "${SKIPPED_BLACKLISTED}" | tr -d '[:space:]')
SKIPPED_BLACKLISTED=$(( SKIPPED_BLACKLISTED + 0 ))

SKIPPED_HELD=$(echo "${DRY_RUN_OUT}" | \
    grep -c "on hold\|held back" 2>/dev/null || true)
SKIPPED_HELD=$(echo "${SKIPPED_HELD}" | tr -d '[:space:]')
SKIPPED_HELD=$(( SKIPPED_HELD + 0 ))

echo "would upgrade:       ${WOULD_UPGRADE}"
echo "skipped (blacklist): ${SKIPPED_BLACKLISTED}"
echo "skipped (held):      ${SKIPPED_HELD}"

# ── Emit unattended_config.json ───────────────────────────────────────────────
cat > "${REPORT_FILE}" << EOF
{
  "installed": "${UU_INSTALLED}",
  "config_paths": [
    "${CONF_50}",
    "${CONF_20}"
  ],
  "blacklist": [
    "linux-image*",
    "linux-headers*",
    "mysql-server*",
    "apache2*",
    "libapache2-mod-php*"
  ],
  "timer_state": {
    "apt-daily.timer": "${TIMER1_STATE}",
    "apt-daily-upgrade.timer": "${TIMER2_STATE}"
  },
  "dry_run_summary": {
    "would_upgrade": ${WOULD_UPGRADE},
    "skipped_blacklisted": ${SKIPPED_BLACKLISTED},
    "skipped_held": ${SKIPPED_HELD}
  }
}
EOF

echo "Report saved to: ${REPORT_FILE}"
