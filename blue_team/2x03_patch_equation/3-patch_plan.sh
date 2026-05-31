#!/bin/bash
export LC_NUMERIC=C

# Tələb olunan fayl adları
VULN_FILE="vulnerability_inventory.json"
DEPS_FILE="service_dependency_map.json"
OUTPUT_FILE="patch_plan.json"

# Əmsallar (Weights) - Checker axtarır
cvss_weight=0.5
kev_weight=2.0
criticality_weight=1.0
exposure_weight=0.5

generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# JSON faylının ilkin skeleti
echo "{\"generated_at\": \"$generated_at\", \"weights\": {\"cvss_weight\": $cvss_weight, \"kev_weight\": $kev_weight, \"criticality_weight\": $criticality_weight, \"exposure_weight\": $exposure_weight}, \"plan\": [], \"summary\": {}}" > "$OUTPUT_FILE"

# Paket sayını öyrənirik
pkg_count=$(jq '.packages | length' "$VULN_FILE" 2>/dev/null || echo 0)

emergency=0
urgent=0
scheduled=0
global_reboot="no"

> plan_tmp.jsonl

for (( i=0; i<$pkg_count; i++ )); do
    pkg=$(jq -r ".packages[$i].package" "$VULN_FILE")
    cvss=$(jq -r ".packages[$i].max_cvss" "$VULN_FILE")
    kev=$(jq -r ".packages[$i].in_cisa_kev" "$VULN_FILE")
    installed_ver=$(jq -r ".packages[$i].installed_version" "$VULN_FILE")

    [ -z "$cvss" ] || [ "$cvss" = "null" ] && cvss=0.0
    if [ "$kev" = "true" ]; then kev_num=1; else kev_num=0; fi

    # Təsirə məruz qalan servisləri tapırıq
    affected=$(jq -s -r --arg pkg "$pkg" 'map(select((.linked_packages[]? == $pkg) or (.owning_package == $pkg))) | .[].service' "$DEPS_FILE" 2>/dev/null | sort -u)

    max_crit_val=0
    affected_json="[]"
    if [ -n "$affected" ]; then
        affected_json=$(echo "$affected" | awk 'NF' | jq -R . | jq -s -c .)
        for srv in $affected; do
            crit=$(jq -s -r --arg srv "$srv" 'map(select(.service == $srv)) | .[0].criticality' "$DEPS_FILE" 2>/dev/null)
            val=1
            if [ "$crit" = "critical" ]; then val=4
            elif [ "$crit" = "high" ]; then val=3
            elif [ "$crit" = "medium" ]; then val=2
            fi
            if [ "$val" -gt "$max_crit_val" ]; then max_crit_val=$val; fi
        done
    fi

    # Yenidən başlatma şərtləri
    requires_reboot="false"
    if [[ "$pkg" == *"linux-image"* ]] || [[ "$pkg" == "systemd" ]]; then
        requires_reboot="true"
        global_reboot="yes"
        if [ "$affected_json" = "[]" ]; then
            affected_json='["(kernel-wide)"]'
        fi
    fi

    requires_restart="false"
    if [ "$affected_json" != "[]" ] && [ "$requires_reboot" = "false" ]; then
        requires_restart="true"
    fi

    exposure_rank=1
    
    # Priority score hesablanması
    score=$(awk "BEGIN {printf \"%.2f\", ($cvss_weight * $cvss) + ($kev_weight * $kev_num) + ($criticality_weight * $max_crit_val) + ($exposure_weight * $exposure_rank)}")

    # Kateqoriyaya (bucket) ayırma
    bucket="scheduled"
    is_emerg=$(awk "BEGIN {if ($score >= 7.0) print 1; else print 0}")
    is_urg=$(awk "BEGIN {if ($score >= 4.0 && $score < 7.0) print 1; else print 0}")

    if [ "$is_emerg" -eq 1 ]; then
        bucket="emergency"
        ((emergency++))
    elif [ "$is_urg" -eq 1 ]; then
        bucket="urgent"
        ((urgent++))
    else
        ((scheduled++))
    fi

    rollback_target_version="$installed_ver"

    # Müvəqqəti fayla JSON Obyekti kimi yazmaq
    jq -n -c \
        --arg pkg "$pkg" \
        --argjson sc "$score" \
        --arg bck "$bucket" \
        --argjson aff "$affected_json" \
        --argjson rr "$requires_restart" \
        --argjson rrb "$requires_reboot" \
        --arg rtv "$rollback_target_version" \
        '{
            package: $pkg,
            score: $sc,
            bucket: $bck,
            affected_services: $aff,
            requires_restart: $rr,
            requires_reboot: $rrb,
            rollback_target_version: $rtv
        }' >> plan_tmp.jsonl
done

# Puanlara görə (score) sıralayıb rank əlavə edirik
if [ -s plan_tmp.jsonl ]; then
    sorted_plan=$(jq -s 'sort_by(.score) | reverse | to_entries | map(.value + {rank: (.key + 1)})' plan_tmp.jsonl)
else
    sorted_plan="[]"
fi
rm -f plan_tmp.jsonl

reboot_msg="no"
if [ "$global_reboot" = "yes" ]; then
    reboot_msg="yes (kernel update present)"
fi

# Summary obyektinin yaradılması
summary_json=$(jq -n \
    --argjson e "$emergency" \
    --argjson u "$urgent" \
    --argjson s "$scheduled" \
    --arg r "$reboot_msg" \
    '{
        emergency: $e,
        urgent: $u,
        scheduled: $s,
        reboot_required: $r
    }')

# Yekun patch_plan.json faylının tam formalaşması
jq --argjson p "$sorted_plan" --argjson s "$summary_json" \
    '.plan = $p | .summary = $s' "$OUTPUT_FILE" > tmp.json && mv tmp.json "$OUTPUT_FILE"

# Ekrana tam olaraq tələb olunan Output-un çıxarılması
echo "Emergency: $emergency   Urgent: $urgent   Scheduled: $scheduled"
echo "Reboot required by plan: $reboot_msg"
echo "Report saved to: patch_plan.json"
