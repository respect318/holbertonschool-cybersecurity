Engagement Plan, Aldermere
Scope, in my words

This engagement covers cryptographic failures and SQL injection on Aldermere's authorized surface only. Cryptographic scope means examining what actually protects stored and in-transit data: hashing algorithms and their parameters (salting, work factor), encryption choices, key handling, and transport configuration — not just noting that something looks encoded. SQL injection scope means testing whether untrusted input reaches database queries unsafely. Unrelated systems, destructive activity, and any scope expansion beyond what's authorized are excluded.

Methodology (observe -> controlled exploitation -> proof -> reasoning)

Observation first: trace where data is stored, transmitted, and queried, and identify what mechanism is supposedly protecting it at each point. Controlled exploitation second: test one specific hypothesis at a time — a single input change for injection, a single sample for crypto — against a known baseline. Proof third: capture the exact evidence that demonstrates the behavior, no more. Reasoning last: keep the SQL injection path and the cryptographic weakness it may expose analytically separate — an injection finding proves data access; a crypto finding proves that data, once reached, was never really protected.

Proving without damage, and holding scope

For SQL injection, I'll establish a baseline response, change one input at a time, and use minimally invasive boolean or time-based comparisons — stopping the instant interpretation is proven, never dumping or modifying real records. For cryptographic findings, I'll collect only the minimum authorized sample to identify the algorithm, salt, and work factor, and demonstrate weakness through analysis (e.g., recognizing an unsalted fast hash) rather than broad, unbounded cracking. Scope stays fixed to authorized targets and accounts; unclear boundaries mean I pause, not proceed.

Sofia's lesson

Applied: inspect what is actually protecting the data before judging it — encoded isn't encrypted, and a scanner flag isn't proof.
Not applied: treating every finding as isolated: I'll deliberately connect the injection path to what it exposes about the crypto underneath, since here that reasoning link is the point, not a shortcut to skip.
