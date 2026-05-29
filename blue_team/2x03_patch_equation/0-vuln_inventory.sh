#!/bin/bash

# Fayl yolları
FEED_FILE="cve_feed.json"
OUTPUT_FILE="vulnerability_inventory.json"

# Nəticəni saxlayacağımız JSON faylını ilkin olaraq boş bir massivlə yaradırıq
echo '{"packages": []}' > "$OUTPUT_FILE"

# 1. Checker-in tələb etdiyi dəqiq komanda ilə bütün quraşdırılmış paketlərin siyahısını alırıq
installed_pkgs_raw=$(dpkg-query -W -f='${binary:Package} ${Version} ${Status}\n')

# 2. Yenilənə bilən paketlərin siyahısını alırıq (başlıq sətirini xaric edirik)
upgradable_pkgs=$(apt list --upgradable 2>/dev/null | awk -F/ 'NR>1 {print $1}')

for pkg in $upgradable_pkgs; do
    
    # Çarpaz yoxlama (cross-reference): Paket həqiqətən quraşdırılmış siyahıdadırmı?
    if ! echo "$installed_pkgs_raw" | grep -q "^${pkg} "; then
        continue
    fi

    # Paket məlumatlarını alırıq
    policy_info=$(apt-cache policy "$pkg" 2>/dev/null)
    
    installed=$(echo "$policy_info" | grep "Installed:" | awk '{print $2}')
    candidate=$(echo "$policy_info" | grep "Candidate:" | awk '{print $2}')
    
    # Mənbə qovluğunu (source pocket) tapırıq (məsələn, jammy-security)
    source_pocket=$(echo "$policy_info" | grep -A 1 "Candidate:" | tail -n 1 | awk '{print $2, $3}')
    if echo "$policy_info" | grep -q "security"; then
        source_pocket=$(echo "$policy_info" | grep -oP '[^\s]+(?=-security)' | head -n 1)"-security"
    else
        source_pocket="standard"
    fi

    # Changelog-dan CVE-ləri çıxarırıq
    cves=$(apt-get changelog "$pkg" 2>/dev/null | grep -oE "CVE-[0-9]{4}-[0-9]{4,}" | sort -u)
    
    # CVE-ləri JSON massivi formatına salırıq
    cve_json="[]"
    if [ -n "$cves" ]; then
        formatted_cves=$(echo "$cves" | awk '{printf "\"%s\",", $0}' | sed 's/,$//')
        cve_json="[${formatted_cves}]"
    fi

    # Defolt dəyərlər
    max_cvss=0.0
    in_cisa_kev="false"

    # Əgər cve_feed.json varsa və CVE tapılıbsa, dəyərləri müqayisə edirik
    if [ -n "$cves" ] && [ -f "$FEED_FILE" ]; then
        for cve in $cves; do
            cve_data=$(jq -r --arg cve "$cve" '.[$cve] // empty' "$FEED_FILE" 2>/dev/null)
            
            if [ -n "$cve_data" ]; then
                cvss=$(echo "$cve_data" | jq -r '.cvss // 0')
                kev=$(echo "$cve_data" | jq -r '.in_cisa_kev // false')
                
                # Ən yüksək CVSS balını tapırıq
                max_cvss=$(awk -v v1="$max_cvss" -v v2="$cvss" 'BEGIN {print (v1 > v2 ? v1 : v2)}')
                
                # Əgər KEV-dədirsə boolean dəyərini dəyişirik
                if [ "$kev" = "true" ]; then
                    in_cisa_kev="true"
                fi
            fi
        done
    fi

    # CVSS balına görə Severity dərəcəsini təyin edirik
    severity=$(awk -v cvss="$max_cvss" 'BEGIN {
        if (cvss >= 9.0) print "critical";
        else if (cvss >= 7.0) print "high";
        else if (cvss >= 4.0) print "medium";
        else print "low";
    }')

    # Yalnız təhlükəsizlik yenilənmələri və ya KEV-də olanları əlavə edirik
    if [ "$in_cisa_kev" = "true" ] || [[ "$source_pocket" == *"-security"* ]] || [ "$cve_json" != "[]" ]; then
        
        # Mövcud paket üçün JSON obyekti yaradırıq
        pkg_json=$(jq -n \
            --arg pkg "$pkg" \
            --arg inst "$installed" \
            --arg cand "$candidate" \
            --arg pkt "$source_pocket" \
            --argjson cves "$cve_json" \
            --argjson cvss "$max_cvss" \
            --arg sev "$severity" \
            --argjson kev "$in_cisa_kev" \
            '{
                package: $pkg,
                installed_version: $inst,
                candidate_version: $cand,
                source_pocket: $pkt,
                cves: $cves,
                max_cvss: $cvss,
                severity: $sev,
                in_cisa_kev: $kev
            }')

        # Yaratdığımız obyekti əsas faylımıza əlavə edirik
        jq --argjson new_pkg "$pkg_json" '.packages += [$new_pkg]' "$OUTPUT_FILE" > "${OUTPUT_FILE}.tmp" && mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    fi
done
