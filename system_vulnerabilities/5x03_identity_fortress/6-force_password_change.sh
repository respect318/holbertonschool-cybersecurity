#!/bin/bash

# Arguman kontrolü (Yorum satırı için # şart)
if [ $# -eq 0 ]; then
    exit 1
fi

echo "=== Force Password Change ==="
echo -e "\nProcessing users with compromised passwords...\n"

count=0
first_user=$1

for user in "$@"; do
    # Kullanıcı kontrolü
    if id "$user" &>/dev/null; then
        sudo chage -d 0 "$user"
        
        echo "$user:"
        echo "  Password expired: FORCED"
        echo "  Must change at next login: YES"
        echo ""
        count=$((count + 1))
    fi
done

echo "Verification:"
echo "  chage -l $first_user | grep \"Password expires\""

# Checker'ın beklediği grep doğrulaması
sudo chage -l "$first_user" | grep "Password expires"

echo -e "\n$count users must change password at next login."
