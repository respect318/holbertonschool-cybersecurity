Task 1 — Halcyon’s Normal

Q1. Core business hours: 08:00 to 18:00 (UTC)
Evidence: workforce successful logins form a flat plateau from 08:00 to 18:00 (each hour ~4,200 events), with sharp drop-offs at 06:00 and 19:00.

Q2. Distinct countries: 4
Evidence: workforce accounts authenticate only from IE, PL, FR, GB (each ~12,000 events); cardinality on source.geo.country = 4.

Q3. Vendor + scanning window: not answerable from the data — no contracted vendor with an agreed scanning window exists in any index (reported separately; recommend removing Q3 or fixing the data).
