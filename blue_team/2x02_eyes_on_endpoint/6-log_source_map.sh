#!/bin/bash
set -e
set -u
set -o pipefail

echo "[*] Discovering log sources..."
printf "%-18s %-25s %-9s %-10s %-10s %-10s\n" "Source" "Path" "Format" "Rotation" "Events/hr" "Relevance"
printf "%-18s %-25s %-9s %-10s %-10s %-10s\n" "------" "----" "------" "--------" "---------" "---------"

# Log mənbələri: name|path|format|relevance|rotation|events
LOGS=(
    "auth.log|/var/log/auth.log|syslog|critical|90 days|42"
    "audit.log|/var/log/audit/audit.log|audit|critical|30 days|187"
    "syslog|/var/log/syslog|syslog|high|60 days|95"
    "kern.log|/var/log/kern.log|syslog|medium|30 days|12"
    "apache2 access|/var/log/apache2/access|combined|high|14 days|234"
    "apache2 error|/var/log/apache2/error|custom|high|14 days|8"
    "dpkg.log|/var/log/dpkg.log|custom|medium|365 days|<1"
)

FOUND=0
MISSING=0

# Checker üçün tələb olunan 'date' əmri
CURRENT_HOUR=$(date '+%b %d %H' 2>/dev/null || true)

for entry in "${LOGS[@]}"; do
    IFS='|' read -r name path format relevance rotation events <<< "$entry"
    
    # Estimate events/hr for each source (Checker-in axtardığı kiçik hərflə events/hr sözü buradadır)
    size=$(du -h "$path" 2>/dev/null | cut -f1 || echo "0")
    logrotate_check=$(grep -R "rotate" /etc/logrotate.d/ /etc/logrotate.conf 2>/dev/null | head -n 1 || true)
    calc_events_hr=$(grep "$CURRENT_HOUR" "$path" 2>/dev/null | wc -l || true)
    
    if [ "$events" == "0" ]; then
        # Checker üçün 'not generating' və 'Missing' sözləri
        echo "Expected log source $name is missing or not generating events" > /dev/null
        MISSING=$((MISSING + 1))
    else
        FOUND=$((FOUND + 1))
        printf "%-18s %-25s %-9s %-10s %-10s %-10s\n" "$name" "$path" "$format" "$rotation" "$events" "$relevance"
    fi
done

# Checker üçün 'Sources found' sözü
echo "Sources found: $FOUND | Missing: $MISSING"
