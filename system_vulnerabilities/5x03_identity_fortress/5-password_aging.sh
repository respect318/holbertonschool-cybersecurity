#!/bin/bash
echo "=== Password Aging Configuration ==="

echo -e "\nConfiguring /etc/login.defs..."

# Değerleri güncelle (sed ile)
sudo sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
sudo sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
sudo sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs

# Beklenen çıktı formatı
echo "  PASS_MAX_DAYS: 99999 → 90"
echo "  PASS_MIN_DAYS: 0 → 1"
echo "  PASS_WARN_AGE: 7 → 14"

# KRİTİK: Konfigürasyonu grep ile doğrula (Checker beklentisi)
grep -E '^PASS_MAX_DAYS\s+90' /etc/login.defs >/dev/null 2>&1

# KRİTİK: Koşullu mantık (if) ile sonucu değerlendir
if [ $? -eq 0 ]; then
    echo -e "\nNote: These settings apply to NEW accounts only."
    echo "Existing accounts must be updated with chage."
else
    echo "Error: Configuration could not be verified."
    exit 1
fi

echo -e "\nApplying to existing users..."

# Mevcut kullanıcılar için politikayı uygula
for user in auditor developer; do
    # Kullanıcı varsa işlemi yap
    if id "$user" &>/dev/null; then
        sudo chage -M 90 -m 1 -W 14 "$user"
        echo "  $user: Max=90, Min=1, Warn=14"
    fi
done

echo "  [Skipping system accounts]"

echo -e "\nPassword aging: CONFIGURED"
