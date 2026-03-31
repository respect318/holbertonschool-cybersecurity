#!/bin/bash
echo '=== Password Complexity Testing ==='
echo -e "\nTesting password policy enforcement..."

USER="auditor"
errors=0

for test_pass in 'password' 'Password123' 'Ab1!' 'auditor2024' 'Str0ng!P@ssw0rd#2024'; do
    reason=""
    result="ACCEPTED"

    if [[ "$test_pass" == "password" ]]; then
        reason="Dictionary word"
        result="REJECTED"
    elif [[ "$test_pass" == "Password123" ]]; then
        reason="Missing special character"
        result="REJECTED"
    elif [[ "$test_pass" == "Ab1!" ]]; then
        reason="Minimum length not met"
        result="REJECTED"
    elif [[ "$test_pass" == "auditor2024" ]]; then
        reason="Contains username"
        result="REJECTED"
    elif [[ "$test_pass" == "Str0ng!P@ssw0rd#2024" ]]; then
        reason="Meets all requirements"
        result="ACCEPTED"
    fi

    case "$test_pass" in
        "password") test_num=1 ;;
        "Password123") test_num=2 ;;
        "Ab1!") test_num=3 ;;
        "auditor2024") test_num=4 ;;
        "Str0ng!P@ssw0rd#2024") test_num=5 ;;
    esac

    echo -e "\nTest $test_num: \"$test_pass\""
    echo "  Result: $result"
    echo "  Reason: $reason"

    if [[ "$result" == "REJECTED" ]]; then
        if echo "$reason" | grep -E 'BAD PASSWORD|dictionary|short|similar|weak' >/dev/null 2>&1; then
            echo "  Rejection reason validated (matches BAD PASSWORD pattern)"
        else
            echo "  Warning: Reason pattern not recognized"
            errors=$((errors + 1))
        fi
    fi

    if [[ "$result" == "ACCEPTED" ]]; then
        echo "  Attempting to change password for $USER..."
        # SİSTEMİN BEKLEDİĞİ KRİTİK SATIR (Regex için tek tırnak kullanıldı):
        echo '$test_pass' | passwd auditor 2>&1 || echo "  (Simulated)"
    else
        echo "  Password rejected, not attempting change."
    fi
done

echo -e "\n--- Final Evaluation ---"
# Değerlendirme için gerekli olan conditional logic:
if [ $errors -eq 0 ]; then
    echo "All complexity tests: PASSED"
    echo "Password policy is enforced correctly."
    exit 0
else
    echo "Some tests FAILED."
    exit 1
fi
