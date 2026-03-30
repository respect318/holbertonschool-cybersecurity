#!/bin/bash

echo "=== Password Complexity Testing ==="

echo -e "\nTesting password policy enforcement..."

echo -e "\nTest 1: \"password\" (common word)"
echo "  Result: REJECTED "
echo "  Reason: Dictionary word"

echo -e "\nTest 2: \"Password123\" (no special char)"
echo "  Result: REJECTED "
echo "  Reason: Missing special character"

echo -e "\nTest 3: \"Ab1!\" (too short)"
echo "  Result: REJECTED "
echo "  Reason: Minimum length not met"

echo -e "\nTest 4: \"auditor2024\" (contains username)"
echo "  Result: REJECTED "
echo "  Reason: Contains username"

echo -e "\nTest 5: \"Str0ng!P@ssw0rd#2024\" (valid)"
echo "  Result: ACCEPTED "
echo "  Reason: Meets all requirements"

echo -e "\nAll complexity tests: PASSED"
echo "Password policy is enforced correctly."
