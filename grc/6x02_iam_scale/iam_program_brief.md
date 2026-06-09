# Identity Program Brief for Dr. Morales

**Prepared for:** Dr. Morales, CISO | **For:** Board Risk Committee | **Date:** June 2026

---

## Identity Posture Summary

The identity audit and cloud security assessment produced **6 Critical findings** and **5 High findings** across our on-premises Active Directory and AWS environments. Critical findings represent conditions that could directly enable a repeat of the prior breach. High findings represent exposures that require only one additional step to become critical.

Key facts: three active service accounts hold the highest level of system privilege (Domain Admin) with no business justification; one AWS account bucket containing patient health records was publicly readable; and our AWS root account had no login protection enabled.

---

## Connection to the Incident

The prior Cobalt Strike breach followed this path: **compromised workstation → stolen service account credential → Domain Admin access → lateral movement across systems.**

That path remains reproducible today through findings that were still present at the start of this program:

- **IAM-CRIT-001 / svc_epic_int**: A service account with full Domain Admin rights that has not been used in over three years. A static, never-rotated password on a dormant privileged account is exactly the type of credential that was exploited in the incident. This single account could recreate the prior lateral movement path in full.
- **IAM-CRIT-002 / svc_backup** and **IAM-CRIT-003 / svc_helpdesk**: Two additional active service accounts with Domain Admin rights granted by vendors or legacy configuration, with no current review or rotation.
- **IAM-CRIT-004 / t.morrison**: A contractor account with Domain Admin access that remained active 248 days after the contract ended — a direct off-boarding failure matching the incident timeline.
- **CLOUD-CRIT-001 / AWS root, no MFA**: Full cloud environment takeover possible with stolen credentials and no second factor.
- **CLOUD-CRIT-002 / meddefense-clinical-backup-2022**: Patient health records stored in a publicly accessible AWS storage bucket (Finding: `Principal: "*"` on `s3:GetObject`), creating both a breach notification risk and a data destruction risk.

---

## What Has Been Completed

- **Service account audit completed** (Evidence: accounts.csv, svc_epic_int_static_account_risk.md): All Domain Admin service accounts identified, documented, and flagged for removal or rotation. `svc_epic_int` has been isolated pending decommission.
- **AWS IAM overpermissive policies corrected** (Evidence: original_ehr_backup_policy.json → corrected version): The backup role's permission to access any S3 bucket (`s3:*` on `Resource: *`) has been scoped to the specific backup bucket only.
- **Vault dynamic credential design validated** (Evidence: vault_database_secrets_transcript.md, vault_lease_revoke_transcript.md): A replacement architecture for static service account passwords using short-lived, auto-rotating credentials has been tested and confirmed functional. Credentials can now be revoked in real time if an account is suspected of compromise.
- **SAML SSO configuration reviewed** (Evidence: saml_flow_notes.md, keycloak_realm_export_meddefense.json): Federated login paths have been analyzed to ensure that identity assertions cannot be forged or replayed.

---

## What Must Be Completed Before the Next Board Meeting

| Action | Owner | Target Date |
|---|---|---|
| Decommission or rotate all three Domain Admin service accounts (`svc_epic_int`, `svc_backup`, `svc_helpdesk`) and disable `t.morrison` and `j.yamamoto` (CRIT-004, CRIT-005) | Identity & Access Manager | 30 days |
| Enable MFA on AWS root account and delete root access keys; enforce MFA for all three console users currently without it (CLOUD-CRIT-001, CLOUD-HIGH-002) | Cloud Security Lead | 21 days |
| Enable CloudTrail logging in the DR region (`us-east-2`) and restrict public access on the clinical backup S3 bucket (CLOUD-CRIT-002, CLOUD-HIGH-005) | Cloud Security Lead | 21 days |

---

## What Requires Board Authorization or Budget

Eliminating standing privileged passwords at the program level requires deploying HashiCorp Vault (or equivalent Privileged Access Management platform) across all service accounts and administrative roles. The proof-of-concept is complete. Full deployment requires dedicated engineering headcount and an estimated platform licensing and implementation budget. Without this investment, static passwords will continue to be re-created as operational teams provision new accounts, and the remediation completed above will erode within 12–18 months.

Additionally, enabling AWS Organizations with Service Control Policies (CLOUD-MED-010) requires architectural change that carries operational risk and needs formal change approval.

---

## Board Resolution Requested

The Board Risk Committee is asked to **authorize a budget allocation for full Privileged Access Management (PAM) platform deployment** to replace static service account credentials organization-wide, with implementation to begin within 60 days of approval — directly addressing the credential exposure that enabled the prior breach.
