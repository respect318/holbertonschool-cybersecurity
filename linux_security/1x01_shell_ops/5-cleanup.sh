#!/bin/bash
while IFS= read -r user; do
    if id "$user" &>/dev/null; then
        sudo usermod -L "$user"
        echo "User $user locked"
    else
        echo "User $user not found"
    fi
done < "$1"
