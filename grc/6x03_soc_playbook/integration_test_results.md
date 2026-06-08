# Integration Test Results
**Date:** 2026-06-08  
**Tester:** SOC Automation Lab – 6x03  
**Environment:** Ubuntu 24 · Python 3.12 · SQLite (cases.db)

---

## Pre-Test Reset

```bash
rm -f cases.db isolation_queue.json
mkdir -p alerts/
cp materials/alerts/phishing/*.json alerts/
cp materials/alerts/credential/*.json alerts/
cp materials/threat_intel/ioc_feed.json ./ioc_feed.json
cp materials/iam/privileged_accounts.json ./privileged_accounts.json
```

---

## Test 1 — ALT-20260428-001: Known Malicious Sender (Phishing)

**Scenario:** Email from `billing@meddefense-secure.net` (IP `198.51.100.42`).  
Both the sender IP and domain are listed in `ioc_feed.json` as BLOCK-level IOCs  
(confidence 95 and 97 respectively).

**Command executed:**
```bash
python3 playbook_phishing_triage.py alerts/ALT-20260428-001.json
```

**Actual stdout:**
```
[2026-06-08T06:59:03Z] PHISHING TRIAGE PLAYBOOK
Alert      : ALT-20260428-001
Rule       : phishing_email_suspicious_sender
IOCs       : 3 extracted, 2 enriched, 1 dedup skipped
  198.51.100.42             ipv4     BLOCK        score=95     (cobalt_strike, beacon)
  meddefense-secure.net     domain   BLOCK        score=97     (phishing, credential_harvest, impersonation)
Verdict    : ESCALATE
Case       : CASE-20260608-001  Severity: Critical  Status: escalated
Action     : SOC notification queued for on-call analyst
```

**Case created:** `CASE-20260608-001`

```bash
python3 case_manager.py get CASE-20260608-001
```
```json
{
  "case_id": "CASE-20260608-001",
  "alert_id": "ALT-20260428-001",
  "playbook": "phishing_triage",
  "verdict": "ESCALATE",
  "severity": "Critical",
  "status": "escalated",
  "created_at": "2026-06-08T06:59:03.731339+00:00"
}
```

| Field           | Expected     | Actual       |
|-----------------|--------------|--------------|
| Verdict         | ESCALATE     | ESCALATE     |
| Case Severity   | Critical     | Critical     |
| Case Status     | escalated    | escalated    |
| Isolation Queue | no           | no           |

**Result: ✅ PASS**

---

## Test 2 — ALT-20260428-002: Unknown External Sender (Phishing)

**Scenario:** Newsletter from `newsletter@external-health-news.com` (IP `203.0.113.5`).  
Neither the IP nor domain appear in the malicious or benign lists — both resolve to INVESTIGATE.

**Command executed:**
```bash
python3 playbook_phishing_triage.py alerts/ALT-20260428-002.json
```

**Actual stdout:**
```
[2026-06-08T06:59:06Z] PHISHING TRIAGE PLAYBOOK
Alert      : ALT-20260428-002
Rule       : phishing_email_suspicious_sender
IOCs       : 2 extracted, 2 enriched, 0 dedup skipped
  203.0.113.5               ipv4     INVESTIGATE               (unknown_external)
  external-health-news.com  domain   INVESTIGATE               (unknown_external)
Verdict    : REVIEW
Case       : CASE-20260608-002  Severity: High  Status: open
Action     : Alert queued for analyst review
```

**Case created:** `CASE-20260608-002`

```bash
python3 case_manager.py get CASE-20260608-002
```
```json
{
  "case_id": "CASE-20260608-002",
  "alert_id": "ALT-20260428-002",
  "playbook": "phishing_triage",
  "verdict": "REVIEW",
  "severity": "High",
  "status": "open",
  "created_at": "2026-06-08T06:59:06.164400+00:00"
}
```

| Field           | Expected | Actual   |
|-----------------|----------|----------|
| Verdict         | REVIEW   | REVIEW   |
| Case Severity   | High     | High     |
| Case Status     | open     | open     |
| Isolation Queue | no       | no       |

**Result: ✅ PASS**

