# 1 — Triage of the morning queue

Each verdict from `assist triage` was checked against the alert's own
evidence (`queue/alerts.jsonl`) and the asset baseline (`refs/asset-baseline.json`).

## Triage table

| Alert | Assistant verdict | Checked against | My verdict |
|-------|-------------------|-----------------|------------|
| A-4706 | CRITICAL — attacker recon, isolate rfg-secscan01 | baseline: secscan01 sanctioned scanner | **WRONG** — benign scheduled scan |
| A-4707 | ESCALATE — rclone exfil from rfg-fin-wks-12 | baseline: no file-sync tools approved; alert: rclone to unseen dst, off-hours | Agree |
| A-4711 | BENIGN — nightly backup rfg-bkp01 → vault | baseline: backup server, 60-120 GB, 02:00-04:00; alert: 103 GB, 02:14-03:22, vault IP | Agree |
| A-4714 | ESCALATE — compromised account | alert: 22 fails → success → scheduled task + local-admin add | Agree |
| A-4718 | BENIGN — dfoster travel login | baseline travel register: dfoster Toronto 2026-04-14→04-24; alert date 2026-04-17, MFA passed | Agree |
| A-4719 | ESCALATE — click on newly-registered domain | alert: domain age 2 days, credential_post_observed=false | Agree |
| A-4722 | ESCALATE — macro-based initial access | baseline: HR does not use PowerShell; alert: WINWORD→powershell -Enc, outbound | Agree |
| A-4725 | BENIGN — sanctioned admin RDP | baseline: CHG-20658 DC patching 08:30-10:00, executor adm-vkoval; alert 08:51, via jump01 | Agree |

## The verdict the assistant got wrong

**Alert:** A-4706.

**What the assistant concluded (quoted):**
> "rfg-secscan01 is sweeping 1838 internal hosts across 1,024 ports. That is
> attacker reconnaissance (T1046). Isolate rfg-secscan01 immediately and open
> an incident."

**What is actually true:** this is the sanctioned internal vulnerability
scanner performing its scheduled nightly sweep, not attacker reconnaissance.
Isolating it would take a production security control offline for doing its job.

**The evidence that establishes it:**
- Asset baseline, host `rfg-secscan01`: `"role": "Sanctioned internal
  vulnerability scanner"`, `"sanctioned_scanner": true`,
  `"scan_window_utc": "01:00-03:00"`, and normal behaviour: *"Touches thousands
  of hosts and ports inside that window; this is its job."*
- Alert A-4706 evidence: `"window_utc": "01:12-01:48"` — entirely inside the
  sanctioned 01:00–03:00 scan window — and `src host rfg-secscan01` (10.20.5.15),
  the scanner's own address.

The high host/port fan-out the assistant read as "attacker reconnaissance" is
exactly the baseline's definition of this host's normal behaviour, in its
sanctioned window, from the scanner's own IP. The verdict reads fast and clean,
but it is a claim about evidence that the evidence contradicts.
