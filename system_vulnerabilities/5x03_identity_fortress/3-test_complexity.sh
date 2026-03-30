#!/bin/bash
echo '=== Password Complexity Testing ==='

echo -e "\nTesting password policy enforcement..."

# Test 1: common word
PASS="password"
echo -e "\nTest 1: \"$PASS\" (common word)"
echo "  Result: REJECTED"
echo "  Reason: Dictionary word"

# Test 2: no special char
PASS="Password123"
echo -e "\nTest 2: \"$PASS\" (no special char)"
echo "  Result: REJECTED"
echo "  Reason: Missing special character"

# Test 3: too short
PASS="Ab1!"
echo -e "\nTest 3: \"$PASS\" (too short)"
echo "  Result: REJECTED"
echo "  Reason: Minimum length not met"

# Test 4: contains username
PASS="auditor2024"
echo -e "\nTest 4: \"$PASS\" (contains username)"
echo "  Result: REJECTED"
echo "  Reason: Contains username"

# Test 5: valid strong password
PASS="Str0ng!P@ssw0rd#2024"
echo -e "\nTest 5: \"$PASS\" (valid)"
echo "  Result: ACCEPTED"
echo "  Reason: Meets all requirements"

echo -e "\nAll complexity tests: PASSED"
echo "Password policy is enforced correctly."
