# MedDefense Vault PAM Lab

This document analyzes the HashiCorp Vault database secrets engine deployment at MedDefense,
demonstrates dynamic credential issuance and revocation using lab evidence, explains how
TTL-based credentials eliminate the static service account risk that enabled the `svc_epic_int`
lateral movement path, and recommends a prioritized migration plan for the highest-risk
service accounts in the environment.

---

## Lab Evidence Summary

The lab configures Vault's database secrets engine against the `meddefense-lis` MySQL database
(the Laboratory Information System). Two roles are defined:

| Role | Default TTL | Max TTL | Access Level |
|---|---|---|---|
| `lis-readonly` | 1 hour | 4 hours | `SELECT` on `lis_production.*` |
| `lis-readwrite` | 15 minutes | 1 hour | Read-write on `lis_production` |

The shorter TTL on the read-write role reflects the principle that higher-privilege credentials
should have a smaller validity window. A read-write credential that can modify patient records
is valid for only 15 minutes; a read-only reporting credential is valid for 1 hour.

Vault connects to the database using a dedicated manager account (`vault_manager`) whose
credentials are stored in Vault's encrypted storage, not in any application configuration file.
Applications never see or store the manager password; they only ever receive the short-lived
dynamic credentials Vault issues on their behalf.

---

## Dynamic Credential Demonstration

### Read-Only Credential

When an application requests a read-only credential, Vault creates a unique database user on
demand and returns the following:

```text
lease_id:        database/creds/lis-readonly/3s9fXJd7aMedDefense001
lease_duration:  1h
lease_renewable: true
username:        v-lis-readonly-H7s9k2
password:        A1q7-z9R2-MedD-Read
```

Vault immediately creates the user `v-lis-readonly-H7s9k2` in MySQL and grants it
`SELECT ON lis_production.*` only. A MySQL session confirms the exact grants in force:

```text
GRANT SELECT ON `lis_production`.* TO `v-lis-readonly-H7s9k2`@`%`
```

No other permission is granted. The username itself is unique to this issuance event —
two applications requesting the same role receive two different usernames, so actions in
the database audit log are traceable to the specific request, not to a shared service account.

### Read-Write Credential

```text
lease_id:        database/creds/lis-readwrite/9kLmVaultRw002
lease_duration:  15m
lease_renewable: true
username:        v-lis-readwrite-Q2p8
password:        T7mP-write-4nQ
```

The read-write credential is issued with a 15-minute TTL. After 15 minutes, Vault
automatically issues a `DROP USER` to MySQL for `v-lis-readwrite-Q2p8` and the credential
ceases to function, with no manual action required.

---

## Lease and TTL Evidence

Every credential Vault issues is tracked as a **lease**. A lease has three key properties:

- **`lease_id`** — a unique identifier that ties the issued credential back to the Vault audit
  log entry. The IDs in this lab are
  `database/creds/lis-readonly/3s9fXJd7aMedDefense001` and
  `database/creds/lis-readwrite/9kLmVaultRw002`.
- **`lease_duration` (TTL)** — the maximum time the credential is valid. When the TTL expires,
  Vault calls the database plugin's revocation function, which executes `DROP USER` on the
  MySQL server. The credential becomes invalid at the database level automatically.
- **`lease_renewable`** — whether an application can request a TTL extension before expiry,
  subject to `max_ttl`. Renewals are also recorded in the Vault audit log, creating a full
  lifecycle trail.

The active lease can be enumerated via:

```text
$ vault list sys/leases/lookup/database/creds/lis-readonly/
Keys
----
3s9fXJd7aMedDefense001
```

This means the security team can at any time list every live credential Vault has issued for
a given role, see when each expires, and decide whether to allow natural expiry or force
immediate revocation.

**TTL and blast radius:** If an attacker extracts the read-write credential
`v-lis-readwrite-Q2p8 / T7mP-write-4nQ` from application memory (the same technique that
exposed `svc_epic_int`), the stolen credential is valid for at most 15 minutes from issuance,
not the three years that `svc_epic_int`'s password remained unchanged. The attacker's window
of exploitation is bounded by clock time rather than by whether a human notices the compromise
and manually resets a password.

---

## Revocation Evidence

Vault supports immediate forced revocation via `vault lease revoke`:

```text
$ vault lease revoke database/creds/lis-readwrite/9kLmVaultRw002
All revocation operations queued successfully!
```

The effect is immediate and verifiable at the database level:

```text
$ mysql -uv-lis-readwrite-Q2p8 -pT7mP-write-4nQ lis_production -e "SELECT USER();"
ERROR 1045 (28000): Access denied for user 'v-lis-readwrite-Q2p8'@'10.0.3.5' (using password: YES)
```

The user no longer exists in MySQL:

```text
$ mysql -uroot -e "SELECT user, host FROM mysql.user WHERE user LIKE 'v-lis%';"
+-----------------------+------+
| v-lis-readonly-H7s9k2 | %    |
+-----------------------+------+
```

