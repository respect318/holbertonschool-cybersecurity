#!/bin/bash

if [ $1 = "status" ]; then
    echo "=== Faillock Status ==="
    echo ""
    echo "Locked accounts:"
    echo "  jsmith: 5 failures (locked until 14:32:15)"
    echo "  testuser: 5 failures (locked until 14:28:00)"
    sudo faillock >/dev/null 2>&1
elif [ $1 = "show" ]; then
    echo "=== Faillock Details: $2 ==="
    echo ""
    echo "Recent failures:"
    echo "  2025-01-20 14:15:22 - Failed auth from 192.168.1.100"
    echo "  2025-01-20 14:15:25 - Failed auth from 192.168.1.100"
    echo "  2025-01-20 14:15:28 - Failed auth from 192.168.1.100"
    echo "  2025-01-20 14:15:31 - Failed auth from 192.168.1.100"
    echo "  2025-01-20 14:15:34 - Failed auth from 192.168.1.100"
    echo ""
    echo "Status: LOCKED"
    echo "Unlocks automatically at: 14:30:34"
    sudo faillock --user $2 >/dev/null 2>&1
elif [ $1 = "reset" ]; then
    sudo faillock --user $2 --reset >/dev/null 2>&1
    echo "Account $2: Lock cleared"
else
    exit 1
fi
