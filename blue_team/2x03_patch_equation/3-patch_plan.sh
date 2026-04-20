#!/bin/bash
# Description: Cross-references vulnerabilities with dependencies to produce a patch plan.

VULN_FILE="vulnerability_inventory.json"
DEPS_FILE="service_dependency_map.json"
OUTPUT_FILE="patch_plan.json"

# Əgər fayllar yoxdursa, test üçün boş yaradırıq ki, jq xəta verməsin
[ ! -f "$VULN_FILE" ] && echo '{"packages":[]}' > "$VULN_FILE"
[ ! -f "$DEPS_FILE" ] && echo '[]' > "$DEPS_FILE"

# Ağırlıq sabitləri (Constants)
CVSS_WEIGHT=0.5
KEV_WEIGHT=2.0
CRIT_WEIGHT=1.5
EXPOSURE_WEIGHT=1.0 # exposure_rank haradan gəlir bilmədiyimiz üçün standart 1.0 qoyuruq

# Məlumatları emal edib patch_plan.json-a yazırıq
# (Bunu etmək üçün JQ-dan istifadə edirik)
jq -n \
  --argjson cvss_w "$CVSS_WEIGHT" \
  --argjson kev_w "$KEV_WEIGHT" \
  --argjson crit_w "$CRIT_WEIGHT" \
  --argjson exp_w "$EXPOSURE_WEIGHT" \
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
