#!/bin/bash

STATE_DIR="/tmp/rtest_state"
LOG_FILE="recovery_test_log.txt"
RTO_MINUTES=30

mkdir -p "$STATE_DIR"

usage() {
    echo "Usage: $0 \"<step name>\" START|PASS|FAIL"
    echo "       $0 SUMMARY"
    exit 1
}

get_seconds() {
    date '+%s'
}

get_timestamp() {
    date '+%H:%M:%S'
}

get_step_count() {
    local count=0
    if [ -f "$STATE_DIR/step_count" ]; then
        count=$(cat "$STATE_DIR/step_count")
    fi
    echo "$count"
}

increment_step_count() {
    local count
    count=$(get_step_count)
    count=$((count + 1))
    echo "$count" > "$STATE_DIR/step_count"
    echo "$count"
}

if [ "$1" = "SUMMARY" ]; then
    if [ ! -f "$STATE_DIR/test_start_epoch" ]; then
        echo "ERROR: No test in progress. Run a step with START first."
        exit 1
    fi

    test_start=$(cat "$STATE_DIR/test_start_epoch")
    test_end=$(get_seconds)
    total_elapsed=$((test_end - test_start))
    total_minutes=$((total_elapsed / 60))
    total_seconds=$((total_elapsed % 60))

    echo ""
    echo "========================================"
    echo "       LIS RECOVERY TEST SUMMARY"
    echo "========================================"
    echo ""
    echo "Total elapsed time: ${total_minutes}m ${total_seconds}s"
    echo "Declared RTO: ${RTO_MINUTES} minutes"
    echo ""

    if [ "$total_minutes" -lt "$RTO_MINUTES" ]; then
        echo "RTO STATUS: PASS — Recovery completed within the 30-minute RTO"
    else
        echo "RTO STATUS: FAIL — Recovery exceeded the 30-minute RTO"
    fi

    echo ""
    echo "--- Step Log ---"
    if [ -f "$LOG_FILE" ]; then
        cat "$LOG_FILE"
    else
        echo "(No steps logged)"
    fi
    echo "========================================"

    # Append summary to log
    echo "" >> "$LOG_FILE"
    echo "SUMMARY | Total elapsed: ${total_minutes}m ${total_seconds}s | RTO (${RTO_MINUTES} min): $([ "$total_minutes" -lt "$RTO_MINUTES" ] && echo PASS || echo FAIL)" >> "$LOG_FILE"
    exit 0
fi

if [ $# -lt 2 ]; then
    usage
fi

STEP_NAME="$1"
STATUS="$2"
SAFE_NAME=$(echo "$STEP_NAME" | tr ' ' '_' | tr -cd '[:alnum:]_')

case "$STATUS" in
    START)
        now_epoch=$(get_seconds)
        now_ts=$(get_timestamp)

        # Record global test start if first step
        if [ ! -f "$STATE_DIR/test_start_epoch" ]; then
            echo "$now_epoch" > "$STATE_DIR/test_start_epoch"
        fi

        # Store step start info
        echo "$now_epoch" > "$STATE_DIR/step_${SAFE_NAME}_start_epoch"
        echo "$now_ts" > "$STATE_DIR/step_${SAFE_NAME}_start_ts"
        echo "$STEP_NAME" > "$STATE_DIR/step_${SAFE_NAME}_name"

        echo "[$(get_timestamp)] STARTED: $STEP_NAME"
        ;;

    PASS|FAIL)
        if [ ! -f "$STATE_DIR/step_${SAFE_NAME}_start_epoch" ]; then
            echo "ERROR: No START recorded for step: $STEP_NAME"
            exit 1
        fi

        start_epoch=$(cat "$STATE_DIR/step_${SAFE_NAME}_start_epoch")
        start_ts=$(cat "$STATE_DIR/step_${SAFE_NAME}_start_ts")
        end_epoch=$(get_seconds)
        end_ts=$(get_timestamp)

        elapsed=$((end_epoch - start_epoch))
        dur_min=$((elapsed / 60))
        dur_sec=$((elapsed % 60))

        step_num=$(increment_step_count)
        step_num_fmt=$(printf "%02d" "$step_num")

        log_line="[STEP ${step_num_fmt}] $(printf '%-35s' "$STEP_NAME") | Start: $start_ts | End: $end_ts | Duration: ${dur_min}m ${dur_sec}s | $STATUS"

        echo "$log_line" | tee -a "$LOG_FILE"
        ;;

    *)
        echo "ERROR: Unknown status '$STATUS'. Use START, PASS, FAIL, or SUMMARY."
        exit 1
        ;;
esac
