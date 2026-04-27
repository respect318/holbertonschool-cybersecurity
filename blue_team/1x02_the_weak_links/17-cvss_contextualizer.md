# 17-cvss_contextualizer.md

## 1. Finding 001 - Apache mod_lua Buffer Overflow (CVE-2021-44790)
**CVSS Base Score:** 9.8

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** billing-srv-01
* **CIA Rating:** C: High, I: High, A: Medium
* **Criticality Impact on Priority:** Raises urgency (Core financial system).

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Ransomware Deployment, Data Exfiltration
* **Chain Role:** Initial Access Point
* **Kill Chain Impact on Priority:** Raises urgency (Stops the attack at the perimeter).

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5
* **CISA KEV:** Yes
* **Exploit Impact on Priority:** Raises urgency (Weaponized and actively exploited).

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None (Flat network).
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** Confidentiality Requirement (CR): High, Integrity Requirement (IR): High.
* **Adjusted Score:** 9.8

**Final Priority:** Critical
**Final Justification:** This vulnerability provides an unauthenticated attacker with immediate root-level access to the core financial database. Given the lack of network segmentation, active exploitation status in CISA KEV, and its position as the initial entry point, fixing this represents the highest possible priority for the organization.

---

## 2. Finding 031 - Tomcat AJP Ghostcat (CVE-2020-1938)
**CVSS Base Score:** 9.8

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** ehr-srv-01
* **CIA Rating:** C: Critical, I: Critical, A: Critical
* **Criticality Impact on Priority:** Raises urgency (Crown jewel asset).

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Data Exfiltration (HIPAA Breach)
* **Chain Role:** Exploitation / Action on Objectives
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5
* **CISA KEV:** Yes
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None.
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** CR: High, IR: High, AR: High.
* **Adjusted Score:** 9.8

**Final Priority:** Critical
**Final Justification:** The EHR server houses the most sensitive patient data. Ghostcat allows trivial, unauthenticated file reads (including database credentials). Combined with its High/Critical CIA requirement and 5/5 exploitability score, this represents a catastrophic and immediate threat to patient data confidentiality.

---

## 3. Finding 004 - Windows XP SMB / EternalBlue (CVE-2017-0144)
**CVSS Base Score:** 8.1

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** WS-RAD-01 (MRI Workstation)
* **CIA Rating:** C: High, I: High, A: Critical
* **Criticality Impact on Priority:** Raises urgency (Direct patient care/life safety).

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Ransomware Deployment
* **Chain Role:** Lateral Movement / Infection Vector
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5
* **CISA KEV:** Yes
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** Network segmentation was proposed but failed (host is on flat network).
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** Safety/Availability Requirement (AR): High. 
* **Adjusted Score:** 8.1 (Qualitatively treated as 10.0 due to life safety).

**Final Priority:** Critical
**Final Justification:** While the base score is 8.1 (High), the environmental context pushes this to a qualitative Critical. Compromise of an MRI control station via a self-propagating ransomware worm directly halts life-saving radiological services, shifting the impact from digital data loss to physical patient harm.

---

## 4. Finding 010 - BD Alaris Pump Firmware (CVE-2020-25165)
**CVSS Base Score:** 7.5

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** BD Alaris Infusion Pumps (Medical IoT)
* **CIA Rating:** C: Low, I: High, A: Critical
* **Criticality Impact on Priority:** Raises urgency (Direct kinetic impact on human life).

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Cyber-Physical Attack
* **Chain Role:** Final Target (Action on Objectives)
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 3
* **CISA KEV:** No
* **Exploit Impact on Priority:** Lowers urgency slightly (No active mass-exploitation).

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None (Flat network).
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** AR: High, IR: High.
* **Adjusted Score:** 7.5 (Qualitatively Critical).

**Final Priority:** Critical
**Final Justification:** The CVSS 7.5 rating completely fails to capture the risk of an unauthenticated attacker altering intravenous medication dosing. Because the flat network exposes these pumps to the entire hospital, the severity overrides the base score, demanding immediate isolation or patching.

---

## 5. Finding 008 - PrintNightmare (CVE-2021-34527)
**CVSS Base Score:** 8.8

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** print-srv-01
* **CIA Rating:** C: Low, I: Low, A: Medium
* **Criticality Impact on Priority:** Lowers urgency (Print server has low value data).

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Domain Compromise
* **Chain Role:** Privilege Escalation / Pivot Point
* **Kill Chain Impact on Priority:** Raises urgency (Gateway to Domain Admin).

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5
* **CISA KEV:** Yes
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None.
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** CR: High, IR: High, AR: High (Adjusted for the entire Domain, not just the print server).
* **Adjusted Score:** 9.3

