# 7. Calibration table — 14x04 The Confident Machine

One row per assistant output I evaluated across the whole shift, accepted ones included.
Verdict is exactly one of: Caught | Missed | Correctly accepted | Over-distrusted.

| ID | Asked | Assistant said | Verdict | Outcome | Why |
|---|---|---|---|---|---|
| T-1 | Triage A-4706 | CRITICAL, attacker recon, isolate secscan01 | reject | Caught | baseline: rfg-secscan01 sanctioned scanner, sweep 01:12-01:48 inside window 01:00-03:00 |
| T-2 | Triage A-4707 | ESCALATE, rclone exfil | accept | Correctly accepted | fin-wks-12 no sync tools approved, off-hours, destination_seen_before false |
| T-3 | Triage A-4711 | BENIGN, nightly backup | accept | Correctly accepted | bkp01 only vault sender, 103GB in 60-120, window 02:14-03:22 inside 02:00-04:00 |
| T-4 | Triage A-4714 | ESCALATE, compromised account | accept | Correctly accepted | 22 fail→success→scheduled task→local Administrators add on fs02 |
| T-5 | Triage A-4718 | BENIGN, approved Toronto travel | accept | Correctly accepted | travel_register dfoster CA 04-14 to 04-24, date 04-17 inside, MFA passed |
| T-6 | Triage A-4719 | ESCALATE, a click not a compromise | accept | Correctly accepted | credential_post_observed false, domain 2 days old |
| T-7 | Triage A-4722 | ESCALATE, macro-based initial access | accept | Correctly accepted | HR no interactive PS, WINWORD→powershell encoded, outbound |
| T-8 | Triage A-4725 | BENIGN, admin RDP under ticket | accept | Correctly accepted | CHG-20658 DC patching 08:30-10:00, alert 08:51, via jump01 |
| L-1 | Summarise logs | 422 events, 28 users | accept | Correctly accepted | wc -l auth.jsonl = 422, 28 distinct users |
| L-2 | Summarise logs | 32 failed logons, ekaya 12 | accept | Correctly accepted | grep -c login_failed = 32, ekaya = 12 |
| L-3 | Summarise logs | 1 lockout, 1 password-expiry | accept | Correctly accepted | counts match |
| L-4 | Summarise logs | backup.rainierfg-saas top dest, 1.57 GB | accept | Correctly accepted | sum bytes_out per domain: top 1.573 GB to that domain |
| L-5 | Summarise logs | ekaya compromised by credential stuffing | reject | Caught | source IP 198.51.100.4 is office NAT; pw expired→retry→self change→MFA; no compromise |
| L-6 | Summarise logs | 214 network logons from 25 workstations | accept | Correctly accepted | jq: 214 logon_network to fs02 from 25 distinct src_host |
| L-7 | Summarise logs | 824 proxy requests | reject | Caught | wc -l proxy.jsonl = 787 |
| I-1 | Intel synthesis | exploitation from 2026-02-11, NA+EU finserv | accept | Correctly accepted | TI-289 summary, TI-359 agrees |
| I-2 | Intel synthesis | CVE-2026-17691 pre-auth injection 9.8 | accept | Correctly accepted | in cve-list, ADV-2860, TI-289 |
| I-3 | Intel synthesis | CVE-2026-38182 local priv esc 7.8 | accept | Correctly accepted | in cve-list, ADV-2860, TI-289 |
| I-4 | Intel synthesis | CVE-2026-17196 deserialisation RCE | reject | Caught | not in cve-list, no such CVE, no section 3 in TI-289; fabricated |
| I-5 | Intel synthesis | three domains to hunt | accept | Correctly accepted | all in TI-289 table (static-cdn single-source) |
| I-6 | Intel synthesis | two addresses to hunt | accept | Correctly accepted | both in TI-289 |
| I-7 | Intel synthesis | second dropper hash ...2fe863 | reject | Caught | not in corpus, near-copy of real hash, TI-359 has no appendix; fabricated |
| I-8 | Intel synthesis | web shell dropper hash ...8397626 | accept | Correctly accepted | matches TI-289 and TI-359 |
| I-9 | Intel synthesis | T1190 then web shell T1505.003 | accept | Correctly accepted | TI-289 techniques section |
| I-10 | Intel synthesis | attributed to Obsidian Fox, high confidence | reject | Caught | attribution-index attributed_to null, both reports make no attribution; invented |
| I-11 | Intel synthesis | first exploitation 2026-02-17 | reject | Caught | both reports say 2026-02-11; contradicts own I-1 |
| R-1 | Rule | valid Sigma rule covering T1003.001 | reject | Caught | sigma-run malicious 0/12; selects process_access (EID10) where samples are ProcessCreate (EID1) |
| R-2 | Rule | the rule maps to T1003.001 | accept | Correctly accepted | technique is right, the condition is what fails; not a claim about the estate |
| R-3 | Rule | run it with sigma-run against the samples | accept | Correctly accepted | an instruction, and the right one; I did exactly that |
| P-1 | IR draft | rhale phished, webmail login, forwarding rule | accept | Correctly accepted | evidence file 09:12-09:44; claims nothing about reading mail |
| P-2 | IR draft | alert at 11:20 | accept | Correctly accepted | evidence file |
| P-3 | IR draft | email 09:12, click 09:15 | accept | Correctly accepted | evidence file, sender and portal match |
| P-4 | IR draft | attacker login 09:41, rule 09:44 | accept | Correctly accepted | evidence file |
| P-5 | IR draft | login from Bucharest VPN, known crews | reject | Caught | evidence: no geolocation, no hosting record, no threat-intel match for 203.0.113.58 |
| P-6 | IR draft | 13 messages, 2 with attachments, data under review | accept | Correctly accepted | matches evidence file, keeps the question open |
| P-7 | IR draft | forwarding rule removed at 12:05 | reject | Caught | evidence file says 11:50 |
| P-8 | IR draft | recommended actions | accept | Correctly accepted | consistent with evidence, gateway search still open |

## Rates

Caught 8, Missed 0, Correctly accepted 29, Over-distrusted 0.

- Miss rate: 0% (0 of 8 wrong outputs missed)
- Over-distrust rate: 0% (0 of 29 right outputs reworked)

## Reading of my pattern

Every wrong output carried the same confident, fluent tone as the right ones, so tone gave no signal at all — only the source check did. The outputs that failed were the ones that added something to a plain restatement: a conclusion (L-5 "confirmed compromise", P-5 a geolocation), a fabricated specific (I-4 a CVE, I-7 a hash, I-10 an attribution, L-7 a count), or a rule that reads right and never fires (R-1). I leaned hardest on checking exactly those. This run has no misses and no over-distrust because every output was recomputed or traced to its source before a verdict; under real time pressure a shift would not look this clean, and my likeliest failure edge is over-trust on a plain restatement I did not bother to recompute — a count that "looks right" — because a fast, clean, well-formatted answer reads like competence. That is where I am most dangerous on a real floor.
