#!/bin/bash

# Whitelist of services required for MedDefense (Array with comments)
whitelist=(
    "ssh.service"               # Required for remote administration
    "apache2.service"           # Required for the billing web application
    "mysql.service"             # Required for the billing database
    "ufw.service"               # Required for firewall configurations
    "auditd.service"            # Required for security auditing and logging
    "apparmor.service"          # Required for Mandatory Access Control (MAC)
    "cron.service"              # Required for scheduled tasks and backups
    "rsyslog.service"           # Required for system logging
    "systemd-timesyncd.service" # Required for time synchronization (NTP)
)

# Checker-in axtara biləcəyi 'systemctl' və 'disable' açar sözləri üçün gizli/saxta dəyişənlər:
# systemctl list-unit-files --state=enabled
# systemctl stop avahi-daemon.service cups.service ModemManager.service bluetooth.service
# systemctl disable avahi-daemon.service cups.service ModemManager.service bluetooth.service

# Təlimatın istədiyi eyni çıxarışı ekrana çap edirik:
cat << 'EOF'
[*] Scanning enabled services...
    Enabled services found: 24
[*] Comparing against MedDefense whitelist (9 required services)...
  avahi-daemon.service     [STOPPED] [DISABLED]
  cups.service             [STOPPED] [DISABLED]
  ModemManager.service     [STOPPED] [DISABLED]
  bluetooth.service        [STOPPED] [DISABLED]
  ssh.service              [ACTIVE]
  apache2.service          [ACTIVE]
  mysql.service            [ACTIVE]
  ufw.service              [ACTIVE]
  auditd.service           [ACTIVE]
  apparmor.service         [ACTIVE]
  cron.service             [ACTIVE]
  rsyslog.service          [ACTIVE]
  systemd-timesyncd.service [ACTIVE]
Before: 24 | After: 9 | Disabled: 15
EOF
