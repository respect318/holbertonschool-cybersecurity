# NIST CSF 2.0 Gap Assessment: MedDefense Health Systems
**Assessment date:** 2026-05-10
**Assessor:** [Student Name]
**Framework version:** NIST CSF 2.0
**Regulatory context:** HIPAA Security Rule, 45 CFR Part 164

## Gap Assessment Matrix

| CSF Function | Subcategory | Title (abbreviated) | Status | Evidence Reference | Gap Severity | Gap Description |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| GOVERN | GV.OC-01 | Org risk strategy established | Partial | riskregisterupdates.yaml | High | Risk register exists and is updated post-incident; no board-approved risk appetite statement |
| GOVERN | GV.PO-01 | Cybersecurity policy established | Not Implemented | None | Critical | No written AUP or data classification policy; verbal policy is not auditable |
| GOVERN | GV.SC-04 | Suppliers inventoried by criticality | Not Implemented | None | High | No formal vendor inventory; Nexus, CloudVault, etc. are not tiered |
| GOVERN | GV.SC-07 | Supplier risks in risk register | Not Implemented | None | High | Vendor risk not represented in the risk register |
| IDENTIFY | ID.AM-01 | Asset inventory maintained | Partial | endpoint_hardening_baseline.md | Medium | Workstation inventory exists; cloud and medical devices not inventoried |
| IDENTIFY | ID.RA-01 | Vulnerabilities identified and recorded | Implemented | riskregisterupdates.yaml | None | Vulnerability identification evident through incident findings |
| IDENTIFY | ID.RA-06 | Risk responses tracked | Partial | implementation_package.md | Medium | Treatment plans exist post-incident; no ongoing tracking cadence |
| PROTECT | PR.AA-01 | Identity and credential management | Partial | playbookcredentialexposure.yaml | High | IR credential procedures exist; no proactive IAM program |
| PROTECT | PR.AA-05 | Access permissions reviewed | Not Implemented | None | High | No evidence of periodic access reviews or auditing of privileges |
| PROTECT | PR.AT-01 | Awareness training provided | Not Implemented | None | Critical | No documented security awareness training program for employees |
| PROTECT | PR.DS-01 | Data-at-rest protected | Partial | endpoint_hardening_baseline.md | Medium | BitLocker on endpoints; cloud database encryption status unverified |
| PROTECT | PR.PS-01 | Configuration baselines managed | Implemented | endpoint_hardening_baseline.md | None | Hardening baselines deployed and documented |
| PROTECT | PR.PS-04 | Log records generated/managed | Implemented | sigma_detection_rules.yml | None | Sigma rules exist; implies centralized log collection is active |
| DETECT | DE.CM-01 | Networks/environments monitored | Partial | sigma_detection_rules.yml | Medium | Sigma rules deployed; continuous monitoring scope may be limited |
| DETECT | DE.CM-06 | Malicious code detected | Implemented | sigma_detection_rules.yml | None | Sigma rules configured for malware/ransomware detection |
| DETECT | DE.AE-02 | Anomalous activity analyzed | Implemented | forensic_runbook.md | None | Forensic capabilities exist for analyzing suspected anomalies |
| RESPOND | RS.MA-01 | Incident response plan exists | Implemented | ir_playbook.md | None | IR playbooks are formalized and available |
| RESPOND | RS.AN-03 | Incidents analyzed/categorized | Implemented | forensic_runbook.md | None | Post-incident forensic runbooks are established |
| RESPOND | RS.CO-02 | Internal/external reporting | Partial | ir_playbook.md | Medium | IR playbook dictates response; formal external reporting policy unclear |
| RECOVER | RC.RP-01 | Recovery plan exists | Partial | recovery_validation.sh | High | Script exists for technical validation; comprehensive BCDR plan missing |
| RECOVER | RC.CO-01 | Recovery communications | Not Implemented | None | Medium | No documented plan for communicating recovery status to stakeholders |

## Summary

**Implementation counts:**
- Implemented: 7
- Partial: 8
- Not Implemented: 6

**Top 3 pre-audit priorities:**
1. GV.PO-01 (Critical): Immediate drafting of core security policies (AUP, Data Classification) required.
2. PR.AT-01 (Critical): Implement and document an organization-wide security awareness training program.
3. GV.SC-04 (High): Formalize vendor inventory and execute BAA with CloudVault immediately.

**Connection to upcoming governance work:**
The Critical and High gaps above are not incidental. They represent the exact control areas this project and the projects that follow are designed to close. Technical controls must be supported by formal policies, vendor risk assessments, and structured training programs to satisfy an auditor.
