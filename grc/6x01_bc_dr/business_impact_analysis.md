# MedDefense Business Impact Analysis
**Version:** 1.0
**Classification:** Confidential
**Prepared by:** Farid & Ramazan
**Date:** 2026-05-20
**CISO approval:** _________________________ Date: _________

## Executive Summary
This Business Impact Analysis (BIA) evaluates the criticality of ten core IT and clinical systems at MedDefense to prioritize disaster recovery efforts. Our analysis identifies the **Network Core**, **Backup and DR Infrastructure**, **Active Directory**, **Epic EHR**, and the **Laboratory Information System (LIS)** as the highest-risk systems. A failure in these systems immediately halts critical patient care workflows, disrupts medication dispensing, and compromises patient safety by preventing access to real-time clinical data and life-saving diagnostics. Immediate recovery priorities must focus on restoring foundational infrastructure (Network Core and Backup Systems) before recovering identity management (Active Directory) and Tier 1 clinical applications (Epic EHR and LIS) to ensure dependent systems can authenticate and route clinical traffic successfully.

## Methodology
This BIA was conducted by analyzing the clinical, operational, financial, and regulatory impacts of system outages over time. Each system was evaluated based on the consequences of downtime at specific intervals (**1 hour**, **4 hours**, and **24 hours**). Recovery priorities were categorized into four tiers (**Tier 1** through **Tier 4**), defining Maximum Tolerable Downtime (MTD), Recovery Time Objective (RTO), and Recovery Point Objective (RPO) based on strict patient safety, HIPAA, and Joint Commission compliance requirements. All RTOs are strictly architected to be lower than their respective MTDs, and dependent system RTOs are logically sequenced to be equal to or greater than their prerequisite systems. Specific timing choices are directly correlated to clinical workflow limitations and patient harm thresholds.

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
* **Timing Justification**: Backup infrastructure has an MTD of 2 hours strictly because it is on the critical path for Epic EHR recovery. A 30-minute RTO is mandated to ensure that valid backup payloads are staged and available *before* the critical 2-hour RTO window for Active Directory and Epic EHR begins.

### 3. Active Directory
* **Patient Safety Impact**: 
  * **1 hour**: Clinicians cannot log into clinical workstations to view patient charts.
  * **4 hours**: Shift changes fail as incoming nurses cannot authenticate to access patient medication records.
  * **24 hours**: Severe risk of medication errors and missed treatments due to complete reliance on unverified paper records.
* **Regulatory Impact**: HIPAA Security Rule 164.312(a)(1) (Access Control) failure.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core, Backup and DR Infrastructure. Pre-requisite for Epic EHR, LIS, PACS/RIS, and Email.
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 1 hour
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: MTD is set to 2 hours because a nursing shift cannot safely transition without system authentication to verify patient handover notes. The 1-hour RTO provides the mandatory prerequisite identity services required to launch Epic EHR within its designated recovery window.

### 4. Epic EHR
* **Patient Safety Impact**: 
  * **1 hour**: Loss of real-time patient history, allergy warnings, and active orders.
  * **4 hours**: Medication administration delayed; code blues lack recent clinical context.
  * **24 hours**: Critical patient deterioration goes unnoticed; emergency surgeries delayed due to lack of surgical history.
* **Regulatory Impact**: HIPAA 164.308(a)(7) Contingency Plan violation; Joint Commission medical record-keeping citations.
* **Revenue Impact**: $100,000/hour.
* **Operational Dependencies**: Network Core, Backup and DR Infrastructure, Active Directory. Pre-requisite for LIS, Pharmacy, and PACS.
* **Maximum Tolerable Downtime**: 4 hours
* **Recovery Time Objective**: 2 hours
* **Recovery Point Objective**: 15 minutes
* **Priority Tier**: Tier 1
* **Timing Justification**: A 4-hour MTD is the absolute clinical limit before scheduled medication administration (especially antibiotics and critical drips) is severely compromised, directly risking patient lives. The 2-hour RTO provides a 2-hour safety buffer to reconcile data and verify active orders safely before the MTD threshold is breached.

