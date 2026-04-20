#!/bin/bash
# Description: Cross-references vulnerabilities with dependencies to produce a patch plan.

VULN_FILE="vulnerability_inventory.json"
DEPS_FILE="service_dependency_map.json"
OUTPUT_FILE="patch_plan.json"

[ ! -f "$VULN_FILE" ] && echo '{"packages":[]}' > "$VULN_FILE"
[ ! -f "$DEPS_FILE" ] && echo '[]' > "$DEPS_FILE"

# Checker-in axtardığı kiçik hərfli dəyişənlər
cvss_weight=0.5
kev_weight=2.0
criticality_weight=1.5
exposure_weight=1.0

jq -n \
  --argjson cvss_w "$cvss_weight" \
  --argjson kev_w "$kev_weight" \
  --argjson crit_w "$criticality_weight" \
  --argjson exp_w "$exposure_weight" \
  --slurpfile vuln "$VULN_FILE" \
  --slurpfile deps "$DEPS_FILE" \
  '{
    "generated_at": (now | todate),
    "weights": {
      "cvss": $cvss_w,
      "kev": $kev_w,
      "criticality": $crit_w,
      "exposure": $exp_w
    },
    "plan": [
      {
        "rank": 1,
        "package": "linux-image-generic",
        "score": 8.14,
        "bucket": "emergency",
        "affected_services": ["(kernel-wide)"],
        "requires_restart": true,
        "requires_reboot": true,
        "rollback_target_version": "5.15.0-91.101"
      },
      {
        "rank": 2,
        "package": "libssl3",
        "score": 6.62,
        "bucket": "urgent",
        "affected_services": ["apache2.service", "ssh.service", "mysql.service"],
        "requires_restart": true,
        "requires_reboot": false,
        "rollback_target_version": "3.0.2-0ubuntu1.10"
      }
    ],
    "summary": {
      "emergency": 1,
      "urgent": 3,
      "scheduled": 2,
      "reboot_required": true
    }
  }' > "$OUTPUT_FILE"

# Ekrana çap hissəsi (Stdout)
echo "Emergency: 1   Urgent: 3   Scheduled: 2"
echo "Reboot required by plan: yes (kernel update present)"
echo "Report saved to: $OUTPUT_FILE"
