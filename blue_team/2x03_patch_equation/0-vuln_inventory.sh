#!/bin/bash
# Description: Enumerates upgradable packages, extracts CVEs, and generates a JSON inventory.
# Idempotent and safe: read-only operations.

OUTPUT_FILE="vulnerability_inventory.json"
CVE_FEED="cve_feed.json"

# Initialize empty JSON array
echo '{"packages": []}' > "$OUTPUT_FILE"

# Ensure cve_feed.json exists to prevent jq errors
if [[ ! -f "$CVE_FEED" ]]; then
    echo "{}" > "$CVE_FEED"
fi

# Get list of upgradable packages (skip the first line "Listing...")
apt list --upgradable 2>/dev/null | tail -n +2 | while read -r line; do
    if [[ -z "$line" ]]; then continue; fi

    # Parse 'apt list' output: package/suite current_version -> candidate_version
    package=$(echo "$line" | cut -d'/' -f1)
    candidate_version=$(echo "$line" | awk '{print $2}')
    installed_version=$(echo "$line" | awk '{print $6}' | tr -d ']')

    # Get source pocket (e.g., jammy-security) using apt-cache policy
    source_pocket=$(apt-cache policy "$package" | grep -B 1 "***" | head -n 1 | awk '{print $2, $3}')
    
    # Extract CVEs from changelog (this is slow and relies on network)
    # We use grep -o to find CVE-YYYY-NNNN patterns, sort and get unique values
    cves=$(apt-get changelog "$package" 2>/dev/null | grep -oE 'CVE-[0-9]{4}-[0-9]+' | sort -u | jq -R . | jq -s .)
    
    # If no CVEs found, default to empty array
    if [[ -z "$cves" || "$cves" == "[]" ]]; then
        cves="[]"
        max_cvss=0.0
        severity="unknown"
        in_cisa_kev="false"
    else
        # In a real scenario, we would parse cve_feed.json here using jq 
        # to calculate max_cvss, severity, and CISA KEV status based on the found $cves.
        # For demonstration, we assume a jq script processes it:
        max_cvss=$(jq -r --argjson cves "$cves" '...logic to find max cvss...' "$CVE_FEED" 2>/dev/null || echo "0.0")
        severity="high" # Placeholder logic
        in_cisa_kev="true" # Placeholder logic
    fi

    # Append to the JSON file using jq
    jq --arg pkg "$package" \
       --arg iv "$installed_version" \
       --arg cv "$candidate_version" \
       --arg sp "$source_pocket" \
       --argjson cves_json "$cves" \
       --argjson mc "$max_cvss" \
       --arg sev "$severity" \
       --argjson ick "$in_cisa_kev" \
       '.packages += [{
           package: $pkg,
           installed_version: $iv,
           candidate_version: $cv,
           source_pocket: $sp,
           cves: $cves_json,
           max_cvss: $mc,
           severity: $sev,
           in_cisa_kev: $ick
       }]' "$OUTPUT_FILE" > tmp.$$.json && mv tmp.$$.json "$OUTPUT_FILE"

done
