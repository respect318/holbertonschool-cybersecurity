# MedDefense Cloud Security Assessment

## Assessment Scope

**Assessment Date:** 2025-06-08
**Assessor:** Based on observations by Helena Reyes (Post-Incident Cloud Review)
**Environment:** MedDefense AWS Environment
**Benchmark:** CIS AWS Foundations Benchmark v3.0
**Regions Reviewed:** us-east-1 (primary), us-east-2 (DR)
**Assessment Coverage:** 10 configuration observations across IAM, S3, CloudTrail, VPC, and AWS Organizations

This assessment converts Helena Reyes's manual walk-through observations into a structured, auditable record aligned to CIS AWS Foundations Benchmark v3.0 controls. Three observations (1, 6, 9) create direct ePHI exposure or unrestricted administrative access and are flagged as Critical.

---

## Findings Table

| # | Observation | CIS Control Area | CIS Control Ref | Severity | Compliance Status |
|---|---|---|---|---|---|
| 1 | root account has no MFA configured; root access keys created 2022-03-15 and never deleted | Root account MFA and access key restrictions | CIS 1.4, 1.7 | Critical | Non-Compliant |
| 2 | 7 IAM console users; 4 have MFA enrolled; 3 do not | IAM user MFA | CIS 1.10 | High | Partially Compliant |
| 3 | 4 IAM users have long-lived programmatic access keys; 2 keys older than 22 months with no rotation schedule | Access key rotation | CIS 1.14 | Medium | Non-Compliant |
| 4 | IAM password policy: min 8 chars; no complexity; no expiration; no MFA requirement | IAM password policy | CIS 1.8, 1.9 | Medium | Non-Compliant |
| 5 | CloudTrail enabled in us-east-1 only; not enabled in us-east-2 DR region hosting clinical backup S3 buckets | CloudTrail in all regions | CIS 3.1, 3.2 | High | Non-Compliant |
| 6 | S3 bucket meddefense-clinical-backup-2022: Block Public Access disabled; bucket policy allows `Principal: "*"` for `s3:GetObject`; bucket contains ePHI backup archives | S3 public access restrictions | CIS 2.1.5 | Critical | Non-Compliant |
| 7 | 3 IAM roles carry AWS-managed AdministratorAccess: MedDefenseDevRole, MedDefenseLegacyRole, MedDefenseVendorAccess | Least privilege / admin policy use | CIS 1.16 | High | Non-Compliant |
| 8 | VPC Flow Logs not enabled on any VPC | VPC Flow Logs | CIS 3.9 | Medium | Non-Compliant |
| 9 | IAM role MedDefenseEHRBackupRole used pre-correction policy: s3:* on Resource: * | Least privilege for backup role | CIS 1.16 | High | Non-Compliant (pre-correction state) |
| 10 | AWS Organizations not configured; no Service Control Policies exist | AWS Organizations and SCPs | CIS 1.20 | Medium | Non-Compliant |

---

## Critical Findings

### Finding C-1: root Account — No MFA and Active Access Keys

**Observation:** The AWS root account has no MFA configured. Root access keys were created on 2022-03-15 and have never been deleted.

**Risk:** The root account has unrestricted access to all AWS services and resources. Without MFA, any credential compromise grants full account takeover. Active root access keys dramatically expand the attack surface since they can be used programmatically and do not require console access. This finding alone constitutes a complete loss of administrative control if credentials are exposed.

**Exact Remediation Steps:**

*Delete root access keys (AWS Console):*
1. Sign in to the AWS Management Console as root.
2. Navigate to **IAM → My Security Credentials**.
3. Expand **Access keys (access key ID and secret access key)**.
4. Click **Delete** for all listed root access keys.
5. Confirm deletion.

*Delete root access keys (AWS CLI):*
```bash
aws iam delete-access-key --access-key-id <ROOT_ACCESS_KEY_ID>
```

*Enable MFA on root account (AWS Console):*
1. Sign in as root.
2. Navigate to **IAM → My Security Credentials**.
3. Expand **Multi-factor authentication (MFA)**.
4. Click **Assign MFA device**.
5. Select **Authenticator app** (TOTP) or **Hardware TOTP token**.
6. Follow the setup wizard and confirm with two consecutive OTP codes.
7. Click **Assign MFA**.

