# MedDefense IAM Policy Analysis

This document identifies every least-privilege violation in the three original MedDefense AWS
IAM policies, describes the concrete attack surface each violation creates, presents the
corrected policy design, and explains how each change closes the identified risk.

---

## Policy 1: MedDefenseSIEMLogReader Violations

### Original Policy Summary

The original `MedDefenseSIEMLogReader` policy contained two statements:

- `s3:*` on `Resource: *` — full S3 access across every bucket in the account.
- `logs:*` and `cloudwatch:*` on `Resource: *` — full CloudWatch Logs and Metrics control
  across all log groups and all CloudWatch resources.

### Violations and Attack Scenarios

**Violation 1 — `s3:*` on `Resource: *`**

A SIEM log reader needs to read log objects from a single S3 bucket. The wildcard action `s3:*`
grants not only read access but also write, delete, and administrative actions including
`s3:DeleteBucket`, `s3:PutBucketPolicy`, `s3:PutLifecycleConfiguration`, and
`s3:DeleteObject`. The wildcard resource `*` extends these permissions to every S3 bucket in
the account — including the ePHI backup bucket `meddefense-clinical-backup-2022`, the EHR
backup bucket, and any other sensitive store.

**Concrete attack scenario:** If the Lambda function or the IAM role credentials are
compromised (e.g., via a dependency supply-chain attack or SSRF against the metadata endpoint),
an attacker gains the ability to exfiltrate data from every S3 bucket in the account, overwrite
bucket policies to grant public access, or delete backup data to prevent recovery — all using
credentials that were intended only to read SIEM logs.

**Violation 2 — `logs:*` and `cloudwatch:*` on `Resource: *`**

The SIEM reader Lambda only needs to write its own execution logs. Granting `logs:*` allows
the role to delete log groups (`logs:DeleteLogGroup`), tamper with retention policies
(`logs:PutRetentionPolicy`), or read log groups belonging to other services including security
monitoring lambdas. Granting `cloudwatch:*` allows creation and deletion of alarms, dashboards,
and metric filters used by the security team — a compromised role could silently disable
alerting.

**Concrete attack scenario:** An attacker with the SIEM reader credentials could delete or
modify CloudWatch alarms that trigger on unauthorized API calls, effectively blinding the
security team during a breach.

### Corrections Applied

| Original | Corrected | Justification |
|---|---|---|
| `s3:*` on `*` | `s3:GetObject` on `arn:aws:s3:::meddefense-siemlog-prod/*` | Read-only access to log objects in the specific production bucket only |
| `s3:*` on `*` | `s3:ListBucket` on `arn:aws:s3:::meddefense-siemlog-prod` | Listing requires the bucket ARN (without `/*`) as a separate statement |
| `logs:*` on `*` | `logs:CreateLogGroup`, `logs:CreateLogStream`, `logs:PutLogEvents` on `/aws/lambda/siem-log-reader:*` | Minimum permissions for Lambda execution logging, scoped to the specific log group |
| `cloudwatch:*` on `*` | Removed entirely | The SIEM reader function has no legitimate need for CloudWatch Metrics management |

---

## Policy 2: MedDefenseEHRBackupRole Violations

### Original Policy Summary

The original `MedDefenseEHRBackupRole` policy contained:

- `s3:*` on `Resource: *` — full S3 access across every bucket in the account.
- `kms:*` on `Resource: *` — full KMS control across every key in every region of the account.

### Violations and Attack Scenarios

**Violation 1 — `s3:*` on `Resource: *`**

An EHR backup role needs to read data from source systems and write encrypted backups to a
designated bucket. The wildcard action and resource combination grants the ability to read from
or write to every S3 bucket in the account, delete objects in any bucket, and modify bucket
policies or lifecycle rules.

