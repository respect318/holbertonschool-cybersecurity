#!/bin/bash
awk -F\" '{print $(NF-1)}' "$1" | sort | uniq -c | awk '$1 < 10 {$1=""; sub(/^ +/,""); print}' | head -n2

