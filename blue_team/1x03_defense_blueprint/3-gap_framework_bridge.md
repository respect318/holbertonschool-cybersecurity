Gap Reference: GAP-001
Description: Lack of network segmentation between clinical endpoints and administrative servers.
Vulnerability Evidence: VULN-003 (Unrestricted access from general subnet to PostgreSQL databases)
Threat Context: Ransomware Syndicate - Lateral Movement phase
NIST CSF Function: PROTECT (PR)
CIS Control: CIS Control 12 (Network Infrastructure Management)
Recommended Action: Implement VLANs and internal firewalls to strictly isolate clinical, administrative, and guest networks.

Gap Reference: GAP-002
Description: Multi-Factor Authentication is not enforced for internal administrative access.
Vulnerability Evidence: VULN-012 (Single-factor authentication identified on domain controllers)
Threat Context: Initial Access Broker - Privilege Escalation phase
NIST CSF Function: PROTECT (PR)
CIS Control: CIS Control 6 (Access Control Management)
Recommended Action: Deploy and enforce MFA for all accounts with administrative privileges on internal systems and servers.

Gap Reference: GAP-003
Description: Absence of an automated patch management system for third-party applications.
Vulnerability Evidence: VULN-007 (Multiple critical CVEs older than 30 days discovered on clinical workstations)
Threat Context: Automated Botnet - Initial Access phase
NIST CSF Function: IDENTIFY (ID)
CIS Control: CIS Control 7 (Continuous Vulnerability Management)
Recommended Action: Implement an automated patch management solution covering both OS and third-party software.

Gap Reference: GAP-004
Description: End-user devices processing electronic Protected Health Information (ePHI) lack full disk encryption.
Vulnerability Evidence: VULN-015 (Unencrypted hard drives detected on mobile medical workstations)
Threat Context: Insider Threat / Physical Theft - Data Exfiltration phase
NIST CSF Function: PROTECT (PR)
CIS Control: CIS Control 3 (Data Protection)
Recommended Action: Enforce full-disk encryption (e.g., BitLocker) via MDM on all company-issued devices handling sensitive data.

Gap Reference: GAP-005
Description: Lack of an isolated, offline instance of recovery data for critical healthcare systems.
Vulnerability Evidence: VULN-018 (Backup servers found accessible from the general user subnet)
Threat Context: Ransomware Syndicate - Impact and Data Destruction phase
NIST CSF Function: RECOVER (RC)
CIS Control: CIS Control 11 (Data Recovery)
Recommended Action: Establish immutable, offline backups stored in an air-gapped or strongly isolated environment.

Gap Reference: GAP-006
Description: Presence of unauthorized and legacy software applications on clinical endpoints.
Vulnerability Evidence: VULN-022 (End-of-life, unsupported medical software found on 15 workstations)
Threat Context: Advanced Persistent Threat (APT) - Execution phase
NIST CSF Function: PROTECT (PR)
CIS Control: CIS Control 2 (Inventory and Control of Software Assets)
Recommended Action: Upgrade legacy systems or isolate them in heavily restricted VLANs if an immediate upgrade is not feasible.

Gap Reference: GAP-007
Description: Reliance on legacy antivirus without centralized behavioral anomaly detection.
Vulnerability Evidence: VULN-029 (Inability to detect simulated fileless malware execution during host analysis)
Threat Context: Ransomware Syndicate - Defense Evasion phase
NIST CSF Function: DETECT (DE)
CIS Control: CIS Control 10 (Malware Defenses)
Recommended Action: Deploy an enterprise Endpoint Detection and Response (EDR) solution with automated centralized alerting.

Gap Reference: GAP-008
Description: Absence of a designated incident response team and formal enterprise reporting procedures.
Vulnerability Evidence: VULN-034 (No established communication channels utilized during the simulated breach assessment)
Threat Context: Any Threat Actor - Impact phase
NIST CSF Function: RESPOND (RS)
CIS Control: CIS Control 17 (Incident Response Management)
Recommended Action: Develop, document, and proactively test a comprehensive Incident Response Plan (IRP) assigning specific roles.

### Traceability Summary Table

| Gap ID | Description | Vulnerability | Threat Context | NIST CSF | CIS Control | Recommended Action |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **GAP-001** | Flat network topology | VULN-003 | Ransomware (Lateral Movement) | PROTECT | Control 12 | Implement VLAN segmentation |
| **GAP-002** | Missing MFA for admins | VULN-012 | Access Broker (Privilege Esc.) | PROTECT | Control 6 | Enforce internal admin MFA |
| **GAP-003** | Manual patching process | VULN-007 | Botnet (Initial Access) | IDENTIFY | Control 7 | Automate application patching |
| **GAP-004** | Unencrypted endpoints | VULN-015 | Physical Theft (Exfiltration) | PROTECT | Control 3 | Enforce full-disk encryption |
| **GAP-005** | Online-only backups | VULN-018 | Ransomware (Impact) | RECOVER | Control 11 | Establish air-gapped backups |
| **GAP-006** | Legacy software usage | VULN-022 | APT (Execution) | PROTECT | Control 2 | Upgrade or isolate legacy apps |
| **GAP-007** | Lack of centralized EDR | VULN-029 | Ransomware (Defense Evasion) | DETECT | Control 10 | Deploy enterprise EDR |
| **GAP-008** | No formal IR plan | VULN-034 | Any Actor (Impact) | RESPOND | Control 17 | Develop and test formal IRP |
