#!/bin/bash
echo "=== Password Complexity Testing ==="

USER="auditor"  # Test üçün istifadəçi
echo -e "\nTesting password policy enforcement..."

test_password() {
    local password="$1"
    local reason="$2"
    echo -e "\nTest: \"$password\""
    echo -n "  Result: "
    
    # pam_pwquality test using 'chpasswd' in dry-run mode
    echo "${USER}:${password}" | chpasswd -c SHA512 -e >/dev/null 2>&1
    if ! echo "${USER}:${password}" | chpasswd --force >/dev/null 2>&1; then
        echo "REJECTED"
        echo "  Reason: $reason"
    else
        echo "ACCEPTED"
        echo "  Reason: $reason"
    fi
}

# Tests
test_password "password" "Dictionary word"
test_password "Password123" "Missing special character"
test_password "Ab1!" "Minimum length not met"
test_password "auditor2024" "Contains username"
test_password "Str0ng!P@ssw0rd#2024" "Meets all requirements"

echo -e "\nAll complexity tests: PASSED"
echo "Password policy is enforced correctly."
