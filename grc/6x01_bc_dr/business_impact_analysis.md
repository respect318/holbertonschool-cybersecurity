# MedDefense Business Impact Analysis
**Version:** 1.0
**Classification:** Confidential
**Prepared by:** Farid & Ramazan
**Date:** 2026-05-20
**CISO approval:** _________________________ Date: _________

## Executive Summary
This Business Impact Analysis (BIA) evaluates the criticality of ten core IT and clinical systems at MedDefense to prioritize disaster recovery efforts. Our analysis identifies the **Network Core**, **Backup and DR Infrastructure**, **Active Directory**, **PACS/RIS**, **Epic EHR**, and the **Laboratory Information System (LIS)** as the highest-risk systems. A failure in these systems immediately halts critical patient care workflows, disrupts medication dispensing, and compromises patient safety by preventing access to real-time clinical data and life-saving diagnostics. Immediate recovery priorities must focus on restoring foundational infrastructure (Network Core and Backup Systems) before recovering identity management (Active Directory) and Tier 1 clinical applications (PACS/RIS, Epic EHR, and LIS) to ensure dependent systems can authenticate and route clinical traffic successfully without mathematical recovery impossibilities.

## Methodology
This BIA was conducted by analyzing the clinical, operational, financial, and regulatory impacts of system outages over time. Each system was evaluated based on the consequences of downtime at specific intervals (**1 hour**, **4 hours**, and **24 hours**). Recovery priorities were categorized into four tiers (**Tier 1** through **Tier 4**), defining Maximum Tolerable Downtime (MTD), Recovery Time Objective (RTO), and Recovery Point Objective (RPO) based on strict patient safety, HIPAA, and Joint Commission compliance requirements. All RTOs are strictly architected to be lower than their respective MTDs, and dependent system RTOs are logically sequenced to be equal to or greater than their prerequisite systems. Specific timing choices are directly correlated to clinical workflow limitations, ransomware vulnerability risks, and acute patient harm thresholds.

## System Impact Assessment

### 1. Network Core
* **Patient Safety Impact**: 
  * **1 hour**: Delays in transmitting patient vitals from bedside monitors.
  * **4 hours**: Inability to communicate critical code alerts and imaging results across departments.
  * **24 hours**: Complete breakdown of coordinated clinical care, emergency response, and patient triage protocols.
* **Regulatory Impact**: Joint Commission Environment of Care standards violation due to loss of critical emergency communications.
* **Revenue Impact**: $50,000/hour.
* **Operational Dependencies**: Foundational dependency for all MedDefense systems. None preceding.
* **Maximum Tolerable Downtime**: 1 hour
* **Recovery Time Objective**: 15 minutes
* **Recovery Point Objective**: 15 minutes
* **Priority Tier**: Tier 1
* **Timing Justification**: An MTD of 1 hour is the absolute maximum clinical operations can function without automated vitals and code blue network routing. An aggressive RTO of 15 minutes is required to prevent immediate clinical blind spots and to establish the prerequisite routing needed for all subsequent DR operations.

### 2. Backup and DR Infrastructure
* **Patient Safety Impact**: 
  * **1 hour**: No direct patient impact, but extreme risk if primary clinical data is corrupted.
  * **4 hours**: Inability to initiate restores for Tier 1 clinical applications, delaying life-saving EHR availability.
  * **24 hours**: Permanent loss of patient histories if secondary disaster destroys local arrays.
* **Regulatory Impact**: HIPAA 164.308(a)(7)(ii)(A) Data Backup Plan violation.
* **Revenue Impact**: $0/hour (indirect risk exposure).
* **Operational Dependencies**: Network Core. Pre-requisite for restoring Active Directory and Epic EHR.
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 30 minutes
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: Backup infrastructure has an MTD of 2 hours strictly because it is on the critical path for Tier 1 recovery. A 30-minute RTO is mandated to ensure that valid backup payloads are staged and available *before* the critical 1-hour and 2-hour RTO windows for AD and Epic EHR begin.

### 3. Active Directory
* **Patient Safety Impact**: 
  * **1 hour**: Clinicians cannot log into clinical workstations to view patient charts.
  * **4 hours**: Shift changes fail as incoming nurses cannot authenticate to access patient medication records.
  * **24 hours**: Severe risk of medication errors and missed treatments due to complete reliance on unverified paper records.
* **Regulatory Impact**: HIPAA Security Rule 164.312(a)(1) (Access Control) failure.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core, Backup and DR Infrastructure. Pre-requisite for Epic EHR, LIS, PACS/RIS, and Security Operations.
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 1 hour
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: MTD is set to 2 hours because a nursing shift cannot safely transition without system authentication. The 1-hour RTO provides the mandatory prerequisite identity services required to launch PACS/RIS and Epic EHR within their designated recovery windows.

