# SOC Automation Brief
**To:** James Chen, SOC Lead  
**Date:** 2026-06-08  
**Re:** Phishing and Credential-Exposure Automation — Lab to Production Decision

---

## What was built

- **enrichment engine** — Looks up any IP address or domain against MedDefense's internal threat-intelligence feed and returns a risk verdict (block, investigate, or allow) in under one second. Replaces the manual browser-based lookup that took 45 minutes during the Cobalt Strike incident.
- **case manager** — Creates a structured case record for every alert processed, assigns a severity level, and writes it to a searchable log. Replaces the current practice of tracking cases in Slack threads with no audit trail.
- **phishing triage playbook** — Takes a raw email-gateway alert, runs the sender IP and domain through the enrichment engine, and decides whether to escalate to Critical, queue for review, or close as benign. No analyst involvement required for the enrichment step.
- **credential exposure playbook** — Takes an endpoint alert about credential-access activity, checks the source IP against known threats, checks whether the user account has Domain Admin or Server Admin privileges, and decides the case severity. If the source IP is a known command-and-control address and the account is privileged, the host is written to an isolation queue for analyst sign-off before any action is taken.

---

## Integration test results

Five alert scenarios were run against both playbooks. All five produced the expected outcome.

- **ALT-20260428-001** — Email from a known malicious sender (IP and domain both flagged as command-and-control). The phishing triage playbook correctly escalated this to Critical without analyst involvement.
- **ALT-20260428-002** — Email from an unknown external sender with no threat-intelligence match. The playbook correctly flagged it for analyst review at High severity rather than closing it.
- **ALT-20260428-003** — Internal maintenance email from a private IP address. The playbook correctly identified it as benign and closed the case at Low severity, saving 8 minutes of manual triage.
- **ALT-20260428-007** — LSASS credential dump from the same C2 IP seen in ALT-001, under a Domain Admin account. The credential exposure playbook correctly escalated to Critical and wrote the host to the isolation queue for analyst authorization before any action.
- **ALT-20260428-009** — Lateral movement attempt from an internal IP by a standard (non-privileged) user. The playbook correctly classified this as Medium severity for manual review with no isolation queue entry.

---

## Efficiency estimate

At current volume — 150 alerts per day, 8 minutes of analyst time per alert, with 67 percent of that time spent on enrichment lookups — the phishing triage playbook running at an 80 percent automation rate would save approximately **352 analyst-hours per month** (16 hours per day × 22 working days). That is the equivalent of roughly two full analyst-weeks per month redirected from repetitive lookup work to investigation and threat hunting. This estimate assumes the alert mix and volume stay near the current baseline and that the IOC feed is kept current (updated within 24 hours). If the false-negative rate on auto-closed alerts turns out to exceed 5 percent once measured in production, the automation rate will need to drop and the savings estimate should be revised downward.

---

## What the playbooks cannot do yet

- **No deduplication across alerts.** If the same malicious sender IP appears in ten alerts in one hour, ten separate cases are created. There is no logic to group related alerts into a single case, which will generate noise in the case queue on the first day of production use.
- **No connection to the email gateway for quarantine.** The phishing playbook decides that an email should be escalated but cannot quarantine the mailbox or block the sender. An analyst still has to log in to the email gateway and take that action manually.
- **No caching of enrichment lookups.** Every alert queries the IOC feed from scratch on every run. A high-volume burst of 50 alerts from the same IP will result in 50 identical feed lookups rather than one lookup reused across the batch. This is a performance concern at scale but does not affect decision accuracy.

---

## What James Chen needs to authorize

1. **Deployment to a staging SIEM feed** — Connect both playbooks to a read-only copy of the live alert stream for a 30-day observation period. No automated actions fire; analysts review playbook outputs alongside their normal triage.
2. **Access to the email gateway API for quarantine integration** — Required before the phishing playbook can progress beyond enrichment and triage to automated containment actions.
3. **A 30-day false-positive measurement period before the auto-close logic goes live** — The strategy requires a measured false-negative rate below 5 percent over at least 500 processed alerts before any alert is automatically closed without analyst review. This clock cannot start until the staging deployment is live.

---

## Recommendation

Deploy both playbooks to the staging SIEM feed by **2026-07-01** so the 30-day false-positive measurement period completes before the Q3 staffing review, giving James Chen real production data to justify the Phase 2 auto-close rollout and the tooling budget request.
