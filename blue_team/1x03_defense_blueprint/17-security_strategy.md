# MedDefense Health Systems: Security Strategy Document
**Prepared For:** Board of Directors & Executive Leadership  
**Date:** April 2026

---

## 1. Executive Summary
MedDefense Health Systems currently operates with a high-risk security posture characterized by a flat network topology, single-factor remote access, and unpatched legacy systems, leaving critical Electronic Protected Health Information (ePHI) highly vulnerable to ransomware and data exfiltration. Our strategic approach leverages the NIST Cybersecurity Framework (CSF) for high-level governance and the CIS Controls (v8) for tactical, prioritized implementation. 

We are requesting a highly optimized security investment of **$58,000** (well under the $120,000 maximum budget), which targets the most critical attack vectors to deliver over **$2.6 million in Annualized Loss Expectancy (ALE) reduction**. 

**Top 3 Priority Actions:**
1. **Enforce Multi-Factor Authentication (MFA)** on the FortiGate VPN and all administrative accounts.
2. **Implement Network Segmentation** to isolate servers, clinical endpoints, and medical devices.
3. **Establish Offsite Immutable Backups** to guarantee recovery from destructive ransomware.

---

## 2. Governance Framework
* **Framework Selection Rationale:** We selected NIST CSF to communicate lifecycle maturity (Identify, Protect, Detect, Respond, Recover) to the Board, while using the CIS Controls (IG1/IG2) to provide IT with a prescriptive, prioritized checklist of technical safeguards.
* **NIST CSF Current vs Target Profile:** MedDefense is currently operating at Tier 1 (Partial) in most functions, characterized by reactive processes. Our 6-month target is Tier 2 (Risk-Informed), with a 1-year goal of reaching Tier 3 (Repeatable) for the PROTECT and RECOVER functions.
* **CIS Controls Maturity Scorecard:** Out of the 18 CIS Controls, our baseline assessment evaluated 13 as Implemented, 5 as Partial, and 0 as Not Implemented (after resolving basic hygiene gaps).
* **Governance Structure & Roles:** We formally defined data governance to eliminate the "loudest voice" problem. Department Heads act as **Data Owners** (determining access), MedDefense acts as the **Data Controller**, third-party EHR vendors are **Data Processors**, and IT acts as the **Data Custodian** (implementing security). We recommend hiring a Virtual CISO (vCISO) to maintain executive alignment.

---

## 3. Quantitative Risk Analysis
By moving from qualitative opinions to quantitative math, we identified our top financial exposures based on Asset Value, Exposure Factor, and Annualized Rate of Occurrence.

**Top 5 Risks by ALE:**
1. Complete Enterprise Breach via Compromised VPN ($1,500,000 ALE)
2. Ransomware Encryption of EHR System ($1,000,000 ALE)
3. ePHI Breach via Physical Device Theft ($825,000 ALE)
4. Negligent Insider Data Mishandling ($300,000 ALE)
5. Widespread Malware Infection via Unpatched Software ($250,000 ALE)

* **Risk Appetite Statement:** MedDefense operates with a low risk appetite for threats impacting patient safety and ePHI confidentiality. Any risk carrying an ALE over $50,000 or directly threatening patient outcomes must be mitigated, unless formally accepted by the Board due to insurmountable operational constraints.

---

## 4. Control Strategy
* **Cost-Benefit Analysis:** We evaluated 8 potential controls. Expensive, un-optimized solutions like an outsourced 24/7 SOC ($150k) and an open-source SIEM ($85k labor) yielded negative ROI and were rejected. 
* **Budget Allocation:** We are funding MFA ($5k), Network Segmentation ($15k), Offsite Backups ($8k), and an EDR Upgrade ($30k). Total spend is **$58,000**, leaving $62,000 in budget reserves.
* **Control Selection Mapping:** * MFA maps to CIS 6 / NIST PR.AA
  * Segmentation maps to CIS 12 / NIST PR.AC
  * Offsite Backups map to CIS 11 / NIST RC.RP
  * EDR maps to CIS 10 / NIST DE.CM
* **Quick Wins (Zero-Cost):** We immediately disabled dormant AD accounts, enforced 5-minute screen locks via GPO, disabled USB AutoPlay, maximized enterprise DNS filtering, and forced password resets for all Domain Admins.

---

## 5. Architecture Recommendations
To break the dangerously flat 10.10.0.0/16 network, we designed a Zero-Trust inspired segmentation plan.
* **Network Zones:** Server Zone (VLAN 10), Clinical Zone (VLAN 20), Medical Device Zone (VLAN 30), Management Zone (VLAN 40), and Guest/IoT Zone (VLAN 50).
* **Kill Chain Disruption:** By applying strict firewall rules (e.g., explicitly denying Clinical Zone RDP/SMB traffic to the Server Zone), this architecture completely breaks the Ransomware kill chain at Step 3 (Lateral Movement). An infected nurse's station can no longer bridge to the EHR database or medical devices.

---

## 6. Policy Foundation
* **AUP Summary:** The new Acceptable Use Policy formally prohibits bypassing security tools, outlaws unencrypted personal USB drives, defines MFA and session locking mandates, and legally binds staff to handle ePHI securely.
* **Policy Roadmap:** Over the next two quarters, MedDefense will draft and approve:
  1. A formal Incident Response Plan (IRP)
  2. A Business Continuity and Disaster Recovery (BCDR) Policy
  3. A Third-Party Vendor Risk Management Policy

---

## 7. Residual Risk Assessment
* **Red Team Findings:** An adversarial simulation confirmed that while catastrophic ransomware is mitigated, MedDefense is still vulnerable to "Living off the Land" (LotL) data exfiltration by insiders or hijacked VPN sessions due to our lack of 24/7 logging/SIEM.
* **Accepted Risks:** We formally accepted the risk of the legacy Windows XP MRI workstation (due to an 18-month unvoidable $2.1M lease constraint) by isolating it entirely. We also temporarily accepted the lack of an enterprise SOC/SIEM due to budget caps.
* **Year 2 Priorities:** The #1 strategic priority for next fiscal year is funding an Enterprise SIEM or Managed SOC to provide visibility, reduce dwell time, and close the off-hours monitoring gap.

---

## 8. Implementation Roadmap
* **Phase 1: Foundation (Months 1-2):** Deploy zero-cost quick wins. Procure Sophos EDR and AWS Glacier contracts. Deploy MFA to VPN and IT admins. *Success Metric: 100% of external access secured by MFA.*
* **Phase 2: Architecture (Months 3-4):** Execute VLAN segmentation and firewall rule cutovers. Deploy EDR agents to all clinical endpoints. Configure cloud backup replication. *Success Metric: 0 lateral SMB traffic permitted between Clinical and Server zones.*
* **Phase 3: Validation (Months 5-6):** Conduct backup restoration tests. Tune EDR to reduce false positives. Audit AD for compliance. *Success Metric: Complete recovery of a test EHR database from AWS Glacier in under 4 hours.*

---

## 9. Next Steps
Executing this blueprint secures MedDefense's infrastructure, identity access, and architectural perimeters. The immediate next step (Project 1x04) will focus on our **Cryptographic Foundation**—ensuring that all ePHI data at rest and data in transit is protected by mathematical encryption, rendering stolen data useless and fulfilling the final requirements for HIPAA Safe Harbor compliance.
