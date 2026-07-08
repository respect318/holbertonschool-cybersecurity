#!/usr/bin/python3
"""
DNS Reconnaissance Module for The Cartographer.
Built from scratch using dnspython. No subprocess calls.
"""
import dns.resolver
import dns.exception
from core.module_base import ModuleBase
from core.logger import get_logger


class DNSModule(ModuleBase):
    @property
    def name(self) -> str:
        return "dns"

    @property
    def dependencies(self) -> list:
        return []

    def run(self, state):
        logger = get_logger("DNSModule")
        
        # We start scanning the base domains provided to the state
        target_domains = list(state.domains)
        if not target_domains:
            logger.error("No domains in state to resolve.")
            return

        resolver = dns.resolver.Resolver()
        resolver.timeout = 5
        resolver.lifetime = 5

        record_types = ['A', 'AAAA', 'MX', 'TXT', 'NS', 'SOA', 'CAA']
        
        # Common service labels for SRV discovery
        srv_prefixes = [
            '_sip._tcp.', '_autodiscover._tcp.', 
            '_xmpp-client._tcp.', '_ldap._tcp.', '_service._tcp.'
        ]

        for domain in target_domains:
            logger.info(f"[*] Resolving DNS records for: {domain}")
            
            # 1. Standard DNS Records
            for rtype in record_types:
                try:
                    answers = resolver.resolve(domain, rtype)
                    for rdata in answers:
                        val = rdata.to_text().strip('"')
                        logger.info(f"[+] Found {rtype} record: {val}")
                        
                        # Add resolved IP addresses to state
                        if rtype in ['A', 'AAAA']:
                            state.add_host(val)
                            
                        # Add discovered nameservers or mail servers to domains
                        elif rtype in ['NS', 'MX']:
                            # e.g., "10 mail.example.com." -> extract "mail.example.com"
                            host = val.split()[-1].rstrip('.')
                            state.add_domain(host)
                            
                except (dns.exception.DNSException, Exception):
                    pass

            # 2. Extract DMARC Policy
            try:
                dmarc_domain = f"_dmarc.{domain}"
                dmarc_answers = resolver.resolve(dmarc_domain, 'TXT')
                for rdata in dmarc_answers:
                    val = rdata.to_text().strip('"')
                    logger.info(f"[+] Found DMARC record: {val}")
            except (dns.exception.DNSException, Exception):
                pass

            # 3. Discover SRV Records
            for prefix in srv_prefixes:
                srv_domain = f"{prefix}{domain}"
                try:
                    srv_answers = resolver.resolve(srv_domain, 'SRV')
                    for rdata in srv_answers:
                        val = rdata.to_text()
                        logger.info(f"[+] Found SRV record for {srv_domain}: {val}")
                        
                        # Example SRV val: "10 5 8080 host.example.com."
                        parts = val.split()
                        if len(parts) >= 4:
                            target_host = parts[3].rstrip('.')
                            state.add_domain(target_host)
                except (dns.exception.DNSException, Exception):
                    pass
