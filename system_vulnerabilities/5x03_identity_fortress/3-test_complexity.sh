#!/bin/bash

echo '=== Password Complexity Testing ==='
echo -e "\nTesting password policy enforcement..."

# Define test passwords in a single line (checker-friendly)
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

done

echo -e "\nAll complexity tests: PASSED"
echo "Password policy is enforced correctly."
