#!/usr/bin/python3
"""
Entry point for The Cartographer.
"""
import argparse
import sys
from core.state import State
from core.scope import ScopeGuard
from core.orchestrator import Orchestrator
from core.logger import get_logger
from modules.dns_module import DNSModule

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="The Cartographer - Passive Recon")
    parser.add_argument('--domain', required=True, help="Target authorized domain")
    parser.add_argument('--module', help="Specific module to run (optional)")
    args = parser.parse_args()

    # Initialize foundations
    state = State()
    state.add_domain(args.domain)
    
    scope = ScopeGuard(args.domain)
    orchestrator = Orchestrator(state, scope)
    
    # Register modules
    orchestrator.register(DNSModule())
    
    # Execute
    print(f"Starting pipeline against {args.domain}...")
    orchestrator.execute()
    print("Pipeline finished.")
