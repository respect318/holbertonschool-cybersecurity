#!/bin/bash
[[ ! -d "$1" ]] && exit 1
mkdir -p "$1/backups"
for f in "$1"/*.log; do
    [ ! -f "$f" ] && continue
    if [ $(stat -c%s "$f") -gt 1024 ]; then
        gzip -c "$f" > "$1/backups/$(basename "$f").gz"
    else
        echo "Skipping small file: $(basename "$f")"
    fi
done
