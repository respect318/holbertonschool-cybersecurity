# MedDefense Cloud Security Assessment

**Classification:** Confidential
**Assessment date:** 2026-04-28
**Assessor:** Security Analyst, GRC Team
**Reviewed by:** Helena Reyes, Systems Administrator; James Chen, SOC Lead
**Benchmark:** CIS AWS Foundations Benchmark v3.0
**Source observations:** `aws_environment_observations.md`

---

## Assessment Scope

This assessment reviews ten specific AWS configuration states observed in the MedDefense
production AWS environment by Helena Reyes during the post-incident cloud review. Each
observation is mapped to the relevant CIS AWS Foundations Benchmark v3.0 control area,
assigned a compliance status and severity, and paired with specific remediation steps using
exact AWS Console or CLI commands.

**In scope:** IAM root account configuration; IAM user MFA and access key practices; IAM
password policy; CloudTrail coverage; S3 bucket access controls for the clinical backup
bucket; IAM role privilege assignments; VPC Flow Log configuration; EHR backup role policy;
AWS Organizations configuration.

**Out of scope:** Application-layer security controls; endpoint detection; network intrusion
detection; Active Directory (addressed in the IAM audit report).

**Compliance status definitions:**
- **Compliant:** Control requirement fully satisfied.
- **Partially Compliant:** Control partially satisfied; gap identified.
- **Non-Compliant:** Control requirement not satisfied.

---

## Findings Table

| # | Observation | CIS Control Area | Severity | Compliance Status |
|---|---|---|---|---|
| 1 | Root account no MFA; root access keys exist | Root account MFA and access key restrictions | Critical | Non-Compliant |
| 2 | 3 of 7 IAM console users lack MFA | IAM user MFA | High | Partially Compliant |
| 3 | Long-lived programmatic access keys (22+ months) | Access key rotation | Medium | Non-Compliant |
| 4 | Weak password policy — 8 chars, no complexity, no expiry | IAM password policy | Medium | Non-Compliant |
| 5 | CloudTrail not enabled in us-east-2 (DR region with ePHI) | CloudTrail multi-region | High | Partially Compliant |
| 6 | meddefense-clinical-backup-2022: public ePHI bucket | S3 public access restrictions | Critical | Non-Compliant |
| 7 | MedDefenseDevRole, MedDefenseLegacyRole, MedDefenseVendorAccess carry AdministratorAccess | Least privilege / admin policy use | High | Non-Compliant |
| 8 | VPC Flow Logs not enabled on any VPC | VPC Flow Logs | Medium | Non-Compliant |
| 9 | MedDefenseEHRBackupRole: pre-correction s3:* on Resource:* | Least privilege for backup role | High | Non-Compliant |
| 10 | AWS Organizations not configured; no SCPs | AWS Organizations and SCPs | Medium | Non-Compliant |

---

## Critical Findings

### Finding 1 — Root Account Has No MFA and Root Access Keys Exist

**CIS Control:** CIS AWS v3.0 — Root account MFA and access key restrictions
**Severity:** Critical
**Compliance Status:** Non-Compliant

**Observation:** The AWS root account has no MFA configured. Root access keys were created on
2022-03-15 and have never been deleted. The root account provides unrestricted access to every
AWS resource and service in the account, including the ability to delete all IAM controls, all
CloudTrail logs, and all S3 buckets.

