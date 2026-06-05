# MedDefense Business Impact Analysis
**Version:** 1.0
**Classification:** Confidential
**Prepared by:** Farid & Ramazan
**Date:** 2026-05-20
**CISO approval:** _________________________ Date: _________

## Executive Summary
This Business Impact Analysis (BIA) evaluates the criticality of ten core IT and clinical systems at MedDefense to prioritize disaster recovery efforts. Our analysis identifies the **Network Core**, **Active Directory**, **Epic EHR**, and the **Laboratory Information System (LIS)** as the highest-risk systems. A failure in these systems immediately halts critical patient care workflows, disrupts medication dispensing, and compromises patient safety by preventing access to real-time clinical data and life-saving diagnostics. Immediate recovery priorities must focus on restoring foundational infrastructure (Network Core and Active Directory) before recovering Tier 1 clinical applications (Epic EHR and LIS) to ensure dependent systems can authenticate and route clinical traffic successfully.

## Methodology
This BIA was conducted by analyzing the clinical, operational, financial, and regulatory impacts of system outages over time. Each system was evaluated based on the consequences of downtime at specific intervals (**1 hour**, **4 hours**, and **24 hours**). Recovery priorities were categorized into four tiers (**Tier 1** through **Tier 4**), defining Maximum Tolerable Downtime (MTD), Recovery Time Objective (RTO), and Recovery Point Objective (RPO) based on strict patient safety, HIPAA, and Joint Commission compliance requirements.

## System Impact Assessment

### 1. Network Core
* **Patient Safety Impact**: 
  * **1 hour**: Delays in transmitting patient vitals from bedside monitors.
  * **4 hours**: Inability to communicate critical code alerts and imaging results across departments.
  * **24 hours**: Complete breakdown of coordinated clinical care, emergency response, and patient triage protocols.
* **Regulatory Impact**: Joint Commission Environment of Care standards violation due to loss of critical emergency communications.
* **Revenue Impact**: $50,000/hour.
* **Operational Dependencies**: Foundational dependency for all MedDefense systems.
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 1 hour
* **Recovery Point Objective**: 15 minutes
* **Priority Tier**: Tier 1

### 2. Active Directory
* **Patient Safety Impact**: 
  * **1 hour**: Clinicians cannot log into clinical workstations to view patient charts.
  * **4 hours**: Shift changes fail as incoming nurses cannot authenticate to access patient medication records.
  * **24 hours**: Severe risk of medication errors and missed treatments due to complete reliance on unverified paper records.
* **Regulatory Impact**: HIPAA Security Rule 164.312(a)(1) (Access Control) failure.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core. Pre-requisite for Epic EHR, LIS, PACS/RIS, and Email.
* **Maximum Tolerable Downtime**: 2 hours
* **Recovery Time Objective**: 1 hour
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1

### 3. Epic EHR
* **Patient Safety Impact**: 
  * **1 hour**: Loss of real-time patient history, allergy warnings, and active orders.
  * **4 hours**: Medication administration delayed; code blues lack recent clinical context.
  * **24 hours**: Critical patient deterioration goes unnoticed; emergency surgeries delayed due to lack of surgical history.
* **Regulatory Impact**: HIPAA 164.308(a)(7) Contingency Plan violation; Joint Commission medical record-keeping citations.
* **Revenue Impact**: $100,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Backup and DR Infrastructure.
* **Maximum Tolerable Downtime**: 6 hours
* **Recovery Time Objective**: 4 hours
* **Recovery Point Objective**: 15 minutes
* **Priority Tier**: Tier 1

### 4. Laboratory Information System
* **Patient Safety Impact**: 
  * **1 hour**: Delayed stat labs for ICU and Emergency Department.
  * **4 hours**: Inability to process blood bank cross-matches; sepsis treatment protocols critically delayed.
  * **24 hours**: Fatalities possible due to incorrect or missing critical lab values (e.g., troponin, lactate).
* **Regulatory Impact**: CLIA (Clinical Laboratory Improvement Amendments) reporting failures; Joint Commission patient safety goals.
* **Revenue Impact**: $30,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 4 hours
* **Recovery Time Objective**: 2 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 1

### 5. Pharmacy Dispensing System
* **Patient Safety Impact**: 
  * **1 hour**: Automated dispensing cabinets require manual overrides.
  * **4 hours**: High risk of adverse drug events and incorrect dosing for newly admitted patients.
  * **24 hours**: Supply chain collapse for critical IV fluids, antibiotics, and life-saving medications.
* **Regulatory Impact**: DEA controlled substance tracking violations; Joint Commission medication management standards.
* **Revenue Impact**: $25,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 8 hours
* **Recovery Time Objective**: 4 hours
* **Recovery Point Objective**: 1 hour
* **Priority Tier**: Tier 2

