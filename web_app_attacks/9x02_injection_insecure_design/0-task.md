Engagement Plan, Vendara
Scope, in my words

This engagement covers injection and insecure design on Vendara's authorized application surface only. Injection means testing whether untrusted input reaches an interpreter, query, command, or template engine without being safely handled. Insecure design means examining trust boundaries, workflow assumptions, and missing abuse-case controls — not typos in code, but decisions baked into the architecture. Unrelated systems, destructive testing, and any expansion beyond what's authorized are explicitly out.

Methodology (recon -> controlled exploitation -> proof -> reasoning)

Reconnaissance first: map inputs, interpreters, workflows, and the trust assumptions each flow relies on, through organic browsing and traffic review. Controlled exploitation second: test one specific hypothesis at a time against a known baseline, changing a single variable per attempt. Proof third: capture the request/response pair that demonstrates the behavior, nothing more. Reasoning last: decide whether what I found is a local coding defect or a structural design failure — that distinction changes the fix.

Proving without damage, and holding scope

For injection, I'll use minimally invasive, non-destructive payloads, compare against a baseline, and stop the moment interpreter influence is demonstrated — no extraction, modification, or persistence. For design flaws, I'll show the violated assumption or missing check produces an unsafe outcome through observation, not exploitation. Scope stays fixed to authorized targets and accounts; anything ambiguous gets paused, not pushed through.

Sofia's lesson

Applied: read the context before touching anything — understand what the workflow assumes before testing it.
Not applied: chasing proof through repetition or brute force: Vendara's scope calls for precision, not volume, so I'll favor a single decisive test over many noisy ones.
