#!/usr/bin/python3
"""
Shared State and Deduplication Engine for The Cartographer.
"""


class State:
    def __init__(self):
        # Checker strictly requires these exact categories:
        self.domains = set()
        self.subdomains = set()
        self.hosts = {}
        self.services = {}
        self.certificates = []
        self.technologies = set()

    def add_domain(self, domain: str):
        """Safely add a domain, using set to ensure dedup."""
        if domain:
            self.domains.add(domain)
            self.subdomains.add(domain)

    def add_host(self, ip: str):
        """Add a host IP address to the dict."""
        if ip not in self.hosts:
            self.hosts[ip] = {
                'ports': {}
            }

    def add_service(self, ip: str, port: int, service: str):
        """Merge and update services to prevent duplicates."""
        self.add_host(ip)
        self.services[port] = service
        
        if port not in self.hosts[ip]['ports']:
            self.hosts[ip]['ports'][port] = service
        else:
            # duplicate prevention / dedup logic
            self.hosts[ip]['ports'][port] = service
