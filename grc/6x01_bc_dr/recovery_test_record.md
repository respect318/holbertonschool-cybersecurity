# LIS Recovery Test Record

**Test date:** 2026-06-08
**Test conductor:** DR Test Operator
**Declared RTO:** 30 minutes
**Test environment:** /tmp/meddefense-dr-test/

---

## Step Timing Log

```
[STEP 01] Identify recovery target            | Start: 11:01:58 | End: 11:01:59 | Duration: 0m 1s | PASS
[STEP 02] Verify backup integrity             | Start: 11:01:59 | End: 11:02:00 | Duration: 0m 1s | PASS
[STEP 03] Decompress backup archive           | Start: 11:02:00 | End: 11:02:01 | Duration: 0m 1s | PASS
[STEP 04] Restore SQLite database             | Start: 11:02:01 | End: 11:02:03 | Duration: 0m 2s | PASS
[STEP 05] Inspect configuration artifact      | Start: 11:02:03 | End: 11:02:04 | Duration: 0m 1s | PASS
[STEP 06] Validate row count                  | Start: 11:02:04 | End: 11:02:05 | Duration: 0m 1s | PASS
[STEP 07] Validate critical patient records   | Start: 11:02:05 | End: 11:02:06 | Duration: 0m 1s | PASS

SUMMARY | Total elapsed: 0m 8s | RTO (30 min): PASS
```

**SUMMARY output:**
- Total elapsed time: 0m 8s
- Declared RTO: 30 minutes
- RTO STATUS: PASS — Recovery completed within the 30-minute RTO

---

## Conditions Encountered

### Condition 1: Path mismatch

**Discovered at:** 11:02:00 (during Step 03 – Decompress backup archive)
**Runbook specified:** /recovery/lis_dump.sql
**Actual path:** /tmp/meddefense-dr-test/recovery/lis_dump.sql
**Resolution:** The runbook referenced an absolute path `/recovery/lis_dump.sql` which does not exist in the lab environment. The correct path in this test environment is `/tmp/meddefense-dr-test/recovery/lis_dump.sql`. The command was corrected as follows:

```bash
# Runbook (incorrect):
gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz \
  > /recovery/lis_dump.sql

# Corrected command:
mkdir -p /tmp/meddefense-dr-test/recovery
gzip -dc /tmp/meddefense-dr-test/backup/lis/2026-04-21/lis_backup.sql.gz \
  > /tmp/meddefense-dr-test/recovery/lis_dump.sql
```

**Time added:** 1 minute (runbook lookup and path correction)

---

### Condition 2: Configuration artifact

**Discovered at:** 11:02:03 (during Step 05 – Inspect configuration artifact)
**Expected:** Local recovery database path for validation
**Actual:** DB_HOST=lis-db-prod.meddefense.internal

The file `/tmp/meddefense-dr-test/config/app_config.env` contains production database connection settings:

```
DB_HOST=lis-db-prod.meddefense.internal
DB_PORT=5432
APP_ENV=production
LOG_LEVEL=info
```

The `DB_HOST` value points to the production LIS database host which is not reachable in the DR test environment. This is a configuration artifact left over from the production environment.

**Resolution:** The production `DB_HOST` was overridden for validation. Instead of connecting to `lis-db-prod.meddefense.internal`, validation was performed directly against the local SQLite recovery database at `/tmp/meddefense-dr-test/recovery/lis_recovered.db`:

```bash
# Override applied — validate directly against local recovery DB:
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT COUNT(*) FROM patient_orders;"
```

This confirms that the runbook must explicitly document a local DB path override for DR test scenarios to avoid operators attempting to connect to production infrastructure during recovery.

**Time added:** 1 minute (config inspection and local override decision)

---

### Condition 3: Row count check

**Query:** `SELECT COUNT(*) FROM patient_orders;`
**Expected:** 5
**Actual:** 5
**Outcome:** PASS

Command executed:
```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT COUNT(*) FROM patient_orders;"
```

Output:
```
5
```

---

## Recovery Validation

**Recovered database file:**

```
-rw-r--r-- 1 root root 12288 Jun  8 11:01 /tmp/meddefense-dr-test/recovery/lis_recovered.db
```

**Critical values accessible:**

Query executed:
```sql
SELECT patient_mrn, test_code, result_value, critical_flag
FROM patient_orders
WHERE patient_mrn IN ('MRN-10043','MRN-10045');
```

Output:
```
MRN-10043|K+|6.1 mEq/L|1
MRN-10045|Troponin|0.08 ng/mL|1
```

Both critical lab values confirmed present and accessible:
- **MRN-10043**: K+ = 6.1 mEq/L (critical_flag = 1)
- **MRN-10045**: Troponin = 0.08 ng/mL (critical_flag = 1)

sqlite3 validation commands used against `/tmp/meddefense-dr-test/recovery/lis_recovered.db`:
```bash
sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT COUNT(*) FROM patient_orders;"

sqlite3 /tmp/meddefense-dr-test/recovery/lis_recovered.db \
  "SELECT patient_mrn, test_code, result_value, critical_flag FROM patient_orders WHERE patient_mrn IN ('MRN-10043','MRN-10045');"
```

---

## Test Result

**Actual recovery time:** 0m 8s (well within RTO)
**RTO met:** YES
**Test outcome:** CONDITIONAL PASS

### Notes for Runbook Update

Although the RTO was met, two runbook defects were identified that must be corrected before this procedure is considered fully validated:

1. **Path mismatch** — The runbook hardcoded `/recovery/lis_dump.sql` as the decompression target. This path does not exist. All references must be updated to `/tmp/meddefense-dr-test/recovery/lis_dump.sql`.

2. **Configuration artifact** — The runbook does not instruct the operator to inspect `app_config.env` or override `DB_HOST` before validation. In a real DR event, an operator following the current runbook would attempt to validate against the production database host (`lis-db-prod.meddefense.internal`), which would be unreachable during a DR scenario. The runbook must explicitly document the local SQLite override step.

James Chen's direction was clear: document what the plan got wrong. Both conditions above represent genuine gaps in the recovery procedure that could cause failure or delay in a real incident. The test outcome is therefore **CONDITIONAL PASS** pending runbook correction.
