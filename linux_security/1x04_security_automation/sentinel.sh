#!/bin/bash
source sentinel.conf && check_integrity(){ for file in "${FILES_TO_WATCH[@]}"; do [ "$(md5sum "$file" | awk '{print $1}')" = "$(md5sum "/var/backups/sentinel/$(basename "$file").gold" | awk '{print $1}')" ] && echo "OK: $file integrity verified" || { cp "/var/backups/sentinel/$(basename "$file").gold" "$file" && echo "FIXED: Restored $file"; }; done; }; check_integrity
