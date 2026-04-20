#!/bin/bash
# Description: Executes the patch plan safely with logging and locking.

PLAN_FILE="patch_plan.json"
LOG_FILE="patch_execution_log.json"
LOCK_FILE="/var/lock/meddefense-patch.lock"

# 1. Advisory Lock & Trap
if ! ( set -o noclobber; echo "$$" > "$LOCK_FILE" ) 2> /dev/null; then
    echo "Lock could not be acquired. Another instance is running." >&2
    exit 2
fi
trap 'rm -f "$LOCK_FILE"' EXIT

# Başlanğıc vaxtı və hash
START_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)
PLAN_HASH=$(sha256sum "$PLAN_FILE" | awk '{print $1}' 2>/dev/null || echo "unknown")

echo "[*] Acquiring lock $LOCK_FILE...  OK"
ENTRY_COUNT=$(jq '.plan | length' "$PLAN_FILE" 2>/dev/null || echo "0")
echo "[*] Loading plan: $PLAN_FILE ($ENTRY_COUNT entries)"

# Boş JSON log faylı yaradırıq
echo "{\"started_at\":\"$START_TIME\",\"hostname\":\"$HOSTNAME\",\"plan_source_hash\":\"$PLAN_HASH\",\"entries\":[]}" > "$LOG_FILE"

GLOBAL_STATUS=0
COUNT=1

# JSON array üzərində döngü
jq -c '.plan[]' "$PLAN_FILE" 2>/dev/null | while read -r row; do
    PKG=$(echo "$row" | jq -r '.package')
    BUCKET=$(echo "$row" | jq -r '.bucket')
    REQ_RESTART=$(echo "$row" | jq -r '.requires_restart')
    REQ_REBOOT=$(echo "$row" | jq -r '.requires_reboot')
    
    # Pre-check (Mövcud versiya)
    PRE_VER=$(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null || echo "none")
    
    echo -n "[$COUNT/$ENTRY_COUNT] $PKG   $BUCKET     apt-get ... "
    
    START_TS=$(date +%s)
    
    # Exponential Backoff for dpkg lock
    MAX_WAIT=120
    WAIT_TIME=1
    TOTAL_WAIT=0
    SUCCESS=false
    
    while [ $TOTAL_WAIT -lt $MAX_WAIT ]; do
        OUT=$(DEBIAN_FRONTEND=noninteractive apt-get install --only-upgrade -y "$PKG" 2>&1)
        EXIT_CODE=$?
        
        if [ $EXIT_CODE -eq 0 ]; then
            SUCCESS=true
            break
        elif echo "$OUT" | grep -q "Could not get lock"; then
            sleep $WAIT_TIME
            TOTAL_WAIT=$((TOTAL_WAIT + WAIT_TIME))
            WAIT_TIME=$((WAIT_TIME * 2))
        else
            break
        fi
    done
    
    END_TS=$(date +%s)
    DURATION=$((END_TS - START_TS))
    
    POST_VER=$(dpkg-query -W -f='${Version}' "$PKG" 2>/dev/null || echo "none")
    
    if [ "$SUCCESS" = true ]; then
        echo "OK (${DURATION}s)"
        STATUS="success"
        
        # Servisləri restart etmək
        if [ "$REQ_RESTART" = "true" ] && [ "$REQ_REBOOT" = "false" ]; then
            echo "$row" | jq -r '.affected_services[]' | while read -r SVC; do
                if [ "$SVC" != "(kernel-wide)" ]; then
                    systemctl try-restart "$SVC" 2>/dev/null
                    echo "      try-restart $SVC             OK"
                fi
            done
        fi
    else
        echo "FAILED"
        STATUS="failed"
        GLOBAL_STATUS=1
    fi
    
    # Log faylına əlavə etmək (jq ilə)
    jq --arg pkg "$PKG" \
       --arg pre "$PRE_VER" \
       --arg post "$POST_VER" \
       --arg status "$STATUS" \
       --argjson dur "$DURATION" \
       '.entries += [{package: $pkg, pre: $pre, post: $post, status: $status, duration_seconds: $dur}]' "$LOG_FILE" > tmp.$$.json && mv tmp.$$.json "$LOG_FILE"
    
    COUNT=$((COUNT + 1))
done

# Yekun
END_TIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
jq --arg et "$END_TIME" '.finished_at = $et' "$LOG_FILE" > tmp.$$.json && mv tmp.$$.json "$LOG_FILE"

echo "Log saved to: $LOG_FILE"
exit $GLOBAL_STATUS