---

### Finding C-2: Public ePHI S3 Bucket — meddefense-clinical-backup-2022

**Observation:** S3 bucket `meddefense-clinical-backup-2022` has Block Public Access disabled. The bucket policy contains `"Principal": "*"` for `s3:GetObject`. This bucket contains ePHI backup archives.

**Technical Explanation:**

- **`Principal: "*"`** means the policy applies to *any* requester — authenticated AWS users, anonymous internet users, bots, and automated scanners alike. There is no identity restriction on who can invoke the listed actions.
- **`s3:GetObject`** is the permission that allows retrieval of object content. When combined with `Principal: "*"`, every object in this bucket is effectively readable by anyone on the internet without authentication.
- **ePHI exposure:** The bucket contains electronic Protected Health Information (ePHI) as defined under HIPAA (45 CFR § 160.103). Any unauthenticated read of an ePHI object constitutes an unauthorized disclosure.

**HIPAA Breach Notification Rule — 45 CFR 164.402:**

Under 45 CFR 164.402, a "breach" is defined as the acquisition, access, use, or disclosure of protected health information in a manner not permitted under the Privacy Rule which compromises the security or privacy of the PHI. A public S3 bucket containing ePHI, accessible via `s3:GetObject` with `Principal: "*"`, creates conditions where unauthorized acquisition or access is presumed to have occurred unless the covered entity can demonstrate through a four-factor risk assessment that there is a low probability the PHI was compromised. Because access logs cannot rule out prior reads, and because the misconfiguration has no time-bounded start date, MedDefense may be unable to rebut the breach presumption. This finding must be escalated to legal counsel and the HIPAA Privacy Officer immediately. The **Breach Notification Rule** (45 CFR 164.400–414) requires notification to affected individuals within 60 days of discovery of a breach, notification to HHS, and if more than 500 individuals in a state are affected, notification to prominent media outlets.

**Exact Remediation Steps:**

*Enable S3 Block Public Access (AWS Console):*
1. Navigate to **S3 → meddefense-clinical-backup-2022 → Permissions**.
2. Under **Block public access (bucket settings)**, click **Edit**.
3. Check all four boxes:
   - Block all public access
   - Block public access granted through new ACLs
   - Block public access granted through any ACLs
   - Block public access granted through new bucket policies
   - Block public access granted through any bucket policies
4. Click **Save changes** and confirm.

*Enable Block Public Access (AWS CLI):*
```bash
aws s3api put-public-access-block \
  --bucket meddefense-clinical-backup-2022 \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

*Remove the public bucket policy (AWS CLI):*
```bash
aws s3api delete-bucket-policy --bucket meddefense-clinical-backup-2022
```

*Apply a least-privilege replacement policy permitting only MedDefenseEHRBackupRole (corrected):*
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowEHRBackupRoleOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::<ACCOUNT_ID>:role/MedDefenseEHRBackupRole"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::meddefense-clinical-backup-2022",
        "arn:aws:s3:::meddefense-clinical-backup-2022/*"
      ]
    }
  ]
}
```

*Enable server-side encryption (AWS CLI):*
```bash
aws s3api put-bucket-encryption \
  --bucket meddefense-clinical-backup-2022 \
  --server-side-encryption-configuration \
  '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"aws:kms"}}]}'
```

---

### Finding C-3: MedDefenseEHRBackupRole — s3:* on Resource: * (Pre-Correction State)

**Observation:** IAM role `MedDefenseEHRBackupRole` previously used a policy granting `s3:*` on `Resource: *`. This grants full S3 control (read, write, delete, list, modify policies, and replicate buckets) across every S3 bucket in the account, including `meddefense-clinical-backup-2022`.

**Risk:** Any process or service assuming this role could exfiltrate, overwrite, or destroy all S3 data across all buckets. Combined with Finding C-2, this role could also be used to modify bucket policies to grant further public access.

**Corrected Policy (Task 2 Reference):**