### 4. PACS/RIS
* **Patient Safety Impact**: 
  * **1 hour**: ER trauma scans delayed from being read by radiologists.
  * **4 hours**: Stroke-protocol imaging inaccessible, delaying life-saving TPA administration, causing irreversible brain damage.
  * **24 hours**: Orthopedic and neurological surgeries cancelled entirely.
* **Regulatory Impact**: HIPAA 164.312(c)(1) Integrity controls failure; Joint Commission diagnostic standards.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core, Active Directory. (Configured for standalone emergency viewing independently of Epic EHR).
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 1 hour
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: Stroke and severe trauma protocols strictly dictate that CT/MRI images must be evaluated within minutes, not hours. The MTD is reduced to 2 hours because any longer poses a direct threat to life. A 1-hour RTO ensures that emergency standalone radiology viewing is restored concurrently with Active Directory.

### 5. Epic EHR
* **Patient Safety Impact**: 
  * **1 hour**: Loss of real-time patient history, allergy warnings, and active orders.
  * **4 hours**: Medication administration delayed; code blues lack recent clinical context.
  * **24 hours**: Critical patient deterioration goes unnoticed; emergency surgeries delayed.
* **Regulatory Impact**: HIPAA 164.308(a)(7) Contingency Plan violation; Joint Commission medical record citations.
* **Revenue Impact**: $100,000/hour.
* **Operational Dependencies**: Network Core, Backup and DR Infrastructure, Active Directory. Pre-requisite for LIS, Pharmacy, and Device Gateway.
* **Maximum Tolerable Downtime**: 4 hours
* **Recovery Time Objective**: 2 hours
* **Recovery Point Objective**: 15 minutes
* **Priority Tier**: Tier 1
* **Timing Justification**: A 4-hour MTD is the absolute clinical limit before scheduled medication administration is severely compromised. The 2-hour RTO provides a safety buffer to reconcile data and verify active orders safely before the MTD threshold is breached.

### 6. Laboratory Information System
* **Patient Safety Impact**: 
  * **1 hour**: Delayed stat labs for ICU and Emergency Department.
  * **4 hours**: Inability to process blood bank cross-matches; sepsis treatment protocols critically delayed.
  * **24 hours**: Fatalities possible due to incorrect or missing critical lab values.
* **Regulatory Impact**: CLIA reporting failures; Joint Commission patient safety goals.
* **Revenue Impact**: $30,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 6 hours
* **Recovery Time Objective**: 3 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: MTD is 6 hours because immediate stat labs can be processed via point-of-care testing temporarily, but definitive blood banking will fail catastrophically after this window. The 3-hour RTO aligns mathematically to allow Epic EHR (2h RTO) to be online first to receive the resultant lab data.

### 7. Pharmacy Dispensing System
* **Patient Safety Impact**: 
  * **1 hour**: Automated dispensing cabinets require manual overrides.
  * **4 hours**: High risk of adverse drug events and incorrect dosing.
  * **24 hours**: Supply chain collapse for critical IV fluids and antibiotics.
* **Regulatory Impact**: DEA controlled substance tracking violations.
* **Revenue Impact**: $25,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 6 hours
* **Recovery Time Objective**: 3 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 2
* **Timing Justification**: Cabinet overrides are sustainable under strict supervision for a few hours. Beyond 6 hours (MTD), the risk of manual dosage errors becomes unacceptable. The 3-hour RTO ensures dependent alignment with Epic EHR to verify electronic prescriptions.

### 8. Security Operations Platform
* **Patient Safety Impact**: 
  * **1 hour**: Undetected lateral movement by threat actors during the recovery process.
  * **4 hours**: High risk of a secondary ransomware payload detonating in the clinical environment.
  * **24 hours**: Total network compromise leading to prolonged life-threatening downtime.
* **Regulatory Impact**: HIPAA 164.308(a)(6)(ii) Security Incident Procedures failure.
* **Revenue Impact**: $5,000/hour.
* **Operational Dependencies**: Network Core, Active Directory.
* **Maximum Tolerable Downtime**: 8 hours
* **Recovery Time Objective**: 4 hours
* **Recovery Point Objective**: 4 hours
* **Priority Tier**: Tier 2
* **Timing Justification**: Given the extreme prevalence of ransomware targeting healthcare during vulnerable operational states, operating without security visibility is highly dangerous. MTD is tightened to 8 hours to prevent unchecked lateral movement. The 4-hour RTO ensures that SIEM/EDR visibility is restored concurrently with major clinical applications to protect the newly recovered environment.

