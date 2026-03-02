#!/bin/bash
grep "Failed password" "$1" | awk '{print $(NF-3)}' | sort | uniq -c | sort -nr | awk '{$1=$1; print}'

