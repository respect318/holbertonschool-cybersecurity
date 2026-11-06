# 2 — Log review: holding the summary against the log

`assist logs` produced seven claims (L-1…L-7) over `logs/auth.jsonl`
and `logs/proxy.jsonl`. Each was checked against the logs themselves.

## Verification of each claim

| Claim | What I checked | Result |
|-------|----------------|--------|
| L-1 — 422 events, 28 users | `wc -l auth.jsonl` = 422; distinct users = 28 | Correct |
| L-2 — 32 failed logons, most on ekaya (12) | `grep -c login_failed` = 32; ekaya = 12 | Correct |
| L-3 — 1 lockout, 1 password-expiry | `grep -c lockout` = 1; `password_expired` = 1 | Correct |
| L-4 — top outbound dest backup.rainierfg-saas.example, 1.57 GB | sum of bytes_out by domain: top = 1,573,000,000 B to that domain | Correct |
| L-5 — ekaya compromised by credential stuffing; attacker has a session | ekaya auth events (see below) | **Overconfident — not supported** |
| L-6 — 214 network logons to rfg-fs02 from 25 workstations | 214 logon_network to fs02; 25 distinct src_host | Correct |
| L-7 — proxy.jsonl has 824 requests | `wc -l proxy.jsonl` = 787 | **Wrong count (787, not 824)** |

## The overconfident claim (the dangerous one)

**L-5, quoted:**
> "Account ekaya was compromised by credential stuffing. Twelve failed logons
> from 198.51.100.4 were followed by a successful logon from the same address;
> the attacker now has a valid session."

**The log evidence it rests on:** twelve `login_failed` (reason `bad_password`)
for ekaya on 2026-04-16 between 15:09 and 15:14, each ~30 s apart, all from
`198.51.100.4`, followed by a `login_ok` from the same address.

**What that evidence actually supports — the summary says more than the log carries:**
- `198.51.100.4` is the **office NAT**, per the asset baseline
  (`networks.office_nat: "198.51.100.4"`). The failures come from inside the
  office, not from an external attacker. Credential stuffing is characterised
  by external, rotating source IPs — none are present.
- The failures are immediately preceded by a `password_expired` event for ekaya
  at 15:02:14. Twelve attempts at ~30 s intervals, all `bad_password`, right
  after an expiry, is the signature of a **user retyping an expired password**,
  not an attack.
- The sequence ends in a self-service `password_change` at 15:17:03, then a
  `login_ok` with `mfa: passed` at 15:18:02. A credential-stuffing attacker does
  not reset the victim's password through the normal flow and then pass MFA.
- Every ekaya `login_ok` in the window carries `mfa: passed`. MFA held
  throughout — inconsistent with an account takeover.

So the raw fact (12 failures then a success from one address) is real, but the
conclusion "compromised / attacker has a session" is not carried by it.

**Correctly-calibrated version of the claim:**
> "ekaya had 12 failed SSO logons on 2026-04-16, all from the office NAT
> (198.51.100.4), beginning right after a password-expiry event and ending in a
> self-service password change followed by an MFA-passed login. This is
> consistent with a user repeatedly entering an expired password, then resetting
> it — not credential stuffing. No external source IPs, and MFA held. No
> compromise indicated; no action beyond routine noted."

## Note on L-7

L-7 ("824 requests") is a separate, plainly-false error: proxy.jsonl has 787
lines, not 824. Unlike L-5 this one is directly checkable and would be
challenged on sight; L-5 is the more dangerous because it reads as a confident,
correct-looking conclusion that would be repeated rather than questioned.