### 5. Laboratory Information System
* **Patient Safety Impact**: 
  * **1 hour**: Delayed stat labs for ICU and Emergency Department.
  * **4 hours**: Inability to process blood bank cross-matches; sepsis treatment protocols critically delayed.
  * **24 hours**: Fatalities possible due to incorrect or missing critical lab values (e.g., troponin, lactate).
* **Regulatory Impact**: CLIA (Clinical Laboratory Improvement Amendments) reporting failures; Joint Commission patient safety goals.
* **Revenue Impact**: $30,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 6 hours
* **Recovery Time Objective**: 3 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1
* **Timing Justification**: MTD is 6 hours because immediate stat labs can be processed via point-of-care testing temporarily, but definitive blood banking and sepsis diagnostics will fail catastrophically after this window. The 3-hour RTO allows Epic EHR (2h RTO) to be online first to receive the resultant lab data.

### 6. Pharmacy Dispensing System
* **Patient Safety Impact**: 
  * **1 hour**: Automated dispensing cabinets require manual overrides.
  * **4 hours**: High risk of adverse drug events and incorrect dosing for newly admitted patients.
  * **24 hours**: Supply chain collapse for critical IV fluids, antibiotics, and life-saving medications.
* **Regulatory Impact**: DEA controlled substance tracking violations; Joint Commission medication management standards.
* **Revenue Impact**: $25,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 6 hours
* **Recovery Time Objective**: 3 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 2
* **Timing Justification**: Automated cabinet overrides are sustainable under strict nursing supervision for a few hours. However, beyond 6 hours (MTD), the risk of adverse drug events and manual dosage errors becomes unacceptably high. The 3-hour RTO ensures dependent alignment with Epic EHR to verify electronic prescriptions.

### 7. PACS/RIS
* **Patient Safety Impact**: 
  * **1 hour**: ER trauma scans delayed from being read by radiologists.
  * **4 hours**: Stroke-protocol imaging inaccessible, delaying life-saving TPA administration.
  * **24 hours**: Orthopedic and neurological surgeries cancelled due to absolute lack of preoperative imaging.
* **Regulatory Impact**: HIPAA 164.312(c)(1) Integrity controls failure; Joint Commission diagnostic standards.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 8 hours
* **Recovery Time Objective**: 4 hours
* **Recovery Point Objective**: 4 hours
* **Priority Tier**: Tier 2
* **Timing Justification**: While stroke/trauma impacts are severe, MTD is justifiable at 8 hours because emergency physicians can utilize portable bedside X-rays and point-of-care ultrasound (POCUS) to stabilize immediate life threats without PACS storage. The 4-hour RTO ensures definitive radiological reads are restored before surgical backlogs become life-threatening.

### 8. Medical Device Integration Gateway
* **Patient Safety Impact**: 
  * **1 hour**: Vitals from ICU bedside monitors do not automatically flow to the EHR.
  * **4 hours**: Nurses stretched thin manually recording vitals, leading to missed patient deterioration indicators.
  * **24 hours**: Exhaustion-induced charting errors and severe clinical blind spots for intensive care patients.
* **Regulatory Impact**: Joint Commission continuous patient monitoring requirements.
* **Revenue Impact**: $10,000/hour.
* **Operational Dependencies**: Network Core, Epic EHR.
* **Maximum Tolerable Downtime**: 12 hours
* **Recovery Time Objective**: 6 hours
* **Recovery Point Objective**: 2 hours
* **Priority Tier**: Tier 2
* **Timing Justification**: MTD is 12 hours because ICU nurses can safely chart vitals manually via paper flowsheets for roughly half a shift. A 6-hour RTO safely restores automated monitoring to the EHR before nursing fatigue and manual transcription errors induce a patient safety crisis.

### 9. Email and Secure Messaging
* **Patient Safety Impact**: 
  * **1 hour**: Minor disruption in non-urgent consult requests.
  * **4 hours**: Difficulty coordinating specialized care teams and transmitting on-call schedules.
  * **24 hours**: Breakdown of administrative clinical coordination and external provider referrals.
* **Regulatory Impact**: HIPAA 164.312(e)(1) Transmission Security failures for external PHI sharing.
* **Revenue Impact**: $5,000/hour.
* **Operational Dependencies**: Network Core, Active Directory.
* **Maximum Tolerable Downtime**: 24 hours
* **Recovery Time Objective**: 12 hours
* **Recovery Point Objective**: 4 hours
* **Priority Tier**: Tier 3
* **Timing Justification**: Urgent clinical consults can fall back to overhead paging and secure cell phones. 24-hour MTD reflects the point where external coordination completely fails. A 12-hour RTO properly prioritizes core clinical systems first while ensuring HIPAA-compliant external communications are restored within a day.

