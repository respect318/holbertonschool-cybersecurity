# Identity Program Brief for Dr. Morales

**Prepared for:** Dr. Morales, Chief Information Security Officer
**Date:** June 2026
**Purpose:** Board Risk Committee Briefing — Identity Program Status

---

## Identity Posture Summary

The IAM audit and cloud security assessment identified **6 Critical findings** and **5 High findings** across on-premises and cloud environments.

Critical findings include: a dormant service account with full administrative access (finding: `svc_epic_int`), a departed contractor account still active with Domain Admin rights (`t.morrison`), a legacy admin account unused for 187 days with no MFA (`admin.legacy`), a publicly accessible S3 bucket containing patient health records (CIS-6), the AWS root account operating without multi-factor authentication and with active access keys since 2022 (CIS-1), and three IAM roles carrying unrestricted administrator access in AWS (CIS-7). High findings include IAM console users without MFA (CIS-2), CloudTrail logging absent in the disaster recovery region (CIS-5), overly permissive backup role permissions (CIS-9), a Finance user retaining IT elevated rights after transfer (`j.yamamoto`), and ticket-routing automation holding full Domain Admin access (`svc_helpdesk`).

---

## Connection to the Incident

The prior Cobalt Strike compromise followed a specific path: a workstation was breached, credentials were extracted from memory, an attacker discovered a service account with Domain Admin access, and used it to move laterally across the network.

**That path exists today.** The account `svc_epic_int` — a post-EHR-migration service account that has not logged in for over three years — holds full Domain Admin membership. Its static, long-lived password can be extracted from any system where it was cached. This account directly matches the prior attack path. Similarly, `svc_helpdesk` and `svc_backup` each carry standing Domain Admin credentials that exceed their stated business functions. An attacker who compromises any one of these accounts gains the same administrative access that enabled the prior breach.

---

## What Has Been Completed

- **Cloud IAM policies corrected:** Three over-permissive AWS policies (`original_break_glass_policy.json`, `original_ehr_backup_policy.json`, `original_siem_reader_policy.json`) were rewritten to enforce least privilege, removing unrestricted `Action: *` and `s3:*` on all resources.
- **SAML single sign-on analyzed and validated:** Keycloak-based SSO federation was reviewed and confirmed to enforce centralized off-boarding — disabling an account in the identity provider immediately blocks access to all connected applications, closing the gap that allowed `t.morrison`'s contractor account to remain active.
- **Dynamic credential prototype operational:** HashiCorp Vault was configured to issue short-lived database credentials (1-hour read, 15-minute write) for the LIS system, replacing the model of shared static passwords. Credentials are automatically revoked and cannot be reused after expiry.
- **Repeatable IAM audit process established:** An automated audit script now generates machine-readable findings (`iam_findings.json`) against the full account inventory (`accounts.csv`), enabling quarterly re-assessment without manual effort.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Target Date |
|---|---|---|
| Remove Domain Admin from `svc_epic_int`, `svc_helpdesk`, and `svc_backup`; migrate to Vault-issued scoped credentials | IT Security Lead | 30 days |
| Disable `t.morrison` (departed contractor, Domain Admin, 248 days dormant) and `admin.legacy` (187 days dormant, no MFA); review `j.yamamoto` elevated rights | IT Director | 14 days |
| Enable MFA on AWS root account; delete root access keys created 2022; restrict `MedDefenseDevRole`, `MedDefenseLegacyRole`, `MedDefenseVendorAccess` to least privilege | Cloud Operations | 21 days |

---

## What Requires Board Authorization or Budget

**Privileged Access Management (PAM) program funding** is required to extend Vault-based dynamic credentials from the current prototype to all 5 identified service accounts and to on-premises privileged user workflows. This requires licensing, a dedicated implementation engineer for approximately 90 days, and integration with the existing Keycloak SSO environment. Estimated investment: $120,000–$180,000. Without this funding, service accounts will continue to hold standing administrative credentials, and the organization remains one compromised endpoint away from a repeat of the prior incident.

---

## Board Resolution Requested

The Board Risk Committee is asked to authorize funding not to exceed $180,000 for deployment of a Privileged Access Management program to eliminate standing administrative credentials across all critical service accounts, with completion required before the next annual HIPAA security risk assessment.
