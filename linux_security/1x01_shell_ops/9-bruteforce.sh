#!/bin/bash
grep "Failed password" "$1" | awk '{for(i=1;i<=NF;i++) if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/) print $i}' | sort | uniq -c | sort -nr | awk '{$1=$1; print}'