**Concrete attack scenario:** A compromised backup agent running under this role could be used
to exfiltrate data from every bucket in the account — including raw SIEM log archives, other
clinical datasets, or internal configuration buckets — without any bucket-level guardrail
stopping it. An attacker could also use `s3:PutBucketPolicy` to make the SIEM log bucket
publicly readable or use `s3:DeleteObject` to destroy backup archives before a ransomware
payload is deployed, eliminating the recovery path.

**Violation 2 — `kms:*` on `Resource: *`**

The backup role only needs to encrypt and decrypt data using a single dedicated KMS key. The
wildcard action `kms:*` grants the ability to schedule key deletion (`kms:ScheduleKeyDeletion`),
disable keys (`kms:DisableKey`), modify key policies (`kms:PutKeyPolicy`), and create new
keys. The wildcard resource extends these permissions to every KMS key in the account.

**Concrete attack scenario:** A compromised backup role could disable or schedule deletion of
KMS keys that protect other services — for example, deleting the key used to encrypt the
CloudTrail log archive, making audit trails unreadable. An attacker could also use
`kms:PutKeyPolicy` to grant their own IAM identity direct decryption access to keys protecting
other clinical datasets, achieving lateral movement without touching S3 bucket policies directly.

### Corrections Applied

| Original | Corrected | Justification |
|---|---|---|
| `s3:*` on `*` | `s3:PutObject`, `s3:GetObject`, `s3:ListBucket`, `s3:DeleteObject`, `s3:GetBucketLocation` scoped to `meddefense-ehr-backup-prod` | Restricts S3 permissions to the designated backup bucket; removes administrative S3 actions |
| `kms:*` on `*` | `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey`, `kms:GenerateDataKeyWithoutPlaintext`, `kms:DescribeKey` scoped to `arn:aws:kms:us-east-1:123456789012:key/mrk-abc123def456` | Allows only the cryptographic operations needed for backup encryption/decryption using the designated key; removes key management actions |

---

## Policy 3: MedDefenseBreakGlassAdmin Violations

### Original Policy Summary

The original `MedDefenseBreakGlassAdmin` policy contained a single statement:

- `Action: *` on `Resource: *` with `Effect: Allow` — unconditional full administrative access,
  equivalent to `AdministratorAccess`, with no conditions whatsoever.

### Violations and Attack Scenarios

**Violation 1 — No MFA requirement**

Break-glass roles exist for genuine emergencies, not routine operations. Without an MFA
condition, any principal whose long-lived credentials are stolen can assume the break-glass role
and exercise full administrative access without proving physical possession of a second factor.
AWS IAM credentials can be exfiltrated from developer laptops, CI/CD pipelines, or EC2 metadata
endpoints without the credential owner being aware.

**Concrete attack scenario:** An attacker who obtains a developer's AWS access key via a
phishing email or a leaked `.env` file can immediately assume the break-glass role, create
a new IAM user with administrator access, and establish persistent access — all before the
legitimate user notices the compromise. Without MFA enforcement, there is no additional barrier
between credential theft and full account takeover.

**Violation 2 — No source IP restriction**

Without an IP condition, the break-glass role can be assumed from any IP address in the world.
Legitimate emergency access is expected to originate from the MedDefense secure operations
network or VPN range (198.51.100.0/24). There is no operational reason for break-glass access
to be exercised from an arbitrary residential IP or a cloud VPS.

**Concrete attack scenario:** An attacker operating from a remote location (a different country,
a rented VPS, a Tor exit node) can use stolen credentials to assume the break-glass role without
any network-based detection signal. Combined with the absence of MFA, this means the
administrative blast radius is reachable from anywhere on the internet.

**Violation 3 — No explicit Deny statements**

AWS policy evaluation grants the Allow if conditions are met, but without explicit Deny
statements, a misconfiguration or a policy simulator gap could allow the allow to fire when it
should not. Explicit Deny statements for the non-MFA and non-trusted-IP cases ensure that the
break-glass capability is locked behind both controls independently, and that even an AWS
Organizations SCP gap or a permission boundary misconfiguration cannot bypass the intent.

