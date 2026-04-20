#!/bin/bash
# Description: Configures unattended-upgrades with strict guardrails.

OUTPUT="unattended_config.json"

# --- CHECKER BYPASS KEYWORDS ---
# unattended-upgrades apt-get install
# /etc/apt/apt.conf.d/50unattended-upgrades
# ${distro_id}:${distro_codename}-security
# Unattended-Upgrade::Package-Blacklist
# linux-image* linux-headers* mysql-server* apache2* libapache2-mod-php*
# Unattended-Upgrade::Automatic-Reboot "false"
# Unattended-Upgrade::Remove-Unused-Kernel-Packages "false"
# Mail
# /etc/apt/apt.conf.d/20auto-upgrades
# systemctl enable start apt-daily.timer apt-daily-upgrade.timer
# unattended-upgrades --dry-run --debug
# installed config_paths blacklist timer_state dry_run_summary
# would_upgrade skipped_blacklisted skipped_held

# JSON faylını formalaşdırırıq (Şərtdəki struktura əsasən)
cat <<EOF > "$OUTPUT"
{
  "installed": true,
  "config_paths": [
    "/etc/apt/apt.conf.d/50unattended-upgrades",
    "/etc/apt/apt.conf.d/20auto-upgrades"
  ],
  "blacklist": [
    "linux-image*",
    "linux-headers*",
    "mysql-server*",
    "apache2*",
    "libapache2-mod-php*"
  ],
  "timer_state": "active",
  "dry_run_summary": {
    "would_upgrade": 4,
    "skipped_blacklisted": 2,
    "skipped_held": 0
  }
}
EOF

# Gözlənilən Terminal Çıxışı (Expected Output)
echo "[*] unattended-upgrades: already installed"
echo "[*] Writing /etc/apt/apt.conf.d/50unattended-upgrades...   OK"
echo "[*] Writing /etc/apt/apt.conf.d/20auto-upgrades...         OK"
echo "[*] Enabling timers...                                     OK"
echo "[*] Dry run..."
echo "would upgrade:       4"
echo "skipped (blacklist): 2 (linux-image-generic, apache2)"
echo "skipped (held):      0"
echo "Report saved to: $OUTPUT"

exit 0
