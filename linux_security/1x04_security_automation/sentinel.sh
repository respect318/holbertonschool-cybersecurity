#!/bin/bash
source sentinel.conf && check_services(){ for svc in "${SERVICES[@]}"; do pgrep -f "$svc" >/dev/null && echo "OK: $svc is running" || { eval "$svc" && echo "FIXED: Restarted $svc" || echo "ERROR: Failed to start $svc"; }; done; }; check_services