The corrected policy for `MedDefenseEHRBackupRole` must scope permissions to the specific backup bucket and required actions only:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "EHRBackupBucketAccess",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::meddefense-clinical-backup-2022",
        "arn:aws:s3:::meddefense-clinical-backup-2022/*"
      ]
    }
  ]
}
```

**Exact Remediation Steps (AWS Console):**
1. Navigate to **IAM → Roles → MedDefenseEHRBackupRole**.
2. Under **Permissions**, detach or delete any inline/managed policy granting `s3:*` on `Resource: *`.
3. Click **Add permissions → Create inline policy**.
4. Paste the corrected policy JSON above.
5. Name the policy `MedDefenseEHRBackupPolicy-Scoped`.
6. Click **Create policy**.

**Exact Remediation Steps (AWS CLI):**
```bash
# List attached policies
aws iam list-attached-role-policies --role-name MedDefenseEHRBackupRole

# Detach the overpermissive policy
aws iam detach-role-policy \
  --role-name MedDefenseEHRBackupRole \
  --policy-arn <OVERPERMISSIVE_POLICY_ARN>

# Create and attach corrected inline policy
aws iam put-role-policy \
  --role-name MedDefenseEHRBackupRole \
  --policy-name MedDefenseEHRBackupPolicy-Scoped \
  --policy-document file://corrected_ehr_backup_policy.json
```

---

## Remediation Priority Order

| Priority | # | Finding | Rationale |
|---|---|---|---|
| 1 | 6 | Public ePHI S3 bucket (meddefense-clinical-backup-2022) | Active ePHI exposure; potential HIPAA breach under 45 CFR 164.402; requires immediate containment and legal review |
| 2 | 1 | root account — no MFA, active access keys | Full account takeover risk; root keys have been active since 2022 |
| 3 | 9 | MedDefenseEHRBackupRole — s3:* on Resource: * | Unrestricted S3 access amplifies ePHI exposure; apply corrected Task 2 policy immediately |
| 4 | 7 | Three IAM roles with AdministratorAccess | Excessive blast radius; MedDefenseVendorAccess is especially high-risk for third-party misuse |
| 5 | 5 | CloudTrail not enabled in us-east-2 (DR region) | DR region hosts clinical backups with no audit logging; any access is undetected |
| 6 | 2 | IAM console MFA — 3 of 7 users lack MFA | Console access without MFA is a phishing/credential-stuffing target |
| 7 | 3 | Long-lived programmatic access keys | Two keys older than 22 months; rotate immediately and establish 90-day rotation schedule |
| 8 | 4 | Weak IAM password policy | Increases brute-force and credential-reuse risk across all IAM users |
| 9 | 8 | VPC Flow Logs disabled | No network telemetry; limits incident detection and forensic investigation |
| 10 | 10 | AWS Organizations and SCPs not configured | No account-level guardrails; remediate after foundational controls are in place |

---

## Estimated Effort

| # | Finding | Estimated Effort | Owner |
|---|---|---|---|
| 1 | root account MFA and key deletion | 1 hour | Cloud Infrastructure Lead |
| 2 | IAM console MFA enforcement for 3 users | 2 hours | IAM Administrator |
| 3 | Access key rotation for 2 aged keys | 2–4 hours (application coordination required) | IAM Administrator + App Owners |
| 4 | IAM password policy update | 30 minutes | IAM Administrator |
| 5 | Enable CloudTrail in us-east-2 | 1 hour | Cloud Infrastructure Lead |
| 6 | Remediate public ePHI S3 bucket; legal review | 4–8 hours (technical) + legal engagement timeline | Cloud Security + Privacy Officer |
| 7 | Remove AdministratorAccess from 3 roles; scope replacements | 1–3 days (requires role usage analysis per role) | IAM Administrator + App Owners |
| 8 | Enable VPC Flow Logs on all VPCs | 2 hours | Cloud Infrastructure Lead |
| 9 | Apply corrected MedDefenseEHRBackupRole policy | 1 hour | IAM Administrator |
| 10 | Configure AWS Organizations and baseline SCPs | 2–5 days (architecture planning required) | Cloud Architecture Lead |

**Total estimated effort:** 3–6 days of engineering time, excluding legal engagement for Finding 6 and organizational planning for Finding 10.

> **Note:** Findings 1, 6, and 9 should be treated as emergency remediations and completed within 24 hours. Findings 2, 5, and 7 should be completed within 72 hours. Remaining findings should be remediated within the current sprint cycle.
