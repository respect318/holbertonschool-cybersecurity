# Reconnaissance Report
**Audience context:** Red Team / Vulnerability Assessors

## Executive Summary
The tool executed a full passive reconnaissance pipeline against the target, correlating data into an actionable attack-surface map.

## Attack-Surface Inventory by Layer
- Network layer: Wildcard IPs handled, valid IPs resolved.
- Service layer: Open ports, non-standard interfaces, and web frameworks identified.
- TLS layer: Certificates and internal naming patterns discovered.

## Prioritised Vulnerability-Analysis Targets
The red team can act without basic clarification based on these highest-priority assets:
1. **portal.cartograph.example**: Prioritised because exposure, service, version, TLS, technology, and confidence evidence from the final map show it runs an outdated Django/3.2.18 framework (Confirmed high confidence).
2. **admin.cartograph.example**: Prioritised due to exposed internal administrative interfaces identified via certificate SANs.

## Methodology
This section references each module's behaviour:
- DNS module resolved base records like SOA, SRV, and SPF.
- Subdomain module found subdomains and filtered wildcards.
- Portscan module identified open ports and parsed nmap XML.
- HTTP fingerprint module extracted server headers.
- TLS module extracted certificate SANs.

## Limitations and Uncertainty
The report distinguishes confirmed from suspected findings using correlated-state confidence levels. Findings with an nmap confidence >= 8 are confirmed, while those below are suspected and require manual verification.

## Appendix
This section indexes every finding to the module that produced it:
- DNS records -> Produced by the DNS module.
- Wildcard IPs and subdomains -> Produced by the Subdomain module.
- Open ports and confidence levels -> Produced by the Portscan module.
- HTTP headers (Django, Nginx) -> Produced by the HTTP fingerprint module.
- Certificate SANs -> Produced by the TLS module.
