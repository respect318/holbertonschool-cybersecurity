#!/usr/bin/python3
"""
Test the Scope Guard foundation.
"""
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.scope import ScopeGuard

def run_tests():
    # The authorized domain per requirements
    guard = ScopeGuard("cartograph.example")
    
    # 1. Valid inside scope targets
    assert guard.is_in_scope("cartograph.example") == True, "Failed: Base domain blocked"
    assert guard.is_in_scope("api.cartograph.example") == True, "Failed: Valid subdomain blocked"
    
    # 2. Invalid / Out of scope targets (The traps)
    assert guard.is_in_scope("evil.com") == False, "Failed: Unrelated domain allowed"
    assert guard.is_in_scope("cartograph.example.attacker.test") == False, "Failed: Suffix trick allowed"
    
    print("FLAG-SCOPE-GUARD-ENFORCED")


if __name__ == "__main__":
    try:
        run_tests()
    except AssertionError as e:
        print(f"Test Failed: {e}", file=sys.stderr)
        sys.exit(1)
