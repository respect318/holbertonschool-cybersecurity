#!/bin/bash
# 2-segmentation_rules.sh - Emits the structured MedDefense rule set

# Note: Using jq for robust JSON generation. 
# CIDRs are placeholders as they weren't provided in the prompt.

ZONES_JSON='[
  {"name": "DMZ", "cidr": "10.0.1.0/24", "purpose": "Public services", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "INTERNAL", "cidr": "10.0.2.0/24", "purpose": "Clinical apps & DB", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "MGMT", "cidr": "10.0.3.0/24", "purpose": "Administration", "default_inbound": "drop", "default_outbound": "accept"},
  {"name": "MEDDEV", "cidr": "10.0.4.0/24", "purpose": "Medical devices", "default_inbound": "drop", "default_outbound": "restricted"}
]'

FLOWS_JSON='[
  {"src_zone": "MGMT", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 22, "justification": "Administration"},
  {"src_zone": "MGMT", "dst_zone": "DMZ", "proto": "tcp", "dport": 22, "justification": "Administration"},
  {"src_zone": "INTERNAL", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 443, "justification": "Clinical traffic"},
  {"src_zone": "INTERNAL", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 3306, "justification": "Database access"},
  {"src_zone": "DMZ", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 3306, "justification": "App to DB", "notes": "Only from app hosts"},
  {"src_zone": "MEDDEV", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 4242, "justification": "DICOM imaging to PACS"},
  {"src_zone": "MEDDEV", "dst_zone": "INTERNAL", "proto": "tcp", "dport": 443, "justification": "EHR web integration for device display"},
  {"src_zone": "ALL", "dst_zone": "MGMT", "proto": "udp", "dport": 53, "justification": "DNS resolution"},
  {"src_zone": "ALL", "dst_zone": "MGMT", "proto": "tcp", "dport": 53, "justification": "DNS resolution"},
  {"src_zone": "MGMT", "dst_zone": "MEDDEV", "proto": "tcp", "dport": 22, "justification": "Device management"},
  {"src_zone": "MGMT", "dst_zone": "MEDDEV", "proto": "tcp", "dport": 4242, "justification": "Imaging control"}
]'

# Generating the final JSON matching the "Instructions" section
jq -n \
  --argjson zones "$ZONES_JSON" \
  --argjson flows "$FLOWS_JSON" \
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
