# 5 - Control Decision: what ships-blocking vs what is watched after

**System:** `Assist` billing + payment expansion (Larkspur Software)
**Budget:** 12 engineering-weeks before launch, fixed; launch date fixed; "do not deploy" off the table.
**Costed control set (from `01-architecture.md` §7):** the full set a competent analyst would want totals **20 engineering-weeks** (F1 2.5 + F2 2 + F3 3 + F4 3 + F5 1.5 + F6 1 + F7 1 + F8 1.5 + F9 2.5 + F10 2). The budget is 12. **The budget does not fit the full set by 8 weeks**, so a real split is forced — there is no third column.

Controls are grouped against **ISO/IEC 42001 control domains** (as described in the dossier materials) so the board sees a recognised shape.

---

## Mandatory before launch (must be true at go-live) — 11.5 weeks of 12

| ISO/IEC 42001 domain | Control | Wk | Risk it addresses | Why it cannot wait |
|---|---|---|---|---|
| Operation / data for AI systems | **F3 — prompt-injection guard on user + retrieved text** | 3 | Me-1/Me-2: tool arguments are unvalidated (`none_passthrough`; `evt_000233` ran `OR 1=1`) | This is the live, exploited gap — and it is the control the self-assessment C-09 falsely claims exists. Shipping without it means shipping the one risk nobody downstream knows is open. |
| Operation / system controls | **F1 — cross-account authorisation test of the billing tools** | 2.5 | M-2: identity binding is in place but never tested under crafted input | Billing tools expose `iban`/`tax_id`. Binding that works in the happy path but fails under injection is a regulated-data breach on day one. Must be proven, not assumed. |
| Operation / AI system impact | **F8 — per-session spend and rate cap on billing tools** | 1.5 | Ma-1/Ma-4: `issue_refund` writes to balance; no second limit behind human approval | A cap bounds the worst case of a bad or fatigued approval. Cheap, and the only hard limit on financial action. |
| Operation / third-party & human oversight | **F7 — staff training for approving agents** | 1 | Ma-1: human approval is the primary refund control | The control the whole refund design leans on is only as good as the approvers. Training the gate before launch is non-negotiable when the gate is the mitigation. |
| Transparency / information for interested parties | **F6 — notice the customer is talking to an AI** | 1 | G-2: Article 50 transparency | Live legal obligation under the AI Act (applies since 2 Aug 2026), currently unmet. A launch without it is non-compliant on day one, not a risk to monitor. |
| Operation / incident response | **F5 — kill switch + incident runbook** | 1.5 | Ma-3: no containment path | If any of the above is exploited at launch, there must be a way to stop it. Containment cannot be built after the incident. |
| **Total mandatory** | | **10.5** | | leaves 1.5 weeks of the 12 |

Remaining 1.5 weeks are held for **F10 (log retention + review dashboard)** in reduced scope — retention policy only (≈1.5 wk), because the audit log is the evidence base for every post-launch acceptance below and must at least be retained and reviewable.

---

## Monitored after launch (deferred within the window)

| ISO/IEC 42001 domain | Control | Wk | What we accept during the window | Monitoring that would show the acceptance was wrong |
|---|---|---|---|---|
| Data for AI systems | **F2 — reply-side regulated-field filter** | 2 | Residual is bounded: regulated fields are already withheld from the model (C-10 holds), so the model cannot echo `iban`/`tax_id`; only `card_last4`/totals are ungoverned in replies | Audit sampling of replies for any regulated field; a single leak closes the window immediately. |
| Third-party / supplier relationships | **F4 — vendor addendum: zero retention + training opt-out** | 3 | DPA already forbids foundation-model training (cl. 5.1); accepted residual is the 30-day / 365-day abuse-flag retention and sub-processor access (cl. 4.1/4.2/6.1) | Count of abuse-flagged requests held by the provider; if flagged billing conversations accumulate, the retention exposure is real and the addendum must be pulled forward. |
| Performance evaluation / internal audit | **F9 — red-team regression suite in CI** | 2.5 | Accepted that a fix could silently regress between launch and suite delivery | Any reappearance of an injection or cross-account finding in production telemetry; one recurrence means the manual gate missed a regression. |
| Operation / monitoring (remainder) | **F10 — review dashboard (beyond retention)** | 0.5 | Retention is in before launch; the dashboard UI is deferred | Time-to-detect on the sampling above; if manual review is too slow to catch a leak within a day, the dashboard is overdue. |

**Deferred total:** 8 weeks — exactly the amount the budget could not fund. Each deferral names what is accepted and the signal that would prove the acceptance wrong.

---

## The split, defended

The two failure modes are opposite. Demanding all 20 weeks produces a document the business routes around, and the feature ships with no conditions — the worst outcome. Accepting the VP's shortest list ships the regulated-data and injection risk with my name on it.

The line drawn here is: **anything that is live-exploitable, legally required now, or the sole mitigation for a financial/regulated-data action goes before launch** (F3, F1, F8, F7, F6, F5, plus log retention). **Anything whose residual is bounded and observable in the audit log is monitored after** (F2, F4, F9, dashboard). The deferrals are defensible precisely because each one has a named acceptance and a named signal — they are watched, not ignored. That judgment, not the list, is the reason this is a person's decision.
