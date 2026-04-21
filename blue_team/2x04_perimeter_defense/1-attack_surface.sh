#!/bin/bash
# 1-attack_surface.sh - Classifies attack surface based on baseline data

# Check for required input files
if [[ ! -f "network_baseline.json" ]] || [[ ! -f "service_catalog.json" ]] || [[ ! -f "service_criticality.json" ]]; then
    echo "Required JSON mapping files are missing."
    exit 1
fi

GENERATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
HOSTNAME=$(hostname)

# Process sockets and build the JSON array using jq
# Note: This logic assumes jq is available as per previous pedagogical suggestions
SOCKETS_ARRAY=$(jq -c '.listening_sockets[]' network_baseline.json | while read -r socket; do
    PORT=$(echo "$socket" | jq -r '.port // .local_port')
    PROTO=$(echo "$socket" | jq -r '.proto')
    BIND=$(echo "$socket" | jq -r '.address // .local_addr')
    PROCESS=$(echo "$socket" | jq -r '.process // .proc_name')
    
    # Resolve Package
    BIN_PATH=$(which "$PROCESS" 2>/dev/null || echo "unknown")
    PACKAGE=$(dpkg -S "$BIN_PATH" 2>/dev/null | cut -d: -f1 || echo "standalone")
    
    # Lookup Function and Criticality (Mocking lookup based on Catalog)
    FUNCTION=$(jq -r --arg p "$PROCESS" '.[$p] // "unknown"' service_catalog.json)
    CRITICALITY=$(jq -r --arg f "$FUNCTION" '.[$f] // "medium"' service_criticality.json)
    
    # Exposure Flags Logic
    FLAGS="[]"
    if [[ "$BIND" == "0.0.0.0" ]] && [[ "$FUNCTION" == "database" || "$FUNCTION" == "rpc" ]]; then
        FLAGS=$(echo "$FLAGS" | jq -c '. + ["bound_0.0.0.0", "database_exposed"]')
    fi
    
    # Insecure protocols check
    if [[ "$FUNCTION" =~ ^(telnet|ftp|snmpv1|snmpv2c|rlogin|nfs)$ ]]; then
        FLAGS=$(echo "$FLAGS" | jq -c --arg f "insecure_protocol_$FUNCTION" '. + [$f]')
    fi

    # Create the socket object
    jq -n --arg proto "$PROTO" --arg port "$PORT" --arg bind "$BIND" \
          --arg proc "$PROCESS" --arg pkg "$PACKAGE" --arg func "$FUNCTION" \
          --arg crit "$CRITICALITY" --argjson flags "$FLAGS" \
          '{proto: $proto, port: ($port|tonumber), bind_addr: $bind, process: $proc, package: $pkg, function: $func, criticality: $crit, exposure_flags: $flags}'
done | jq -s .)

# Emit the final JSON with summary
echo "$SOCKETS_ARRAY" | jq --arg ts "$GENERATED_AT" --arg hn "$HOSTNAME" \
  '{generated_at: $ts, hostname: $hn, sockets: ., summary: {flagged_total: ([.[] | select(.exposure_flags | length > 0)] | length), unknown_functions: ([.[] | select(.function == "unknown")] | length)}}' \
  > attack_surface.json

echo "attack_surface.json generated successfully."
