# MedDefense Health Systems: Enterprise Risk Register

## RISK-001: Ransomware Encryption of EHR System
* **Risk Description:** A ransomware attack encrypts the primary Electronic Health Record (EHR) database, causing severe operational downtime and data loss.
* **Risk Category:** Operational / Financial
* **Threat Source:** Ransomware Syndicate
* **Vulnerability:** VULN-003 (Unrestricted internal DB access)
* **Affected Asset(s):** ehr-srv-01, ehr-db-01
* **Likelihood:** 4 (High - Expected once every 3-5 years without controls)
* **Impact:** 5 (Critical - Severe patient impact, massive financial loss)
* **Inherent Risk Score:** 20 (Critical)
* **ALE:** $1,000,000
* **Risk Owner:** Department Heads (Data Owners) / IT Director (Custodian)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** The ALE is unacceptably high; architectural mitigation provides massive ROI.
* **Planned Control(s):** C1 (VLAN Segmentation) and C4 (AWS Glacier Offsite Backups)
* **Residual Risk:** Low (Score: 4)
* **KRI:** Number of successful, verified backup restores completed per month.
* **Review Date:** October 2026

---

## RISK-002: Complete Enterprise Breach via Compromised VPN
* **Risk Description:** An external attacker gains full internal network access using stolen or brute-forced VPN credentials.
* **Risk Category:** Strategic
* **Threat Source:** Initial Access Broker
* **Vulnerability:** VULN-012 (Single-factor authentication on VPN)
* **Affected Asset(s):** FortiGate VPN, Entire 10.10.0.0/16 Network
* **Likelihood:** 5 (Very High - VPNs are the #1 initial access vector)
* **Impact:** 5 (Critical - Exposes all enterprise data and systems)
* **Inherent Risk Score:** 25 (Critical)
* **ALE:** $1,500,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** This is the highest ROI control available and eliminates the most statistically common attack vector.
* **Planned Control(s):** C2 (MFA Deployment on VPN and Admin accounts)
* **Residual Risk:** Low (Score: 5)
* **KRI:** Count of failed login attempts on the external VPN portal per week.
* **Review Date:** September 2026

---

## RISK-003: ePHI Breach via Physical Device Theft
* **Risk Description:** The physical loss or theft of an unencrypted clinical laptop results in a reportable HIPAA data breach.
* **Risk Category:** Compliance
* **Threat Source:** Insider Threat / Physical Theft
* **Vulnerability:** VULN-015 (Unencrypted hard drives on endpoints)
* **Affected Asset(s):** Mobile Medical Workstations
* **Likelihood:** 4 (High - Common occurrence in busy hospital environments)
* **Impact:** 4 (High - Mandatory reporting, reputational damage, regulatory fines)
* **Inherent Risk Score:** 16 (High)
* **ALE:** $825,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Encrypting hardware grants HIPAA "Safe Harbor" status, turning a major compliance breach into a simple hardware loss.
* **Planned Control(s):** Full-Disk Encryption (BitLocker via MDM)
* **Residual Risk:** Low (Score: 4)
* **KRI:** Percentage of mobile devices checking into the network lacking active encryption.
* **Review Date:** October 2026

---

## RISK-004: Widespread Malware Infection via Unpatched Software
* **Risk Description:** An automated botnet or worm rapidly spreads across clinical endpoints due to outdated software and legacy AV.
* **Risk Category:** Operational
* **Threat Source:** Automated Botnet
* **Vulnerability:** VULN-007 (Critical CVEs older than 30 days)
* **Affected Asset(s):** Clinical Workstation Fleet (280 endpoints)
* **Likelihood:** 5 (Very High - Constant background threat on internet-connected networks)
* **Impact:** 3 (Moderate - Operational disruption requiring IT labor, no data exfiltration)
* **Inherent Risk Score:** 15 (High)
* **ALE:** $250,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Upgrading to automated behavioral blocking yields a high return by stopping fileless malware before it spreads.
* **Planned Control(s):** C5 (Sophos Intercept X EDR Upgrade)
* **Residual Risk:** Medium (Score: 6)
* **KRI:** Average dwell time of unpatched critical CVEs on endpoints.
* **Review Date:** November 2026

---

## RISK-005: Patient Safety Incident via Legacy Clinical Software
* **Risk Description:** Compromise of outdated, unpatchable clinical software results in altered patient treatments or diagnostic disruption.
* **Risk Category:** Financial / Compliance
* **Threat Source:** Advanced Persistent Threat (APT)
* **Vulnerability:** VULN-022 (End-of-life medical software usage)
* **Affected Asset(s):** Legacy Clinical Endpoints
* **Likelihood:** 2 (Low - Highly targeted attacks are rare)
* **Impact:** 5 (Critical - Direct threat to patient safety and maximum liability)
* **Inherent Risk Score:** 10 (Medium)
* **ALE:** $175,000
* **Risk Owner:** Chief Medical Officer / Department Heads
* **Treatment Decision:** Mitigate (via Containment)
* **Treatment Justification:** While dedicated IoT monitors were too expensive, standard network isolation contains the threat at minimal cost.
* **Planned Control(s):** C1 (VLAN Segmentation isolating legacy assets)
* **Residual Risk:** Low (Score: 4)
* **KRI:** Volume of dropped internal traffic attempting to route into the legacy VLAN.
* **Review Date:** December 2026

---

## RISK-006: Negligent Insider Data Mishandling
* **Risk Description:** An employee accidentally exposes or misroutes sensitive patient data due to a lack of technical guardrails (e.g., no DLP).
* **Risk Category:** Compliance
* **Threat Source:** Negligent Insider
* **Vulnerability:** Absence of USB restrictions and Data Loss Prevention (DLP) tools.
* **Affected Asset(s):** Clinical Workstations, ehr-srv-01 data
* **Likelihood:** 5 (Very High - Sector average is 2-3 incidents annually)
* **Impact:** 3 (Moderate - Localized compliance incident)
* **Inherent Risk Score:** 15 (High)
* **ALE:** $300,000
* **Risk Owner:** HR Director / Deputy CISO
* **Treatment Decision:** Accept (Temporarily)
* **Treatment Justification:** No budget remains in FY26 for enterprise DLP tools; the risk is formally accepted for this cycle.
* **Planned Control(s):** None funded (Deferred to FY27)
* **Residual Risk:** High (Score: 15)
* **KRI:** Number of reported accidental data exposure or misrouting incidents per quarter.
* **Review Date:** January 2027

---

## RISK-007: Ransomware Attack on Billing Server
* **Risk Description:** Attackers encrypt the primary billing server, halting revenue processing and destroying recent financial records.
* **Risk Category:** Financial
* **Threat Source:** Ransomware Syndicate
* **Vulnerability:** VULN-007 (Unpatched services on internal servers)
* **Affected Asset(s):** billing-srv-01
* **Likelihood:** 3 (Medium)
* **Impact:** 4 (High - $16,000/day revenue loss)
* **Inherent Risk Score:** 12 (Medium)
* **ALE:** $156,090
* **Risk Owner:** Chief Financial Officer (Robert Kim)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Offsite backups are a cheap, mathematically justified way to guarantee financial records survive an attack.
* **Planned Control(s):** C4 (AWS Glacier Offsite Backups)
* **Residual Risk:** Low (Score: 3)
* **KRI:** Time required to successfully restore a test billing database from the AWS cloud.
* **Review Date:** October 2026

---

## RISK-008: Delayed Incident Response
* **Risk Description:** Lack of 24/7 monitoring allows an attacker to dwell undetected in the network, escalating privileges over weeks.
* **Risk Category:** Strategic
* **Threat Source:** APT / Ransomware Syndicate
* **Vulnerability:** VULN-034 (No established SOC or SIEM monitoring)
* **Affected Asset(s):** All Enterprise Assets
* **Likelihood:** 3 (Medium)
* **Impact:** 4 (High)
* **Inherent Risk Score:** 12 (Medium)
* **ALE:** $120,000
* **Risk Owner:** Deputy CISO (James Chen)
* **Treatment Decision:** Accept
* **Treatment Justification:** The $150k cost of an outsourced SOC exceeds the entire security budget; the risk is accepted while we build foundational automated defenses (EDR).
* **Planned Control(s):** Relying entirely on automated EDR (C5) prevention for now.
* **Residual Risk:** Medium (Score: 12)
* **KRI:** Average time taken to acknowledge and triage high-severity EDR alerts during business hours.
* **Review Date:** January 2027

---

## RISK-009: Medical Device DoS (Infusion Pumps)
* **Risk Description:** Opportunistic malware exploits default credentials on medical devices, causing them to quarantine and disrupting operations.
* **Risk Category:** Operational
* **Threat Source:** Automated Botnet / Script Kiddies
* **Vulnerability:** VULN-010 (Default credentials on medical devices)
* **Affected Asset(s):** BD Alaris infusion pumps (7 units)
* **Likelihood:** 3 (Medium)
* **Impact:** 3 (Moderate - Switch to manual dosing)
* **Inherent Risk Score:** 9 (Medium)
* **ALE:** $10,000
* **Risk Owner:** Biomedical Engineering Head
* **Treatment Decision:** Mitigate (via Containment)
* **Treatment Justification:** Dedicated IoT security tools were rejected for budget reasons, but isolating the pumps via VLANs provides adequate protection.
* **Planned Control(s):** C1 (VLAN Segmentation)
* **Residual Risk:** Low (Score: 3)
* **KRI:** Volume of unauthorized broadcast traffic hitting the medical device VLAN.
* **Review Date:** December 2026

---

## RISK-010: Opportunistic Branch Compromise
* **Risk Description:** An attacker easily breaches the Westside Clinic perimeter due to a lack of enterprise-grade firewall protection.
* **Risk Category:** Operational
* **Threat Source:** Opportunistic Attacker
* **Vulnerability:** Consumer-grade perimeter router in use at the branch.
* **Affected Asset(s):** Westside Clinic Network
* **Likelihood:** 4 (High)
* **Impact:** 2 (Low - Minimal local data, no bridge to HQ without VPN auth)
* **Inherent Risk Score:** 8 (Medium)
* **ALE:** $5,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Accept (Temporarily)
* **Treatment Justification:** Because Control 2 (MFA) fully secures the VPN tunnel to HQ, the branch network risk is acceptable until the standard IT hardware refresh cycle next year.
* **Planned Control(s):** None funded (Deferred to FY27)
* **Residual Risk:** Medium (Score: 8)
* **KRI:** Number of unauthorized network scans or login attempts originating from the branch VPN tunnel toward HQ.
* **Review Date:** January 2027

---

### Risk Register Governance Note

This Risk Register is owned and maintained by the Deputy CISO (James Chen) and the Security Analyst, serving as the definitive system of record for MedDefense's security posture. It is formally reviewed on a monthly basis during the IT and Security Steering Committee meetings to ensure alignment with ongoing operations. An out-of-cycle emergency review is automatically triggered in the event of a major security incident, a significant architectural change (such as a clinic acquisition), or the publication of a critical zero-day vulnerability affecting core assets. Furthermore, if any defined Key Risk Indicator (KRI) threshold is breached—such as offsite backup failure rates exceeding 5%—an automated alert is generated for the Risk Owner, and emergency remediation must be scheduled within 48 hours to bring the exposure back within the Board's acceptable risk tolerance limits.
