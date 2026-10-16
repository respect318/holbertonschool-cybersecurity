# Halcyon Shift Report — Kestrel Defense SOC

**Shift:** 2026-10-10, 41 open alerts plus the auto-closed list. **Analyst:** on-shift. **Regulated-data handling:** every record below is referenced by identifier only; no personal, cardholder, or credential content was reproduced in any deliverable.

## What I worked and what I closed

I worked the full queue of 41 open alerts and reviewed the six auto-closed entries. After triage, 7 alerts are true positives, 11 are false positives, and 23 are noise.

I closed the 23 noise alerts in grouped categories, each on a verified reason rather than on how the alert read. Nine were repeated authentication failures from svc_backup against the internal source 10.34.3.59 (HAL-482068 and siblings) — a backup service failing to authenticate from inside the network, not an external attempt. Six were routine service restarts across internal hosts (HAL-699743 and siblings). Two were browser-extension installs with software.authorised=True on standard workstations (HAL-773525, HAL-739411). The remaining six are single infrastructure events with no corroborating activity: a printer restart, a disk-usage threshold, a cert nearing expiry, a failed scheduled job, a firewall-rule change, and a new DNS record (HAL-141423).

I closed 11 as false positives where the alarming surface had a benign, checkable cause. Five were password-expired failures (HAL-521013 and siblings) — the failure reason field itself is "password_expired", not a guessed password. Two concerned adm.h.lindqvist creating an admin account off-hours (HAL-999978, HAL-943390): the creation carries change ticket CHG-6913 and was performed from his normal internal workstation admws-910. One was a scheduled monthly finance export (HAL-918535, export.scheduled=true). Three were external port probes from 203.0.113.84 (HAL-416486 and siblings) that are detected-only, with no successful connection.

## What I escalated, and why not the fourth

I escalated three findings, chosen by harm to Halcyon if real and unactioned, not by how interesting they were.

**Ticket 1 (Critical) — HAL-502452:** the service account svc_txn_reconcile authenticated to the crown-jewel payments host txn-proc01 from legacy-jump03, a host that appears in zero other events across 14 days; its baseline source is batch-svc01/02 at ~04:20 daily. Crown-jewel asset, high confidence, access already achieved.

**Ticket 2 (High) — the JA3 cluster** (HAL-753699, HAL-157752, HAL-214031, HAL-467427): one external actor from 198.51.100.12, tied across all four by JA3 ea60867, who sprayed in, compromised u.ferreira, reached remote-gw02, and ran directory enumeration. Active confirmed intrusion, but it has not reached a crown-jewel asset, so it ranks below Ticket 1.

**Ticket 3 (High) — HAL-723401:** an unrestricted share (finding.acl=none) flagged with a regulated data_classification, 214 files. Serious latent exposure, but a standing condition with no evidenced unauthorised access.

The fourth credible candidate, **HAL-242743** (an unauthorised remote-access tool, software.authorised=False, on ws-6250), is a genuine true positive and I did not escalate it. It sits on a standard-tier workstation, shows no link to the cluster, and no action on it yet. Spending one of three slots on a single standard-host tool, while a crown-jewel access, an active intruder, and a regulated-data exposure waited, would have been the wrong use of Tier 2's morning capacity. It stays in the log, flagged for follow-up.

## Where the queue volume comes from

Most of the volume is a small number of noisy rules, not 41 distinct problems. From the Task 6 analysis, three rules produce 21 of the 41 open alerts: rule 100285 (repeated auth failures, 10 alerts — 9 of them the svc_backup internal flood), rule 100274 (service restart, 6), and rule 100307 (password expired, 5). The svc_backup flood specifically comes from the backup service failing against the file_backup service from an internal source; I tuned rule 100285 to restrict it to destination.service=vpn_portal, which suppresses that flood while still firing on the genuine external spray (verified against both corpora). The queue's shape is a tuning problem, not an attack.

## The verdict I am least confident in

My least-confident verdict is **HAL-723401, marked true positive at medium confidence**. I can prove the exposure (finding.acl=none with a regulated classification on 214 files), but I cannot yet prove harm: there is no evidence anyone actually read those files, and the finding comes from a single automated share-permission scan rather than observed access. What would settle it: access logs on the share host for the 24-hour window. Reads by an external or unexpected identity — especially the Ticket 2 actor — would confirm a true data-access incident; no reads would downgrade it to a standing misconfiguration to be fixed, not an active breach.

## How I handled regulated data

Halcyon's data is regulated, so throughout the triage log, the escalation tickets, and this report I referenced every record by its identifier (alert ID, field name, host, account) and reproduced no personal or cardholder content. Where a finding concerned cardholder-format data, I cited the alert ID and the data_classification field rather than describing or copying the records.

## Handoff

**Hypothesis, stated as a hypothesis:** a single external actor (JA3 ea60867, 198.51.100.12, ASN AS64512) gained a foothold overnight by spraying the VPN portal, compromising u.ferreira, and conducting internal reconnaissance. I can evidence entry and discovery; I cannot evidence lateral movement, credential theft, data access, persistence, or exfiltration — u.ferreira has no activity after 03:32:30. The actor optimised for an ordinary-looking path (the everyday VPN portal, an allowlisted partner ASN that even got one sibling event wrongly auto-closed, HAL-751883).

**The open question I cannot yet rule out:** whether the crown-jewel anomaly in Ticket 1 (svc_txn_reconcile from legacy-jump03) is the same actor reaching the payments system by a second route, or an unrelated issue. The JA3 does not tie them, so I am keeping them as separate findings, not one chain — asserting a link I cannot prove would overstate the picture.

**What the next shift should watch:** any event carrying JA3 ea60867, source 198.51.100.12, or the account u.ferreira; any new authentication to txn-proc01 or other txn-proc hosts from sources outside batch-svc01/02; any access to the HAL-723401 share; and the removal of the stale AS64512 allowlist entry so it stops auto-closing this actor's logons.
