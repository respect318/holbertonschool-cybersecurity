#!/usr/bin/python3
"""
Test the foundation: Module Interface and Shared State.
"""
import sys
import os

# Ensure we can import from core correctly
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.module_base import ModuleBase
from core.state import State


class StubModuleA(ModuleBase):
    @property
    def name(self):
        return "stub_A"

    @property
    def dependencies(self):
        return []

    def run(self, state):
        state.add_domain("cartograph.example")
        state.add_host("10.0.0.1")


class StubModuleB(ModuleBase):
    @property
    def name(self):
        return "stub_B"

    @property
    def dependencies(self):
        return ["stub_A"]

    def run(self, state):
        # Deliberate duplicate to test dedup and merge logic
        state.add_domain("cartograph.example")
        state.add_host("10.0.0.1")


def run_tests():
    state = State()
    
    mod_a = StubModuleA()
    mod_b = StubModuleB()
    
    mod_a.run(state)
    mod_b.run(state)
    
    # Verify duplicate prevention and merging worked
    assert len(state.domains) == 1, "Duplicate domains were not merged!"
    assert len(state.hosts) == 1, "Duplicate hosts were not merged!"
    
    print("FLAG-STATE-FOUNDATION-VALIDATED")


if __name__ == "__main__":
    try:
        run_tests()
    except AssertionError as e:
        print(f"Test Failed: {e}", file=sys.stderr)
        sys.exit(1)
