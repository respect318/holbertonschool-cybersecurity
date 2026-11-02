# 1 - Risk Register: Assist billing expansion

**System:** `Assist` billing + payment expansion (Larkspur Software)
**Author:** Security analyst (deployment governance)
**Date assessed:** 2026-11-01
**Sources:** `01-architecture.md`, `02-dataflow-diagram.md`, `03-vendor-model-card.md`, `04-dpa-excerpt.md`, `05-sample-logs.jsonl`, `06-compliance-self-assessment.md`
**Method:** Posture reconstructed from the architecture, the data-flow diagram and the audit log — what the system *does*, not what it is designed to do. Risk classes carried in from prior attack work (14x00 excessive agency, 14x01 injection) are included only where this dossier shows evidence for them. Each entry maps to an OWASP LLM Top-10 class and a MITRE ATLAS technique, and is grouped by NIST AI RMF function.

---

## What the system actually does with regulated data (reconstructed)

- Regulated fields are `iban`, `billing_address`, `tax_id`; `card_last4` and `invoice_total_cents` are treated as ordinary account data (`01` §4, `02`).
- `billing_lookup` returns the full regulated set from the billing DB — every `tool_result` for it carries `fields_returned: [invoice_id, invoice_total_cents, card_last4, iban, billing_address, tax_id]` (e.g. `evt_000032`, `evt_000123`, `evt_000169`).
- **Scrubbing to the model holds.** Every `model_call` that follows a `billing_lookup` sends only `[customer_id, plan, invoice_total_cents, card_last4]` and records `scrubbed: [iban, billing_address, tax_id]` (e.g. `evt_000031`, `evt_000078`, `evt_000125`). No regulated field reaches the provider in the log. This matches `02` (`paths_to_provider_without_scrubbing: none`).
- **Identity binding holds.** Cross-customer `billing_lookup` attempts are rejected with `auth_denied / customer_ref_not_session_identity` (`evt_000085`, `evt_000135`, `evt_000161`, `evt_000180`).
- **Refund approval holds.** Every `issue_refund` carries `approval.mode: human` with a named `approver`, and at least one is `denied` (`evt_000275`), confirming a real gate, not a rubber stamp.
- **Ingest allowlist holds.** Customer ticket text is rejected (`ingest_rejected / unverified_source`: `evt_000015`, `evt_000081`, `evt_000103`…); only `docs-ci`-signed `policy_repo`/`kb_internal` documents are indexed (`evt_000094`, `evt_000225`).
- **Where it breaks:** tool arguments are never validated. Every `tool_call` records `validation: skipped`, and `evt_000233` passes `billing_lookup` a `filter` of `status='open' OR 1=1` that the gateway forwards unmodified and the tool executes (`status: ok`). This is the control the self-assessment claims and the system does not have (see the discrepancy note below; full write-up is Task 2).

---

## Govern

| ID | Risk | Evidence | OWASP LLM | MITRE ATLAS |
|----|------|----------|-----------|-------------|
| G-1 | **No regulatory classification of the billing feature.** The feature processes regulated financial + personal data but has never been classified against the applicable regime, so obligations are unknown at launch. | `06` C-12 = No ("not yet performed") | LLM09 Misinformation | AML.T0048 External Harms (unclassified deployment of a regulated-data feature — the regulatory/financial harm ATLAS groups under External Harms) |
| G-2 | **No notice to the customer that they are interacting with an AI system.** No disclosure anywhere in the flow; funded work F6 is not in scope. Transparency is a live obligation, not a deferred one. | `01` §7 F6 (not funded); no disclosure event in `05` | LLM09 Misinformation | AML.T0074 Masquerading (an AI agent presented to the customer without disclosing it is AI) |
| G-3 | **Third-party processing is governed by a weaker reality than the vendor presents.** The model card implies near-zero data exposure ("we do not use your API inputs to train"); the contract permits 30-day retention, up to 365 days for abuse-flagged requests with reviewer access, use of retained input to train abuse classifiers, and sub-processor access. Governance must bind to the contract, not the card. | `03` ("Your data") vs `04` cl. 4.1 / 4.2 / 5.2 / 6.1 / 6.2 | LLM03 Supply Chain | AML.T0010 (AI Supply Chain Compromise — third-party model service and its sub-processors) |

## Map

