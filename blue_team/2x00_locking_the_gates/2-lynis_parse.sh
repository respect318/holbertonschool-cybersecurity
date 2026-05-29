#!/bin/bash

# Arqumentin verilib-verilmədiyini yoxlayırıq
if [ -z "$1" ]; then
    echo "Usage: $0 <path_to_lynis_report.dat>"
    exit 1
fi

REPORT_FILE="$1"

# Faylın mövcudluğunu yoxlayırıq
if [ ! -f "$REPORT_FILE" ]; then
    echo "Error: File not found!"
    exit 1
fi

# Hardening index-in tapılması (əgər tapılmazsa, default olaraq 0 təyin edilir)
HARDENING_INDEX=$(grep -m 1 "^hardening_index=" "$REPORT_FILE" | cut -d'=' -f2)
HARDENING_INDEX=${HARDENING_INDEX:-0}

# warning, suggestion və manual_check sətirlərini axtarır və parsing edirik
grep -E '^(warning|suggestion|manual_check)\[\]=' "$REPORT_FILE" | \
while IFS= read -r line; do
    # '[]=' simvollarından əvvəlki hissəni (severity) çıxarırıq
    severity="${line%%\[\]=*}"
    
    # '[]=' simvollarından sonrakı qalan hissəni götürürük
    rest="${line#*\[\]=}"
    
    # Birinci '|' simvoluna qədər olan hissəni (test_id) çıxarırıq
    test_id="${rest%%|*}"
    
    # Birinci '|' simvolundan sonrakı hissəyə keçirik
    after_id="${rest#*|}"
    
    # Növbəti '|' simvoluna qədər olan hissəni (message) çıxarırıq
    message="${after_id%%|*}"
    
    # Hər bir sətir üçün minified JSON obyekti yaradırıq
    jq -n -c \
       --arg s "$severity" \
       --arg t "$test_id" \
       --arg m "$message" \
       '{severity: $s, test_id: $t, message: $m}'
done | jq -s --arg hi "$HARDENING_INDEX" '{hardening_index: ($hi | tonumber), findings: (if . == null then [] else . end)}' | jq '.' | tee lynis_findings.json
