# LIS Recovery Gap Analysis

## Test Summary Table

| Metric | Result |
| :--- | :--- |
| **Declared RTO** | 30 minutes |
| **Actual recovery time** | 8 minutes 33 seconds |
| **Delta in minutes** | 21 minutes 27 seconds (Faster than RTO) |
| **Overall test result** | CONDITIONAL PASS |

## Condition Analysis

### Condition 1: Path mismatch
* **Category:** Runbook Error
* **Root cause:** The legacy runbook was written for a Docker-based architecture and specified `/recovery/lis_dump.sql`, but the current environment uses a local SQLite path at `/tmp/meddefense-dr-test/recovery/lis_dump.sql`.
* **Patient safety consequence:** A 2-minute delay in restoring the LIS delays the processing of STAT labs. According to the BIA, delays beyond 15 minutes in returning critical values (e.g., Potassium, Troponin) can lead to missed diagnoses of life-threatening events. Every minute spent troubleshooting paths directly postpones critical bedside clinical decisions.
* **Time added:** 2 minutes.

### Condition 2: Configuration artifact
* **Category:** Configuration Drift
* **Root cause:** The `app_config.env` file statically hardcoded the production database hostname (`DB_HOST=lis-db-prod.meddefense.internal`) instead of dynamically adapting to a local recovery variable during an incident.
* **Patient safety consequence:** A 3-minute delay caused by application connection failures prevents nurses and physicians from viewing restored historical lab results, forcing reliance on delayed paper records. This increases the risk of redundant blood draws, medication dosing errors, and delayed emergency care.
* **Time added:** 3 minutes.

### Condition 3: Row count check
* **Category:** Documentation Gap
* **Root cause:** While the row count returned the expected results (5 rows), the original runbook lacked the explicit SQLite query syntax for the validation step, relying on DBA tribal knowledge to formulate the query during the incident.
* **Patient safety consequence:** Although minimal time was lost during this specific test (1 minute added for execution), lacking exact query commands risks severe delays if the primary DBA is unavailable. This could potentially push the recovery past the 30-minute RTO, leaving the ICU without lab capacities during mass casualty incidents.
* **Time added:** 1 minute.

## Runbook Deficiencies

* Step 2 specifies `gzip -dc ... > /recovery/lis_dump.sql`, but the lab recovery environment actually stages the decompressed file at `/tmp/meddefense-dr-test/recovery/lis_dump.sql`.
* Step 5 assumes the application will automatically connect to the restored database, but the environment configuration still points to `DB_HOST=lis-db-prod.meddefense.internal`, requiring a manual override to point the application to the local SQLite path.
* Step 4 lacked the precise `sqlite3` command strings for data validation, assuming the incident responder would know the exact schema and syntax for the `patient_orders` table.

## Revised RTO

Recommendation: The 30-minute RTO must be maintained. It is honestly achievable after corrections, but should not be artificially lowered based solely on this test.

Evidence and Justification: The actual recovery time was 8 minutes and 33 seconds. The runbook deviations (path mismatch, configuration artifact, missing query syntax) added 6 minutes of troubleshooting. While correcting these deficiencies will mathematically reduce the test recovery time to under 3 minutes, this test utilized a simulated, lightweight SQLite database. In a real-world disaster scenario involving the full production database payload, network latency, and server provisioning, the data restoration phase will take significantly longer. Therefore, the 30-minute RTO remains an honest, evidence-based target. It is fully achievable with the updated runbook, providing a realistic buffer for production data volumes while still meeting the clinical BIA safety requirements.

## Updated LIS Recovery Runbook

### Step 1: Identify and Verify Backup Target
* **Command:** `cd /tmp/meddefense-dr-test/backup/lis/2026-04-21/ && sha256sum -c backup_manifest.sha256`
* **Expected Output:** `lis_backup.sql.gz: OK`
* **Verification:** Ensure the output explicitly states "OK". 
* **Deviation Handling:** If checksum fails, abort recovery and pull the prior hour's backup.

### Step 2: [UPDATED] Create Recovery Workspace and Decompress Backup
* **Command:** `mkdir -p /tmp/meddefense-dr-test/recovery/ && gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz > /tmp/meddefense-dr-test/recovery/lis_dump.sql`
* **Expected Output:** Silent execution.
* **Verification:** Run `ls -lah /tmp/meddefense-dr-test/recovery/lis_dump.sql` to verify the uncompressed SQL file exists. Note: This correctly utilizes the local lab path, fixing the previous `/recovery/` path mismatch.
* **Deviation Handling:** If the gzip command fails, the archive is damaged. Re-download the backup.

### Step 3: Restore SQL Dump into SQLite
* **Command:** `sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db < /tmp/meddefense-dr-test/recovery/lis_dump.sql`
* **Expected Output:** Silent execution.
* **Verification:** Run `ls -lah /tmp/meddefense-dr-test/recovery/lis_recovered.db`.
* **Deviation Handling:** If sqlite3 throws syntax errors, verify backup SQL dialect compatibility.

### Step 4: [UPDATED] Validate Data Integrity
* **Command:** `sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"` followed by `sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT patient_mrn, test_code, result_value, critical_flag FROM patient_orders WHERE patient_mrn IN ('MRN-10043','MRN-10045');"`
* **Expected Output:** Row count returns `5`. Critical values show `K+: 6.1 mEq/L` and `0.08 ng/mL`.
* **Verification:** Cross-reference the exact row counts with the ICU records. This explicit command eliminates the documentation gap for query syntax.
* **Deviation Handling:** If the row count is lower than expected, declare a Tier 1 escalation.

### Step 5: [UPDATED] Application Reconfiguration and Overrides
* **Command:** Query `/tmp/meddefense-dr-test/config/app_config.env` and apply the local SQLite recovery database path to bypass the hardcoded `DB_HOST=lis-db-prod.meddefense.internal` artifact.
* **Expected Output:** The application routes to the local `/tmp/meddefense-dr-test/recovery/lis_recovered.db`.
* **Verification:** Application login screen loads without Database Connection Error.
* **Deviation Handling:** If the application still tries to route to the old host, ensure the override is applied at the environment variable level.

### Step 6: Clinical Team Notification
* **Command:** Broadcast message: "LIS Database has been recovered. Please commence backfilling downtime paper lab orders."
* **Expected Output:** Confirmation of receipt from Nursing Lead.
* **Verification:** Check application logs for new order entries.
* **Deviation Handling:** Verify Active Directory authentication if logins fail.

## Remediation Roadmap

| Priority | Action | Owner Role | Target Completion | Success Criterion |
| :--- | :--- | :--- | :--- | :--- |
| **High** | Update all LIS runbooks with the exact local staging paths. | Lead DBA | 1 Week | Runbook officially published in the IT portal without legacy paths. |
| **High** | Implement dynamic environment variables in `app_config.env` for DR scenarios. | Infrastructure Architect | 2 Weeks | Application successfully fails over to local SQLite path without manual DNS overrides. |
| **Medium** | Add explicit SQL validation queries (row count, critical values) to documentation. | IT Documentation Specialist | 1 Week | Validation commands are directly copy-pasteable by any IT responder. |
| **Medium** | Conduct a tabletop exercise with the newly updated LIS runbook. | Disaster Recovery Coordinator | 1 Month | Junior system admin successfully recovers the database in under 10 minutes. |
| **Low** | Automate the decompression and SQLite import steps via a bash script. | Systems Engineer | 2 Months | A single script executes Steps 1-3 automatically, removing manual typo risks. |
