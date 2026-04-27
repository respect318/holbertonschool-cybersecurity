# MedDefense Health Systems: Enterprise Risk Register

## RISK-001: Ransomware Encryption of EHR System
* **Risk Description:** Based on 1x01 Kill Chain #1, a ransomware attack encrypts the primary Electronic Health Record (EHR) database due to a flat network topology, causing severe operational downtime.
* **Risk Category:** Operational / Financial
* **Threat Source:** [From 1x01 Threat Profile] BlackReef-style Ransomware Syndicate
* **Vulnerability:** [From 1x02 Finding 003] Unrestricted access from general subnet to PostgreSQL databases
* **Affected Asset(s):** [From 1x00 Asset Registry] ehr-srv-01, ehr-db-01
* **Likelihood:** 4 (High - Expected once every 3-5 years based on sector data)
* **Impact:** 5 (Critical - Severe patient impact, massive financial loss)
* **Inherent Risk Score:** 20 (Critical)
* **ALE:** $1,000,000
* **Risk Owner:** Department Heads (Data Owners) / IT Director (Custodian)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** The ALE is unacceptably high; architectural mitigation (segmentation and backups) provides massive ROI.
* **Planned Control(s):** C1 (VLAN Segmentation) and C4 (AWS Glacier Offsite Backups)
* **Residual Risk:** Low (Score: 4)
* **KRI:** Number of successful, verified backup restores completed per month.
* **Review Date:** October 2026

---

