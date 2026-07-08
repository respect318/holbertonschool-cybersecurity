#!/usr/bin/python3
"""
Test the Orchestrator: Dependency resolution and execution order.
"""
import sys
import os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.module_base import ModuleBase
from core.state import State
from core.orchestrator import Orchestrator

# Global list to track the actual order of execution in our stubs
execution_log = []

class StubModuleA(ModuleBase):
    @property
    def name(self): return "A"
    @property
    def dependencies(self): return []
    def run(self, state): execution_log.append("A")

class StubModuleB(ModuleBase):
    @property
    def name(self): return "B"
    @property
    def dependencies(self): return ["A"]
    def run(self, state): execution_log.append("B")

class StubModuleC(ModuleBase):
    @property
    def name(self): return "C"
    @property
    def dependencies(self): return ["A"]
    def run(self, state): execution_log.append("C")

class StubModuleD(ModuleBase):
    @property
    def name(self): return "D"
    @property
    def dependencies(self): return ["B", "C"]
    def run(self, state): execution_log.append("D")

class StubModuleCycle1(ModuleBase):
    @property
    def name(self): return "Cycle1"
    @property
    def dependencies(self): return ["Cycle2"]
    def run(self, state): pass

class StubModuleCycle2(ModuleBase):
    @property
    def name(self): return "Cycle2"
    @property
    def dependencies(self): return ["Cycle1"]
    def run(self, state): pass

def run_tests():
    state = State()
    orchestrator = Orchestrator(state)
    
    # 1. Register valid modules
    orchestrator.register(StubModuleA())
    orchestrator.register(StubModuleB())
    orchestrator.register(StubModuleC())
    orchestrator.register(StubModuleD())
    
    # Execute the pipeline
    orchestrator.execute()
    
    # 2. Check if all modules ran
    for mod in ["A", "B", "C", "D"]:
        assert mod in execution_log, f"Module {mod} did not execute!"
        
    # 3. Verify strict execution order based on dependencies
    idx_a = execution_log.index("A")
    idx_b = execution_log.index("B")
    idx_c = execution_log.index("C")
    idx_d = execution_log.index("D")
    
    assert idx_a < idx_b, "Error: Module A must execute before B"
    assert idx_a < idx_c, "Error: Module A must execute before C"
    assert idx_b < idx_d, "Error: Module B must execute before D"
    assert idx_c < idx_d, "Error: Module C must execute before D"

    # 4. Verify Circular Dependency Detection
    state2 = State()
    orch_cycle = Orchestrator(state2)
    orch_cycle.register(StubModuleCycle1())
    orch_cycle.register(StubModuleCycle2())
    try:
        orch_cycle.execute()
        assert False, "Error: Orchestrator failed to detect a circular dependency!"
    except ValueError:
        pass # Expected behavior

    print("FLAG-PIPELINE-ORCHESTRATED")


if __name__ == "__main__":
    try:
        run_tests()
    except AssertionError as e:
        print(f"Test Failed: {e}", file=sys.stderr)
        sys.exit(1)
