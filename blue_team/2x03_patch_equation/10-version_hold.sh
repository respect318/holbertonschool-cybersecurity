#!/bin/bash
export LC_ALL=C

REG_FILE="hold_registry.json"
OUT_FILE="hold_management.json"
PIN_FILE="/etc/apt/preferences.d/meddefense-pins"

# Qovluğun mövcud olduğundan əmin oluruq və pin faylını sıfırlayırıq
mkdir -p /etc/apt/preferences.d
> "$PIN_FILE"

# Müvəqqəti log faylları
> applied.tmp
> overdue.tmp
> registry_pkgs.txt
> released.tmp

today_epoch=$(date -d "$(date +%Y-%m-%d)" +%s 2>/dev/null || date +%s)
reg_count=$(jq '.holds | length' "$REG_FILE" 2>/dev/null || echo 0)
current_holds=$(apt-mark showhold 2>/dev/null)
curr_count=$(echo "$current_holds" | awk 'NF' | wc -l)

echo "[*] Reading hold_registry.json...           ($reg_count entries)"
echo "[*] Reading current apt-mark showhold...    ($curr_count entry)"

echo "Applying holds:"

for (( i=0; i<$reg_count; i++ )); do
    pkg=$(jq -r ".holds[$i].package" "$REG_FILE")
    reason=$(jq -r ".holds[$i].reason" "$REG_FILE")
    owner=$(jq -r ".holds[$i].owner" "$REG_FILE")
    review_date=$(jq -r ".holds[$i].review_date" "$REG_FILE")
    pin_version=$(jq -r ".holds[$i].pin_version" "$REG_FILE")

    echo "$pkg" >> registry_pkgs.txt

    # days_to_review hesablanması
    rev_epoch=$(date -d "$review_date" +%s 2>/dev/null || echo 0)
    if [ "$rev_epoch" -eq 0 ]; then
        days_to_review=0
    else
        diff=$((rev_epoch - today_epoch))
        days_to_review=$((diff / 86400))
    fi

    # apt preferences yazılması
    echo "Package: $pkg" >> "$PIN_FILE"
    echo "Pin: version $pin_version" >> "$PIN_FILE"
    echo "Pin-Priority: 1001" >> "$PIN_FILE"
    echo "" >> "$PIN_FILE"

    # Hold tətbiqi
    apt-mark hold "$pkg" >/dev/null 2>&1
    
    printf "  %-23s hold + pin %-28s OK\n" "$pkg" "$pin_version"

    # JSON üçün applied array
    jq -n -c \
        --arg p "$pkg" \
        --arg r "$reason" \
        --arg o "$owner" \
        --arg rd "$review_date" \
        --arg pv "$pin_version" \
        --argjson dtr "$days_to_review" \
        '{package: $p, reason: $r, owner: $o, review_date: $rd, pin_version: $pv, days_to_review: $dtr}' >> applied.tmp

    # Gecikmiş (overdue) review yoxlaması
    if [ "$days_to_review" -lt 0 ]; then
        jq -n -c \
            --arg p "$pkg" \
            --argjson dtr "$days_to_review" \
            '{package: $p, days_to_review: $dtr}' >> overdue.tmp
    fi
done

echo "Releasing holds no longer in registry:"
released_count=0
for curr_pkg in $current_holds; do
    if ! grep -q "^${curr_pkg}$" registry_pkgs.txt 2>/dev/null; then
        apt-mark unhold "$curr_pkg" >/dev/null 2>&1
        echo "  $curr_pkg"
        jq -n -c --arg p "$curr_pkg" '{package: $p}' >> released.tmp
        ((released_count++))
    fi
done

if [ "$released_count" -eq 0 ]; then
    echo "  (none)"
fi

applied_arr=$(jq -s '.' applied.tmp 2>/dev/null || echo "[]")
released_arr=$(jq -s '.' released.tmp 2>/dev/null || echo "[]")
overdue_arr=$(jq -s '.' overdue.tmp 2>/dev/null || echo "[]")

overdue_count=$(echo "$overdue_arr" | jq 'length')
echo "Overdue reviews: $overdue_count"

total_held=$(apt-mark showhold 2>/dev/null | awk 'NF' | wc -l)

# Yekun hold_management.json faylının formalaşması
jq -n \
    --argjson app "$applied_arr" \
    --argjson rel "$released_arr" \
    --argjson odr "$overdue_arr" \
    --argjson tot "$total_held" \
    '{
        applied: $app,
        released: $rel,
        overdue_reviews: $odr,
        total_held: $tot
    }' > "$OUT_FILE"

echo "Report saved to: hold_management.json"

# Müvəqqəti faylların silinməsi
rm -f applied.tmp released.tmp overdue.tmp registry_pkgs.txt
exit 0
