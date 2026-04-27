# 1. The NIST CSF Mapping

## MedDefense Current Profile Assessment

### Function: GOVERN (GV)
* **Current Level:** Partial
* **Evidence:** While MedDefense has a Deputy CISO and a Security Analyst, there is no documented cybersecurity strategy or formal framework currently in place (as noted in Project 1x03 context). Roles are informally understood but lack a centralized policy (AUP or Risk Strategy) to guide decision-making.
* **Key Gaps:** Lack of a formal cybersecurity policy and risk management strategy approved by the Board.
* **Target Level:** Managed
* **Justification:** Within 6 months, MedDefense must document its risk appetite and establish basic policies to ensure the small security team has the authority and direction needed to implement controls.

---

### Function: IDENTIFY (ID)
* **Current Level:** Partial
* **Evidence:** Prior to Project 1x00, MedDefense had no comprehensive asset inventory (Marcus's notes). While an inventory was created during 1x00, the process is not yet repeatable or automated, and data flows are not fully mapped.
* **Key Gaps:** Absence of a continuous, automated asset management process and formal risk assessment (likelihood vs. impact).
* **Target Level:** Managed
* **Justification:** As a hospital, knowing exactly what devices are on the network is critical for patient safety. The inventory must be documented and updated monthly to maintain a "Managed" state.

---

### Function: PROTECT (PR)
* **Current Level:** Partial
* **Evidence:** The vulnerability scan in Project 1x02 revealed several critical vulnerabilities and unpatched systems, indicating that protective safeguards (like patch management and secure configurations) are inconsistent. MFA and network segmentation are not yet fully matured across all clinical systems.
* **Key Gaps:** Inconsistent patch management and lack of hardened baseline configurations for medical workstations.
* **Target Level:** Managed
* **Justification:** MedDefense must reach a "Managed" state by implementing a repeatable patching cycle and deploying MFA for all remote and administrative access to prevent common attack vectors.

---

### Function: DETECT (DE)
* **Current Level:** Not Implemented
* **Evidence:** Marcus's notes explicitly stated that MedDefense has "zero monitoring capability." There is currently no SIEM, centralized logging, or 24/7 alerting mechanism to identify adverse events as they happen.
* **Key Gaps:** Total lack of visibility into network anomalies or unauthorized system access.
* **Target Level:** Partial
* **Justification:** Moving from "Not Implemented" to "Managed" in 6 months is unrealistic for a 2-person team. The goal is "Partial": implementing centralized logging for critical servers so the analyst can manually review alerts.

---

### Function: RESPOND (RS)
* **Current Level:** Not Implemented
* **Evidence:** Because there is no detection capability (Project 1x02/1x03), there is no formal mechanism to triage or escalate incidents. No evidence of a tested Incident Response Plan (IRP) exists in the organization's current documentation.
* **Key Gaps:** No formal Incident Response Plan (IRP) or defined communication channels for breach notification.
* **Target Level:** Managed
* **Justification:** To meet regulatory requirements, MedDefense must have a documented and repeatable plan for acting on incidents, even if the detection remains manual.

---

### Function: RECOVER (RC)
* **Current Level:** Partial
* **Evidence:** Like most medical facilities, MedDefense likely has a backup system (Project 1x01 context), but there is no evidence that these backups are isolated from the production network or regularly tested for full-scale restoration (RTO/RPO).
* **Key Gaps:** Lack of tested recovery procedures and isolation between production data and backup repositories.
* **Target Level:** Managed
* **Justification:** To defend against ransomware, MedDefense must ensure backups are isolated and that a recovery plan is documented and tested at least once every 6 months.
