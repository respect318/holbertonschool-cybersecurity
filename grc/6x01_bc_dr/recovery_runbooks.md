# MedDefense Recovery Runbooks

## Runbook 1: Laboratory Information System (LIS) Recovery
Scenario: Primary LIS database failure. Simulated via SQLite restore from compressed SQL dump.

### Step 1: Identify and Verify Backup Target
**Command:**
`cd /tmp/meddefense-dr-test/backup/lis/2026-04-21/ && sha256sum -c backup_manifest.sha256`

**Expected Output:**
lis_backup.sql.gz: OK

**Verification:**
Ensure the output explicitly states "OK". If it says "FAILED", the payload is corrupted.

**Deviation Handling:**
If checksum fails, abort recovery. Escalate to Storage Admin and pull the prior hour's backup.

### Step 2: Create Recovery Workspace and Decompress Backup
**Command:**
`mkdir -p /tmp/meddefense-dr-test/recovery/ && gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz > /tmp/meddefense-dr-test/recovery/lis_dump.sql`

**Expected Output:**
Silent execution. Returns to prompt.

**Verification:**
Run `ls -lah /tmp/meddefense-dr-test/recovery/lis_dump.sql` to verify the uncompressed SQL file exists and is larger than 0 bytes. Note: We use this local path instead of the old /recovery/lis_dump.sql path.

**Deviation Handling:**
If the gzip command fails or reports unexpected end of file, the archive is damaged. Re-download the backup.

### Step 3: Restore SQL Dump into SQLite
**Command:**
`sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db < /tmp/meddefense-dr-test/recovery/lis_dump.sql`

**Expected Output:**
Silent execution. Returns to prompt.

**Verification:**
Run `ls -lah /tmp/meddefense-dr-test/recovery/lis_recovered.db` to verify the .db file has been successfully created.

**Deviation Handling:**
If sqlite3 throws syntax errors, check if the backup was generated in an incompatible SQL dialect.

### Step 4: Validate Data Integrity
**Command:**
`sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"` and `sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT test_code, result_value FROM patient_orders WHERE patient_mrn IN ('MRN-10043', 'MRN-10045');"`

**Expected Output:**
Critical values output shows: K+: 6.1 mEq/L and 0.08 ng/mL. Row count matches expected total.

**Verification:**
Cross-reference the queried values with the downtime paper records from the ICU.

**Deviation Handling:**
If the row count is lower than expected or MRN results are missing, declare a Tier 1 escalation to the Lead DBA.

### Step 5: Application Reconfiguration and Overrides
**Command:**
`cat /tmp/meddefense-dr-test/config/app_config.env`

**Expected Output:**
Output shows the artifact: DB_HOST=lis-db-prod.meddefense.internal

**Verification:**
Verify that local override to /tmp/meddefense-dr-test/recovery/lis_recovered.db is applied and the application login screen loads without Database Connection Error.

**Deviation Handling:**
If the application still tries to route to the old host, ensure the override is applied at the correct environment variable level.

### Step 6: Clinical Team Notification
**Command:**
Broadcast message: "LIS Database has been recovered. Please commence backfilling downtime paper lab orders."

**Expected Output:**
Confirmation of receipt from Nursing Lead.

**Verification:**
Check application logs for new order entries from the clinical staff.

**Deviation Handling:**
If clinical staff cannot log in, verify Active Directory authentication is fully restored.

---

## Runbook 2: Active Directory Recovery
Scenario: Primary Domain Controller (DC01) is confirmed unrecoverable. Secondary Domain Controller (DC02) is healthy.

### Step 1: Document FSMO Roles
**Command:**
`netdom query fsmo`

**Expected Output:**
A list showing which DC holds the Schema, Domain Naming, PDC, RID, and Infrastructure master roles.

**Verification:**
Note if DC01 (the dead server) held any roles.

**Deviation Handling:**
If the command hangs, ensure DNS is resolving correctly to the surviving DC02.

### Step 2: Authoritative vs Non-Authoritative Restore Decision
**Command:**
Document the decision in the incident log: Select NON-AUTHORITATIVE restore because DC01 suffered a hardware failure and DC02 is healthy. Authoritative is only used to recover accidentally deleted objects domain-wide.

**Expected Output:**
The decision is documented as Non-Authoritative.

**Verification:**
Verify with the Incident Commander that no domain-wide object deletions occurred.

**Deviation Handling:**
If it is discovered that an OU was accidentally deleted before the crash, escalate to switch to an Authoritative restore.

### Step 3: Initiate System State Recovery
**Command:**
`wbadmin start systemstaterecovery -version:04/21/2026-02:00 -backupTarget:D: -quiet`

**Expected Output:**
System state recovery successfully completed.

**Verification:**
Reboot the server upon completion and verify it boots into normal mode.

**Deviation Handling:**
If wbadmin fails to find the version, run `wbadmin get versions` to verify the correct timestamp syntax.

### Step 4: Replication Health Check
**Command:**
`repadmin /showrepl`

**Expected Output:**
Last attempt was successful for all inbound directory partitions.

**Verification:**
No RPC errors or Access Denied messages.

**Deviation Handling:**
If replication fails, force a topology check using `repadmin /kcc`.

### Step 5: Domain Controller Diagnostics
**Command:**
`dcdiag /v /c /d /e /s:DC01`

**Expected Output:**
DC01 passed test Connectivity, passed test Replications, passed test Services.

**Verification:**
Look for passed test on all critical AD components.

**Deviation Handling:**
If NetLogon or SYSVOL tests fail, verify the File Replication Service states.

### Step 6: Recovery Declaration Criteria
**Command:**
Execute a test user authentication against the newly recovered DC01.

**Expected Output:**
Authentication succeeds. All services green.

**Verification:**
Log in with a test service account to a clinical workstation using DC01.

**Deviation Handling:**
If authentication fails, check DNS configuration on the client workstation.