| ID | Risk | Evidence | OWASP LLM | MITRE ATLAS |
|----|------|----------|-----------|-------------|
| M-1 | **Regulated data leaves Larkspur's boundary to the provider.** Even after scrubbing, `customer_id`, `plan`, `invoice_total_cents` and `card_last4` are sent off-boundary and retained under `04`. Scrubbing reduces, but does not remove, the data-export exposure. | `02` "What is sent…"; `05` `fields_sent` on every `model_call`; `04` cl. 4 | LLM02 Sensitive Information Disclosure | AML.T0024 (Exfiltration via AI Inference API — data sent to and retained by the inference endpoint) |
| M-2 | **Cross-account access is controlled but untested.** Binding rejects mismatched `customer_ref` today, but the cross-account authorisation test (F1) has not been run, so behaviour under crafted arguments / injection is unproven. | `05` `auth_denied` events; `01` §7 F1 (not funded) | LLM06 Excessive Agency | AML.T0012 (Valid Accounts / identity-scoping abuse — reaching another customer's data if binding fails under crafted input) |
| M-3 | **Self-assessment overstates the control set (paper control).** C-09 claims tool inputs are schema-validated; the architecture and logs show they are not. A reader relying on the form believes a control exists that does not. | `06` C-09 = Yes vs `01` §5 `tool_args_validation: none_passthrough`; `05` `validation: skipped` everywhere + `evt_000233` | LLM05 Improper Output Handling | AML.T0051 (LLM Prompt Injection — unvalidated input reaching the tool as instructions) |
| M-4 | **Retrieval-index poisoning / indirect injection (carry-in: data-poisoning class).** The system has a retrieval layer (`kb_search`, `retrieval`, `ingest-worker`). Today the allowlist holds (only `docs-ci`-signed `policy_repo`/`kb_internal` indexed; ticket text rejected), but the signing/allowlist is the only barrier between an indexed document and the model's context. From the 14x00/14x01 attack work, a poisoned or attacker-controlled source document carries instructions into the agent via retrieved text — the exact failure this control prevents, so it is a live residual if the allowlist or `docs-ci` signing is ever bypassed or misconfigured. | `01` §1 (`retrieval`, `ingest-worker`), §5 (ingest allowlist); `05` `ingest`/`ingest_rejected` (`evt_000094`, `evt_000015`); carry-in 14x01 | LLM04 Data and Model Poisoning | AML.T0020 (Poison Training/RAG Data — poisoned source document indexed into retrieval) |
| M-5 | **Retrieval-context leakage via embeddings (carry-in: embedding/vector class).** `ingest-worker` builds a vector index over KB documents and `retrieval` serves them into the model context. The index is shared infrastructure not scoped per customer; retrieved KB passages are not subject to the per-customer identity binding that guards the billing tools. From the 14x00/14x01 work, embedding/vector-store weaknesses let crafted queries surface indexed content that should not reach a given session — a retrieval-leak surface that grows once regulated-data-adjacent material is indexed. | `01` §1 (`retrieval` over KB index, `ingest-worker` builds index); `02` (retrieval path); carry-in 14x01 | LLM08 Vector and Embedding Weaknesses | AML.T0057 (LLM Data Leakage — indexed content surfaced through the retrieval interface) |

## Measure

| ID | Risk | Evidence | OWASP LLM | MITRE ATLAS |
|----|------|----------|-----------|-------------|
| Me-1 | **Unvalidated tool arguments (carry-in: injection class).** `tool-gateway` forwards model-produced arguments unparsed; free-text `reason`/`filter` reach the tool. `evt_000233` demonstrates an injection-style payload (`OR 1=1`) executing. Directly exploitable, present in the live log. | `01` §5; `05` `evt_000233`; `validation: skipped` on all tool calls | LLM05 Improper Output Handling | AML.T0051.001 (LLM Prompt Injection: Indirect — model-produced argument executed unvalidated) |
| Me-2 | **Prompt injection — partially mitigated, not closed (carry-in: injection class).** Direct "ignore your instructions" attempts are declined by a guard (`evt_000142`, `evt_000150`), and retrieved content is allowlisted (C-08), but the unvalidated tool-arg path (Me-1) is an open injection channel and the full guard layer F3 is unfunded. | `05` `guard` events; `01` §7 F3; cross-ref Me-1 | LLM01 Prompt Injection | AML.T0051 (LLM Prompt Injection — direct attempts observed and declined, channel still open via Me-1) |
| Me-3 | **No red-team regression in CI.** Nothing re-tests these weaknesses after changes; a fix could silently regress. | `01` §7 F9 (not funded) | LLM06 Excessive Agency | AML.T0043 (Craft Adversarial Data — no adversarial-input testing staged in the pipeline) |

## Manage

| ID | Risk | Evidence | OWASP LLM | MITRE ATLAS |
|----|------|----------|-----------|-------------|
| Ma-1 | **Refund agency without a spend/rate cap (carry-in: excessive agency class).** `issue_refund` writes to `customer_balance`. Human approval gates it (strong), but there is no per-session spend or rate cap, so a bad-approval or approver-fatigue path has no second limit. | `01` §2 (issue_refund writes balance), §5 (human_required_all_amounts), §7 F8; `05` refund events | LLM06 Excessive Agency | AML.T0053 (AI Agent Tool Invocation — financial action via a connected tool) |
| Ma-2 | **No reply-side regulated-field filter.** Scrubbing runs only on context *to* the model; there is no filter on model output *to* the customer. Residual exposure is bounded (regulated fields are already withheld from the model, so the model cannot echo them), but card_last4 / totals in replies are ungoverned. | `01` §5 (scrubber scope = model context only); `01` §7 F2 (not funded) | LLM02 Sensitive Information Disclosure | AML.T0057 (LLM Data Leakage — regulated values surfaced in the model reply) |
| Ma-3 | **No kill switch or incident runbook for Assist.** If any of the above is exploited at launch, there is no defined containment path. | `01` §7 F5 (not funded) | LLM06 Excessive Agency | AML.T0048 External Harms (no containment means an exploited agent action runs through to real-world harm; the absence of a halt/response control) |
| Ma-4 | **Unbounded consumption on billing tools.** A per-session RPM limit exists (`rate_limit` events), but no spend or call budget on the billing tools themselves. | `05` `evt_000061`, `evt_000127`; `01` §7 F8 | LLM10 Unbounded Consumption | AML.T0034 (Cost Harvesting — denial-of-wallet via unbounded tool calls) |
| Ma-5 | **Audit log has no retention policy or review surface.** Events are written (schema v3), but F10 (retention + review dashboard) is unfunded, so the log that proves everything above is itself ungoverned. | `01` §5 (audit), §7 F10; `06` C-11 = Yes (logging only) | LLM09 Misinformation | No direct ATLAS technique — this is a detection/monitoring control gap. ATLAS mitigation AML.M0015 (Adversarial Input Detection) and AML.M0024 (monitoring) are the relevant countermeasures; the gap leaves techniques such as AML.T0024 and AML.T0053 undetectable. |

---

## Discrepancy flagged for Task 2

The compliance self-assessment claims a control (**C-09: tool inputs are schema-validated before execution → Yes**) that the architecture configuration (`tool_args_validation: none_passthrough`), the per-event log state (`validation: skipped` on every tool call) and a concrete executed payload (`evt_000233`: `filter = status='open' OR 1=1`) all show does not exist. Proven by the artefacts, not by absence. Full analysis in `2-compliance_review.md`.

## ATLAS technique mapping notes

ATLAS techniques were selected per risk by the specific attack mechanism each risk enables, verified against `atlas.mitre.org` (Nov 2026), each used for one mechanism only:
- AML.T0051 LLM Prompt Injection (.001 Indirect for Me-1) — injection-channel risks (Me-1, Me-2, M-3). M-3 is a paper-control discrepancy; its mapping is the injection the missing validation would enable, not the paperwork.
- AML.T0020 Poison Training/RAG Data — retrieval-index poisoning (M-4).
- AML.T0057 LLM Data Leakage — content surfaced through the retrieval/model interface (M-5, Ma-2).
- AML.T0024 Exfiltration via AI Inference API — regulated data leaving to the inference endpoint (M-1).
- AML.T0053 AI Agent Tool Invocation — tool acting beyond intended scope (Ma-1 refund action).
- AML.T0012 Valid Accounts — identity-scope abuse reaching another customer if binding fails (M-2).
- AML.T0010 AI Supply Chain Compromise — third-party model service and sub-processors (G-3).
- AML.T0034 Cost Harvesting — unbounded consumption / denial-of-wallet (Ma-4).
- AML.T0043 Craft Adversarial Data — missing adversarial-test pipeline (Me-3).
- AML.T0074 Masquerading — AI presented to the user without disclosure (G-2).
- AML.T0048 External Harms — real-world regulatory/financial harm from an unclassified deployment (G-1) and from an uncontainable agent action (Ma-3).
- Ma-5 (audit/monitoring gap) has no single offensive technique; it is a detection-control gap, mapped to ATLAS mitigations AML.M0015 / M0024, and it is what leaves the techniques above undetectable.
