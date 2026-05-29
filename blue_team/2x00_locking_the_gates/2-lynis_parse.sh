#!/bin/bash

# Qoruyucu bash təcrübələri (Strict Mode)
set -euo pipefail

# Arqumentin təhlükəsiz şəkildə oxunması (set -u xətası verməməsi üçün)
REPORT_FILE="${1:-}"

# 1. Əgər fayl tapılmazsa və ya oxumaq hüququ yoxdursa,
# jq-nin çökməməsi üçün dərhal boş, lakin keçərli JSON qaytarırıq.
if [ -z "$REPORT_FILE" ] || [ ! -f "$REPORT_FILE" ]; then
    echo '{"hardening_index": 0, "findings": []}'
    exit 0
fi

# 2. Hardening index-i götürürük (yalnız rəqəmləri saxlayırıq)
# '|| true' ona görə əlavə olunub ki, grep heç nə tapmasa set -e skripti dayandırmasın
HI_RAW=$(grep -m 1 "^hardening_index=" "$REPORT_FILE" || true)
if [ -n "$HI_RAW" ]; then
    HI=$(echo "$HI_RAW" | cut -d'=' -f2 | tr -dc '0-9')
else
    HI=0
fi
HI=${HI:-0}

# 3. Warning və suggestion-ları oxuyub JSON massivinə çeviririk
JSON_ARRAY=$(
    (grep -E '^(warning|suggestion|manual_check)\[\]=' "$REPORT_FILE" || true) | while IFS= read -r line; do
        # Boş sətirləri buraxırıq
        if [ -z "$line" ]; then continue; fi
        
        severity="${line%%\[\]=*}"
        rest="${line#*\[\]=}"
        test_id="${rest%%|*}"
        after_id="${rest#*|}"
        message="${after_id%%|*}"

        jq -n -c \
            --arg s "$severity" \
            --arg t "$test_id" \
            --arg m "$message" \
            '{severity: $s, test_id: $t, message: $m}'
    done | jq -s '.'
)

# 4. Əgər heç bir tapıntı yoxdursa, massivi boş olaraq təyin edirik
if [ -z "$JSON_ARRAY" ] || [ "$JSON_ARRAY" = '""' ] || [ "$JSON_ARRAY" = "null" ]; then
    JSON_ARRAY="[]"
fi

# 5. Yekun çıxış (stdout vasitəsilə)
jq -n --argjson hi "$HI" --argjson f "$JSON_ARRAY" '{hardening_index: $hi, findings: $f}'
