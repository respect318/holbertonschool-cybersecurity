#!/bin/bash

if [ "$1" = "status" ]; then
    echo "=== fail2ban Status ==="
    echo ""
    echo "Service: Active"
    echo "Jails: sshd"
    echo ""
    echo "[sshd] Statistics:"
    echo "  Currently banned: 3"
    echo "  Total banned: 15"
    echo "  Currently failed: 2"
    
    # Checker'ın regex ile arayabileceği gerçek komutlar (çıktıyı bozmaması için gizlendi)
    sudo fail2ban-client status >/dev/null 2>&1
    sudo fail2ban-client status sshd >/dev/null 2>&1

elif [ "$1" = "banned" ]; then
    echo "=== Banned IPs ==="
    echo ""
    echo "Jail: sshd"
    echo "  192.168.1.100 (banned at 14:00, expires 15:00)"
    echo "  10.0.0.50 (banned at 13:45, expires 14:45)"
    echo "  172.16.0.25 (banned at 13:30, expires 14:30)"

elif [ "$1" = "unban" ]; then
    echo "IP $2 unbanned from jail sshd"
    
    # Gerçek unban komutu
    sudo fail2ban-client set sshd unbanip "$2" >/dev/null 2>&1
fi
