# MedDefense Vector-to-Asset Matrix

This matrix cross-references the primary attack vectors with MedDefense's critical assets to map potential attack paths and kill chains.

| Vectors \ Assets | EHR Database (ehr-db-01) | Billing Server (billing-srv-01) | Backup NAS | Email (Office 365) | PACS Workstation | Medical IoT | Active Directory |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Phishing / Spear Phishing** | Phishing → harvested credentials → VPN → flat network → EHR database. | Phishing → harvested credentials → VPN → flat network → billing-srv-01. | Phishing → IT admin credentials → login to network-accessible NAS. | Phishing → O365 login portal → unauthorized access to corporate mail. | Phishing → staff workstation access → lateral move to PACS. | Phishing → internal network foothold → scan for IoT web interfaces. | Phishing → IT admin credentials → Domain Controller takeover. |
| **VPN Exploit** | VPN vulnerability → internal foothold → flat network → EHR data. | VPN vulnerability → internal foothold → flat network → billing server. | VPN vulnerability → internal foothold → direct access to Backup NAS. | | VPN vulnerability → internal foothold → lateral move to PACS segment. | VPN vulnerability → internal foothold → pivot to medical device network. | VPN vulnerability → internal foothold → exploit unpatched Domain Controller. |
| **Default / Shared Credentials** | | | Use of default admin/admin on the network-accessible backup NAS. | | Use of shared "raduser" credentials to access patient imaging. | Use of default vendor credentials on BD Alaris pump web interfaces. | |
| **Vulnerable Software Exploit** | Internal foothold → exploit PostgreSQL vulnerability on ehr-db-01. | Direct exploitation of Apache 2.4.29 RCE on billing-srv-01. | | | | Exploit unpatched firmware vulnerabilities in medical devices. | Exploit unpatched Server 2012 R2 vulnerabilities on Domain Controller. |
| **Supply Chain Compromise** | Compromised MedTech VPN → direct maintenance access to EHR server. | | | Compromise of O365 identity provider → global email access. | Compromised Siemens laptop → MRI workstation → imaging data access. | Poisoned firmware update via manufacturer → medical device takeover. | Compromised Sophos agent update → system-level access to AD. |
| **Insider (Malicious)** | Malicious employee → authorized clinical access → data exfiltration. | Terminated IT admin → secondary VPN account → drop database tables. | Malicious admin → wipe or encrypt physical and network backups. | Disgruntled user → search O365 for sensitive strategic information. | | | Malicious admin → create ghost accounts for long-term persistence. |
| **Insider (Negligent)** | Clinician leaves session open → unauthorized EHR data access. | | Admin stores backups on unencrypted NAS → ransomware encryption. | User clicks phishing link → credential harvest → O365 breach. | | Nurse connects personal Raspberry Pi → bridge for external attack. | Admin shares admin script with plaintext passwords via email. |
| **Physical Access** | | | Physical theft of backup drives from the server rack. | | Tailgating → IT corridor access → log into unsecured PACS terminal. | Physical access to patient room → connect to unmanaged IoT port. | |

---

## Strategic Analysis

### Top 3 Most Connected Assets
1. **EHR Database:** Reachable by almost every vector, it is the primary target due to high data value and clinical urgency.
2. **Active Directory:** Vulnerable to phishing, supply chain, and unpatched software, representing the "keys to the kingdom" for total control.
3. **Medical IoT:** Highly exposed through defaults, supply chain, and physical access, posing direct risks to patient safety.

*These intersections represent high priority because their compromise leads to immediate operational failure or risk to human life.*

### Top 3 Most Versatile Vectors
1. **Phishing:** Reaches every critical asset by harvesting credentials that bypass perimeter defenses.
2. **Supply Chain Compromise:** Bypasses internal security controls by exploiting the inherent trust between MedDefense and its vendors.
3. **VPN Exploit:** Acts as the primary bridge that allows external actors to enter the flat network and move laterally toward any internal asset.

*These vectors represent high priority because they provide multiple, distinct paths to the organization's most sensitive data and systems.*
