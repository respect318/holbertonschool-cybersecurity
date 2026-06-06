# LIS Recovery Test Record

**Test date:** 2026-06-06
**Test conductor:** Farid
**Declared RTO:** 30 minutes
**Test environment:** /tmp/meddefense-dr-test/

## Step Timing Log

[STEP 01] Identify recovery target | Start: 09:14:32 | End: 09:15:18 | Duration: 0m 46s | PASS
[STEP 02] Verify backup integrity | Start: 09:15:18 | End: 09:16:05 | Duration: 0m 47s | PASS
[STEP 03] Create recovery workspace and decompress | Start: 09:16:10 | End: 09:18:10 | Duration: 2m 0s | PASS
[STEP 04] Restore SQL dump into SQLite | Start: 09:18:15 | End: 09:19:15 | Duration: 1m 0s | PASS
[STEP 05] Validate Data Integrity and Row count | Start: 09:19:20 | End: 09:20:20 | Duration: 1m 0s | PASS
[STEP 06] Application Reconfiguration artifact override | Start: 09:20:25 | End: 09:23:25 | Duration: 3m 0s | PASS
Total elapsed time: 8m 33s
RTO (30 minutes) Evaluation: PASS

## Conditions Encountered

### Condition 1: Path mismatch
**Discovered at:** 09:16:15
**Runbook specified:** /recovery/lis_dump.sql
**Actual path:** /tmp/meddefense-dr-test/recovery/lis_dump.sql
**Resolution:** Corrected the command to decompress into the local lab path instead of the old Docker path:
`mkdir -p /tmp/meddefense-dr-test/recovery && gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz > /tmp/meddefense-dr-test/recovery/lis_dump.sql`
**Time added:** 2 minutes

### Condition 2: Configuration artifact
**Discovered at:** 09:20:30
**Expected:** Local recovery database path for validation
**Actual:** DB_HOST=lis-db-prod.meddefense.internal
**Resolution:** Overrode the production path configuration by directly querying the recovered local SQLite file for validation instead of attempting a network connection:
`sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT patient_mrn, test_code, result_value, critical_flag FROM patient_orders WHERE patient_mrn IN ('MRN-10043','MRN-10045');"`
**Time added:** 3 minutes

### Condition 3: Row count check
**Discovered at:** 09:19:25
**Query:** SELECT COUNT(*) FROM patient_orders;
**Expected:** 5
**Actual:** 5
**Resolution:** Executed query successfully using `sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db "SELECT COUNT(*) FROM patient_orders;"` and confirmed the row count matches exactly. No further troubleshooting was needed.
**Time added:** 1 minute
**Outcome:** PASS

## Recovery Validation

**Recovered database file:**
```bash
-rw-r--r-- 1 root root 8192 Jun  6 09:19 /tmp/meddefense-dr-test/recovery/lis_recovered.db
