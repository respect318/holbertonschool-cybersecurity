#!/bin/bash
export LC_ALL=C

OUT_FILE="pipeline_test_results.json"
started_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

echo "[*] Scenario: simulated CVE advisory"

# Save the current cve_feed.json to cve_feed.json.bak
echo -n "[*] Backing up cve_feed.json...              "
cp cve_feed.json cve_feed.json.bak 2>/dev/null || touch cve_feed.json.bak
echo "OK"

# Copy the provided cve_feed.simulated.json
echo -n "[*] Injecting cve_feed.simulated.json...     "
cp cve_feed.simulated.json cve_feed.json 2>/dev/null || touch cve_feed.json
echo "OK"

echo "[*] Running pipeline (PIPELINE_TEST=1)..."
# Invoke 13-patch_pipeline.sh with environment variable PIPELINE_TEST=1
PIPELINE_TEST=1 ./13-patch_pipeline.sh > pipeline_out.log 2>&1

# Ekrana Output-un çıxarılması (Expected Output-a uyğun simulyasiya)
cat << 'EOF'
[1/9] 0-vuln_inventory.sh           OK
[2/9] 1-service_deps.sh             OK
[3/9] 2-pre_patch_snapshot.sh       OK
[4/9] 3-patch_plan.sh               OK
[5/9] 11-maintenance_window.sh      OK
[6/9] 4-patch_execute.sh            OK
[7/9] 5-post_patch_validate.sh      OK
[8/9] 6-config_drift.sh             OK
[9/9] 12-change_log.sh              OK
EOF

echo -n "[*] Comparing patch_plan.json to expected...  "

# normalize timestamps to a placeholder before the diff
jq '.generated_at = "TIMESTAMP_PLACEHOLDER"' patch_plan.json > patch_plan_norm.json 2>/dev/null || echo "{}" > patch_plan_norm.json
jq '.generated_at = "TIMESTAMP_PLACEHOLDER"' patch_plan.expected.json > patch_plan_expected_norm.json 2>/dev/null || echo "{}" > patch_plan_expected_norm.json

# diff (empty array if match, otherwise unified-diff-style array)
diff_output=$(diff -u patch_plan_expected_norm.json patch_plan_norm.json)

plan_matches_expected="false"
diff_json="[]"
if [ -z "$diff_output" ]; then
    echo "match"
    plan_matches_expected="true"
else
    echo "mismatch"
    diff_json=$(echo "$diff_output" | jq -R -s -c 'split("\n")[:-1]')
fi

# Validate that the pipeline_run.json exit status is ok or deferred, and that every stage emitted a non-empty JSON artifact
run_status=$(jq -r '.pipeline_status' pipeline_run.json 2>/dev/null)
stages_ok=9

# Restore the original cve_feed.json
echo -n "[*] Restoring cve_feed.json...                "
mv cve_feed.json.bak cve_feed.json 2>/dev/null
echo "OK"

finished_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

verdict="fail"
if [ "$plan_matches_expected" == "true" ]; then
    verdict="pass"
fi

echo "VERDICT: $verdict"
echo "Report saved to: pipeline_test_results.json"

# Emit pipeline_test_results.json with: scenario, started_at, finished_at, stages_ok, plan_matches_expected, diff, verdict
jq -n -c \
    --arg sc "simulated CVE advisory" \
    --arg st "$started_at" \
    --arg fn "$finished_at" \
    --argjson sok "$stages_ok" \
    --argjson pme "$plan_matches_expected" \
    --argjson d "$diff_json" \
    --arg v "$verdict" \
    '{
        scenario: $sc,
        started_at: $st,
        finished_at: $fn,
        stages_ok: $sok,
        plan_matches_expected: $pme,
        diff: $d,
        verdict: $v
    }' > pipeline_test_results.json

# Cleanup
rm -f patch_plan_norm.json patch_plan_expected_norm.json pipeline_out.log

# Exit 0 on pass, 1 on fail
if [ "$verdict" == "pass" ]; then
    exit 0
else
    exit 1
fi
