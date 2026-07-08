#!/usr/bin/python3
"""
Scope Guard for The Cartographer.
Ensures no network actions target unauthorized domains or IPs.
"""

class ScopeGuard:
    def __init__(self, authorized_domain: str):
        self.authorized_domain = authorized_domain.lower().strip()
        self.allowed_ips = set()

    def add_allowed_ip(self, ip: str):
        """Add an IP resolved from an in-scope domain."""
        self.allowed_ips.add(ip)

    def is_in_scope(self, target: str) -> bool:
        """
        Check if a target (domain or IP) is strictly within scope.
        Blocks suffix tricks like 'cartograph.example.attacker.test'.
        """
        target = target.lower().strip()
        
        # Exact match
        if target == self.authorized_domain:
            return True
            
        # Subdomain match (must strictly end with .authorized_domain)
        if target.endswith("." + self.authorized_domain):
            return True
            
        # Allowed IP match
        if target in self.allowed_ips:
            return True
            
        return False
