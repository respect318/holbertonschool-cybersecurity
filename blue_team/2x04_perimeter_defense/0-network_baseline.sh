#!/bin/bash
# 0-network_baseline.sh - Captures network baseline in JSON format

# Requirement: Idempotency and Root check (though not explicitly asked, sudo is implied)
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Collecting data
HOSTNAME=$(hostname)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Interfaces, Routes, Neighbors using built-in JSON support in iproute2
INTERFACES=$(ip -j addr show)
ROUTES=$(ip -j route show)
NEIGHBORS=$(ip -j neigh show)

# Sockets - Handling the hint about JSON support
if ss -j -h > /dev/null 2>&1; then
    LISTENING_SOCKETS=$(ss -tulnpHj)
    ESTABLISHED=$(ss -tnpH state established -j)
else
    # Fallback to a simple count/string if -j is not supported to keep script running
    LISTENING_SOCKETS="\"JSON not supported by ss, raw: $(ss -tulnpH | tr '\n' ' ')\""
    ESTABLISHED="\"JSON not supported by ss, raw: $(ss -tnpH state established | tr '\n' ' ')\""
fi

# DNS Resolvers
DNS_CONF=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}' | jq -R . | jq -s .)
RESOLVE_CTL=$(resolvectl status --no-pager 2>/dev/null || echo "not active")

# Emitting JSON (Constructing complex JSON with jq is safest)
jq -n \
  --arg hn "$HOSTNAME" \
  --arg ts "$TIMESTAMP" \
  --argjson iface "$INTERFACES" \
  --argjson rt "$ROUTES" \
  --argjson neigh "$NEIGHBORS" \
  --argjson listen "$LISTENING_SOCKETS" \
  --argjson estab "$ESTABLISHED" \
  --arg dns_res "$RESOLVE_CTL" \
  '{
    timestamp: $ts,
    hostname: $hn,
    interfaces: $iface,
    routes: $rt,
    neighbors: $neigh,
    listening_sockets: $listen,
    established_connections: $estab,
    dns_resolvers: $dns_res
  }' > network_baseline.json

echo "network_baseline.json has been generated."
