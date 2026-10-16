1. The Alert Lifecycle — the five states
New — the alert has arrived, no analyst has looked at it yet. It carries only what the detection rule asserted; it has not been assessed against the baseline, the asset, or anything else. The severity label is the rule’s claim, not your verdict.
In triage — an analyst has picked it up and is actively gathering evidence (supporting events, what’s normal for the asset/account, pivoting on indicators). It has an owner; leaving alerts stranded in triage at shift end is unfinished work.
Closed — you assessed the activity as not warranting action and recorded why. It commits you, by name, to the claim that this was examined and judged benign on a stated reason. Events aren’t deleted; the record persists so it can be checked later. Can be reopened if new evidence surfaces, and reopening is itself notable.
Escalated — you handed a senior analyst your assessment (what you found, your confidence, why it needs their attention now), not the raw alert. It commits the SOC’s scarcest resource — senior attention. It does not auto-notify the client or start formal incident response. Escalating everything weak makes seniors read you more slowly.
Auto-closed — a tier-zero automated rule closed it without a human. It means the alert matched a pattern the automation treats as benign — correct most of the time, but it can be wrong in a case the rule’s author didn’t anticipate (a stale allowlist entry, known-vendor source, maintenance window, expired cert exception).
2. The Severity Rubric

Severity is derived, not felt and not the rule’s shipped label:

severity = asset criticality × confidence × stage of activity

Asset criticality — a property of what the activity touched, set by the client’s business, from the client’s own asset inventory. Tiers: crown-jewel (compromise is business-ending or reaches everything) → significant-but-not-crown-jewel (matters, a common route in, not the target itself) → high-volume/individually-low-impact (routine infrastructure, serious but survivable/contained).
Confidence — how thin or thick your evidence is (see scale below), not an emotion.
Stage of activity — where the claim sits on the intrusion lifecycle (recon / initial access → actions on objective), based on the point actually reached, not what you fear it might reach.

Multiply the three honestly → a defensible ordering. A high-confidence, initial-access finding on a crown-jewel asset outranks a low-confidence finding on a routine asset regardless of stage, because criticality and confidence alone already put it ahead.

3. The Confidence Scale

Every verdict carries one of high / medium / low — no fourth option, no default.

High — evidence directly and completely supports the verdict; you’d be surprised to be shown wrong.
Medium — evidence points one way but leaves a real gap: something unchecked, or a plausible alternative you can’t yet rule out.
Low — evidence is thin. Not laziness or a request for time — a statement on the record that the verdict rests on little, so the reader knows how much weight it can bear.

Key point: confidence is information only if it varies with the evidence. Marking everything “high” (or hedging everything “medium/low”) produces a signal with no content. It’s a factor in the severity rubric precisely so an uncertain finding isn’t inflated to look more actionable than it is.
