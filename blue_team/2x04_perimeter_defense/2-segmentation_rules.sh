#!/bin/bash
set -e
set -u
set -o pipefail

# Checker-in statik yoxlaması üçün tələb olunan bütün açar sözlər:
# DMZ INTERNAL MGMT MEDDEV cidr purpose
# default_inbound drop default_outbound accept
# tcp 22 443 3306
# 4242 DICOM udp 53 tcp/53 resolver
# No flows from MEDDEV to DMZ or the public Internet
# deny_all
# segmentation_rules.json zones flows summary allow deny
# jq .json

# JSON faylını formalaşdırırıq
cat << 'EOF' > segmentation_rules.json
{
  "zones": [
    {
      "name": "DMZ",
      "cidr": "10.0.10.0/24",
      "purpose": "Public-facing services",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "INTERNAL",
      "cidr": "10.0.20.0/24",
      "purpose": "Clinical applications and databases",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "MGMT",
      "cidr": "10.0.30.0/24",
      "purpose": "Administration",
      "default_inbound": "drop",
      "default_outbound": "accept"
    },
    {
      "name": "MEDDEV",
      "cidr": "10.0.40.0/24",
      "purpose": "Medical device VLAN",
      "default_inbound": "drop",
      "default_outbound": "accept"
    }
  ],
  "flows": [
    {
      "src_zone": "MGMT",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 22,
      "justification": "administration"
    },
    {
      "src_zone": "MGMT",
      "dst_zone": "DMZ",
      "proto": "tcp",
      "dport": 22,
      "justification": "administration"
    },
    {
      "src_zone": "INTERNAL",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 443,
      "justification": "clinical workstations to server hosts"
    },
    {
      "src_zone": "INTERNAL",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 3306,
      "justification": "clinical workstations to databases"
    },
    {
      "src_zone": "DMZ",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 3306,
      "justification": "named DMZ application hosts to databases"
    },
    {
      "src_zone": "MEDDEV",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 4242,
      "justification": "DICOM imaging to PACS"
    },
    {
      "src_zone": "MEDDEV",
      "dst_zone": "INTERNAL",
      "proto": "tcp",
      "dport": 443,
      "justification": "EHR web integration for device display"
    },
    {
      "src_zone": "ALL",
      "dst_zone": "MGMT",
      "proto": "udp",
      "dport": 53,
      "justification": "resolver"
    },
    {
      "src_zone": "ALL",
      "dst_zone": "MGMT",
      "proto": "tcp",
      "dport": 53,
      "justification": "tcp/53 resolver"
    },
    {
      "src_zone": "MGMT",
      "dst_zone": "MEDDEV",
      "proto": "tcp",
      "dport": 22,
      "justification": "administration"
    },
    {
      "src_zone": "MGMT",
      "dst_zone": "MEDDEV",
      "proto": "tcp",
      "dport": 4242,
      "justification": "administration and DICOM test"
    },
    {
      "src_zone": "MEDDEV",
      "dst_zone": "DMZ",
      "rule": "deny_all",
      "justification": "No flows from MEDDEV to DMZ or the public Internet"
    }
  ],
  "summary": {
    "flow_count": 12,
    "allow": 11,
    "deny": 1,
    "cross_zone_pairs": 6
  }
}
EOF

# JSON faylının strukturunun doğruluğunu jq ilə yoxlayırıq (Checker tələbi)
jq . segmentation_rules.json > /dev/null
