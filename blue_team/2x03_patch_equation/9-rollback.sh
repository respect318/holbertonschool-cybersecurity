#!/bin/bash
export LC_ALL=C

if [ -z "$1" ]; then
    echo "Usage: $0 <package>"
    exit 1
fi

# package argument handling
package="$1"

PRE_FILE="pre_patch_state.json"
DEPS_FILE="service_dependency_map.json"
PROBES_FILE="service_probes.json"
OUT_FILE="rollback_result.json"

# Load target version from pre_patch_state.json (packages array)
target_version=$(jq -r --arg p "$package" '.packages[] | select(.package == $p) | .version' "$PRE_FILE" 2>/dev/null)

if [ -z "$target_version" ] || [ "$target_version" = "null" ]; then
    echo "Error: target version for package $package not found in $PRE_FILE"
    exit 1
fi

echo "[*] Target version from pre_patch_state.json: $target_version"

# Confirm version is available via apt-cache madison
madison_check=$(apt-cache madison "$package" 2>/dev/null | grep "$target_version")
if [ -z "$madison_check" ]; then
    echo "[*] Version available in cache: no"
    exit 1
else
    echo "[*] Version available in cache: yes"
fi

from_version=$(dpkg-query -W -f='${Version}' "$package" 2>/dev/null || echo "none")
to_version="$target_version"

# Execute allow-downgrades apt install
printf "[*] Downgrading %-41s " "$package..."
DEBIAN_FRONTEND=noninteractive apt-get install -y --allow-downgrades "${package}=${target_version}" >/dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "OK"
    success_bool="true"
else
    echo "FAIL"
    success_bool="false"
fi

# Apply apt-mark hold
hold_applied="false"
if [ "$success_bool" = "true" ]; then
    printf "[*] apt-mark hold %-39s " "$package"
    apt-mark hold "$package" >/dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "OK"
        hold_applied="true"
    else
        echo "FAIL"
    fi
fi

echo "[*] Re-running probes for affected services..."
> probes_tmp.jsonl

if [ "$success_bool" = "true" ] && [ -f "$DEPS_FILE" ] && [ -f "$PROBES_FILE" ]; then
    affected_services=$(jq -r --arg p "$package" '.[] | select(.linked_packages[]? == $p) | .service' "$DEPS_FILE" 2>/dev/null | sort -u)
    
    for srv in $affected_services; do
        probe_cmd=$(jq -r --arg s "$srv" '.[$s] // empty' "$PROBES_FILE" 2>/dev/null)
        if [ -n "$probe_cmd" ] && [ "$probe_cmd" != "null" ]; then
            if eval "$probe_cmd" >/dev/null 2>&1; then
                printf "    %-46s PASS\n" "$srv probe ($probe_cmd)"
                jq -n -c --arg s "$srv" --arg st "PASS" '{service: $s, status: $st}' >> probes_tmp.jsonl
            else
                printf "    %-46s FAIL\n" "$srv probe ($probe_cmd)"
                jq -n -c --arg s "$srv" --arg st "FAIL" '{service: $s, status: $st}' >> probes_tmp.jsonl
                success_bool="false"
            fi
        fi
    done
fi

if [ -s probes_tmp.jsonl ]; then
    probes_json=$(jq -s '.' probes_tmp.jsonl)
else
    probes_json="[]"
fi
rm -f probes_tmp.jsonl

# Emit rollback_result.json
jq -n \
    --arg p "$package" \
    --arg fv "$from_version" \
    --arg tv "$to_version" \
    --argjson ha "$hold_applied" \
    --argjson pr "$probes_json" \
    --argjson suc "$success_bool" \
    '{
        package: $p,
        from_version: $fv,
        to_version: $tv,
        hold_applied: $ha,
        probes: $pr,
        success: $suc
    }' > "$OUT_FILE"

res_text="success"
[ "$success_bool" = "false" ] && res_text="failure"

echo "ROLLBACK: $res_text"
echo "from $from_version to $to_version"
echo "Report saved to: rollback_result.json"

if [ "$success_bool" = "true" ]; then
    exit 0
else
    exit 1
fi
