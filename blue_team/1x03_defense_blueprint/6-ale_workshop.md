Risk: Ransomware encrypts EHR system
Source: GAP-001 (Flat network) + VULN-003 (Unrestricted DB access) + Ransomware Syndicate
Asset: EHR System (ehr-srv-01 + ehr-db-01)
Asset Value (AV): $5,000,000
  Replacement/recovery cost: $100,000
  Revenue loss during downtime: $288,000 ($16,000 per day × 18 days)
  Regulatory penalties: $1,500,000
  Reputation/patient trust impact: $3,112,000
Exposure Factor (EF): 100%
  Reasoning: A successful ransomware encryption renders the system entirely inaccessible, realizing the full downtime, recovery, and regulatory impact.
SLE: $5,000,000 × 1.0 = $5,000,000
ARO: 0.20
  Reasoning: Based on sector data, hospitals with flat networks and poor segmentation face a severe ransomware event approximately once every 5 years.
ALE: $5,000,000 × 0.20 = $1,000,000
Proposed Control: Implement VLAN Segmentation (CIS 12) + Air-gapped Backups (CIS 11)
Control Annual Cost: $60,000
Estimated ALE After Control: $50,000 (ARO reduced to 0.05, EF reduced to 20% due to rapid recovery)
Net Benefit: $1,000,000 - $50,000 - $60,000 = $890,000

---

Risk: Complete Enterprise Breach via Compromised VPN
Source: GAP-002 (Missing MFA) + VULN-012 (Single-factor admin access) + Initial Access Broker
Asset: FortiGate VPN & Entire Internal Network
Asset Value (AV): $6,000,000
  Replacement/recovery cost: $500,000 (Full enterprise incident response & rebuild)
  Revenue loss during downtime: $400,000 ($16,000 per day × 25 days)
  Regulatory penalties: $2,000,000
  Reputation/patient trust impact: $3,100,000
Exposure Factor (EF): 100%
  Reasoning: The VPN provides root access to the flat internal network; a breach here exposes the entire organization.
SLE: $6,000,000 × 1.0 = $6,000,000
ARO: 0.25
  Reasoning: VPNs are the top initial access vector. Without MFA, a credential stuffing or brute-force attack is highly likely to succeed every 4 years.
ALE: $6,000,000 × 0.25 = $1,500,000
Proposed Control: Enforce MFA for all external and administrative access (CIS 6)
Control Annual Cost: $25,000
Estimated ALE After Control: $120,000 (ARO drops to 0.02 as credential theft becomes vastly harder to exploit)
Net Benefit: $1,500,000 - $120,000 - $25,000 = $1,355,000

---

Risk: ePHI Breach via Physical Device Theft
Source: GAP-004 (Unencrypted endpoints) + VULN-015 (Unencrypted hard drives) + Insider Threat / Physical Theft
Asset: Mobile Medical Workstations (e.g., Clinical Laptops)
Asset Value (AV): $1,650,000
  Replacement/recovery cost: $50,000 (Cost of replacing hardware + forensics)
  Revenue loss during downtime: $0 (Minimal, devices are interchangeable)
  Regulatory penalties: $1,000,000 (HIPAA breach for 10,000 localized records)
  Reputation/patient trust impact: $600,000
Exposure Factor (EF): 100%
  Reasoning: The loss of an unencrypted device triggers immediate mandatory reporting and the full cost of a HIPAA breach.
SLE: $1,650,000 × 1.0 = $1,650,000
ARO: 0.50
  Reasoning: In a busy hospital environment, the physical loss or theft of a laptop/mobile device is a frequent occurrence, expected at least once every 2 years.
ALE: $1,650,000 × 0.50 = $825,000
Proposed Control: Enforce Full-Disk Encryption via MDM (CIS 3)
Control Annual Cost: $15,000
Estimated ALE After Control: $25,000 (Hardware replacement cost only. Under HIPAA Safe Harbor, encrypted data loss is not a reportable breach, EF drops to ~1.5%)
Net Benefit: $825,000 - $25,000 - $15,000 = $785,000

---

Risk: Widespread Malware Infection via Unpatched Software
Source: GAP-003 (No automated patching) + VULN-007 (Critical CVEs older than 30 days) + Automated Botnet
Asset: Clinical Workstation Fleet (280 endpoints)
Asset Value (AV): $250,000
  Replacement/recovery cost: $150,000 (IT labor to re-image 100+ endpoints)
  Revenue loss during downtime: $100,000 (Localized clinic disruptions)
  Regulatory penalties: $0 (Assuming no data exfiltration by simple botnets)
  Reputation/patient trust impact: $0
Exposure Factor (EF): 100%
  Reasoning: A rapidly spreading worm/botnet will fully realize the IT labor and operational disruption costs associated with mass cleanup.
SLE: $250,000 × 1.0 = $250,000
ARO: 1.0
  Reasoning: With manual, delayed patching processes, a widespread malware infection disrupting clinic operations is highly probable at least once a year.
ALE: $250,000 × 1.0 = $250,000
Proposed Control: Implement Automated Patch Management (CIS 7) and EDR (CIS 10)
Control Annual Cost: $45,000
Estimated ALE After Control: $25,000 (ARO drops to 0.1 due to drastically reduced attack surface)
Net Benefit: $250,000 - $25,000 - $45,000 = $180,000

---

Risk: Patient Safety Incident via Legacy Clinical Software
Source: GAP-006 (Legacy software usage) + VULN-022 (End-of-life medical software) + APT
Asset: Legacy Clinical Endpoints
Asset Value (AV): $3,500,000
  Replacement/recovery cost: $150,000 (FDA investigation and forensics)
  Revenue loss during downtime: $100,000
  Regulatory penalties: $500,000
  Reputation/patient trust impact: $2,750,000 (Medical malpractice liability and extreme trust loss)
Exposure Factor (EF): 100%
  Reasoning: If legacy software manipulating patient treatment is compromised, the maximum liability and safety impact is fully realized.
SLE: $3,500,000 × 1.0 = $3,500,000
ARO: 0.05
  Reasoning: Targeted attacks altering medical devices/software for harm are rare (1 in 20 years), but highly catastrophic when they occur.
ALE: $3,500,000 × 0.05 = $175,000
Proposed Control: Upgrade or Strictly Isolate Legacy Apps via Network Access Control (CIS 2 & CIS 12)
Control Annual Cost: $30,000
Estimated ALE After Control: $35,000 (ARO drops to 0.01 as isolation prevents network-based exploitation)
Net Benefit: $175,000 - $35,000 - $30,000 = $110,000

---

### Risk Prioritization by ALE

| Rank | Risk Description | ALE (Before Control) | Proposed Control | Net Benefit |
| :--- | :--- | :--- | :--- | :--- |
| **1** | Complete Enterprise Breach via Compromised VPN | $1,500,000 | Enforce MFA (CIS 6) | $1,355,000 |
| **2** | Ransomware encrypts EHR system | $1,000,000 | VLAN Segmentation (CIS 12) & Backups (CIS 11) | $890,000 |
| **3** | ePHI Breach via Physical Device Theft | $825,000 | Full-Disk Encryption via MDM (CIS 3) | $785,000 |
| **4** | Widespread Malware Infection via Unpatched Software | $250,000 | Automated Patching (CIS 7) & EDR (CIS 10) | $180,000 |
| **5** | Patient Safety Incident via Legacy Clinical Software | $175,000 | Upgrade/Isolate Legacy Apps (CIS 2 & CIS 12) | $110,000 |
