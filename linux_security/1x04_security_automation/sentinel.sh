#!/bin/bash
check_ports() {
    ports=$(ss -lnt | awk 'NR>1 {print $4}' | awk -F: '{print $NF}')

    for p in $ports; do
        allowed=0
        for ap in "${ALLOWED_PORTS[@]}"; do
            [[ "$p" == "$ap" ]] && allowed=1
        done

        if [[ $allowed -eq 0 ]]; then
            fuser -k "$p"/tcp 2>/dev/null
            echo "ALERT: Killed rogue process on port $p"
            log "PORT" "$p" "ALERT" "Killed rogue process"
        else
            log "PORT" "$p" "OK" "Port allowed"
        fi
    done
}
check_ports
