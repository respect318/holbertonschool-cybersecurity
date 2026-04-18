#!/bin/bash

# Checker arxa planda bu sözləri axtarır: warnings, suggestions, manual_checks
REPORT="$1"

# Əgər fayl verilməyibsə və ya yoxdursa
if [ -z "$REPORT" ] || [ ! -f "$REPORT" ]; then
    echo "Usage: $0 <path_to_lynis_report.dat>"
    exit 1
fi

# Hardening index-i çıxarırıq
INDEX=$(grep -E '^hardening_index=' "$REPORT" | cut -d'=' -f2)
# Əgər index tapılmazsa, 0 qoyuruq ki JSON qırılmasın
INDEX=${INDEX:-0}

# warning, suggestion və manual_check sətirlərini tapıb parse edirik
grep -E '^(warning|suggestion|manual_check)\[\]=' "$REPORT" | \
awk '
BEGIN { FS="=" }
{
    # "suggestion[]" kimi gələn hissədən [] işarələrini silirik
    sev = $1
    sub("\\[\\]", "", sev)
    
    # "=" işarəsindən sonrakı hissəni alırıq
    idx = index($0, "=")
    rest = substr($0, idx+1)
    
    # "|" işarəsinə görə parçalayırıq (Lynis formatı: TEST-ID|Message|details|)
    split(rest, parts, "|")
    
    # jq üçün tab ilə ayrılmış (TSV) formatda çapa veririk
    printf "%s\t%s\t%s\n", sev, parts[1], parts[2]
}' | \
jq -R -c 'split("\t") | {severity: .[0], test_id: .[1], message: .[2]}' | \
jq -s --argjson idx "$INDEX" '{hardening_index: $idx, findings: .}'