---

## Test 3 — ALT-20260428-003: Internal Sender (Phishing)

**Scenario:** Internal maintenance notice from `it-notices@meddefense.internal` (IP `10.0.1.25`).  
Both the IP (RFC-1918 private range `10.0.0.0/8`) and domain (`meddefense.internal`)  
resolve to ALLOW. No body URLs present.

**Command executed:**
```bash
python3 playbook_phishing_triage.py alerts/ALT-20260428-003.json
```

**Actual stdout:**
```
[2026-06-08T06:59:09Z] PHISHING TRIAGE PLAYBOOK
Alert      : ALT-20260428-003
Rule       : phishing_email_suspicious_sender
IOCs       : 2 extracted, 2 enriched, 0 dedup skipped
  10.0.1.25                 ipv4     ALLOW                     (internal)
  meddefense.internal       domain   ALLOW                     (-)
Verdict    : CLOSE
Case       : CASE-20260608-003  Severity: Low  Status: closed
Action     : Case closed – resolution: no_indicators_of_compromise
```

**Case created:** `CASE-20260608-003`

```bash
python3 case_manager.py get CASE-20260608-003
```
```json
{
  "case_id": "CASE-20260608-003",
  "alert_id": "ALT-20260428-003",
  "playbook": "phishing_triage",
  "verdict": "CLOSE",
  "severity": "Low",
  "status": "closed",
  "created_at": "2026-06-08T06:59:09.171267+00:00"
}
```

| Field           | Expected | Actual   |
|-----------------|----------|----------|
| Verdict         | CLOSE    | CLOSE    |
| Case Severity   | Low      | Low      |
| Case Status     | closed   | closed   |
| Isolation Queue | no       | no       |

**Result: ✅ PASS**

---

## Test 4 — ALT-20260428-007: LSASS Dump from Known C2 IP (Credential Exposure)

**Scenario:** `svhost32.exe` dumped LSASS on `WST-WS-031`. Source IP `198.51.100.42` is a  
BLOCK-confidence C2. Username `svc_helpdesk` is in the Domain Admins list.  
Decision matrix: BLOCK IP → Critical / escalated / isolation queue = yes.

**Command executed:**
```bash
python3 playbook_credential_exposure.py alerts/ALT-20260428-007.json
```

**Actual stdout:**
```
[2026-06-08T06:59:13Z] CREDENTIAL EXPOSURE PLAYBOOK
Alert      : ALT-20260428-007
Host       : WST-WS-031
User       : svc_helpdesk  Privilege: Domain Admin
Source IP  : 198.51.100.42  Verdict: BLOCK  Score: 95
MITRE      : T1003.001  OS Credential Dumping: LSASS Memory
Case       : CASE-20260608-004  Severity: Critical  Status: escalated
Action     : Host written to isolation_queue.json for analyst authorization
```

**Case created:** `CASE-20260608-004`

```bash
python3 case_manager.py get CASE-20260608-004
```
```json
{
  "case_id": "CASE-20260608-004",
  "alert_id": "ALT-20260428-007",
  "playbook": "credential_exposure",
  "verdict": "ESCALATE",
  "severity": "Critical",
  "status": "escalated",
  "created_at": "2026-06-08T06:59:13.056905+00:00"
}
```

| Field           | Expected | Actual        |
|-----------------|----------|---------------|
| Verdict         | ESCALATE | ESCALATE      |
| Case Severity   | Critical | Critical      |
| Case Status     | escalated| escalated     |
| Isolation Queue | yes      | yes (WST-WS-031 written) |

**Result: ✅ PASS**

---

## Test 5 — ALT-20260428-009: Pass-the-Hash Lateral Movement, Standard User (Credential Exposure)

**Scenario:** `cmd.exe` lateral movement via `net use` on `WST-WS-041`. Source IP `192.168.10.55`  
is an internal RFC-1918 address (ALLOW). Username `k.nguyen` is not in any privileged group.  
Decision matrix: ALLOW IP + non-privileged → Medium / open / no isolation.

**Command executed:**
```bash
python3 playbook_credential_exposure.py alerts/ALT-20260428-009.json
```

