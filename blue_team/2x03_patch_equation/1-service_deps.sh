#!/bin/bash
# Description: Builds a service-to-package dependency map using systemctl, ldd, and dpkg.

OUTPUT_FILE="service_dependency_map.json"
CRIT_FILE="service_criticality.json"

# Empty/create the output file
> "$OUTPUT_FILE"

# Ensure the criticality JSON exists to prevent jq errors
if [[ ! -f "$CRIT_FILE" ]]; then
    echo "{}" > "$CRIT_FILE"
fi

# Get all active running systemd services
systemctl list-units --type=service --state=running --no-pager --no-legend | awk '{print $1}' | while read -r service; do
    
    # Get Main PID of the service
    pid=$(systemctl show -p MainPID --value "$service" 2>/dev/null)
    
    # Skip if no valid PID (e.g., oneshot services that exited)
    if [[ -z "$pid" || "$pid" == "0" ]]; then
        continue
    fi

    # Resolve executable path
    exec_path=$(readlink -f "/proc/$pid/exe" 2>/dev/null)
    
    # Skip if path cannot be resolved (requires sudo for many services)
    if [[ -z "$exec_path" || ! -f "$exec_path" ]]; then
        continue
    fi

    # Find the owning package
    owning_package=$(dpkg -S "$exec_path" 2>/dev/null | awk -F: '{print $1}')
    [[ -z "$owning_package" ]] && owning_package="unknown"

    # Find dynamic libraries and map to packages (Optimized bulk dpkg lookup)
    lib_paths=$(ldd "$exec_path" 2>/dev/null | awk '{print $3}' | grep "^/")
    
    if [[ -n "$lib_paths" ]]; then
        # shellcheck disable=SC2086 # We want word splitting here to pass multiple paths
        linked_pkgs=$(dpkg -S $lib_paths 2>/dev/null | awk -F: '{print $1}' | sort -u | jq -R . | jq -s .)
    else
        linked_pkgs="[]"
    fi

    # Determine criticality (fallback to "low")
    criticality=$(jq -r --arg srv "$service" '.[$srv] // "low"' "$CRIT_FILE" 2>/dev/null)
    
    # Placeholder for restart_required logic (assume true if linked packages exist)
    restart_required="true"

    # Emit JSON object (Outputting as JSON Lines to match expected output format)
    jq -n --arg srv "$service" \
          --arg ep "$exec_path" \
          --arg op "$owning_package" \
          --argjson lp "$linked_pkgs" \
          --arg crit "$criticality" \
          --argjson rr "$restart_required" \
          '{
              service: $srv,
              exec_path: $ep,
              owning_package: $op,
              linked_packages: $lp,
              criticality: $crit,
              restart_required_on_patch: $rr
          }' >> "$OUTPUT_FILE"

done