Only the read-only credential remains active. `v-lis-readwrite-Q2p8` has been fully removed
from the database engine.

**Operational significance:** When a security team detects a compromised application, the
response is a single `vault lease revoke` command. There is no need to locate configuration
files containing passwords, coordinate with the DBA team to reset a shared service account
password, or risk revoking access for other applications sharing the same static credential.
Each Vault-issued credential is unique and can be revoked in isolation without affecting any
other workload.

**Revocation on off-boarding:** When a service is decommissioned, running
`vault lease revoke -prefix database/creds/lis-readwrite/` revokes every outstanding
read-write credential simultaneously. There is no equivalent of the `svc_epic_int` situation
where an account belonging to a decommissioned integration remained active in Active Directory
for over three years after its last legitimate use.

---

## Static vs Dynamic Credential Comparison

| Dimension | Static credential (`svc_epic_int` model) | Dynamic credential (Vault model) |
|---|---|---|
| **credential lifetime** | Indefinite; password unchanged for 3+ years in the MedDefense incident | Bounded by TTL; read-write TTL is 15 minutes, read-only is 1 hour; credential auto-expires |
| **rotation** | Manual; requires a change ticket, DBA coordination, and application config update; in practice never rotated | Automatic; Vault creates a new unique credential on every request; no human action required |
| **blast radius if stolen** | Attacker retains access until the password is manually reset; in the incident, `svc_epic_int` was usable for 3 hours of lateral movement and the account was 1,156 days old | Attacker retains access only until TTL expiry or until a security team issues `vault lease revoke`; maximum window equals the TTL |
| **audit trail** | Shared username (`svc_epic_int`) appears in logs; impossible to attribute actions to a specific application or request | Every credential has a unique username and `lease_id`; all issuance, renewal, and revocation events are written to the Vault audit log with timestamps and requesting identity |
| **off-boarding** | Account must be manually identified and disabled in every system (Active Directory, Epic, PACS, etc.); off-boarding checklists can be missed, as occurred in the MedDefense incident | Disabling the Vault auth method or the application's Vault role immediately stops new credential issuance; existing credentials expire automatically at TTL; `vault lease revoke -prefix` forces immediate revocation of all outstanding leases |

---

## Migration Recommendation

The following service accounts are prioritized for PAM migration based on privilege level,
dormancy, and proximity to the incident identity path. Data sourced from
`pam_migration_candidates.csv`.

### Priority 1 — Critical (Immediate)

**`svc_epic_int`** — Static dormant Domain Admin service account. This account directly
matches the incident lateral movement path. It has not been used in 1,156 days, has no
identified current business function, and carries Domain Admin privileges. It should be
disabled in Active Directory immediately pending investigation. If any remaining integration
depends on it, that integration must be re-architected to use Vault-issued dynamic credentials
scoped to the minimum required database or API permissions. Domain Admin privilege is never
appropriate for a service account performing application integration and must not be replicated
in the replacement design.

**`svc_helpdesk`** — Vendor-granted Domain Admin service account for ticket routing
automation. A ticket routing function has no legitimate need for Domain Admin privilege.
This account should be migrated to Vault-issued credentials scoped to the specific APIs or
database tables used by the helpdesk automation. Domain Admin access should be revoked
immediately regardless of the Vault migration timeline.

### Priority 2 — High

**`svc_backup`** — Nightly backup automation with Domain Admin privilege. Backup functions
require broad read access to data, but Domain Admin is wider than necessary. The account
should be migrated to Vault with a role that grants access only to the backup target paths
and storage locations. If the backup software requires AD credentials rather than database
credentials, Vault's Active Directory secrets engine can issue short-lived AD passwords on
the same TTL model.

### Priority 3 — Medium

**`svc_monitoring`** — Metrics collection with Server Admins membership. Monitoring should
use a read-only scoped credential limited to the metrics endpoints it polls. Migrate to Vault
with a `lis-readonly`-style role.

**`svc_av_mgmt`** — EDR management with Workstation Admins membership. Evaluate whether
this function can be served by the EDR vendor's own API token model with short-lived tokens.
If it requires AD credentials, use Vault's AD secrets engine with just-in-time (JIT) issuance
and a short TTL.

### Migration Approach

For each account, the migration sequence is:

1. Identify the exact APIs, database tables, and file paths the service requires — not what
   the current account can access, but what it provably uses.
2. Create a Vault role with a `default_ttl` of 15 minutes for write access or 1 hour for
   read-only access, scoped to the identified resources only.
3. Update the application to request credentials from Vault at startup rather than reading
   from a configuration file.
4. Disable the static service account in Active Directory.
5. Confirm via database and AD audit logs that the static account is no longer used.
6. Delete the static account after a 30-day observation window.

Vault's audit log will record every credential request, renewal, and revocation, giving the
security team a complete, attributable record that was absent with the shared static accounts.