**Risk:** The root account without MFA can be fully compromised with a password alone — via
phishing, credential stuffing, or a leaked password. Root access keys stored outside AWS
(e.g., in a developer's file system, a CI/CD pipeline, or a leaked configuration file) give
any holder immediate, permanent, unconstrained administrative access to the entire AWS account.
There is no IAM policy, SCP, or permission boundary that applies to the root account. A root
account compromise at MedDefense means immediate access to all ePHI in S3, all KMS keys, all
clinical system backups, and the ability to destroy all audit evidence.

**Remediation (exact steps):**

1. Enable MFA on the root account:
   - Log in to the AWS Console as root.
   - Navigate to **IAM → Dashboard → Add MFA for root user**.
   - Select a hardware MFA device (TOTP software is acceptable as a minimum; physical key
     preferred for root).
   - Store the MFA device and root credentials in a sealed physical safe with dual-control
     access; document the access procedure.

2. Delete root access keys:
   ```bash
   aws iam list-access-keys --user-name ""
   # Root keys are returned with no username; identify KeyId values
   aws iam delete-access-key --access-key-id <AKID_FROM_STEP_ABOVE>
   ```
   Alternatively: IAM Console → **Security Credentials** (root) → **Access keys** → Delete.

3. Verify no root keys remain:
   ```bash
   aws iam get-account-summary | grep -i "AccountAccessKeysPresent"
   # Expected: "AccountAccessKeysPresent": 0
   ```

4. Create a named break-glass IAM user with AdministratorAccess (not root) for emergency
   operations; gate it with MFA and IP restrictions as specified in the corrected
   break-glass IAM policy.

**Owner:** IT Director; Cloud Infrastructure team
**Target completion:** Immediate (within 24 hours)

---

### Finding 6 — Public ePHI S3 Bucket: meddefense-clinical-backup-2022

**CIS Control:** CIS AWS v3.0 — S3 bucket public access restrictions
**Severity:** Critical
**Compliance Status:** Non-Compliant

**Observation:** S3 bucket `meddefense-clinical-backup-2022` has Block Public Access disabled.
The bucket policy contains `"Principal": "*"` for `s3:GetObject`. This bucket contains ePHI
backup archives.

**Technical explanation:**

`"Principal": "*"` in an S3 bucket policy means any entity in the world — authenticated or
unauthenticated, any AWS account, any anonymous HTTP client — can invoke `s3:GetObject` on
this bucket. Because Block Public Access is also disabled, there is no account-level guardrail
overriding this bucket policy. Any person or automated system that knows or discovers the
bucket name can download ePHI backup archives without any credential.

The combination of `Principal: "*"`, `s3:GetObject`, and ePHI content means that every object
in this bucket is currently accessible to the public internet.

**HIPAA Breach Notification Rule — 45 CFR 164.402:**

Under the HIPAA Breach Notification Rule at 45 CFR 164.402, a "breach" is defined as the
acquisition, access, use, or disclosure of protected health information in a manner not
permitted under the HIPAA Privacy Rule. An S3 bucket policy granting `s3:GetObject` to
`Principal: "*"` constitutes an impermissible disclosure of any PHI stored in the bucket to
any party who accessed it. The burden of proof under 45 CFR 164.402 is on the covered entity
to demonstrate that a breach has not occurred — a standard that cannot be met without
complete, attributable S3 access logs, which this configuration may not have produced if
access logging was also disabled.

If any individual accessed ePHI from this bucket without authorization, MedDefense has a
reportable breach obligation under 45 CFR 164.410 (notification to individuals) and 45 CFR
164.408 (notification to HHS). MedDefense should engage legal counsel and a HIPAA privacy
officer to assess whether a breach notification obligation has already been triggered.

**Remediation (exact steps):**

1. Enable S3 Block Public Access at the bucket level immediately:
   ```bash
   aws s3api put-public-access-block \
     --bucket meddefense-clinical-backup-2022 \
     --public-access-block-configuration \
     "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
   ```

2. Remove the public bucket policy:
   ```bash
   aws s3api delete-bucket-policy --bucket meddefense-clinical-backup-2022
   ```
   If a policy is required for the backup role, replace it with a resource-based policy
   granting access only to the `MedDefenseEHRBackupRole` ARN.

3. Enable S3 server access logging to capture a record of all past object access:
   ```bash
   aws s3api put-bucket-logging --bucket meddefense-clinical-backup-2022 \
     --bucket-logging-status '{"LoggingEnabled":{"TargetBucket":"meddefense-access-logs","TargetPrefix":"clinical-backup/"}}'
   ```

4. Review S3 access logs and CloudTrail `GetObject` events for the bucket to determine
   whether any unauthorized access occurred; preserve logs for breach determination.

5. Enable S3 Block Public Access at the account level to prevent future misconfiguration:
   ```bash
   aws s3control put-public-access-block \
     --account-id 123456789012 \
     --public-access-block-configuration \
     "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
   ```

6. Notify the HIPAA Privacy Officer and legal counsel immediately for breach risk assessment.

**Owner:** Cloud Infrastructure team; HIPAA Privacy Officer; Legal
**Target completion:** Immediate (block public access within 1 hour; legal notification same day)

---

## Findings — All Ten Observations

### Observation 2 — IAM Console MFA Coverage Incomplete

**CIS Control:** IAM user MFA
**Severity:** High
**Compliance Status:** Partially Compliant

Three of seven IAM console users do not have MFA enrolled. IAM console users without MFA can
be compromised with credentials alone via phishing or credential stuffing.

**Remediation:**
1. Identify the three users without MFA:
   ```bash
   aws iam generate-credential-report
   aws iam get-credential-report --output text --query 'Content' | base64 -d | \
     awk -F',' 'NR>1 && $4=="true" && $8=="false" {print $1}'
   ```
2. For each user, require MFA enrollment before next console login by attaching an IAM
   policy that denies all actions except `iam:EnableMFADevice` until MFA is configured.
3. Set a 48-hour deadline; disable console access for any user who does not enroll.

**Owner:** Cloud IAM team
**Target completion:** 7 days

---

### Observation 3 — Long-Lived Programmatic Access Keys

**CIS Control:** Access key rotation (CIS AWS v3.0 — credential rotation)
**Severity:** Medium
**Compliance Status:** Non-Compliant

Four IAM users have programmatic access keys; two have not been rotated in 22+ months.
Long-lived static keys create persistent credential theft risk with no automatic expiry.

**Remediation:**
1. List all access keys and their ages:
   ```bash
   aws iam generate-credential-report
   aws iam get-credential-report --output text --query 'Content' | base64 -d | \
     awk -F',' 'NR>1 && $9!="N/A" {print $1, $9, $10}'
   ```
2. For keys older than 90 days: create a new key, update the application or script using
   the old key, verify the new key works, then delete the old key.
3. Implement a key rotation reminder: set a CloudWatch Events rule alerting when any
   access key age exceeds 90 days.
4. Evaluate whether programmatic access can be replaced with IAM roles for EC2 or Lambda
   (instance profiles), eliminating the need for long-lived keys entirely.

**Owner:** Cloud IAM team; application owners for each key
**Target completion:** 30 days

---

### Observation 4 — Weak IAM Password Policy

**CIS Control:** IAM password policy (CIS AWS v3.0)
**Severity:** Medium
**Compliance Status:** Non-Compliant

The current password policy requires only 8 characters with no complexity, no expiration, and
no MFA requirement for console login. This policy is below CIS AWS minimum requirements and
below HIPAA technical safeguard expectations for authentication controls.

**Remediation:**
```bash
aws iam update-account-password-policy \
  --minimum-password-length 14 \
  --require-symbols \
  --require-numbers \
  --require-uppercase-characters \
  --require-lowercase-characters \
  --allow-users-to-change-password \
  --max-password-age 90 \
  --password-reuse-prevention 24 \
  --hard-expiry false
```
Additionally, enforce MFA for all console logins via IAM Identity Center conditional access
policy or per-user MFA enforcement policy.

**Owner:** Cloud IAM team
**Target completion:** 14 days

---

### Observation 5 — CloudTrail Not Enabled in DR Region (us-east-2)

**CIS Control:** CloudTrail multi-region logging (CIS AWS v3.0)
**Severity:** High
**Compliance Status:** Partially Compliant

CloudTrail is enabled in `us-east-1` but not in `us-east-2`, which is the DR region where
clinical backup S3 buckets reside. All API calls against ePHI backup buckets in `us-east-2` —
including any unauthorized `GetObject` access — are currently unlogged.

**Remediation:**
```bash
aws cloudtrail create-trail \
  --name meddefense-us-east-2-trail \
  --s3-bucket-name meddefense-cloudtrail-logs \
  --include-global-service-events \
  --is-multi-region-trail \
  --enable-log-file-validation \
  --region us-east-2

aws cloudtrail start-logging \
  --name meddefense-us-east-2-trail \
  --region us-east-2
```
Enable S3 data events for the clinical backup bucket specifically:
```bash
aws cloudtrail put-event-selectors \
  --trail-name meddefense-us-east-2-trail \
  --event-selectors '[{"ReadWriteType":"All","IncludeManagementEvents":true,"DataResources":[{"Type":"AWS::S3::Object","Values":["arn:aws:s3:::meddefense-clinical-backup-2022/"]}]}]' \
  --region us-east-2
```

**Owner:** Cloud Infrastructure team
**Target completion:** 7 days

---

### Observation 7 — Three IAM Roles Carry AdministratorAccess

**CIS Control:** Least privilege and admin policy use (CIS AWS v3.0)
**Severity:** High
**Compliance Status:** Non-Compliant

`MedDefenseDevRole`, `MedDefenseLegacyRole`, and `MedDefenseVendorAccess` each carry the
AWS-managed `AdministratorAccess` policy. Any principal able to assume one of these roles
gains unrestricted access to all AWS services and resources, including ePHI buckets, KMS
keys, and IAM management.

**Remediation:**
1. For each role, identify the actual AWS services and actions used in the past 90 days:
   ```bash
   aws iam generate-service-last-accessed-details --arn arn:aws:iam::123456789012:role/MedDefenseLegacyRole
   # Repeat for each role; use the report to scope minimum required actions
   ```
2. Replace `AdministratorAccess` with a custom policy containing only the actions and
   resources identified as actually used.
3. For `MedDefenseVendorAccess`: require the vendor to document the specific IAM actions
   their integration needs; enforce a scoped policy; add a `Condition` block restricting
   `aws:SourceIp` or `sts:ExternalId` to the vendor's known network.
4. For `MedDefenseLegacyRole`: if no current principal assumes this role, disable it.
   ```bash
   aws iam update-role --role-name MedDefenseLegacyRole --max-session-duration 900
   # Then verify no active sessions; delete if confirmed unused
   ```

**Owner:** Cloud IAM team; application owners; vendor management
**Target completion:** 30 days

---

### Observation 8 — VPC Flow Logs Not Enabled

**CIS Control:** VPC Flow Logs (CIS AWS v3.0)
**Severity:** Medium
**Compliance Status:** Non-Compliant

VPC Flow Logs are not enabled on any VPC. Without flow log data, network-level forensic
investigation of any incident is impossible — lateral movement, data exfiltration, or C2
beacon traffic between internal hosts leaves no network telemetry record.

**Remediation:**
```bash
# List all VPCs
aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text

# Enable flow logs for each VPC (repeat for each VpcId)
aws ec2 create-flow-logs \
  --resource-type VPC \
  --resource-ids vpc-XXXXXXXX \
  --traffic-type ALL \
  --log-destination-type cloud-watch-logs \
  --log-group-name /aws/vpc/flowlogs \
  --deliver-logs-permission-arn arn:aws:iam::123456789012:role/flowlogsRole
```

**Owner:** Cloud Infrastructure team
**Target completion:** 14 days

---

### Observation 9 — MedDefenseEHRBackupRole: Pre-Correction s3:* on Resource:*

**CIS Control:** Least privilege for backup role (CIS AWS v3.0)
**Severity:** High
**Compliance Status:** Non-Compliant (corrected in Task 2)

The original `MedDefenseEHRBackupRole` policy granted `s3:*` on `Resource: *` and `kms:*` on
`Resource: *`. This allowed the backup role to read, write, delete, and administratively
modify any S3 bucket and any KMS key in the account — including exfiltrating ePHI from
unrelated buckets and deleting or disabling KMS keys used to protect other clinical data.

The corrected policy (produced in Task 2 and stored in `iam_policies/ehr_backup_policy.json`)
scopes S3 access to `meddefense-ehr-backup-prod` with only the actions required for backup
operations, and scopes KMS access to the single designated key
`arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456` with only encrypt, decrypt, and
key-description actions.

**Remediation:**
```bash
# Apply the corrected policy
aws iam create-policy \
  --policy-name MedDefenseEHRBackupRoleCorrected \
  --policy-document file://iam_policies/ehr_backup_policy.json

# Detach the old overly-permissive policy
aws iam detach-role-policy \
  --role-name MedDefenseEHRBackupRole \
  --policy-arn arn:aws:iam::123456789012:policy/ORIGINAL_POLICY_ARN

# Attach the corrected policy
aws iam attach-role-policy \
  --role-name MedDefenseEHRBackupRole \
  --policy-arn arn:aws:iam::123456789012:policy/MedDefenseEHRBackupRoleCorrected
```

**Owner:** Cloud IAM team
**Target completion:** Immediate (corrected policy already produced; deployment pending)

---

### Observation 10 — AWS Organizations Not Configured; No SCPs

**CIS Control:** AWS Organizations and SCPs (CIS AWS v3.0)
**Severity:** Medium
**Compliance Status:** Non-Compliant

AWS Organizations is not configured, and no Service Control Policies (SCPs) exist. Without
SCPs, there are no account-level guardrails preventing any IAM principal from performing
actions that should be permanently restricted — such as disabling CloudTrail, disabling
GuardDuty, creating public S3 buckets, or creating new root access keys. An IAM user or role
with sufficient permissions can unilaterally remove all security controls.

**Remediation:**
1. Enable AWS Organizations and create an organization with the current account as the
   management account via the AWS Console (IAM → Organizations → Create organization).
2. Create a foundational SCP that denies high-risk actions regardless of IAM permissions:
   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {"Sid": "DenyCloudTrailDisable","Effect":"Deny","Action":["cloudtrail:StopLogging","cloudtrail:DeleteTrail"],"Resource":"*"},
       {"Sid": "DenyS3PublicAccess","Effect":"Deny","Action":"s3:PutBucketPublicAccessBlock","Resource":"*","Condition":{"StringEquals":{"s3:PublicAccessBlockEnabled":"false"}}},
       {"Sid": "DenyRootKeyCreation","Effect":"Deny","Action":"iam:CreateAccessKey","Resource":"arn:aws:iam::*:root"}
     ]
   }
   ```
3. Attach the SCP to the root OU.

**Owner:** Cloud Infrastructure team; IT Director approval required
**Target completion:** 60 days

---

## Remediation Priority Order

| Priority | Finding | Severity | Action | Target |
|---|---|---|---|---|
| 1 | Finding 6 — Public ePHI S3 bucket | Critical | Enable Block Public Access; delete public policy; notify HIPAA officer | Immediate (1 hour) |
| 2 | Finding 1 — Root no MFA, root keys exist | Critical | Enable root MFA; delete root access keys | Within 24 hours |
| 3 | Finding 9 — EHRBackupRole s3:* / kms:* | High | Deploy corrected policy from Task 2 | Within 24 hours |
| 4 | Finding 5 — CloudTrail missing in us-east-2 | High | Enable CloudTrail with data events in DR region | Within 7 days |
| 5 | Finding 2 — IAM console MFA incomplete | High | Enforce MFA for three non-compliant users | Within 7 days |
| 6 | Finding 7 — Three roles with AdministratorAccess | High | Scope roles to minimum required actions | Within 30 days |
| 7 | Finding 4 — Weak password policy | Medium | Apply 14-character minimum with complexity requirements | Within 14 days |
| 8 | Finding 8 — VPC Flow Logs disabled | Medium | Enable flow logs on all VPCs | Within 14 days |
| 9 | Finding 3 — Long-lived programmatic access keys | Medium | Rotate keys older than 90 days | Within 30 days |
| 10 | Finding 10 — No AWS Organizations / SCPs | Medium | Enable Organizations; deploy foundational SCP | Within 60 days |

---

## Estimated Effort

| Finding | Effort | Notes |
|---|---|---|
| Finding 1 — Root MFA and key deletion | 1 hour | Console + 2 CLI commands; requires physical MFA device |
| Finding 2 — IAM console MFA | 2 hours | Policy attachment + user follow-up |
| Finding 3 — Access key rotation | 4–8 hours | Depends on number of applications using keys |
| Finding 4 — Password policy | 30 minutes | Single CLI command |
| Finding 5 — CloudTrail us-east-2 | 2 hours | Trail creation + data event selector + log bucket config |
| Finding 6 — Public ePHI S3 bucket | 2 hours technical + legal engagement | Block public access is 1 CLI command; breach assessment is ongoing |
| Finding 7 — AdminAccess roles | 5–15 hours | Requires service-last-accessed analysis per role; custom policy authoring |
| Finding 8 — VPC Flow Logs | 2 hours | One command per VPC; requires a CloudWatch log group and delivery role |
| Finding 9 — EHRBackupRole policy | 1 hour | Policy already written in Task 2; deployment only |
| Finding 10 — AWS Organizations + SCPs | 4 hours | Organizations setup + SCP authoring and testing |
