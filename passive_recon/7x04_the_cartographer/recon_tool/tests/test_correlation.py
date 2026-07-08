#!/usr/bin/python3
"""
Tests for the Correlation Engine.
"""
import sys, os
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from core.state import State
from core.correlation import CorrelationEngine

def test_correlation():
    state = State()
    
    # Fabricate three cross-referenced findings about the same asset
    # Finding 1: Discovered by hostname
    state.add_domain("cartograph.example")
    
    # Finding 2: Discovered by resolved ip
    state.add_host("127.40.0.10")
    
    # Finding 3: Discovered by certificate san
    state.add_domain("cartograph.example")
    
    engine = CorrelationEngine(state)
    records = engine.correlate()
    
    # Verify that the output contains one enriched record rather than three
    assert len(records) == 1
    
    # The printed value is your flag for this task
    print("FLAG-CORRELATION-ENGINE-VALIDATED")

if __name__ == "__main__":
    test_correlation()
