#!/usr/bin/python3
"""
Test the Scope Guard against out-of-scope targets.
"""
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.scope import ScopeGuard


def run_tests():
    guard = ScopeGuard("cartograph.example")
    
    # Valid targets
    assert guard.is_in_scope("cartograph.example") == True
    assert guard.is_in_scope("api.cartograph.example") == True
    
    # Invalid / out-of-scope targets
    assert guard.is_in_scope("evil.com") == False
    assert guard.is_in_scope("cartograph.example.attacker.test") == False
    
    print("example-scope-flag-value")


if __name__ == "__main__":
    run_tests()
