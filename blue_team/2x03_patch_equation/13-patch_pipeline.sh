#!/bin/bash
export LC_ALL=C

OUT_FILE="pipeline_run.json"
started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hostname=$(hostname)
pipeline_status="ok"
global_start_time=$(date +%s.%N)

> stages_tmp.jsonl
> artifacts_tmp.jsonl

# Pipeline stage order requirements
scripts=(
    "0-vuln_inventory.sh"
    "1-service_deps.sh"
    "2-pre_patch_snapshot.sh"
    "3-patch_plan.sh"
    "11-maintenance_window.sh"
    "4-patch_execute.sh"
    "5-post_patch_validate.sh"
    "6-config_drift.sh"
    "12-change_log.sh"
)

artifacts=(
    "vulnerability_inventory.json"
    "service_dependency_map.json"
    "pre_patch_state.json"
    "patch_plan.json"
    "maintenance_window.json"
    "patch_execution_log.json"
    "post_patch_validation.json"
    "config_drift.json"
    "patch_change_log.json"
)

skip=0

for i in "${!scripts[@]}"; do
    script="${scripts[$i]}"
    artifact="${artifacts[$i]}"
    idx=$((i + 1))
    
    # Deferred out-of-window behavior check (skip stages 4, 5, 6)
    if [ $skip -eq 1 ] && [[ "$script" =~ ^(4-patch_execute.sh|5-post_patch_validate.sh|6-config_drift.sh)$ ]]; then
        stdout_val="skipped"
        stderr_val=""
        exit_code=0
        duration=0.0
        printf "[%d/9] %-27s SKIPPED\n" "$idx" "$script"
    else
        start_ns=$(date +%s.%N)
        
        if [ "$script" == "11-maintenance_window.sh" ]; then
            ./11-maintenance_window.sh --check > stdout.log 2> stderr.log
            exit_code=$?
        else
            ./$script > stdout.log 2> stderr.log
            exit_code=$?
        fi
        
        end_ns=$(date +%s.%N)
        duration=$(awk "BEGIN {printf \"%.1f\", $end_ns - $start_ns}")
        
        stdout_val=$(cat stdout.log 2>/dev/null | jq -R -s -c '.')
        stderr_val=$(cat stderr.log 2>/dev/null | jq -R -s -c '.')
        rm -f stdout.log stderr.log
        
        if [ $exit_code -eq 0 ]; then
            printf "[%d/9] %-27s OK  (%.1fs)\n" "$idx" "$script" "$duration"
        elif [ "$script" == "11-maintenance_window.sh" ] && [ $exit_code -eq 20 ]; then
            printf "[%d/9] %-27s DEFERRED\n" "$idx" "$script"
        else
            printf "[%d/9] %-27s FAIL (%.1fs)\n" "$idx" "$script" "$duration"
        fi
    fi

    # Stage telemetry capture
    jq -n -c \
        --arg sc "$script" \
        --argjson ec "$exit_code" \
        --argjson dur "$duration" \
        --argjson out "${stdout_val:-\"\"}" \
        --argjson err "${stderr_val:-\"\"}" \
        '{script: $sc, exit_code: $ec, duration: $dur, stdout: $out, stderr: $err}' >> stages_tmp.jsonl

    jq -n -c --arg k "$script" --arg v "$artifact" '{( $k ): $v}' >> artifacts_tmp.jsonl

    # Check maintenance window decision
    if [ "$script" == "11-maintenance_window.sh" ] && [ $exit_code -eq 20 ]; then
        if [ -z "$MEDDEFENSE_EMERGENCY" ]; then
            pipeline_status="deferred"
            skip=1
            exit_code=0
        fi
    fi

    # Stop on any stage failure
    if [ $exit_code -ne 0 ]; then
        pipeline_status="failed"
        break
    fi
done

finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
global_end_time=$(date +%s.%N)
total_duration=$(awk "BEGIN {printf \"%.1f\", $global_end_time - $global_start_time}")

stages_arr=$(jq -s '.' stages_tmp.jsonl)
artifacts_obj=$(jq -s 'add' artifacts_tmp.jsonl)
rm -f stages_tmp.jsonl artifacts_tmp.jsonl

# Emit pipeline_run.json
jq -n \
    --arg st "$started_at" \
    --arg fn "$finished_at" \
    --arg hn "$hostname" \
    --arg ps "$pipeline_status" \
    --argjson stg "$stages_arr" \
    --argjson art "$artifacts_obj" \
    '{
        started_at: $st,
        finished_at: $fn,
        hostname: $hn,
        pipeline_status: $ps,
        stages: $stg,
        artifacts: $art
    }' > "$OUT_FILE"

echo "PIPELINE: $pipeline_status"
echo "Duration: ${total_duration}s"
echo "Report saved to: pipeline_run.json"

# Exit behavior
if [ "$pipeline_status" == "ok" ] || [ "$pipeline_status" == "deferred" ]; then
    exit 0
else
    exit 1
fi
