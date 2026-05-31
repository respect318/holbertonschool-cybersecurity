#!/bin/bash

OUTPUT_FILE="vulnerability_inventory.json"
FEED_FILE="cve_feed.json"

echo '{"packages": []}' > "$OUTPUT_FILE"

# Enumerate all installed packages
INSTALLED_PKGS=$(dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n' 2>/dev/null)

# Analyze upgradable packages
apt list --upgradable 2>/dev/null | grep -v 'Listing...' | while read -r line; do
    pkg=$(echo "$line" | cut -d'/' -f1)
    cand_ver=$(echo "$line" | awk '{print $2}')
    
    # Check if installed
    inst_ver=$(echo "$INSTALLED_PKGS" | grep "^$pkg " | awk '{print $2}' | head -n 1)
    [ -z "$inst_ver" ] && continue
    
    # Determine pocket (security, updates, backports)
    pocket=$(apt-cache policy "$pkg" 2>/dev/null | grep -E 'security|updates|backports' | grep -oP '\w+-\w+' | head -n 1)
    [ -z "$pocket" ] && pocket="unknown"
    
    # CVE extraction via changelog
    cves=$(apt-get changelog "$pkg" 2>/dev/null | grep -o 'CVE-[0-9]\{4\}-[0-9]\+' | sort -u)
    
    # Fallback to USN mapping via ubuntu-advantage tools if changelog fails
    if [ -z "$cves" ]; then
        if [ -d "/usr/share/ubuntu-advantage-tools" ]; then
            cves=$(grep -r "USN" /usr/share/ubuntu-advantage-tools 2>/dev/null | grep -i "$pkg" | grep -o 'CVE-[0-9]\{4\}-[0-9]\+' | sort -u)
        fi
    fi
    
    if [ -n "$cves" ]; then
        max_cvss=0.0
        in_cisa="false"
        
        cve_array=$(echo "$cves" | jq -R -s -c 'split("\n")[:-1]')
        
        for cve in $cves; do
            if [ -f "$FEED_FILE" ]; then
                cvss=$(jq -r --arg c "$cve" '.[$c].cvss // 0' "$FEED_FILE")
                cisa=$(jq -r --arg c "$cve" '.[$c].in_cisa_kev // false' "$FEED_FILE")
                
                max_cvss=$(awk -v c="$cvss" -v m="$max_cvss" 'BEGIN { if(c>m) print c; else print m }')
                [ "$cisa" = "true" ] && in_cisa="true"
            fi
        done
        
        severity=$(awk -v m="$max_cvss" 'BEGIN {
            if (m == 0) print "unknown"
            else if (m < 4.0) print "low"
            else if (m < 7.0) print "medium"
            else if (m < 9.0) print "high"
            else print "critical"
        }')
        
        # Construct JSON output
        jq --arg pkg "$pkg" \
           --arg i_ver "$inst_ver" \
           --arg c_ver "$cand_ver" \
           --arg pkt "$pocket" \
           --argjson cvs "$cve_array" \
           --argjson mx "$max_cvss" \
           --arg sev "$severity" \
           --argjson cisa "$in_cisa" \
           '.packages += [{
               package: $pkg, 
               installed_version: $i_ver, 
               candidate_version: $c_ver, 
               source_pocket: $pkt, 
               cves: $cvs, 
               max_cvss: $mx, 
               severity: $sev, 
               in_cisa_kev: $cisa
           }]' "$OUTPUT_FILE" > tmp.json && mv tmp.json "$OUTPUT_FILE"
    fi
done
