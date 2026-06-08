# Identity Program Brief for Dr. Morales

**Prepared for:** Dr. Morales, Chief Information Security Officer
**Date:** 2025-06-08
**Purpose:** Board Risk Committee — Identity Posture Update

---

## Identity Posture Summary

A structured audit of MedDefense's identity and cloud access controls identified **3 Critical findings** and **4 High findings** across IAM user accounts, cloud storage, and administrative roles.

In plain terms: before this review, any attacker who obtained a single set of credentials could have moved freely through our systems, read patient backup files without authentication, and left no trace in our secondary data center. That is no longer fully the case — but remediation is not complete.

| Severity | Count | Status |
|---|---|---|
| Critical | 3 | 2 remediated; 1 in progress |
| High | 4 | 2 remediated; 2 scheduled |
| Medium | 4 | Scheduled |

---

## Connection to the Incident

The prior breach followed a path that our audit confirmed still existed — in some cases unchanged — at the time of this review:

- **IAM-006 (Critical):** The S3 bucket `meddefense-clinical-backup-2022` holding patient backup archives was publicly readable on the internet. No login required. This is the same class of misconfiguration that enabled unauthorized data access during the incident.
- **IAM-007 (High):** Three administrative roles — including `MedDefenseVendorAccess` — carried unrestricted administrator permissions. The incident's lateral movement was possible because a compromised vendor-linked credential had no effective boundaries.
- **IAM-009 (High):** The EHR backup role (`MedDefenseEHRBackupRole`) had full read/write/delete access to every storage bucket in the account, not just the one it needed. A compromised backup process could have destroyed or exfiltrated all data.
- **IAM-001 (Critical):** The master AWS account had no second-factor authentication and carried active programmatic keys created in 2022. This key pair, if obtained, would have granted complete and undetectable control of the entire environment.

What is different now: two of these four conditions have been corrected. The other two have defined remediation plans with assigned owners and deadlines.

---

## What Has Been Completed

- **corrected IAM policies** for `MedDefenseEHRBackupRole` — access is now limited to the single backup bucket and only the three operations required (read, write, list). The previous policy permitted full destructive access to every bucket in the account.
- **SSO federation review** completed via SAML assertion analysis; off-boarding gaps for departed users identified and submitted for HR-coordinated access revocation.
- **Vault PAM lab** implemented and validated: the dynamic credential system now issues short-lived, auto-expiring credentials for privileged service accounts, replacing static passwords that had no rotation schedule.
- **Repeatable IAM audit script** deployed — the audit that found these gaps can now be re-run on demand and on a scheduled basis, replacing a process that was previously entirely manual.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Target Date |
|---|---|---|
| Delete AWS root access keys; enforce MFA on root account (IAM-001 Critical) | Cloud Infrastructure Lead | 2025-06-15 |
| Enable Block Public Access and remove open bucket policy on `meddefense-clinical-backup-2022`; notify Privacy Officer for HIPAA breach risk assessment (IAM-006 Critical / 45 CFR 164.402) | Cloud Security Lead + Privacy Officer | 2025-06-15 |
| Remove AdministratorAccess from `MedDefenseDevRole`, `MedDefenseLegacyRole`, `MedDefenseVendorAccess`; replace with scoped role policies (IAM-007 High) | IAM Administrator + Application Owners | 2025-06-30 |

---

## What Requires Board Authorization or Budget

Two program-level investments cannot be completed within existing team capacity and operating budget:

1. **Privileged Access Management (PAM) platform deployment** — The Vault dynamic credential proof-of-concept is validated but not production-deployed. Scaling it to cover all privileged accounts requires dedicated implementation resources. Estimated cost: $180,000–$240,000 (tooling + implementation). Without this, service account credentials continue to be long-lived and manually managed — the same condition that enabled undetected persistence during the prior incident.

2. **AWS Organizations and Service Control Policy enforcement** — There are currently no guardrails preventing any administrator from creating unrestricted public storage buckets, disabling audit logs, or granting root-equivalent access. Configuring AWS Organizations with baseline preventive controls requires a one-time architecture engagement. Estimated effort: 3–5 days of cloud architecture time plus legal review of SCP scope.

Deferring both items leaves MedDefense in a position where a single compromised administrator credential reproduces the prior incident conditions.

---

## Board Resolution Requested

> The Board Risk Committee authorizes the CISO to procure and deploy a Privileged Access Management platform (budget not to exceed $240,000) and directs the Cloud Infrastructure team to complete AWS Organizations configuration with Service Control Policies by September 30, 2025, with monthly status reporting to the Risk Committee until both items are closed.