### 10. Security Operations Platform
* **Patient Safety Impact**: 
  * **1 hour**: Undetected lateral movement by potential threat actors.
  * **4 hours**: Potential for active ransomware deployment affecting clinical systems without alerts.
  * **24 hours**: High likelihood of full-scale network compromise resulting in prolonged clinical downtime.
* **Regulatory Impact**: HIPAA 164.308(a)(6)(ii) Security Incident Procedures failure.
* **Revenue Impact**: $5,000/hour (incident response and compliance penalties).
* **Operational Dependencies**: Network Core.
* **Maximum Tolerable Downtime**: 48 hours
* **Recovery Time Objective**: 24 hours
* **Recovery Point Objective**: 12 hours
* **Priority Tier**: Tier 4
* **Timing Justification**: While an undetected threat is a severe risk, clinical care can continue physically without SIEM visibility. MTD is 48 hours because restoring patient-facing applications takes absolute precedence over security logging. The 24-hour RTO ensures visibility is regained before a secondary attack can leverage the post-disaster chaos.

## Dependency Map
Understanding system dependencies is critical to orchestrating a mathematically sound recovery sequence. A failure to sequence RTOs correctly results in systems attempting to recover before their prerequisites are available.

1. **Network Core (RTO: 15m)**: The foundational layer. Required for all subsequent recovery actions.
2. **Backup and DR Infrastructure (RTO: 30m)**: Depends on Network Core. Must be restored immediately to provide backup payloads to core servers.
3. **Active Directory (RTO: 1h)**: Depends on Network Core and Backup Systems. Required for DNS resolution, service accounts, and identity access management.
4. **Epic EHR (RTO: 2h)**: Depends on Network Core, Active Directory, and Backup Systems. Serves as the central hub for clinical data.
5. **Laboratory Information System (LIS) / Pharmacy / PACS/RIS (RTO: 3h-4h)**: Depend heavily on Epic EHR for patient orders and Active Directory for authentication. Their RTOs are correctly structured to allow Epic EHR to fully recover first.
6. **Medical Device Integration Gateway (RTO: 6h)**: Depends on Epic EHR to write patient vitals to the database.
7. **Email / Security Operations (RTO: 12h-24h)**: Depend on the Network Core for visibility and routing.

## RTO / RPO / MTD Summary Table

| System | Priority Tier | RPO | RTO | MTD |
| :--- | :--- | :--- | :--- | :--- |
| Network Core | Tier 1 | 15 minutes | 15 minutes | 1 hour |
| Backup and DR Infrastructure | Tier 1 | 1 hour | 30 minutes | 2 hours |
| Active Directory | Tier 1 | 1 hour | 1 hour | 2 hours |
| Epic EHR | Tier 1 | 15 minutes | 2 hours | 4 hours |
| Laboratory Information System | Tier 1 | 1 hour | 3 hours | 6 hours |
| Pharmacy Dispensing System | Tier 2 | 1 hour | 3 hours | 6 hours |
| PACS/RIS | Tier 2 | 4 hours | 4 hours | 8 hours |
| Medical Device Integration Gateway | Tier 2 | 2 hours | 6 hours | 12 hours |
| Email and Secure Messaging | Tier 3 | 4 hours | 12 hours | 24 hours |
| Security Operations Platform | Tier 4 | 12 hours | 24 hours | 48 hours |

## Assumptions and Limitations
- **Assumptions:** It is assumed that downtime boxes containing paper forms (nursing station locations) are fully stocked and clinicians are trained to utilize them during the stated RTO windows. Cloud backups and offsite infrastructure are assumed to be accessible independently of the primary data center. RTO times account for logical dependencies, ensuring prerequisite services are online first.
- **Limitations:** Revenue impact metrics are calculated as broad estimations based on average historical billing. This BIA focuses primarily on cyber and IT operational disaster recovery and does not account for total physical facility destruction requiring complete patient evacuation.
