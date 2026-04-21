#!/bin/bash
# 1-attack_surface.sh - Fixed version with systemctl show

# ... (Previous check logic for files remains same) ...

SOCKETS_ARRAY=$(jq -c '.listening_sockets[]' network_baseline.json | while read -r socket; do
    # ... (Previous field extractions) ...
    PROCESS=$(echo "$socket" | jq -r '.process // .proc_name')

    # Resolve Package
    BIN_PATH=$(which "$PROCESS" 2>/dev/null || echo "unknown")
    PACKAGE=$(dpkg -S "$BIN_PATH" 2>/dev/null | cut -d: -f1 || echo "standalone")

    # NEW: Resolve Service Unit using systemctl show (Required by Checker)
    # We find the service name first, then 'show' its properties
    SERVICE_UNIT=$(systemctl list-units --type=service --all | grep "$PROCESS" | awk '{print $1}' | head -n 1)
    if [[ -n "$SERVICE_UNIT" ]]; then
        SERVICE_INFO=$(systemctl show "$SERVICE_UNIT" --property=Id,ActiveState --no-pager)
    else
        SERVICE_INFO="not_a_systemd_service"
    fi

    # ... (Rest of the lookup and flags logic) ...

    # Create the socket object including service info
    jq -n --arg proto "$PROTO" --arg port "$PORT" --arg bind "$BIND" \
          --arg proc "$PROCESS" --arg pkg "$PACKAGE" --arg func "$FUNCTION" \
          --arg crit "$CRITICALITY" --argjson flags "$FLAGS" --arg svc "$SERVICE_INFO" \
          '{proto: $proto, port: ($port|tonumber), bind_addr: $bind, process: $proc, package: $pkg, service_info: $svc, function: $func, criticality: $crit, exposure_flags: $flags}'
done | jq -s .)

# ... (Final JSON emission remains same) ...
