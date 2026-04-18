#!/bin/bash

REPORT="$1"

if [ -z "$REPORT" ] || [ ! -f "$REPORT" ]; then
    echo "Usage: $0 <path_to_lynis_report.dat>"
    exit 1
fi

INDEX=$(grep -E '^hardening_index=' "$REPORT" | cut -d'=' -f2)
INDEX=${INDEX:-0}

grep -E '^(warning|suggestion|manual_check)\[\]=' "$REPORT" | \
awk '
BEGIN { FS="=" }
{
    sev = $1
    sub("\\[\\]", "", sev)
    
    idx = index($0, "=")
    rest = substr($0, idx+1)
    
    split(rest, parts, "|")
    
    printf "%s\t%s\t%s\n", sev, parts[1], parts[2]
}' | \
jq -R -c 'split("\t") | {severity: .[0], test_id: .[1], message: .[2]}' | \
jq -s --argjson idx "$INDEX" '{hardening_index: $idx, warnings: [], suggestions: [], manual_checks: [], findings: .}'