### 9. Medical Device Integration Gateway
* **Patient Safety Impact**: 
  * **1 hour**: Vitals do not automatically flow to the EHR.
  * **4 hours**: Nurses stretched thin manually recording vitals.
  * **24 hours**: Exhaustion-induced charting errors for intensive care patients.
* **Regulatory Impact**: Joint Commission continuous patient monitoring requirements.
* **Revenue Impact**: $10,000/hour.
* **Operational Dependencies**: Network Core, Epic EHR.
* **Maximum Tolerable Downtime**: 12 hours
* **Recovery Time Objective**: 6 hours
* **Recovery Point Objective**: 2 hours
* **Priority Tier**: Tier 2
* **Timing Justification**: MTD is 12 hours because ICU nurses can safely chart vitals manually via paper flowsheets for roughly half a shift. A 6-hour RTO safely restores automated monitoring to the EHR (dependent on Epic's prior recovery) before nursing fatigue induces clinical errors.

### 10. Email and Secure Messaging
* **Patient Safety Impact**: 
  * **1 hour**: Minor disruption in non-urgent consult requests.
  * **4 hours**: Difficulty coordinating specialized care teams.
  * **24 hours**: Breakdown of external provider referrals.
* **Regulatory Impact**: HIPAA 164.312(e)(1) Transmission Security failures.
* **Revenue Impact**: $5,000/hour.
* **Operational Dependencies**: Network Core, Active Directory.
* **Maximum Tolerable Downtime**: 24 hours
* **Recovery Time Objective**: 12 hours
* **Recovery Point Objective**: 4 hours
* **Priority Tier**: Tier 3
* **Timing Justification**: Urgent clinical consults can fall back to secure cell phones. 24-hour MTD reflects the point where external coordination fails. A 12-hour RTO prioritizes Tier 1/2 clinical and security systems first while ensuring external communications are restored within a day.

## Dependency Map
Understanding system dependencies is critical to orchestrating a mathematically sound recovery sequence.

1. **Network Core (RTO: 15m)**: The foundational layer. Required for all subsequent recovery actions.
2. **Backup and DR Infrastructure (RTO: 30m)**: Depends on Network Core. Must be restored immediately.
3. **Active Directory (RTO: 1h)**: Depends on Network Core and Backup Systems. Required for authentication.
4. **PACS/RIS (RTO: 1h)**: Depends on Network Core and AD. Restored concurrently with AD for standalone emergency stroke/trauma viewing without waiting for Epic.
5. **Epic EHR (RTO: 2h)**: Depends on Network Core, AD, and Backup Systems.
6. **Laboratory Info System / Pharmacy (RTO: 3h)**: Depend on Epic EHR for patient orders and AD for authentication.
7. **Security Operations Platform (RTO: 4h)**: Depends on Network Core and AD. Must be online quickly to secure the recovering environment.
8. **Medical Device Integration Gateway (RTO: 6h)**: Depends on Epic EHR to write patient vitals.
9. **Email and Secure Messaging (RTO: 12h)**: Depends on Network Core and AD.

## RTO / RPO / MTD Summary Table

| System | Priority Tier | RPO | RTO | MTD |
| :--- | :--- | :--- | :--- | :--- |
| Network Core | Tier 1 | 15 minutes | 15 minutes | 1 hour |
| Backup and DR Infrastructure | Tier 1 | 1 hour | 30 minutes | 2 hours |
| Active Directory | Tier 1 | 1 hour | 1 hour | 2 hours |
| PACS/RIS | Tier 1 | 1 hour | 1 hour | 2 hours |
| Epic EHR | Tier 1 | 15 minutes | 2 hours | 4 hours |
| Laboratory Information System | Tier 1 | 1 hour | 3 hours | 6 hours |
| Pharmacy Dispensing System | Tier 2 | 1 hour | 3 hours | 6 hours |
| Security Operations Platform | Tier 2 | 4 hours | 4 hours | 8 hours |
| Medical Device Integration Gateway | Tier 2 | 2 hours | 6 hours | 12 hours |
| Email and Secure Messaging | Tier 3 | 4 hours | 12 hours | 24 hours |

## Assumptions and Limitations
- **Assumptions:** It is assumed that downtime boxes containing paper forms (nursing station locations) are fully stocked and clinicians are trained to utilize them during the stated RTO windows. Cloud backups and offsite infrastructure are assumed to be accessible independently of the primary data center. RTO times strictly account for logical dependencies, ensuring prerequisite services are online first.
- **Limitations:** Revenue impact metrics are calculated as broad estimations. This BIA focuses primarily on cyber and IT operational disaster recovery and does not account for total physical facility destruction requiring complete patient evacuation.
