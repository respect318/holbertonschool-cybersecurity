#!/bin/bash
export LC_NUMERIC=C

# Fayl yolları (Checker-in axtardığı .json faylları)
PRE_FILE="pre_patch_state.json"
DEPS_FILE="service_dependency_map.json"
PROBES_FILE="service_probes.json"
OUT_FILE="post_patch_validation.json"

# Nəticə sayğacları
srv_total=0; srv_pass=0
sock_total=0; sock_pass=0
probe_total=0; probe_pass=0

> tmp_details.jsonl

# 1. Service state regression validation
srv_count=$(jq '.services | length' "$PRE_FILE" 2>/dev/null || echo 0)
for (( i=0; i<$srv_count; i++ )); do
    ((srv_total++))
    srv=$(jq -r ".services[$i].service" "$PRE_FILE")
    pre_state=$(jq -r ".services[$i].ActiveState" "$PRE_FILE")
    
    # systemctl vasitəsilə cari ActiveState yoxlanılır
    cur_state=$(systemctl show -p ActiveState --value "$srv" 2>/dev/null)
    
    status="pass"
    # Əgər əvvəl active idisə və indi deyilsə, bu regression sayılır
    if [ "$pre_state" = "active" ] && [ "$cur_state" != "active" ]; then
        status="regression"
    fi
    
    [ "$status" = "pass" ] && ((srv_pass++))
    
    jq -n -c --arg type "service_state" --arg name "$srv" --arg st "$status" '{type: $type, name: $name, status: $st}' >> tmp_details.jsonl
done

# 2. Listening socket validation
# port və listening vəziyyətini yoxlamaq üçün ss -tulnp istifadə edilir
sock_count=$(jq '.listening | length' "$PRE_FILE" 2>/dev/null || echo 0)
current_sockets=$(ss -tulnp 2>/dev/null)

for (( i=0; i<$sock_count; i++ )); do
    line=$(jq -r ".listening[$i]" "$PRE_FILE")
    
    # Kimi sətirlərdən port nömrəsini çıxarırıq (Məs: 0.0.0.0:22)
    port=$(echo "$line" | awk '{print $5}' | rev | cut -d: -f1 | rev)
    
    # İlk sətir (başlıq) xaric olunur
    if [[ "$port" == *"Port"* ]] || [[ -z "$port" ]]; then
        continue
    fi

    ((sock_total++))
    status="regression"
    
    # Səsli-küysüz yoxlayırıq ki, port hələ də listening vəziyyətindədirmi
    if echo "$current_sockets" | grep -q ":$port\b"; then
        status="pass"
    fi
    
    [ "$status" = "pass" ] && ((sock_pass++))
    
    jq -n -c --arg type "socket" --arg name "$port" --arg st "$status" '{type: $type, name: $name, status: $st}' >> tmp_details.jsonl
done

# 3. Critical liveness probes
if [ -f "$DEPS_FILE" ] && [ -f "$PROBES_FILE" ]; then
    crit_services=$(jq -r '.[] | select(.criticality == "critical") | .service' "$DEPS_FILE" 2>/dev/null)
    for srv in $crit_services; do
        probe_cmd=$(jq -r --arg s "$srv" '.[$s] // empty' "$PROBES_FILE" 2>/dev/null)
        if [ -n "$probe_cmd" ] && [ "$probe_cmd" != "null" ]; then
            ((probe_total++))
            
            # probe işə salınır
            if eval "$probe_cmd" >/dev/null 2>&1; then
                status="pass"
                ((probe_pass++))
            else
                status="probe_failed"
            fi
            
            jq -n -c --arg type "probe" --arg name "$srv" --arg st "$status" '{type: $type, name: $name, status: $st}' >> tmp_details.jsonl
        fi
    done
fi

# Yekun JSON hesabatının formalaşması
total_checks=$((srv_total + sock_total + probe_total))
total_passed=$((srv_pass + sock_pass + probe_pass))
total_failed=$((total_checks - total_passed))

if [ -s tmp_details.jsonl ]; then
    details_json=$(jq -s '.' tmp_details.jsonl)
else
    details_json="[]"
fi
rm -f tmp_details.jsonl

jq -n \
    --argjson t "$total_checks" \
    --argjson p "$total_passed" \
    --argjson f "$total_failed" \
    --argjson d "$details_json" \
    '{
        total_checks: $t,
        passed: $p,
        failed: $f,
        details: $d
    }' > "$OUT_FILE"

# Ekrana Output-un çıxarılması (Eynən tapşırıqdakı kimi)
srv_result="PASS"
[ "$srv_pass" -lt "$srv_total" ] && srv_result="FAIL"
printf "Service state checks:     %-2d/%-2d   %s\n" "$srv_pass" "$srv_total" "$srv_result"

sock_result="PASS"
[ "$sock_pass" -lt "$sock_total" ] && sock_result="FAIL"
printf "Listening socket checks:  %-2d/%-2d   %s\n" "$sock_pass" "$sock_total" "$sock_result"

probe_result="PASS"
[ "$probe_pass" -lt "$probe_total" ] && probe_result="FAIL"
printf "Critical liveness probes: %-2d/%-2d   %s\n" "$probe_pass" "$probe_total" "$probe_result"

verdict="PASS"
[ "$total_failed" -gt 0 ] && verdict="FAIL"
printf "VERDICT: %s (%d/%d)\n" "$verdict" "$total_passed" "$total_checks"
echo "Report saved to: post_patch_validation.json"

# Uğursuzluq (regression) olarsa exit 1 verilir
if [ "$total_failed" -gt 0 ]; then
    exit 1
else
    exit 0
fi
