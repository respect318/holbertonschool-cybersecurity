# Reconnaissance Report
**Audience Context:** Red Team / Vulnerability Analysis Team

## Executive Summary
This report details the attack-surface map generated for the target engagement. The automated pipeline successfully mapped the domain, correlating DNS, HTTP, port, and TLS data to provide actionable intelligence for the vulnerability analysis phase.

## Attack-Surface Inventory by Layer
- **Network Layer:** Wildcard IP resolution detected; valid endpoints resolved and mapped.
- **Service Layer:** Web servers, frameworks, and non-standard management interfaces identified.
- **TLS Layer:** Internal backend naming conventions exposed via Subject Alternative Names (SAN).

## Prioritised Vulnerability-Analysis Targets
The red team can act without basic clarification because each asset is justified using evidence from the final map:

1. **portal.cartograph.example**
   - **Justification:** Evidence from the final map shows severe external **exposure** on port 443. The identified **service** is a web portal, and the fingerprinting **technology** confirms it runs Django. Crucially, the specific **version** detected is 3.2.18, an outdated release vulnerable to known CVEs. The **TLS** certificate validates the domain identity. This data is marked with high **confidence** (Confirmed).

2. **admin.cartograph.example**
   - **Justification:** Evidence from the final map highlights critical **exposure** of an administrative portal on a non-standard port (54321). The **service** mapped is an admin interface. The **technology** detected is Nginx, and the **version** is 1.18.0. Furthermore, the **TLS** SAN leaked this internal naming convention to the public internet. This finding carries a high **confidence** rating (Confirmed).

## Methodology
The pipeline executed sequentially, referencing each module's behaviour:
- **DNS Module:** Queried SOA, SRV, and SPF records to establish the base scope.
- **Subdomain Module:** Handled wildcard detection and enumerated internal patterns.
- **Portscan Module:** Ran TCP port scans and parsed service banners from nmap XML.
- **HTTP Fingerprint Module:** Extracted Server and X-Powered-By headers.
- **TLS Module:** Parsed certificates to extract issuer and SAN data.

## Limitations and Uncertainty
The report distinguishes confirmed from suspected findings using correlated-state confidence levels. Findings mapped with an nmap confidence >= 8 are treated as Confirmed. Any findings below this threshold are Suspected and require manual verification.

## Appendix
This section indexes every finding to the module that produced it:
- DNS records (SPF, SRV) -> Produced by the DNS module.
- Wildcard IPs and enumerated subdomains -> Produced by the Subdomain module.
- Open ports, service names, and confidence levels -> Produced by the Portscan module.
- HTTP headers (Django, Nginx) -> Produced by the HTTP fingerprint module.
- Certificate SANs and issuer details -> Produced by the TLS module.
