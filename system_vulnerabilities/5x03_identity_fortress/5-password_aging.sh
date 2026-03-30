#!/bin/bash
echo "=== Password Aging Configuration ==="

echo -e "\nConfiguring /etc/login.defs..."

# Maksimum yaş: 90 gün
OLD_MAX=$(grep ^PASS_MAX_DAYS /etc/login.defs | awk '{print $2}')
sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
echo "  PASS_MAX_DAYS: ${OLD_MAX:-UNKNOWN} → 90"

# Minimum yaş: 1 gün
OLD_MIN=$(grep ^PASS_MIN_DAYS /etc/login.defs | awk '{print $2}')
sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
echo "  PASS_MIN_DAYS: ${OLD_MIN:-UNKNOWN} → 1"

# Xəbərdarlıq: 14 gün
OLD_WARN=$(grep ^PASS_WARN_AGE /etc/login.defs | awk '{print $2}')
sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   14/' /etc/login.defs
echo "  PASS_WARN_AGE: ${OLD_WARN:-UNKNOWN} → 14"

echo -e "\nNote: These settings apply to NEW accounts only."
echo "Existing accounts must be updated with chage."

# Mövcud istifadəçilərə tətbiq et (sadə nümunə auditor və developer)
echo -e "\nApplying to existing users..."
for user in auditor developer; do
    if id "$user" &>/dev/null; then
        chage --maxdays 90 --mindays 1 --warndays 14 "$user"
        echo "  $user: Max=90, Min=1, Warn=14"
    fi
done

echo -e "\nPassword aging: CONFIGURED"
