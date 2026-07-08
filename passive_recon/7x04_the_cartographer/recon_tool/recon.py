#!/usr/bin/python3
"""
Entry point for The Cartographer.
"""
import argparse
from core.state import State
from core.scope import ScopeGuard
from core.orchestrator import Orchestrator

# Modulları bura import edirik
from modules.dns_module import DNSModule
from modules.subdomain_module import SubdomainModule
from modules.portscan_module import PortScanModule

if __name__ == "__main__":
    # Terminaldan gələn arqumentləri (komandaları) oxuyuruq
    parser = argparse.ArgumentParser(description="The Cartographer - Passive Recon")
    parser.add_argument('--domain', required=True, help="Target authorized domain")
    parser.add_argument('--module', help="Specific module to run (optional)")
    args = parser.parse_args()

    # Nüvə sistemlərini (State və ScopeGuard) işə salırıq
    state = State()
    state.add_domain(args.domain)
    
    scope = ScopeGuard(args.domain)
    orchestrator = Orchestrator(state, scope)
    
    # Bütün modullarımızı Orkestratora qeydiyyatdan keçiririk
    orchestrator.register(DNSModule())
    orchestrator.register(SubdomainModule())
    
    # Skripti tam işə salırıq
    print(f"Starting pipeline against {args.domain}...")
    orchestrator.execute()
    print("Pipeline finished.")
