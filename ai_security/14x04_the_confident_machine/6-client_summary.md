# Northfield Credit Union — core-banking audit log summary
**Date covered:** 2026-04-16 · **Client ref:** NF-0417 · **Prepared by:** Rainier SOC

## What happened

The audit log for 2026-04-16 contains **68 events** across **10 distinct
accounts**. Activity was ordinary account usage — logins, balance views and
statement downloads — with a handful of money-movement and security events.

Event breakdown:

| Event | Count |
|---|---|
| login_ok | 27 |
| balance_view | 15 |
| login_failed | 10 |
| statement_download | 6 |
| ach_batch | 5 |
| card_freeze | 2 |
| wire_initiated | 1 |
| password_reset | 1 |
| limit_change | 1 |

**Failed logins:** 10 in total. Six of them are on a single account
(NFCU-7BC88B35), which is the main item to look at (below).

## What you should look at

**One account shows a pattern consistent with account takeover, in sequence,
within about five minutes on the evening of 2026-04-16:**

Account **NFCU-7BC88B35 (holder Dmitri Lenz)**, all from IP **203.0.113.45**
(an address that does not match the office IP range used by the rest of the
day's activity):

1. **~21:00 — 6 failed logins** on the account (the day's only clustered
   failures).
2. **21:12 — password reset.**
3. **21:14 — wire limit raised from \$5,000 to \$50,000** (a tenfold increase).
4. **21:17 — wire initiated for \$23,400 to a new payee** (reference
   WT-A1AD0575).

The ordering — repeated failed logins, then a password reset, then a large
limit increase, then an immediate high-value wire to a brand-new payee, all from
the same non-office IP — is the classic shape of a compromised account being
drained. We recommend the wire (WT-A1AD0575) be held/reviewed before settlement,
the account's credentials and limit change be treated as attacker-controlled,
and the holder be contacted out of band to confirm.

## Other money movement (no anomaly noted)

Five ACH batches ran during the day, \$1,852 to \$16,887, none to a new payee —
these look like normal scheduled activity. Two card freezes (Priyanka Desai,
Marcus Teller) appear to be ordinary customer actions.

## Totals at a glance
- Total events: **68**
- Distinct accounts: **10**
- Failed logins: **10** (6 on NFCU-7BC88B35)
- Largest single transfer: **\$23,400 wire** (NFCU-7BC88B35, new payee — flagged above)
