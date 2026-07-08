#!/usr/bin/python3
"""
Scope Guard for The Cartographer.
Ensures no network actions target unauthorized domains or IPs.
"""
import ipaddress


class ScopeGuard:
    def __init__(self, domain: str):
        self.domain = domain.lower().strip()
        self.resolved_ips = set()

    def add_allowed_ip(self, ip: str):
        """Add an IP resolved from an in-scope domain."""
        self.resolved_ips.add(ip)

    def is_in_scope(self, target: str) -> bool:
        """
        Check if a target (domain or IP) is strictly within scope.
        """
        target = target.lower().strip()
        
        # Exact match
        if target == self.domain:
            return True
            
        # Subdomain match
        if target.endswith("." + self.domain):
            return True
            
        # Check if it is an explicitly allowed resolved IP address
        try:
            ip_obj = ipaddress.ip_address(target)
            if str(ip_obj) in self.resolved_ips:
                return True
        except ValueError:
            pass
            
        return False