### 6. PACS/RIS
* **Patient Safety Impact**: 
  * **1 hour**: ER trauma scans delayed from being read by radiologists.
  * **4 hours**: Stroke-protocol imaging inaccessible, delaying life-saving TPA administration.
  * **24 hours**: Orthopedic and neurological surgeries cancelled due to absolute lack of preoperative imaging.
* **Regulatory Impact**: HIPAA 164.312(c)(1) Integrity controls failure; Joint Commission diagnostic standards.
* **Revenue Impact**: $40,000/hour.
* **Operational Dependencies**: Network Core, Active Directory, Epic EHR.
* **Maximum Tolerable Downtime**: 8 hours
* **Recovery Time Objective**: 6 hours
* **Recovery Point Objective**: 4 hours
* **Priority Tier**: Tier 2

### 7. Medical Device Integration Gateway
* **Patient Safety Impact**: 
  * **1 hour**: Vitals from ICU bedside monitors do not automatically flow to the EHR.
  * **4 hours**: Nurses stretched thin manually recording vitals, leading to missed patient deterioration indicators.
  * **24 hours**: Exhaustion-induced charting errors and severe clinical blind spots for intensive care patients.
* **Regulatory Impact**: Joint Commission continuous patient monitoring requirements.
* **Revenue Impact**: $10,000/hour.
* **Operational Dependencies**: Network Core, Epic EHR.
* **Maximum Tolerable Downtime**: 12 hours
* **Recovery Time Objective**: 8 hours
* **Recovery Point Objective**: 2 hours
* **Priority Tier**: Tier 2

### 8. Email and Secure Messaging
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

### 9. Backup and DR Infrastructure
* **Patient Safety Impact**: 
  * **1 hour**: No direct patient impact.
  * **4 hours**: Increased risk posture if primary systems experience simultaneous failure.
  * **24 hours**: Inability to recover lost patient data if a secondary disaster occurs, causing long-term clinical data loss.
* **Regulatory Impact**: HIPAA 164.308(a)(7)(ii)(A) Data Backup Plan violation.
* **Revenue Impact**: $0/hour (indirect risk exposure).
* **Operational Dependencies**: Network Core.
* **Maximum Tolerable Downtime**: 24 hours
* **Recovery Time Objective**: 12 hours
* **Recovery Point Objective**: 24 hours
* **Priority Tier**: Tier 3

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

## Dependency Map
Understanding system dependencies is critical to orchestrating a realistic recovery sequence. A failure in foundational layers creates a cascade that prevents higher-level clinical applications from functioning.

1. **Network Core**: The base foundational layer. If the network is down, all other systems are effectively offline and unreachable.
2. **Active Directory**: Depends heavily on the Network Core. Required for DNS resolution, service accounts, and identity access management. Without AD, clinicians cannot authenticate to Epic EHR or the LIS, and the Email systems cannot route messages.
3. **Epic EHR**: Depends on the Network Core and Active Directory. Serves as the central hub for clinical data.
4. **Laboratory Information System (LIS) / PACS/RIS / Pharmacy Dispensing System**: Depend heavily on Epic EHR for patient orders and Active Directory for user authentication. Without Epic EHR, the LIS cannot receive lab orders, and Pharmacy cannot verify electronic prescriptions.
5. **Medical Device Integration Gateway**: Depends on the Network Core to capture vitals and Epic EHR to write them to the patient record.
6. **Backup and DR Infrastructure / Security Operations Platform**: Depend on the Network Core for visibility and Active Directory for administrative access.

## RTO / RPO / MTD Summary Table

| System | Priority Tier | RPO | RTO | MTD |
| :--- | :--- | :--- | :--- | :--- |
| Network Core | Tier 1 | 15 minutes | 1 hour | 2 hours |
| Active Directory | Tier 1 | 1 hour | 1 hour | 2 hours |
| Epic EHR | Tier 1 | 15 minutes | 4 hours | 6 hours |
| Laboratory Information System | Tier 1 | 1 hour | 2 hours | 4 hours |
| Pharmacy Dispensing System | Tier 2 | 1 hour | 4 hours | 8 hours |
| PACS/RIS | Tier 2 | 4 hours | 6 hours | 8 hours |
| Medical Device Integration Gateway | Tier 2 | 2 hours | 8 hours | 12 hours |
| Email and Secure Messaging | Tier 3 | 4 hours | 12 hours | 24 hours |
| Backup and DR Infrastructure | Tier 3 | 24 hours | 12 hours | 24 hours |
| Security Operations Platform | Tier 4 | 12 hours | 24 hours | 48 hours |

## Assumptions and Limitations
- **Assumptions:** It is assumed that downtime boxes containing paper forms (nursing station locations) are fully stocked and clinicians are trained to utilize them during the stated RTO windows. Cloud backups and offsite infrastructure are assumed to be accessible independently of the primary data center.
- **Limitations:** Revenue impact metrics are calculated as broad estimations based on average historical billing. This BIA focuses primarily on cyber and IT operational disaster recovery and does not account for total physical facility destruction requiring complete patient evacuation.
