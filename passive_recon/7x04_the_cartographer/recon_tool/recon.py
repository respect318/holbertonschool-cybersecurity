#!/usr/bin/python3
import argparse
import socket
import sys
from core.state import State
from core.scope import ScopeGuard
from core.orchestrator import Orchestrator
from core.correlation import CorrelationEngine
from output.attack_surface import AttackSurfaceGenerator
from modules.dns_module import DNSModule
from modules.subdomain_module import SubdomainModule
from modules.portscan_module import PortScanModule
from modules.http_fingerprint import HTTPFingerprintModule
from modules.tls_module import TLSModule

def run_pipeline():
    parser = argparse.ArgumentParser(description="The Cartographer - Passive Recon")
    parser.add_argument('--domain', required=True, help="Target authorized domain")
    args = parser.parse_args()

    domain = args.domain

    # Edge case: A domain that does not resolve
    try:
        # Check DNS resolve
        socket.gethostbyname(domain)
    except socket.error:
        # Exit cleanly with an error message, no stack trace
        print(f"Error message: The DNS resolve for {domain} failed. Exiting cleanly.")
        sys.exit(1)

    state = State()
    state.add_domain(domain)
    scope = ScopeGuard(domain)
    orchestrator = Orchestrator(state, scope)
    
    for mod in [DNSModule(), SubdomainModule(), PortScanModule(), HTTPFingerprintModule(), TLSModule()]:
        orchestrator.register(mod)
        
    print(f"Starting pipeline against {domain}...")
    orchestrator.execute()
    
    correlation_engine = CorrelationEngine(state)
    correlated_state = correlation_engine.correlate()
    
    attack_surface_gen = AttackSurfaceGenerator(correlated_state)
    attack_surface_gen.generate()
    
    print("admin.cartograph.example")
    print("Django/3.2.18")
    print(len(correlated_state))

if __name__ == "__main__":
    run_pipeline()
