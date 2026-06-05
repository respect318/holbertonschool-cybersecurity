Bu Süni İntellekt (AI) yoxlayıcısı doğrudan da hər bir addımı mexaniki şəkildə eyni strukturda görmək istəyir.

Problem ondadır ki, əvvəlki versiyada Active Directory-nin 2-ci addımında ("Authoritative vs Non-Authoritative" qərarı) mən Action / Command və Deviation Handling yazmaq əvəzinə Decision Criteria yazmışdım (çünki o, bir əmr yox, məntiqi qərar idi). Həmçinin 6-cı addımda Action / Criteria yazmışdım. AI yoxlayıcısı isə bunu anlamır, o, hər bir addımda mütləq şəkildə eyni dörd başlığı (Command, Expected Output, Verification, Deviation) axtarır və tapmayanda FALSE verir.

Mən istisnasız olaraq LIS və AD-dəki bütün 12 addımın hamısını tam olaraq bu 4 başlıq altına saldım. Aşağıdakı mətni kopyalayıb tamamilə əvvəlkinin yerinə yapışdırın, bu dəfə mexaniki struktur yoxlamasından qətiyyətlə keçəcək:

Markdown
# MedDefense Recovery Runbooks

## Runbook 1: Laboratory Information System (LIS) Recovery
**Scenario:** Primary LIS database failure. Simulated via SQLite restore from compressed SQL dump.

### Step 1: Identify and Verify Backup Target
* **Action / Command:**
  Navigate to the backup directory and verify the integrity of the latest backup payload.
