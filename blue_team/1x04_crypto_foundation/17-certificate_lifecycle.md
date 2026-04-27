# Certificate Lifecycle Management Plan

## Certificate Inventory

| Certificate Subject / Purpose | Current Issuer | Estimated Expiration Date | Responsible Owner |
| :--- | :--- | :--- | :--- |
| **Patient Portal** (`web-srv-01`) | Let's Encrypt | 18 Days from present (Finding 013) | IT Administrator |
| **EHR Internal DB** (`ehr-db-01`) | None (To be implemented) | TBD (1 year from issuance) | Database Administrator |
| **VPN Tunnels** (FortiGate Central/Westside) | Self-Signed / OEM Default | Unknown (Requires immediate audit) | Network Administrator |
| **Email Services** (O365) | Microsoft / DigiCert | Managed natively by Microsoft | IT Administrator |
| **Medical Devices** (PACS, BD Alaris) | OEM CA / Internal CA | Variable | Clinical IT Manager |

## Auto-Renewal Strategy

MedDefense should implement a **hybrid strategy**. For internal systems, automated ACME (like Let's Encrypt or an internal ACME-enabled CA) should be used to issue free, 90-day certificates to eliminate administrative overhead. 

However, for the **Patient Portal specifically, MedDefense must use a Commercial CA (manual, paid, 1-year certificates)**. 
**Justification:** The portal handles 800 daily patient connections. A free Let's Encrypt certificate only provides Domain Validation (DV). A healthcare organization requires Organization Validation (OV) to cryptographically prove MedDefense's legal identity to patients, which defends against sophisticated phishing attacks attempting to steal Protected Health Information (PHI). While the manual 1-year cycle introduces human error risk, this is mitigated by the robust monitoring and alerting strategy below, and the OV trust level is non-negotiable for a medical portal.

## Monitoring and Alerting

**System:** MedDefense must integrate certificate monitoring into its central infrastructure monitoring platform (e.g., Zabbix, Nagios, or Datadog) using external HTTPS checks and internal network probing scripts.

**Alerting Thresholds and Escalation Path:**
* **60 Days Before Expiration:** A standard ticket is generated in the IT Helpdesk system. Assigned to the IT Administrator.
* **30 Days Before Expiration:** A high-priority alert is sent via email and Slack/Teams. Sent to the IT Administrator and Network Administrator.
* **15 Days Before Expiration:** A critical alert is triggered. Sent to the IT Director (Sarah Park) and CISO (James Chen) to force executive visibility.
* **7 Days Before Expiration:** An emergency SMS/PagerDuty notification is fired. Escalated to the entire IT leadership team and On-Call Engineers 24/7 until resolved.

## Certificate Policy

To prevent future cryptographic mismanagement, MedDefense formally adopts the following 5 rules:
1. **No Self-Signed Certificates in Production:** All production services must use certificates signed either by a trusted public Certificate Authority (for external services) or the authorized MedDefense Internal Enterprise CA (for internal services).
2. **Strict Cryptographic Minimums:** All newly issued certificates must utilize at minimum ECC P-256 or RSA-2048 for the key pair, and SHA-256 for the signature algorithm. Algorithms like MD5 and SHA-1 are strictly prohibited.
3. **Mandatory OV for Public Portals:** Any public-facing web service processing PHI, PCI, or authentication credentials must utilize an Organization Validated (OV) or Extended Validation (EV) certificate.
4. **Wildcard Prohibition:** The use of wildcard certificates (e.g., `*.meddefense.com`) is strictly prohibited. Every server and service must have a single-domain certificate with explicit Subject Alternative Names (SANs) to enforce the principle of least privilege.
5. **Centralized Key Escrow for Internal CA:** The private key for the MedDefense Internal Root CA must be kept completely offline in a physical, tamper-evident safe (Key Escrow), accessible only by dual-authorization from the CEO and IT Director.
