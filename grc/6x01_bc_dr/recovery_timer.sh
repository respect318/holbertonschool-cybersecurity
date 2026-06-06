#!/bin/bash

STATE_FILE="/tmp/rtest_state"
LOG_FILE="recovery_test_log.txt"
RTO_LIMIT=1800 # 30 minutes in seconds

if [ "$1" == "SUMMARY" ]; then
    if [ ! -f "$STATE_FILE.total" ]; then
        echo "No test data found."
        exit 1
    fi
    TOTAL_SEC=$(cat "$STATE_FILE.total")
    TOTAL_MIN=$((TOTAL_SEC / 60))
    TOTAL_REM_SEC=$((TOTAL_SEC % 60))

    echo "Total elapsed time: ${TOTAL_MIN}m ${TOTAL_REM_SEC}s" | tee -a "$LOG_FILE"
    
    # Evaluate against the 30-minute RTO
    if [ "$TOTAL_SEC" -le "$RTO_LIMIT" ]; then
        echo "RTO (30 minutes) Evaluation: PASS" | tee -a "$LOG_FILE"
    else
        echo "RTO (30 minutes) Evaluation: FAIL" | tee -a "$LOG_FILE"
    fi
    exit 0
fi

STEP_NAME="$1"
STATUS="$2"

if [ "$STATUS" == "START" ]; then
    START_TS=$(date +%s)
    START_TIME=$(date '+%H:%M:%S')
    echo "$START_TS|$START_TIME" > "$STATE_FILE"
    
    if [ ! -f "$STATE_FILE.step" ]; then echo "1" > "$STATE_FILE.step"; fi
    if [ ! -f "$STATE_FILE.total" ]; then echo "0" > "$STATE_FILE.total"; fi

elif [ "$STATUS" == "PASS" ] || [ "$STATUS" == "FAIL" ]; then
    if [ ! -f "$STATE_FILE" ]; then 
        echo "Error: Start state missing."
        exit 1
    fi
    
    IFS='|' read -r START_TS START_TIME < "$STATE_FILE"
    END_TS=$(date +%s)
    END_TIME=$(date '+%H:%M:%S')
    
    DURATION_SEC=$((END_TS - START_TS))
    DUR_MIN=$((DURATION_SEC / 60))
    DUR_REM_SEC=$((DURATION_SEC % 60))

    STEP_NUM=$(cat "$STATE_FILE.step")
    PADDED_STEP=$(printf "%02d" $STEP_NUM)

    LOG_ENTRY="[STEP $PADDED_STEP] $STEP_NAME | Start: $START_TIME | End: $END_TIME | Duration: ${DUR_MIN}m ${DUR_REM_SEC}s | $STATUS"
    echo "$LOG_ENTRY" | tee -a "$LOG_FILE"

    NEXT_STEP=$((STEP_NUM + 1))
    echo "$NEXT_STEP" > "$STATE_FILE.step"

    TOTAL_SEC=$(cat "$STATE_FILE.total")
    NEW_TOTAL=$((TOTAL_SEC + DURATION_SEC))
    echo "$NEW_TOTAL" > "$STATE_FILE.total"
    
    rm -f "$STATE_FILE"
fi