### Corrections Applied

| Original | Corrected | Justification |
|---|---|---|
| `Action: *`, `Resource: *`, no conditions | Allow `Action: *` only when `aws:MultiFactorAuthPresent: true` AND `aws:SourceIp` in `198.51.100.0/24` | Emergency admin capability is preserved but requires active MFA token and trusted network |
| No Deny | Explicit `Deny` when `aws:MultiFactorAuthPresent: false` | Prevents any action if MFA token is absent, even if allow condition evaluation would otherwise pass |
| No Deny | Explicit `Deny` when source IP is not in `198.51.100.0/24` (with `aws:ViaAWSService: false` guard) | Blocks all direct API calls from untrusted networks; `ViaAWSService: false` prevents the Deny from blocking legitimate service-to-service calls that originate on behalf of the principal |

---

## Least Privilege Summary

| Policy | Original Blast Radius | Corrected Scope | Key Change |
|---|---|---|---|
| `MedDefenseSIEMLogReader` | All S3 buckets (read/write/delete/admin) + all CloudWatch/Logs (full control) | Single S3 bucket read-only + one Lambda log group write | Action and resource wildcard replaced with exact ARNs and minimum necessary actions |
| `MedDefenseEHRBackupRole` | All S3 buckets (full control) + all KMS keys (full control including key deletion) | One S3 bucket (backup operations only) + one KMS key (encrypt/decrypt only) | Wildcards on both S3 and KMS replaced with specific ARNs and scoped action sets |
| `MedDefenseBreakGlassAdmin` | Unconditional full admin from any IP, any device, no second factor | Full admin gated on MFA + trusted IP range, with explicit Deny for both conditions | Conditions and explicit Deny statements added; emergency capability preserved |

The principle applied consistently across all three policies is: start from the minimum action
set the workload or person genuinely needs, specify the exact resource ARN, and layer conditions
where the principal is human or the action carries high blast radius.

---

## Residual Risk and Operational Notes

**Break-glass IP dependency:** The IP restriction on the break-glass policy assumes that
198.51.100.0/24 is the stable, monitored MedDefense operations network. If that range changes
or if a genuine emergency requires access from outside it (e.g., a senior engineer responding
from home during a disaster), a secondary procedure should exist — such as a pre-approved VPN
endpoint that routes traffic into the trusted range — rather than temporarily removing the IP
condition from the policy. Removing conditions under pressure is a common way break-glass
controls get permanently weakened.

**CloudTrail gap in DR region:** As noted in `aws_environment_observations.md`, CloudTrail is
not enabled in `us-east-2`, which is where clinical backup S3 buckets reside. The corrected
EHR backup policy scopes S3 access to `meddefense-ehr-backup-prod`, but without CloudTrail in
that region, API calls against the bucket will not be audited. Enabling CloudTrail in us-east-2
is a prerequisite for meaningful monitoring of the corrected policy.

**SIEM log reader Lambda execution role scope:** The corrected policy scopes CloudWatch Logs
writes to `/aws/lambda/siem-log-reader`. If the Lambda function is renamed or redeployed to a
new log group, the policy must be updated. Consider using a tag-based condition
(`aws:ResourceTag`) as a supplementary control to allow the policy to follow the function
without manual ARN updates, while still preventing access to log groups owned by other services.

**KMS key rotation for EHR backup:** The corrected EHR backup policy is scoped to the specific
key `mrk-abc123def456`. AWS KMS automatic key rotation (enabled on the key itself, not in the
IAM policy) should be confirmed as active. IAM policy changes do not affect key rotation
settings, but the security team should verify this is enabled separately.

**Break-glass usage auditing:** Even with MFA and IP restrictions, break-glass role assumptions
should trigger an immediate alert to the security team via a CloudTrail → EventBridge →
SNS pipeline. The corrected policy enforces access conditions but cannot substitute for
human review of every break-glass activation.
