# Prioritized Gap Analysis

**Gap ID:** GAP-001
**Title:** Flat Network Exposing Medical IoT and Legacy Systems
**Affected Asset(s):** Network Core, Medical IoT (PUMP-ICU, MON-ICU) [Critical]
**Data at Risk:** Patient Medical Records / Vitals [Restricted]
**Current Control Status:** Unprotected (C-001 FortiGate rule is too permissive; no internal boundaries)
**What is Missing:** Technical Preventive (Network Segmentation / VLANs)
**Risk Level:** Critical
**Risk Justification:** Gap affects Critical-rated life-safety IoT devices handling Restricted data and has absolutely no detective or corrective controls in place to stop lateral movement.
**Potential Impact:** Malware or attackers can move laterally from a compromised reception PC directly to life-critical infusion pumps, remotely altering dosages and directly threatening patient lives.

**Gap ID:** GAP-002
**Title:** Single Point of Failure for Disaster Recovery (Local Backups Only)
**Affected Asset(s):** NAS-01 (Backup Storage) [Critical]
**Data at Risk:** Patient Medical Records / Entire DB [Restricted]
**Current Control Status:** Weak (C-006 Veeam Nightly Backups stored locally in the same rack)
**What is Missing:** Technical Corrective (Offsite / Cloud Backup Replication)
**Risk Level:** Critical
**Risk Justification:** Gap affects Critical organizational data with absolutely no secondary corrective control available if the primary physical room is compromised.
**Potential Impact:** A physical disaster (fire, flood) or a network-wide ransomware attack will destroy both primary servers and the backup NAS simultaneously, causing unrecoverable data loss and permanent hospital shutdown.

**Gap ID:** GAP-003
**Title:** Complete Absence of Centralized Security Logging
**Affected Asset(s):** Network Core, All Servers [Critical]
**Data at Risk:** System and Audit Logs [Confidential]
**Current Control Status:** Weak (C-011 Standalone logs only, manually reviewed)
**What is Missing:** Technical Detective (SIEM, Automated Alerting)
**Risk Level:** Critical
**Risk Justification:** Affects Critical infrastructure assets and has zero automated detective controls, allowing threats to operate unseen.
**Potential Impact:** Attackers can breach the network, elevate privileges, and exfiltrate data for months without triggering a single alert, maximizing the severity of the data breach.

**Gap ID:** GAP-004
**Title:** Missing Endpoint Protection on Production Servers
**Affected Asset(s):** billing-srv-01, file-srv-01, ehr-srv-01 [High to Critical]
**Data at Risk:** Financial Data, Employee HR Records [Restricted / Confidential]
**Current Control Status:** Adequate for workstations (C-005), completely absent for servers
**What is Missing:** Technical Preventive (Server Antivirus / EDR)
**Risk Level:** Critical
**Risk Justification:** Critical servers lack preventive malware controls and have no dedicated detective controls to catch an infection as it starts.
**Potential Impact:** Ransomware and cryptominers can execute unimpeded on high-value servers, leading to prolonged downtime of financial and clinical systems (as demonstrated by the January ransomware incident).

**Gap ID:** GAP-005
**Title:** End-of-Life MRI Workstation on Production Network
**Affected Asset(s):** WS-RAD-01 (MRI Control) [Critical]
**Data at Risk:** Diagnostic Imaging Data [Restricted]
**Current Control Status:** Partially Protected (Only if Task 6 compensating controls are applied; currently exposed)
**What is Missing:** Technical Preventive (Microsegmentation) / Technical Detective (NIDS)
**Risk Level:** Critical
**Risk Justification:** Critical asset running unpatchable Windows XP accessing Restricted data, with zero current detective or corrective controls preventing network exploitation.
**Potential Impact:** Trivial exploitation of Win XP vulnerabilities allows attackers a permanent backdoor into the hospital network and the ability to manipulate diagnostic imaging.

