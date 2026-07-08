#!/usr/bin/python3
"""
Subdomain Reconnaissance Module for The Cartographer.
Hybrid approach: own permutation logic combined with subfinder integration.
"""
import subprocess
import dns.resolver
import dns.exception
import random
import string
from core.module_base import ModuleBase

class SubdomainModule(ModuleBase):
    @property
    def name(self) -> str:
        return "subdomain"

    @property
    def dependencies(self) -> list:
        # Depends on dns module output
        return ["dns"]

    def run(self, state):
        target_domains = list(state.domains)
        if not target_domains:
            return

        resolver = dns.resolver.Resolver()
        resolver.timeout = 5
        resolver.lifetime = 5

        # Implement own wordlist candidate generation
        wordlist = ['admin', 'internal', 'backend', 'dev', 'api', 'staging', 'internal-svc']
        
        for base_domain in target_domains:
            # 1. Wildcard detection with a random control candidate
            random_prefix = ''.join(random.choices(string.ascii_lowercase + string.digits, k=12))
            control_domain = f"{random_prefix}.{base_domain}"
            wildcard_ips = set()
            
            try:
                answers = resolver.resolve(control_domain, 'A')
                for rdata in answers:
                    wildcard_ips.add(rdata.to_text())
            except (dns.exception.DNSException, Exception):
                pass

            if wildcard_ips:
                wildcard_ip_str = list(wildcard_ips)[0]
                print(f"[WILDCARD_IP] {wildcard_ip_str}")
            else:
                print("no-wildcard")

            candidates = set() # using set for initial dedup

            # 2. generate candidates from wordlist
            for word in wordlist:
                candidates.add(f"{word}.{base_domain}")
                
            # Generate permutation from known asset
            for known_asset in list(state.domains):
                if known_asset.endswith(base_domain):
                    prefix = known_asset.replace(f".{base_domain}", "")
                    candidates.add(f"{prefix}-dev.{base_domain}") # permutation logic

            # 3. Third-party discovery stream: subfinder
            try:
                result = subprocess.run(
                    ['subfinder', '-d', base_domain, '-silent'],
                    capture_output=True,
                    text=True,
                    timeout=30
                )
                if result.returncode == 0:
                    for line in result.stdout.splitlines():
                        clean_line = line.strip().lower()
                        if clean_line.endswith(base_domain):
                            candidates.add(clean_line)
            except Exception:
                pass

            # 4. Resolve, filter and merge streams
            for candidate in candidates:
                try:
                    answers = resolver.resolve(candidate, 'A')
                    candidate_ips = {rdata.to_text() for rdata in answers}
                    
                    # filter out wildcard artefacts
                    if wildcard_ips:
                        if any(ip in wildcard_ips for ip in candidate_ips):
                            # discard artefact resolving to the control IP
                            continue
                        
                    # merge into state
                    state.add_domain(candidate)
                    for ip in candidate_ips:
                        state.add_host(ip)
                        
                    # Print if it matches internal naming patterns
                    if any(pattern in candidate for pattern in ['internal', 'backend', 'admin']):
                        print(f"[PATTERN_MATCH] {candidate}")
                        
                except (dns.exception.DNSException, Exception):
                    pass
