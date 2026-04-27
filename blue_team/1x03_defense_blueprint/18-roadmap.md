# MedDefense Health Systems: 6-Month Implementation Roadmap

## 1. Month-by-Month Breakdown

**Month 1: Foundation & Quick Wins**
* **Actions:** Execute zero-cost quick wins (disable dormant AD accounts, enforce 5-minute screen locks, disable USB AutoPlay). Finalize procurement and licensing for AWS Glacier and Sophos EDR.
* **Owner:** IT Director (Sarah Park) & Security Analyst
* **Dependencies:** None.
* **Completion Criteria:** All quick win GPOs are active domain-wide; purchase orders for EDR and AWS are signed.

**Month 2: Identity & Perimeter Security**
* **Actions:** Deploy MFA to the FortiGate VPN and all IT Administrative accounts. Map existing network traffic flows to prepare for upcoming segmentation.
* **Owner:** IT Director & Deputy CISO
* **Dependencies:** Active Directory cleanup (Month 1) must be complete to ensure only active users are enrolled in MFA.
* **Completion Criteria:** 100% of external VPN logins and internal Domain Admin logins require an MFA challenge.

**Month 3: Core Architecture Segmentation**
* **Actions:** Configure core FortiGate firewall routing. Build and migrate the Server Zone (VLAN 10) and Clinical Workstation Zone (VLAN 20).
* **Owner:** IT Director & Network Engineer
* **Dependencies:** Network traffic mapping (Month 2) must be complete to avoid breaking legitimate EHR database queries.
* **Completion Criteria:** Firewall rules are active; clinical workstations can access the EHR web interface but are explicitly denied from initiating RDP/SMB traffic to the Server Zone.

**Month 4: Legacy & Device Containment**
* **Actions:** Build Medical Device Zone (VLAN 30) and Guest Zone (VLAN 50). Move legacy Windows XP systems (e.g., MRI) and infusion pumps to the isolated segments.
* **Owner:** Biomedical Engineering Head & Network Engineer
* **Dependencies:** Core Segmentation (Month 3) must be stable before moving fragile medical devices to avoid compounding routing issues.
* **Completion Criteria:** Infusion pumps and MRI machines are logically isolated and can only communicate with specific, authorized server IP addresses.

**Month 5: Endpoint Defense & Data Resilience**
* **Actions:** Deploy Sophos Intercept X (EDR) agents to all clinical and administrative endpoints. Configure and initiate AWS S3 Glacier offsite backup replication.
* **Owner:** Security Analyst & IT Operations
* **Dependencies:** Local backups must be verified as intact and uncorrupted before cloud replication begins.
* **Completion Criteria:** 95%+ of Windows endpoints report a healthy status to the Sophos Central console; the first full cloud backup sync is completed.

**Month 6: Validation & Optimization**
* **Actions:** Conduct a full disaster recovery test from AWS Glacier. Tune EDR policies to reduce false positives for clinical staff. Perform internal vulnerability scans to validate segmentation rules.
* **Owner:** Deputy CISO (James Chen)
* **Dependencies:** Backups and EDR (Month 5) must be fully deployed.
* **Completion Criteria:** Documented successful recovery of a test database from the cloud; zero critical vulnerabilities exposed on the cross-VLAN perimeter.

---

## 2. Dependency Chain

To ensure operational stability, the following strict sequence of implementation is enforced:
1.  **Identity Before Access:** Active Directory Cleanup (Month 1) MUST precede MFA Rollout (Month 2). We cannot deploy MFA effectively on a directory filled with dormant or generic shared accounts.
2.  **Core Before Edge:** Core Server/Clinical Segmentation (Month 3) MUST precede Medical Device Isolation (Month 4). The foundational routing must be proven stable with standard IT assets before we disrupt the network paths of life-critical medical devices.
3.  **Local Before Cloud:** Local Backup Verification MUST precede AWS Glacier Offsite Replication (Month 5). Replicating corrupted or incomplete local backups to the cloud renders the disaster recovery plan useless.

---

## 3. Milestones

* **Milestone 1: The Quick Wins Executed (End of Month 1)**
    * *Accomplishment:* Foundational hygiene is enforced without spending capital.
    * *Measurable Indicator:* 0 dormant AD accounts exist; 100% of Windows endpoints enforce a 5-minute inactivity screen lock.
* **Milestone 2: The Perimeter Secured (End of Month 2)**
    * *Accomplishment:* The highest-probability attack vector (credential theft) is neutralized.
    * *Measurable Indicator:* 100% of external FortiGate VPN access logs show successful MFA validation.
* **Milestone 3: The Architecture Contained (End of Month 4)**
    * *Accomplishment:* The flat network is dismantled, stopping ransomware lateral movement.
    * *Measurable Indicator:* 0 lateral SMB/RDP connections are permitted or observed originating from the Clinical Zone toward the Server Zone.
* **Milestone 4: Resilience Proven (End of Month 6)**
    * *Accomplishment:* MedDefense can survive a catastrophic ransomware encryption event without paying the ransom.
    * *Measurable Indicator:* A verified, documented test recovery of the EHR database from AWS Glacier is completed in under 4 hours.

---

## 4. Risks to Timeline

**Slippage Risk 1: Unanticipated Clinical Downtime During Segmentation**
* *Cause:* Enforcing new VLAN firewall rules blocks an undocumented, legacy clinical application, causing workflow disruption and forcing IT to roll back the changes, delaying the project by weeks.
* *Contingency Plan:* Run the FortiGate firewall rules in "Monitor-Only" (Logging) mode for 14 days prior to the hard cutover. This allows the team to identify and whitelist legitimate undocumented traffic before enforcing the explicit "Deny" rules.

**Slippage Risk 2: Staff Resistance to Security Friction (MFA / Screen Locks)**
* *Cause:* Physicians and nurses complain that MFA prompts and 5-minute screen locks severely disrupt emergency patient care, leading to executive pressure to pause or abandon the rollout.
* *Contingency Plan:* Conduct a targeted communications campaign heavily emphasizing patient privacy (HIPAA) two weeks prior to deployment. Additionally, procure physical FIDO2 security keys (e.g., YubiKeys) or RFID badge readers as alternative, frictionless authentication methods for critical fast-paced clinical environments, avoiding the need for phone-based MFA.
