.Task 1 — The Maliciousness Rubric (theory ready; EXAMPLE-A/B pending lab)

A verdict is derived, not asserted — provenance × lineage × behaviour × network. “It used PowerShell” is not a finding, because a legitimate process and a malicious one can use the same interpreter and score identically on the tool. The four factors:

Provenance — where the binary came from and what vouches for it: is it signed, from a known publisher, matching a known-good hash, installed through a managed channel? Unsigned / unknown-hash / dropped-into-a-user-path lowers provenance.
Lineage — the parent/child chain that launched it. A payload spawned by a document handler or a script host reads very differently from one spawned by a signed installer or a managed deployment service.
Behaviour — what it actually did: wrote to user-writable paths, set a Run key for persistence, injected, spawned a shell. Benign tools rarely persist themselves via Run keys.
Network — where it connected: internal-only / known update endpoints are benign-leaning; an outbound beacon to an external C2 is the decisive malicious signal.

The two worked processes use the same interpreter but score differently on everything that matters:

EXAMPLE-A / EXAMPLE-B — one is malicious, one is Portway’s IT (the legitimate deployment agent). This is the part that needs the live telemetry — once the lab is fixed and the agent reports, we pull both, score them across the four factors, and show why they diverge (expected: the IT one has good provenance/internal-only network/no self-persistence; the malicious one has weak provenance, a user-path payload, Run-key persistence, and an external beacon).
