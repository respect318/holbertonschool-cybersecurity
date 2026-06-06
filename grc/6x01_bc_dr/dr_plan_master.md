# MedDefense Disaster Recovery Master Plan

## Program scope

This program covers all critical clinical and administrative systems.
* Covered Systems: LIS, EHR, Network, Clinical Back-office.
* Sites: Central Data Center, regional nursing stations.
* Scenarios: Ransomware, data center power loss, LIS/EHR downtime.
* Exclusions: Non-clinical research, secondary admin office hardware.

## Roles and responsibilities

| Role | Responsibility |
| :--- | :--- |
| Disaster Declaration Authority | Final approval to activate DR plans. |
| DR Plan Coordinator | Manages testing schedules and program maintenance. |
| Technical Recovery Lead | Executes system restoration and backup validation. |
| Clinical Downtime Lead | Manages paper-based clinical workflow transitions. |
| Communications Lead | Manages internal/external messaging during outages. |

## Activation criteria

1. System Unavailability: EHR/LIS downtime for >10 minutes.
2. Security Incident: Confirmed ransomware detected on core servers.
3. Physical Failure: Site-wide loss of power or climate control for >1 hour.
4. CISO Discretion: Incident deemed high-risk by CISO.

## Communication plan

1. Declaration: Technical Recovery Lead notifies Disaster Declaration Authority.
2. Alerting: Communications Lead alerts Clinical Downtime Lead via emergency page.
3. Internal: Department heads informed within 15 minutes of declaration.
4. External: Communications Lead provides status updates to Board/Stakeholders every hour.

## Program document index

| Document | Filename | Version | Last Updated | Last Tested |
| :--- | :--- | :--- | :--- | :--- |
| Business Impact Analysis | business_impact_analysis.md | 1.0 | 2026-06-06 | N/A |
| Backup Architecture | backup_architecture.md | 1.0 | 2026-06-06 | N/A |
| Recovery Runbooks | recovery_runbooks.md | 1.0 | 2026-06-06 | 2026-06-06 |
| Clinical Downtime Procedures | clinical_downtime_procedures.md | 1.0 | 2026-06-06 | N/A |
| Recovery Test Record (LIS) | recovery_test_record.md | 1.0 | 2026-06-06 | 2026-06-06 |
| Gap Analysis | gap_analysis.md | 1.0 | 2026-06-06 | N/A |

## Testing and revision schedule

In accordance with HIPAA 164.308(a)(7), this program is subject to annual testing and revision.

## CISO sign-off

Dr. Morales, CISO
Signature: ____________________
Date: 2026-06-06
