#!/usr/bin/python3
"""
DNS Reconnaissance Module for The Cartographer.
Built from scratch using dnspython. No shell calls.
"""
import dns.resolver
import dns.exception
from core.module_base import ModuleBase


class DNSModule(ModuleBase):
    @property
    def name(self) -> str:
        return "dns"

    @property
    def dependencies(self) -> list:
        return []

    def run(self, state):
        target_domains = list(state.domains)
        if not target_domains:
            return

        resolver = dns.resolver.Resolver()
        resolver.timeout = 5
        resolver.lifetime = 5

        record_types = ['A', 'AAAA', 'MX', 'TXT', 'NS', 'SOA', 'CAA']
        
        srv_prefixes = [
            '_sip._tcp.', '_autodiscover._tcp.', 
            '_xmpp-client._tcp.', '_ldap._tcp.'
        ]

        for domain in target_domains:
            for rtype in record_types:
                try:
                    answers = resolver.resolve(domain, rtype)
                    for rdata in answers:
                        val = rdata.to_text().strip('"')
                        
                        if rtype in ['A', 'AAAA']:
                            state.add_host(val)
                            
                        elif rtype == 'NS':
                            host = val.split()[-1].rstrip('.')
                            state.add_domain(host)
                            print(f"[NS] {val}")
                            
                        elif rtype == 'MX':
                            preference = getattr(rdata, 'preference', 0)
                            exchange = rdata.exchange.to_text().rstrip('.')
                            state.add_domain(exchange)
                            
                        elif rtype == 'TXT':
                            if "v=spf1" in val.lower() or "SPF" in val:
                                print(f"[SPF] {val}")
                                
                except (dns.exception.DNSException, Exception):
                    pass

            try:
                dmarc_domain = f"_dmarc.{domain}"
                dmarc_answers = resolver.resolve(dmarc_domain, 'TXT')
                for rdata in dmarc_answers:
                    val = rdata.to_text().strip('"')
                    if "DMARC" in val.upper():
                        pass
            except (dns.exception.DNSException, Exception):
                pass

            for prefix in srv_prefixes:
                srv_domain = f"{prefix}{domain}"
                try:
                    srv_answers = resolver.resolve(srv_domain, 'SRV')
                    for rdata in srv_answers:
                        val = rdata.to_text()
                        print(f"[SRV] {srv_domain} -> {val}")
                        
                        parts = val.split()
                        if len(parts) >= 4:
                            target_host = parts[3].rstrip('.')
                            state.add_domain(target_host)
                except (dns.exception.DNSException, Exception):
                    pass
