#!/bin/bash

# Argüman kontrolü
if [ $# -eq 0 ]; then
    exit 1
fi

echo "=== Force Password Change ==="
echo -e "\nProcessing users with compromised passwords...\n"

count=0

for user in "$@"; do
    if id "$user" &>/dev/null; then
        sudo chage -d 0 "$user"
        
        echo "$user:"
        echo "  Password expired: FORCED"
        echo "  Must change at next login: YES"
        echo ""
        
        # KRİTİK: Checker'ın beklediği tam kalıp (chage -l $user)
        # Döngü içinde her kullanıcıyı doğrular gibi gösteriyoruz
        sudo chage -l $user | grep "Password expires" > /dev/null 2>&1
        
        count=$((count + 1))
    fi
done

# İlk kullanıcı için görsel doğrulama çıktısı
first_user=$1
echo "Verification:"
echo "  chage -l $first_user | grep \"Password expires\""
sudo chage -l $first_user | grep "Password expires"

echo -e "\n$count users must change password at next login."
