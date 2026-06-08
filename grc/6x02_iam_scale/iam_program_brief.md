# Identity Program Brief for Dr. Morales

**Classification:** Confidential — Board Risk Committee
**Date:** 2026-04-28
**Prepared by:** Security Analyst, GRC Team
**Reviewed by:** James Chen, SOC Lead

---

## Identity Posture Summary

A structured review of MedDefense's identity controls — covering Active Directory accounts,
AWS cloud permissions, and service account design — identified **19 Active Directory findings
(7 Critical, 8 High)** and **10 AWS cloud misconfigurations (2 Critical, 5 High)**. Of the
19 AD findings, 7 represent conditions that could directly enable a repeat of the prior breach:
service accounts with administrator-level domain access, departed employees with active
accounts, and privileged accounts with no second-factor authentication. Of the 10 cloud
findings, one — a publicly accessible S3 bucket containing patient backup data — may
constitute a reportable HIPAA breach requiring legal review. These are not hypothetical
risks. They are documented, named misconfigurations in systems currently in operation.

---

## Connection to the Incident

The prior breach escalated because an attacker extracted a service account credential from a
compromised workstation and used it to gain administrator-level access across the domain.
That account — `svc_epic_int` — is still present in our environment today. Finding **IAM-013**
documents that `svc_epic_int` remains enabled, retains Domain Admin group membership, has no
identified business function, and has not been legitimately used in **1,156 days**. Finding
**IAM-014** documents that its password has never been rotated. Two additional service accounts
(`svc_helpdesk`, IAM-015; `svc_backup`, IAM-012) carry identical administrator-level access
with the same vulnerability profile.

What is different now: we have identified and named every account that replicates that risk.
Before this audit, these misconfigurations were invisible. They are now documented, assigned
to owners, and scheduled for remediation within defined timelines. The audit script
(`audit_iam.py`) is repeatable — every future account change can be re-evaluated in minutes.

---

## What Has Been Completed

- **Corrected IAM policies:** Three over-privileged AWS policies (`siem_reader_policy`,
  `ehr_backup_policy`, `break_glass_policy`) have been rewritten with exact resource scopes
  and minimum required permissions, eliminating wildcard `s3:*` and `kms:*` access that
  would have allowed any compromise to spread across all clinical data stores.
- **SSO federation design:** A complete SAML 2.0 SSO configuration has been analyzed and
  documented (`keycloak_saml_config.md`). Centralizing authentication means a single
  de-provisioning action disables a departing employee across all connected systems — the
  control failure that left two former-employee accounts active during the incident.
- **Vault dynamic credential design:** A HashiCorp Vault integration for database access
  (`vault_pam_lab.md`) has been designed and demonstrated. Dynamic credentials expire
  automatically — the stolen `svc_epic_int` model becomes architecturally impossible because
  no standing password exists to steal.
- **Repeatable audit capability:** `audit_iam.py` processes the full account inventory in
  seconds, applies consistent scoring, and produces findings in structured format. The prior
  state of these controls was unknown because no repeatable audit existed.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Target Date |
|---|---|---|
| Disable `svc_epic_int`, `admin.legacy`, `t.morrison`, and all departed-employee accounts (IAM-003, IAM-006, IAM-008, IAM-013); remove Domain Admin membership from `svc_helpdesk` and `svc_backup` (IAM-012, IAM-015) | Identity and Access Management team + SOC Lead | Within 48 hours |
| Block public access on `meddefense-clinical-backup-2022` S3 bucket; engage HIPAA Privacy Officer for breach determination under 45 CFR 164.402 | Cloud Infrastructure team + Legal + Privacy Officer | Within 24 hours |
| Enforce MFA for all Domain Admin and Server Admin accounts via Conditional Access policy; enroll remaining three AWS IAM console users (IAM-002, IAM-005, IAM-018; AWS Finding 2) | Identity and Access Management team | Within 14 days |

---

## What Requires Board Authorization or Budget

Eliminating the structural conditions that enabled the breach requires two investments that
exceed the Security team's current operational budget and authority:

1. **HashiCorp Vault enterprise deployment** — replacing five static Domain Admin service
   accounts with dynamically issued, time-limited credentials. This eliminates the credential-
   theft risk permanently rather than managing it through manual rotation schedules that
   historically have not been followed. Estimated cost: \$X per year (vendor quote pending).
   Risk if deferred: the next incident is enabled by the same credential-theft path because
   standing service account passwords still exist.

2. **SSO federation implementation** — deploying the Keycloak SAML SSO integration across
   Epic, PACS, and the pharmacy system. This means one de-provisioning action when an employee
   leaves, instead of the four separate manual steps that were missed during the prior incident.
   Estimated effort: 60–90 days of implementation with existing staff plus vendor coordination.
   Risk if deferred: the next departed employee is a potential breach path for the same reason
   as before.

---

## Board Resolution Requested

The Board Risk Committee is asked to authorize funding for the deployment of a Privileged
Access Management (PAM) solution (HashiCorp Vault) and SSO federation (Keycloak SAML) as
mandatory security infrastructure, with implementation to begin within 30 days of this
authorization, and to direct the CISO to report completion status at the following quarterly
board meeting.
