#!/bin/bash
export LC_ALL=C

# Tələb olunan fayl yolları
PRE_FILE="pre_patch_state.json"
LOG_FILE="patch_execution_log.json"
OUT_FILE="config_drift.json"

# Nəticə sayğacları
cnt_unchanged=0
cnt_modified=0
cnt_missing=0
cnt_new=0
has_unexpected=0

> drift_tmp.jsonl

# 1. Load the conffile_hashes block from pre_patch_state.json
jq -c '.conffile_hashes[]?' "$PRE_FILE" > pre_hashes.txt 2>/dev/null

# 2. Upgrade olunmuş paketlərin siyahısını log faylından çıxarırıq (gözlənilən dəyişiklikləri tapmaq üçün)
upgraded_pkgs=$(jq -r '.entries[] | select(.status=="succeeded") | .package' "$LOG_FILE" 2>/dev/null || echo "")

# 3. Əvvəlki konfiqurasiya fayllarını yoxlayırıq (unchanged, modified, missing)
while read -r item; do
    [ -z "$item" ] && continue
    file=$(echo "$item" | jq -r '.file')
    old_hash=$(echo "$item" | jq -r '.hash')

    if [ ! -f "$file" ]; then
        status="missing"
        ((cnt_missing++))
        jq -n -c --arg f "$file" --arg st "$status" '{path: $f, status: $st}' >> drift_tmp.jsonl
        continue
    fi

    # Recompute the SHA-256
    new_hash=$(sha256sum "$file" 2>/dev/null | awk '{print $1}')
    
    if [ "$old_hash" = "$new_hash" ]; then
        status="unchanged"
        ((cnt_unchanged++))
        # Nəticəni JSON-a (files arrayinə) hər bir fayl üçün əlavə etmək istəyiriksə:
        jq -n -c --arg f "$file" --arg st "$status" '{path: $f, status: $st}' >> drift_tmp.jsonl
    else
        status="modified"
        ((cnt_modified++))
        
        owning_package=$(dpkg-query -S "$file" 2>/dev/null | awk -F: '{print $1}')
        [ -z "$owning_package" ] && owning_package="unknown"
        
        # Expected / unexpected yoxlaması
        is_expected="false"
        drift_type="unexpected"
        if echo "$upgraded_pkgs" | grep -q "^${owning_package}$"; then
            is_expected="true"
            drift_type="expected"
        else
            has_unexpected=1
        fi
        
        # Capture a unified diff truncated to 40 lines via diff -u
        # (Sistemdə köhnə fayl birbaşa olmadığı üçün fərqi /dev/null ilə yoxlayıb head -n 40 ilə kəsirik)
        diff_out=$(diff -u /dev/null "$file" 2>/dev/null | head -n 40 | jq -R -s -c '.')
        [ -z "$diff_out" ] && diff_out="\"\""
        
        jq -n -c \
            --arg f "$file" \
            --arg st "$status" \
            --arg op "$owning_package" \
            --argjson exp "$is_expected" \
            --arg dt "$drift_type" \
            --argjson d "$diff_out" \
            '{path: $f, status: $st, owning_package: $op, expected: $exp, diff: $d}' >> drift_tmp.jsonl
    fi
done < pre_hashes.txt

# 4. Yeni əlavə olunmuş faylları tapırıq (new)
dpkg-query -W -f='${Conffiles}\n' | awk '/ \/etc\// {print $1}' > current_conffiles.txt 2>/dev/null
while read -r file; do
    if ! grep -q "\"$file\"" pre_hashes.txt 2>/dev/null; then
        if [ -f "$file" ]; then
            status="new"
            ((cnt_new++))
            
            owning_package=$(dpkg-query -S "$file" 2>/dev/null | awk -F: '{print $1}')
            [ -z "$owning_package" ] && owning_package="unknown"
            
            is_expected="false"
            drift_type="unexpected"
            if echo "$upgraded_pkgs" | grep -q "^${owning_package}$"; then
                is_expected="true"
                drift_type="expected"
            else
                has_unexpected=1
            fi
            
            jq -n -c \
                --arg f "$file" \
                --arg st "$status" \
                --arg op "$owning_package" \
                --argjson exp "$is_expected" \
                --arg dt "$drift_type" \
                '{path: $f, status: $st, owning_package: $op, expected: $exp}' >> drift_tmp.jsonl
        fi
    fi
done < current_conffiles.txt

# 5. Yekun config_drift.json faylının formalaşdırılması
if [ -s drift_tmp.jsonl ]; then
    files_arr=$(jq -s 'sort_by(.path)' drift_tmp.jsonl)
else
    files_arr="[]"
fi

jq -n \
    --argjson unc "$cnt_unchanged" \
    --argjson mod "$cnt_modified" \
    --argjson mis "$cnt_missing" \
    --argjson nw "$cnt_new" \
    --argjson arr "$files_arr" \
    '{
        summary: {
            unchanged: $unc,
            modified: $mod,
            missing: $mis,
            new: $nw
        },
        files: $arr
    }' > "$OUT_FILE"

# Müvəqqəti faylların təmizlənməsi
rm -f pre_hashes.txt current_conffiles.txt drift_tmp.jsonl

# Əgər gözlənilməz (unexpected) dəyişiklik varsa çıxış kodu 1, yoxdursa 0
if [ "$has_unexpected" -eq 1 ]; then
    exit 1
else
    exit 0
fi