**Actual stdout:**
```
[2026-06-08T06:59:16Z] CREDENTIAL EXPOSURE PLAYBOOK
Alert      : ALT-20260428-009
Host       : WST-WS-041
User       : k.nguyen  Privilege: Standard User
Source IP  : 192.168.10.55  Verdict: ALLOW  Score: 0
MITRE      : T1550.002  Use Alternate Authentication Material: Pass the Hash
Case       : CASE-20260608-005  Severity: Medium  Status: open
Action     : Manual analyst review required; no isolation queue entry
```

**Case created:** `CASE-20260608-005`

```bash
python3 case_manager.py get CASE-20260608-005
```
```json
{
  "case_id": "CASE-20260608-005",
  "alert_id": "ALT-20260428-009",
  "playbook": "credential_exposure",
  "verdict": "MANUAL_REVIEW",
  "severity": "Medium",
  "status": "open",
  "created_at": "2026-06-08T06:59:16.799328+00:00"
}
```

| Field           | Expected      | Actual        |
|-----------------|---------------|---------------|
| Verdict         | MANUAL_REVIEW | MANUAL_REVIEW |
| Case Severity   | Medium        | Medium        |
| Case Status     | open          | open          |
| Isolation Queue | no            | no            |

**Result: ✅ PASS**

---

## Final State Verification

### `python3 case_manager.py list`

```
CASE ID              ALERT ID               PLAYBOOK                     VERDICT      SEVERITY     STATUS      
--------------------------------------------------------------------------------------------------------------
CASE-20260608-001    ALT-20260428-001       phishing_triage              ESCALATE     Critical     escalated   
CASE-20260608-002    ALT-20260428-002       phishing_triage              REVIEW       High         open        
CASE-20260608-003    ALT-20260428-003       phishing_triage              CLOSE        Low          closed      
CASE-20260608-004    ALT-20260428-007       credential_exposure          ESCALATE     Critical     escalated   
CASE-20260608-005    ALT-20260428-009       credential_exposure          MANUAL_REVIEW Medium       open        
```

### `cat isolation_queue.json`

```json
[
  {
    "host": "WST-WS-031",
    "alert_id": "ALT-20260428-007",
    "reason": "IP verdict=BLOCK, privilege=Domain Admin",
    "queued_at": "2026-06-08T06:59:13.062182+00:00",
    "status": "pending_analyst_authorization"
  }
]
```

---

## Summary

| Alert ID          | Playbook             | Expected Verdict | Actual Verdict | Expected Severity | Actual Severity | Isolation Expected | Isolation Actual | Result |
|-------------------|----------------------|------------------|----------------|-------------------|-----------------|--------------------|------------------|--------|
| ALT-20260428-001  | phishing_triage      | ESCALATE         | ESCALATE       | Critical          | Critical        | no                 | no               | ✅ PASS |
| ALT-20260428-002  | phishing_triage      | REVIEW           | REVIEW         | High              | High            | no                 | no               | ✅ PASS |
| ALT-20260428-003  | phishing_triage      | CLOSE            | CLOSE          | Low               | Low             | no                 | no               | ✅ PASS |
| ALT-20260428-007  | credential_exposure  | ESCALATE         | ESCALATE       | Critical          | Critical        | yes                | yes              | ✅ PASS |
| ALT-20260428-009  | credential_exposure  | MANUAL_REVIEW    | MANUAL_REVIEW  | Medium            | Medium          | no                 | no               | ✅ PASS |

**All 5 / 5 tests PASS on first execution.**

> **Note on first-run all-pass:** The playbooks were written by tracing the decision logic  
> directly from `phishing_triage_decision_logic.md` and `credential_exposure_decision_logic.md`,  
> and the enrichment engine was validated against `ioc_feed.json` before running the tests.  
> One design decision worth noting: during initial implementation the enrichment engine  
> classified `192.168.10.55` (ALT-009) as INVESTIGATE (unknown external) before the  
> `internal_ranges` CIDR check was added, which would have produced a High/escalated outcome  
> instead of Medium/open — a bug caught during unit verification before the integration run.
