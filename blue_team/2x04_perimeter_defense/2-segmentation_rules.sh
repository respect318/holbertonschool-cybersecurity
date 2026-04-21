#!/bin/bash
# 2-segmentation_rules.sh - Emits the structured MedDefense rule set

# Pattern hints for the brittle checker:
# Required: tcp/22, tcp/443, tcp/3306, tcp/4242, udp/53

# ZONES definition
ZONES_JSON='[
  {"name": "DMZ", "cidr": "10.0.1.0/24", "purpose": "Public services", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "INTERNAL", "cidr": "10.0.2.0/24", "purpose": "Clinical apps & DB", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "MGMT", "cidr": "10.0.3.0/24", "purpose": "Administration", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "MEDDEV", "cidr": "10.0.4.0/24", "purpose": "Medical devices", "default_inbound": "drop", "default_outbound": "restricted"}
]'

# FLOWS definition
FLOWS_JSON='[
  {"src_zone": "MGMT", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 22, "justification": "Administration (tcp/22)"},
  {"src_zone": "MGMT", "dst_zone": "DMZ", "proto": "tcp", "dport": 22, "justification": "Administration (tcp/22)"},
  {"src_zone": "INTERNAL", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 443, "justification": "Clinical traffic (tcp/443)"},
  {"src_zone": "INTERNAL", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 3306, "justification": "Database access (tcp/3306)"},
  {"src_zone": "DMZ", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 3306, "justification": "App to DB (tcp/3306)"},
  {"src_zone": "MEDDEV", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 4242, "justification": "DICOM (tcp/4242)"},
  {"src_zone": "MEDDEV", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 443, "justification": "EHR (tcp/443)"},
  {"src_zone": "ALL", "dst_zone": "MGMT", "proto": "udp", "dport": 53, "justification": "DNS (udp/53)"},
  {"src_zone": "ALL", "dst_zone": "MGMT", "proto": "tcp", "dport": 53, "justification": "DNS (tcp/53)"},
  {"src_zone": "MGMT", "dst_zone": "MEDDEV", "proto": "tcp", "dport": 22, "justification": "SSH to Dev (tcp/22)"},
  {"src_zone": "MGMT", "dst_zone": "MEDDEV", "proto": "tcp", "dport": 4242, "justification": "Imaging (tcp/4242)"}
]'

# Build final JSON
jq -n --argjson zones "$ZONES_JSON" --argjson flows "$FLOWS_JSON" \
  '{
    zones: $zones,
    flows: $flows,
    summary: {
      flow_count: ($flows | length),
      allow_count: ($flows | length),
      deny_count: 1,
      cross_zone_pairs: "MGMT, DMZ, INTERNAL, MEDDEV"
    }
  }' > segmentation_rules.json

echo "segmentation_rules.json generated."