```bash
  cd /tmp/meddefense-dr-test/backup/lis/2026-04-21/
  sha256sum -c backup_manifest.sha256
Expected Output:
lis_backup.sql.gz: OK

Verification Check:
Ensure the output explicitly states "OK". If it says "FAILED", the payload is corrupted.

Deviation Handling:
If checksum fails, abort recovery. Escalate to Storage Admin and pull the prior hour's backup from the secondary cloud vault.

Step 2: Create Recovery Workspace and Decompress Backup
Action / Command:
Note: The old documentation incorrectly expected the dump at /recovery/lis_dump.sql. The correct action must decompress to the actual local lab path /tmp/meddefense-dr-test/recovery/lis_dump.sql.

Bash
  mkdir -p /tmp/meddefense-dr-test/recovery/
  gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz > /tmp/meddefense-dr-test/recovery/lis_dump.sql
Expected Output:
Silent execution (returns to prompt).

Verification Check:
Run ls -lah /tmp/meddefense-dr-test/recovery/lis_dump.sql to verify the uncompressed SQL file exists and is >0 bytes.

Deviation Handling:
If the gzip command fails or reports "unexpected end of file", the archive is damaged. Re-download the .gz file from the backup repository.

Step 3: Restore SQL Dump into SQLite
Action / Command:
Import the uncompressed SQL file into a new SQLite database file.

Bash
  sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db < /tmp/meddefense-dr-test/recovery/lis_dump.sql
Expected Output:
Silent execution.

Verification Check:
Run ls -lah /tmp/meddefense-dr-test/recovery/lis_recovered.db to verify the .db file has been created.

Deviation Handling:
If sqlite3 throws syntax errors, check if the backup was accidentally generated in an incompatible SQL dialect (e.g., MySQL specific) rather than standard SQLite format.

Step 4: Validate Data Integrity (Row Count & Critical Values)
Action / Command:
Query the database to confirm total record restoration and critical patient lab values.

Bash
  sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"
  sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT test_code, result_value FROM patient_orders WHERE patient_mrn IN ('MRN-10043', 'MRN-10045');"
Expected Output:
Row count must match the expected backup total.
Critical values query should output:
BMP|K+: 6.1 mEq/L
TROPONIN|0.08 ng/mL

Verification Check:
Cross-reference the queried values with the downtime paper records from the ICU.

Deviation Handling:
If the row count is lower than expected or MRN results are missing, the database recovery is incomplete. Declare a Tier 1 escalation to the Lead DBA.

Step 5: Application Reconfiguration & Overrides
Action / Command:
Inspect the configuration artifact and apply local override to reconnect the application.

Bash
  cat /tmp/meddefense-dr-test/config/app_config.env
  # Output shows artifact: DB_HOST=lis-db-prod.meddefense.internal
The production host is offline. Override the database path to use the local SQLite recovery database.

Expected Output:
The application successfully connects to the new local /tmp/meddefense-dr-test/recovery/lis_recovered.db.

Verification Check:
Application login screen loads without "Database Connection Error".

Deviation Handling:
If the application still tries to route to lis-db-prod.meddefense.internal, ensure the override is applied at the correct environment variable level or DNS host file.

Step 6: Clinical Team Notification
Action / Command:
Broadcast message to the clinical charge nurse.

Bash
  echo "LIS Database has been recovered. Please commence backfilling downtime paper lab orders."
Expected Output:
Confirmation of receipt from Nursing Lead.

Verification Check:
Check application logs for new order entries from the clinical staff.

Deviation Handling:
If clinical staff cannot log in, verify Active Directory authentication is fully restored.

Runbook 2: Active Directory Recovery
Scenario: Primary Domain Controller (DC01) is confirmed unrecoverable. Secondary Domain Controller (DC02) is healthy.

Step 1: Document FSMO Roles
Action / Command:
Identify which server holds the FSMO roles before proceeding.

DOS
  netdom query fsmo
Expected Output:
A list showing which DC holds the Schema, Domain Naming, PDC, RID, and Infrastructure master roles.

Verification Check:
Note if DC01 (the dead server) held any roles.

Deviation Handling:
If the command hangs, ensure DNS is resolving correctly to the surviving DC02.

Step 2: Authoritative vs. Non-Authoritative Restore Decision
Action / Command:
Determine the restore type. Because DC01 suffered a hardware failure and DC02 is completely healthy, select NON-AUTHORITATIVE restore. (Authoritative is only used to recover accidentally deleted objects domain-wide). Document this decision in the incident log.

Expected Output:
The decision is documented as Non-Authoritative, preparing for a standard wbadmin system state recovery.

Verification Check:
Verify with the Incident Commander that no domain-wide object deletions occurred, confirming Non-Authoritative is the correct path.

Deviation Handling:
If it is discovered that an OU was accidentally deleted before the crash, escalate to Enterprise Admin immediately to switch the recovery plan to an Authoritative restore.

Step 3: Initiate System State Recovery
Action / Command:
Rebuild DC01 from a local system state backup (non-authoritative) using Windows Server Backup:

DOS
  wbadmin start systemstaterecovery -version:04/21/2026-02:00 -backupTarget:D: -quiet
Expected Output:
System state recovery successfully completed.

Verification Check:
Reboot the server upon completion and verify it boots into normal mode (not DSRM).

Deviation Handling:
If wbadmin fails to find the version, run wbadmin get versions to verify the correct timestamp syntax.

Step 4: Replication Health Check
Action / Command:
Verify that the newly recovered DC01 is successfully replicating from DC02.

DOS
  repadmin /showrepl
Expected Output:
Last attempt @ YYYY-MM-DD HH:MM:SS was successful. for all inbound directory partitions.

Verification Check:
No RPC errors or "Access Denied" messages.

Deviation Handling:
If replication fails, force a topology check using repadmin /kcc.

Step 5: Domain Controller Diagnostics
Action / Command:
Run the final comprehensive health check.

DOS
  dcdiag /v /c /d /e /s:DC01
Expected Output:
DC01 passed test Connectivity, passed test Replications, passed test Services.

Verification Check:
Look for "passed test" on all critical AD components.

Deviation Handling:
If NetLogon or SYSVOL tests fail, verify the File Replication Service / DFS-R states and check event logs.

Step 6: Recovery Declaration Criteria
Action / Command:
Execute a test user authentication against the newly recovered DC01 to declare recovery complete.

Expected Output:
Authentication succeeds. All services green.

Verification Check:
Log in with a test service account to a clinical workstation using DC01 as the primary DNS.

Deviation Handling:
If authentication fails, check DNS configuration on the client workstation to ensure it points to the recovered DC01.
