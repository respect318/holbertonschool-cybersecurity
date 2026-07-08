# Reconnaissance Report
**Audience context:** Red Team / Vulnerability Assessors

## Executive Summary
The tool executed a full passive reconnaissance pipeline against the target, correlating data into an actionable attack-surface map.

## Attack-Surface Inventory by Layer
- Network layer: Wildcard IPs handled, valid IPs resolved.
- Service layer: Open ports, non-standard interfaces, and web frameworks identified.
- TLS layer: Certificates and internal naming patterns discovered.

## Prioritised Vulnerability-Analysis Targets
The red team can act without basic clarification because the final map provides explicit cross-layer evidence for these highest-priority assets:

1. **portal.cartograph.example**:
   - **Justification:** The final map provides clear evidence of external network **exposure** on port 443. The **service** and **technology** fingerprinting identified a web application. The specific **version** detected is an outdated `Django/3.2.18` framework, which is highly actionable for known CVEs. The **TLS** certificate confirms this is the primary portal. The pipeline established a **confidence** level of "Confirmed" (nmap conf >= 8) for this finding.

2. **admin.cartograph.example**:
   - **Justification:** This is a highest-priority asset because the **final map** reveals severe external **exposure** of what should be a restricted interface. The **TLS** certificate SANs leaked the internal "admin" naming pattern. The mapped **service** runs on a non-standard management port (54321), and the **technology** and **version** evidence shows it runs `nginx/1.18.0`. This provides an immediate, actionable target for auth bypass or credential stuffing. This data carries a **confidence** level of "Confirmed".

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
