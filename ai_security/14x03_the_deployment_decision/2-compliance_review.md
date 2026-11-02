# 2 - Compliance Review: checking the self-assessment claim by claim

**System:** `Assist` billing + payment expansion (Larkspur Software)
**Reviewed:** `06-compliance-self-assessment.md`, cross-checked against `01-architecture.md`, `02-dataflow-diagram.md`, `05-sample-logs.jsonl`
**Date:** 2026-11-01
**Method:** All twelve rows (C-01 to C-12) are checked individually. Each asserted control is checked first against the architecture. Where the architecture is silent or contradicts it, the audit log and data-flow document are used to establish what actually happened. Nothing in the form counts until an artefact confirms it — including the "No" answers, which are verified as truthful rather than taken at face value.

---

## 1. Claim-by-claim check

| Id | Control claimed | Response | Verified against artefacts? | Verdict |
|----|-----------------|----------|-----------------------------|---------|
| C-01 | Accountable owner named for Assist | Yes | `01` header names the Assist platform team as owner | **Holds** |
| C-02 | Changes go through peer review / release approval | Yes | `01` header: "Status: approved for build review" + named owner, consistent with a release process; logs are runtime, not CI records, so no contradiction. | **Holds (architecture-consistent)** |
| C-03 | Tool calls scoped to signed-in customer | Yes | `01` §3 identity binding; `05` `auth_denied / customer_ref_not_session_identity` at `evt_000085`, `evt_000135`, `evt_000161`, `evt_000180` | **Holds** |
| C-04 | Regulated data encrypted in transit and at rest | Yes | `01` §4 (TLS + platform DB encryption); `02` shows TLS legs | **Holds** |
| C-05 | DPA signed with model provider | Yes | `04-dpa-excerpt.md` is the signed DPA (Larkspur ↔ Corvane, cl. 3–6). Confirmed by the artefact. | **Holds** |
| C-06 | Sub-processors listed and approved | Yes | `04` cl. 6.1 names Schedule 2 sub-processors (cloud host + content-review vendor), provider responsible. Confirmed. | **Holds** |
| C-07 | Refunds require human approval before execution | Yes | `01` §5 (`human_required_all_amounts`); `05` every `issue_refund` has `approval.mode: human` + named approver; one `denied` (`evt_000275`) | **Holds** |
| C-08 | Ingested content is source-verified | Yes | `01` §5 (allowlist + `docs-ci` signing); `05` `ingest_rejected / unverified_source` (`evt_000015`, `evt_000081`…), signed `ingest` (`evt_000094`, `evt_000225`) | **Holds** |
| **C-09** | **Tool inputs are schema-validated before execution** | **Yes** | **Architecture contradicts it; logs disprove it (see §2)** | **FALSE** |
| C-10 | Regulated fields stripped before the model call | Yes | `01` §5 (`regulated_field_scrubber_scope: all_model_context`); `02` (`paths_to_provider_without_scrubbing: none`); `05` `model_call` records `scrubbed: [iban, billing_address, tax_id]` (`evt_000031`, `evt_000078`, `evt_000125`) | **Holds** (before the model call only — see note) |
| C-11 | Tool calls and approvals written to an audit log | Yes | `05` is the audit log, schema v3; approvals recorded | **Holds** |
| C-12 | Regulatory classification performed | No | Verified truthful: no classification appears in `01`, `02`, `04` or `05`, and `01` §6/§7 funds none. The "No" is accurate, confirmed absent across the dossier. | **Holds (truthful negative)** |

Note on C-10: the claim is literally true for the direction it names — regulated fields are stripped *before the model call*. It is not evidence of end-to-end protection: there is no reply-side filter (`01` §7 F2 unfunded). Scoped as written, C-10 holds; it is not the false claim.

---

## 2. The false claim: C-09

**C-09 asserts:** "Tool inputs are schema-validated before execution. Response: **Yes**. Evidence cited: Gateway schema checks described in the tool-gateway design note."

This is the one claim in the form that is false. It is disproved by three independent artefacts, not by an inability to find the control.

**Disproof 1 — the architecture states the opposite.**
`01-architecture.md` §5, machine-readable configuration as deployed to staging:
```
tool_args_validation: none_passthrough
```
and in prose: *"`tool-gateway` passes the model's tool arguments to the tool implementation as produced. Each tool parses what it needs; there is no schema check at the gateway. Free-text fields such as `reason` and `filter` reach the tool unmodified."*
The control C-09 claims is not merely undocumented — the architecture explicitly configures its absence.

**Disproof 2 — every log event confirms validation is skipped.**
In `05-sample-logs.jsonl`, every `tool_call` record carries:
```
"validation": "skipped"
```
There is no tool call anywhere in the log with validation applied. The runtime state matches the architecture, not the form.

**Disproof 3 — an unvalidated payload actually executed.**
`evt_000233`:
```json
{"kind":"tool_call","tool":"billing_lookup",
 "args":{"customer_ref":"cus_bc6c3f","period":"current","filter":"status='open' OR 1=1"},
 "validation":"skipped","context_origin":"user_message"}
```
followed by `evt_000234`:
```json
{"kind":"tool_result","tool":"billing_lookup","status":"ok",
 "fields_returned":["invoice_id","invoice_total_cents","card_last4","iban","billing_address","tax_id"]}
```
An injection-style `filter` value (`OR 1=1`) passed through the gateway unmodified and the tool executed successfully (`status: ok`), returning the full regulated field set. A gateway that schema-validated tool inputs would have rejected this argument. It did not, because that control does not exist.

---

## 3. What the organisation believes vs what is true

**What Larkspur currently believes (because C-09 says Yes):** that tool inputs crossing the gateway are schema-validated before execution, so malformed or hostile tool arguments cannot reach the billing tools. On the strength of that belief, the self-assessment presents the agent's tool surface as a controlled boundary, and anyone reading the form — the product VP, the board, a future auditor — treats injection through tool arguments as already handled.

**What is actually true:** the gateway performs no validation (`none_passthrough`). Every tool argument the model produces, including attacker-influenced free-text `reason` and `filter` fields, reaches the tool exactly as written, and the log already contains one such payload executing against the billing data. The protection everyone downstream is relying on does not exist.

---

## 4. Why a paper-only control outranks every other finding

Every other risk in this dossier is a known, visible gap: the missing reply-side filter, the absent spend cap, the unfunded kill switch. Those are honestly costed on the engineering backlog (`01` §7), so the organisation knows it does not have them and can decide what to fund.

C-09 is different in kind. It is a gap the organisation **does not know it has**, because the form says it is covered. A visible gap gets watched; a gap hidden behind a green "Yes" gets designed around. Controls elsewhere, mitigations, risk acceptances and the board's deployment decision are all built on top of a validation layer that is not there — so the one falsely-claimed control silently undermines the assurance value of the whole file. Taking the self-assessment at its word is the single most dangerous move available here, precisely because everyone downstream then relies on a protection nobody has.

**Recommendation:** treat C-09 as the top-priority finding. Either build the gateway schema validation the form claims (closes the gap and makes the form true) or correct C-09 to "No" and re-plan around the real tool surface. Until one of those happens, no risk decision that assumes tool-input validation is sound.