## RISK-002: Complete Enterprise Breach via Compromised VPN
* **Risk Description:** As mapped in 1x01 Kill Chains, an Initial Access Broker gains full internal network access using stolen credentials because the external gateway lacks MFA.
* **Risk Category:** Strategic
* **Threat Source:** [From 1x01 Threat Profile] Initial Access Broker
* **Vulnerability:** [From 1x02 Finding 012] Single-factor authentication identified on FortiGate VPN portal
* **Affected Asset(s):** [From 1x00 Asset Registry] FortiGate VPN, Entire 10.10.0.0/16 Network
* **Likelihood:** 5 (Very High - VPNs are the #1 initial access vector in healthcare)
* **Impact:** 5 (Critical - Exposes all enterprise data and systems)
* **Inherent Risk Score:** 25 (Critical)
* **ALE:** $1,500,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Neutralizing credential-based initial access vectors is the highest ROI control available to MedDefense.
* **Planned Control(s):** C2 (MFA Deployment on VPN and Admin accounts)
* **Residual Risk:** Low (Score: 5)
* **KRI:** Count of failed login attempts on the external VPN portal per week.
* **Review Date:** September 2026

---

## RISK-003: ePHI Breach via Physical Device Theft
* **Risk Description:** The physical loss or theft of an unencrypted clinical laptop results in a reportable HIPAA data breach, confirming the gaps identified in 1x00 policies.
* **Risk Category:** Compliance
* **Threat Source:** [From 1x01 Threat Profile T3] Insider Threat / Physical Theft
* **Vulnerability:** [From 1x02 Finding 015] Unencrypted hard drives detected on mobile endpoints processing ePHI
* **Affected Asset(s):** [From 1x00 Asset Registry] Mobile Medical Workstations
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
* **Risk Description:** An automated botnet rapidly spreads across clinical endpoints due to outdated software and legacy AV, a threat heavily emphasized in 1x01.
* **Risk Category:** Operational
* **Threat Source:** [From 1x01 Threat Profile] Automated Botnet
* **Vulnerability:** [From 1x02 Finding 007] Multiple critical CVEs older than 30 days discovered on clinical workstations
* **Affected Asset(s):** [From 1x00 Asset Registry] Clinical Workstation Fleet (280 endpoints)
* **Likelihood:** 5 (Very High - Constant background threat on internet-connected networks)
* **Impact:** 3 (Moderate - Operational disruption requiring IT labor, no data exfiltration)
* **Inherent Risk Score:** 15 (High)
* **ALE:** $250,000
* **Risk Owner:** IT Director (Sarah Park)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Upgrading to automated behavioral blocking (EDR) yields a high return by stopping fileless malware before it spreads.
* **Planned Control(s):** C5 (Sophos Intercept X EDR Upgrade)
* **Residual Risk:** Medium (Score: 6)
* **KRI:** Average dwell time of unpatched critical CVEs on endpoints.
* **Review Date:** November 2026

---

## RISK-005: Patient Safety Incident via Legacy Clinical Software
* **Risk Description:** Compromise of outdated, unpatchable clinical software results in altered patient treatments, a worst-case scenario modeled in 1x01 APT profiles.
* **Risk Category:** Financial / Compliance
* **Threat Source:** [From 1x01 Threat Profile] Advanced Persistent Threat (APT)
* **Vulnerability:** [From 1x02 Finding 022] End-of-life, unsupported medical software found on 15 workstations
* **Affected Asset(s):** [From 1x00 Asset Registry] Legacy Clinical Endpoints
* **Likelihood:** 2 (Low - Highly targeted attacks modifying medical systems are statistically rare)
* **Impact:** 5 (Critical - Direct threat to patient safety and maximum liability)
* **Inherent Risk Score:** 10 (Medium)
* **ALE:** $175,000
* **Risk Owner:** Chief Medical Officer / Department Heads
* **Treatment Decision:** Mitigate (via Containment)
* **Treatment Justification:** While dedicated IoT monitors were rejected for budget reasons, standard network isolation contains the threat at minimal cost.
* **Planned Control(s):** C1 (VLAN Segmentation isolating legacy assets)
* **Residual Risk:** Low (Score: 4)
* **KRI:** Volume of dropped internal traffic attempting to route into the legacy VLAN.
* **Review Date:** December 2026

---

## RISK-006: Negligent Insider Data Mishandling
* **Risk Description:** An employee accidentally exposes sensitive patient data due to the lack of technical guardrails identified during the 1x00 policy review.
* **Risk Category:** Compliance
* **Threat Source:** [From 1x01 Scenarios 1 & 5] Negligent Insider
* **Vulnerability:** [From 1x00 Gap Analysis] Absence of USB restrictions and Data Loss Prevention (DLP) tools
* **Affected Asset(s):** [From 1x00 Asset Registry] Clinical Workstations, ehr-srv-01 data
* **Likelihood:** 5 (Very High - Healthcare sector average is 2-3 incidents annually)
* **Impact:** 3 (Moderate - Localized compliance incident)
* **Inherent Risk Score:** 15 (High)
* **ALE:** $300,000
* **Risk Owner:** HR Director / Deputy CISO
* **Treatment Decision:** Accept (Temporarily)
* **Treatment Justification:** No budget remains in FY26 for enterprise DLP tools; the risk is formally accepted for this budget cycle.
* **Planned Control(s):** None funded (Deferred to FY27)
* **Residual Risk:** High (Score: 15)
* **KRI:** Number of reported accidental data exposure or misrouting incidents per quarter.
* **Review Date:** January 2027

---

## RISK-007: Ransomware Attack on Billing Server
* **Risk Description:** Attackers encrypt the primary billing server, halting revenue processing, utilizing the access vectors documented in 1x02 scans.
* **Risk Category:** Financial
* **Threat Source:** [From 1x01 Threat Profile] Ransomware Syndicate
* **Vulnerability:** [From 1x02 Finding 007] Unpatched services and default configurations on internal servers
* **Affected Asset(s):** [From 1x00 Asset Registry] billing-srv-01
* **Likelihood:** 3 (Medium)
* **Impact:** 4 (High - $16,000/day revenue loss)
* **Inherent Risk Score:** 12 (Medium)
* **ALE:** $156,090
* **Risk Owner:** Chief Financial Officer (Robert Kim)
* **Treatment Decision:** Mitigate
* **Treatment Justification:** Offsite backups are a mathematically justified way to guarantee financial records survive an attack.
* **Planned Control(s):** C4 (AWS Glacier Offsite Backups)
* **Residual Risk:** Low (Score: 3)
* **KRI:** Time required to successfully restore a test billing database from the AWS cloud.
* **Review Date:** October 2026

---

## RISK-008: Delayed Incident Response
* **Risk Description:** A complete lack of 24/7 monitoring allows an attacker to dwell undetected in the network, as proven during the 1x02 breach simulation.
* **Risk Category:** Strategic
* **Threat Source:** [From 1x01 Threat Profile] Any Threat Actor
* **Vulnerability:** [From 1x02 Finding 034] No established SOC or centralized SIEM monitoring utilized during assessment
* **Affected Asset(s):** [From 1x00 Asset Registry] All Enterprise Assets
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
* **Risk Description:** Opportunistic malware exploits default credentials on medical devices discovered in 1x02, causing them to quarantine and disrupting hospital operations.
* **Risk Category:** Operational
* **Threat Source:** [From 1x01 Threat Profile] Opportunistic Attacker / Script Kiddie
* **Vulnerability:** [From 1x02 Finding 010] Default credentials and flat network access to medical devices
* **Affected Asset(s):** [From 1x00 Asset Registry] BD Alaris infusion pumps (7 units)
* **Likelihood:** 3 (Medium)
* **Impact:** 3 (Moderate - Operational disruption switching to manual dosing)
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
* **Risk Description:** An attacker easily breaches the Westside Clinic perimeter due to a lack of enterprise-grade firewall protection documented in the 1x00 Gap Analysis.
* **Risk Category:** Operational
* **Threat Source:** [From 1x01 Threat Profile] Opportunistic Attacker
* **Vulnerability:** [From 1x00 Gap Analysis] Consumer-grade perimeter router in use at the branch
* **Affected Asset(s):** [From 1x00 Asset Registry] Westside Clinic Network
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