**Final Priority:** Critical
**Final Justification:** A standard print server has low asset criticality, but PrintNightmare turns it into a devastating pivot point. It allows any standard user to gain SYSTEM access and dump credentials, leveraging the server's domain connections to take over the Active Directory. Thus, the environmental score rises above the base score.

---

## 6. Finding 003 - PostgreSQL Unrestricted Access (Misconfiguration)
**CVSS Base Score:** Theoretical 9.8 (AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H)

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** ehr-db-01
* **CIA Rating:** C: Critical, I: Critical, A: Critical
* **Criticality Impact on Priority:** Raises urgency.

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Data Exfiltration
* **Chain Role:** Action on Objectives
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5 (Trivial connection).
* **CISA KEV:** N/A
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None.
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** CR: High, IR: High, AR: High.
* **Adjusted Score:** 9.8

**Final Priority:** Critical
**Final Justification:** Even without a CVE, an unrestricted database on a flat network containing millions of PHI records is structurally equivalent to a Critical RCE. Any compromised node on the network can directly query and dump the database, bypassing all application-layer security.

---

## 7. Finding 002 - Apache Local PrivEsc (CVE-2019-0211)
**CVSS Base Score:** 7.8

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** billing-srv-01
* **CIA Rating:** C: High, I: High, A: Medium
* **Criticality Impact on Priority:** Raises urgency.

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Ransomware Deployment
* **Chain Role:** Privilege Escalation
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 5
* **CISA KEV:** No
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None.
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** CR: High, IR: High.
* **Adjusted Score:** 7.8

**Final Priority:** High
**Final Justification:** This vulnerability is weaponized and dangerous, but it explicitly requires an attacker to already possess a low-level foothold (e.g., via Finding 001) to execute. Therefore, the priority remains High rather than Critical, as mitigating the remote vectors first inherently neutralizes this local threat.

---

## 8. Finding 029 - Grafana Path Traversal (CVE-2021-43798)
**CVSS Base Score:** 7.5

**Factor 1 - Asset Criticality (from 1x00):**
* **Asset:** Shadow IT Linux Host
* **CIA Rating:** C: Low, I: Low, A: Low
* **Criticality Impact on Priority:** Lowers urgency.

**Factor 2 - Kill Chain Position (from 1x01):**
* **Appears in Kill Chain(s):** Unknown / Shadow Operations
* **Chain Role:** Initial Access
* **Kill Chain Impact on Priority:** Raises urgency.

**Factor 3 - Exploitability (from T4):**
* **Exploitability Score:** 4
* **CISA KEV:** Yes
* **Exploit Impact on Priority:** Raises urgency.

**Factor 4 - Compensating Controls (from 1x00):**
* **Existing Controls:** None.
* **Control Impact on Priority:** Raises urgency.

**Environmental CVSS (recalculated):**
* **Environmental Metrics Applied:** CR: Low, IR: Low, AR: Low (Due to the host being a non-production Shadow IT asset).
* **Adjusted Score:** 5.5

**Final Priority:** Medium
**Final Justification:** The base vulnerability is High severity, but it resides on an undocumented, non-critical Shadow IT asset. The environmental risk drops significantly because the data on the server is low-value. The primary remediation is not patching Grafana, but permanently decommissioning the unauthorized server entirely.

---

## Priority Comparison Table

| Finding | Vulnerability | CVSS Base | Adjusted Priority | Change Direction |
| :--- | :--- | :--- | :--- | :--- |
| **001** | Apache mod_lua RCE | 9.8 (Critical) | **Critical** | Same |
| **031** | Tomcat Ghostcat | 9.8 (Critical) | **Critical** | Same |
| **004** | Windows XP / EternalBlue | 8.1 (High) | **Critical** | **Higher** (Life safety overrules base CVSS) |
| **010** | BD Alaris IoT Firmware | 7.5 (High) | **Critical** | **Higher** (Physical patient harm risk) |
| **008** | PrintNightmare | 8.8 (High) | **Critical** | **Higher** (Domain pivot impact) |
| **003** | PostgreSQL Misconfig | 9.8 (Critical)* | **Critical** | Same |
| **002** | Apache Local PrivEsc | 7.8 (High) | **High** | Same |
| **029** | Grafana Path Traversal | 7.5 (High) | **Medium** | **Lower** (Low asset criticality / Shadow IT) |

**Note on significant changes:** As highlighted in the table, Findings 004 and 010 jumped from High to **Critical** because CVSS struggles to measure physical danger and patient life safety. Finding 008 became **Critical** because of its potential to compromise the entire domain, not just the print server. Conversely, Finding 029 dropped to **Medium** because despite the CVE's severity, it affects a worthless Shadow IT asset.
