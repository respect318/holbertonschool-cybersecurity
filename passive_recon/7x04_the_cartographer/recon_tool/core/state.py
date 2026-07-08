#!/usr/bin/python3
"""
Shared State and Deduplication Engine for The Cartographer.
"""
class State:
    def __init__(self):
        self.domains = set()
        self.hosts = {}
        self.errors = []
        self.blocked_references = []

    def add_domain(self, domain: str):
        if domain:
            self.domains.add(domain)

    def add_host(self, ip: str, hostname: str = None):
        if ip not in self.hosts:
            self.hosts[ip] = {
                'hostnames': set(),
                'ports': {},
                'technologies': set(),
                'certificates': []
            }
        if hostname:
            self.hosts[ip]['hostnames'].add(hostname)
            self.add_domain(hostname)

    def add_port(self, ip: str, port: int, service: str = None, version: str = None):
        if ip not in self.hosts:
            self.add_host(ip)
            
        port_data = self.hosts[ip]['ports']
        
        if port not in port_data:
            port_data[port] = {'service': service, 'version': version}
        else:
            if service and not port_data[port].get('service'):
                port_data[port]['service'] = service
            if version and not port_data[port].get('version'):
                port_data[port]['version'] = version