**Gap ID:** GAP-006
**Title:** Unrestricted Outbound Network Traffic (No Egress Filtering)
**Affected Asset(s):** FortiGate Firewall / Internal Subnets [Critical]
**Data at Risk:** Financial & Billing Data, PHI [Restricted]
**Current Control Status:** Weak (C-001 Allows ALL outbound traffic natively)
**What is Missing:** Technical Preventive (Egress firewall rules)
**Risk Level:** High
**Risk Justification:** Affects a Critical routing asset but receives a High rating because a partial detective control (C-002 FortiGate traffic logging) exists.
**Potential Impact:** Infected internal systems (like the billing server cryptominer) can freely communicate with external Command & Control (C2) servers to receive payloads or exfiltrate sensitive data.

**Gap ID:** GAP-007
**Title:** Insecure Clinical Workstation Practices (Unattended Sessions)
**Affected Asset(s):** Endpoints Clinical [High]
**Data at Risk:** Patient Medical Records [Restricted]
**Current Control Status:** Adequate password policy (C-007), but physically bypassed by staff behavior
**What is Missing:** Technical Preventive (Automatic screen lock timeouts) / Administrative Preventive (Secure workflow enforcement)
**Risk Level:** High
**Risk Justification:** Affects High-rated clinical endpoints and Restricted data, but has incomplete control coverage (passwords exist but aren't utilized between shifts).
**Potential Impact:** Unauthorized individuals (visitors, unauthorized staff) can walk up to logged-in nurse stations and view or alter sensitive patient medical records, causing a severe HIPAA violation.

**Gap ID:** GAP-008
**Title:** Radiology Shared Accounts 
**Affected Asset(s):** pacs-srv-01 / WS-RAD-01 [Critical]
**Data at Risk:** Diagnostic Imaging Data [Restricted]
**Current Control Status:** Weak (C-012 Compensating rotation policy, extremely difficult to enforce)
**What is Missing:** Administrative / Technical Preventive (Individual User Authentication)
**Risk Level:** High
**Risk Justification:** Affects a Critical asset, but has a partial compensating administrative measure (C-012) reducing the rating to High.
**Potential Impact:** If malicious or negligent activity originates from the Radiology workstation, it is impossible to establish non-repudiation and identify which specific employee committed the action.

**Gap ID:** GAP-009
**Title:** Unmanaged Shadow IT Storage in Clinical Wards
**Affected Asset(s):** Dr. Patel's Personal NAS [High]
**Data at Risk:** Medical Research Data / PHI [Restricted]
**Current Control Status:** Unprotected (No corporate controls applied)
**What is Missing:** Administrative Preventive (IT Procurement Policy) / Technical Corrective (Backups)
**Risk Level:** High
**Risk Justification:** High-rated asset holding Restricted data entirely outside of IT governance with totally incomplete control coverage.
**Potential Impact:** Severe data loss due to personal hardware failure without backups, or a massive data breach if the unpatched personal hardware is compromised by network malware.

**Gap ID:** GAP-010
**Title:** Physical Security Deficiencies in Primary Server Room
**Affected Asset(s):** Core IT Infrastructure / Central Servers [Critical]
**Data at Risk:** System Credentials / All Data [Restricted]
**Current Control Status:** Weak (C-009 Guard at main entrance, C-010 cameras do not cover server room)
**What is Missing:** Physical Detective / Preventive (Server room cameras, biometric or role-based badge access)
**Risk Level:** High
**Risk Justification:** Affects Critical infrastructure, but partial physical controls (Main lobby guard) provide some, albeit incomplete, coverage.
**Potential Impact:** An insider threat or a tailgating visitor can physically access the server room to destroy backups, plug in rogue devices (like the Raspberry Pi), or steal hard drives containing Restricted data without being recorded.

***

### Gap Distribution Summary
* **Risk Levels:** 5 Critical, 5 High, 0 Medium, 0 Low.
* **Asset Categories with the most gaps:** The vast majority of gaps affect the **Core Network & Servers** (Infrastructure) and **Medical IoT**. These are the most vulnerable areas due to the flat network and unpatched OS environments.
* **Control Concentration:** The gaps are heavily concentrated in the **Technical Preventive** (missing network segmentation, server AV, egress filtering) and **Technical Detective** (missing SIEM, log monitoring, NIDS) categories. This confirms the earlier pattern that MedDefense has extremely weak perimeters and is entirely blind to internal network threats once that perimeter is breached.
