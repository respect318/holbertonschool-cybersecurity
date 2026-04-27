# MedDefense Health Systems: Control Selection and Mapping

## Risk: RISK-001 (Ransomware Encryption of EHR System)
* **Selected Control:** Network Segmentation (VLANs) & Offsite Immutable Backups (AWS S3 Glacier)
* **CIS Control Mapping:** CIS 12 (Safeguard 12.2) & CIS 11 (Safeguard 11.4)
* **NIST CSF Mapping:** PR.AC (Access Control) & RC.RP (Recovery Planning)
* **Control Type:** Preventive (VLANs) & Corrective (Backups)
* **Control Category:** Technical
* **Implementation Cost:** $15,000 (Segmentation) + $8,000 (Backups)
* **Expected Risk Reduction:** $850,000 ALE reduction by containing lateral movement and ensuring offline recoverability.
* **Dependencies:** Requires a functional local backup process before cloud replication can be established.

## Risk: RISK-002 (Complete Enterprise Breach via Compromised VPN)
* **Selected Control:** MFA deployment on VPN and administrative accounts
* **CIS Control Mapping:** CIS 6 (Safeguards 6.3, 6.4, 6.5)
* **NIST CSF Mapping:** PR.AA (Identity Management, Authentication and Access Control)
* **Control Type:** Preventive
* **Control Category:** Technical
* **Implementation Cost:** $5,000 (Leveraging existing O365 licenses)
* **Expected Risk Reduction:** $1,380,000 ALE reduction by neutralizing credential stuffing and brute-force vectors.
* **Dependencies:** Requires Active Directory (AD) cleanup and a reliable identity baseline to map users properly.

## Risk: RISK-003 (ePHI Breach via Physical Device Theft)
* **Selected Control:** Full-Disk Encryption (BitLocker via MDM)
* **CIS Control Mapping:** CIS 3 (Safeguard 3.6)
* **NIST CSF Mapping:** PR.DS (Data Security)
* **Control Type:** Preventive / Compensating
* **Control Category:** Technical
* **Implementation Cost:** $0 incremental (Utilizing existing OS licenses and IT administrative labor)
* **Expected Risk Reduction:** Grants HIPAA "Safe Harbor" status, effectively removing the $800,000+ regulatory and reporting liability.
* **Dependencies:** Requires an accurate Hardware Asset Inventory (CIS 1) to ensure 100% deployment coverage.

## Risk: RISK-004 (Widespread Malware Infection via Unpatched Software)
* **Selected Control:** Endpoint Detection and Response (EDR) upgrade (Sophos Intercept X)
* **CIS Control Mapping:** CIS 10 (Safeguards 10.1, 10.2)
* **NIST CSF Mapping:** DE.CM (Continuous Monitoring) & PR.PT (Protective Technology)
* **Control Type:** Detective & Preventive
* **Control Category:** Technical
* **Implementation Cost:** $30,000
* **Expected Risk Reduction:** $180,000 ALE reduction by actively blocking fileless malware and ransomware behaviors.
* **Dependencies:** Requires a Software Inventory (CIS 2) to prevent conflicts with legacy medical applications.

## Risk: RISK-005 (Patient Safety Incident via Legacy Clinical Software)
* **Selected Control:** Network Access Control and Legacy VLAN Isolation
* **CIS Control Mapping:** CIS 12 (Safeguard 12.2)
* **NIST CSF Mapping:** PR.AC (Access Control)
* **Control Type:** Preventive
* **Control Category:** Technical
* **Implementation Cost:** Covered by the primary $15,000 Segmentation budget.
* **Expected Risk Reduction:** Prevents network-based exploitation of unpatchable medical systems, avoiding massive patient liability.
* **Dependencies:** Requires Network Architecture Mapping and Hardware Inventory (CIS 1).

## Risk: RISK-007 (Ransomware Attack on Billing Server)
* **Selected Control:** Offsite Backup Replication (AWS S3 Glacier)
* **CIS Control Mapping:** CIS 11 (Safeguard 11.4)
* **NIST CSF Mapping:** RC.RP (Recovery Planning)
* **Control Type:** Corrective
* **Control Category:** Technical
* **Implementation Cost:** Covered by the primary $8,000 Enterprise Backup budget.
* **Expected Risk Reduction:** Guarantees continuity of hospital revenue streams and prevents the loss of regulated financial records.
* **Dependencies:** Must be implemented in tandem with proper access controls to ensure the backup repository remains isolated.

## Risk: RISK-009 (Medical Device DoS / Infusion Pumps)
* **Selected Control:** Medical Device Containment (Dedicated IoT VLANs)
* **CIS Control Mapping:** CIS 12 (Safeguard 12.2)
* **NIST CSF Mapping:** PR.AC (Access Control)
* **Control Type:** Preventive
* **Control Category:** Technical
* **Implementation Cost:** Covered by the primary $15,000 Segmentation budget.
* **Expected Risk Reduction:** Protects the devices from opportunistic malware spreading on the general clinic network.
* **Dependencies:** Must be sequenced *after* the core IT server and workstation segmentation is complete.

---

### Control Dependency Map

The following text diagram illustrates the critical path for deploying these controls. Foundational hygiene must precede advanced architectural changes, and automated prevention must precede dedicated monitoring.

```text
PHASE 1: FOUNDATION (Asset & Identity Hygiene)
  [Hardware/Software Inventory (CIS 1 & 2)]
         │
         ├───> [Active Directory Cleanup] ───> [Deploy MFA on VPN/Admins (CIS 6)]
         │
         └───> [Deploy Full-Disk Encryption (CIS 3)]

PHASE 2: ARCHITECTURE & AUTOMATION (The $58k Budget Execution)
  [Baseline Network Mapping]
         │
         ├───> [Network Segmentation (CIS 12)] 
         │            │
         │            ├───> [Isolate Legacy Assets]
         │            └───> [Contain Medical Devices/IoT] ───> *[Dedicated IoT Monitor (Deferred)]*
         │
  [Local Backups Verified]
         │
         └───> [Offsite Immutable Cloud Backups (CIS 11)]

PHASE 3: ADVANCED PREVENTION
  [Endpoint Baseline Established]
         │
         └───> [Deploy EDR / Sophos Intercept X (CIS 10)]
                      │
                      └───> *[Enterprise SIEM (Deferred)]* ───> *[24/7 SOC (Rejected)]*
