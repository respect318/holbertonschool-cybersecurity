# Engagement Report, Nordstrøm Power Group
For: Elin Solberg (CISO) and the Nordstrøm board

## 1. Executive summary (no jargon)

This engagement tested how much of Nordstrøm Power Group's business could be seen and reached from outside the company, without touching anything that would put operations, customers, or partners at risk. The short answer: more than the group would want a stranger to see, and the most sensitive part of that exposure sits in the recently acquired German solar business, where integration work is still underway.

Three things stand out for the board:

1. **A third-party-facing supplier system was reachable and usable with no special access.** This is a governance and vendor-trust issue, not just a technical one — it is the kind of gap that shows up in procurement and supply-chain risk reviews, not only in IT audits.
2. **The German subsidiary's systems exposed internal business and asset information** through a connection point used to integrate it with the rest of the group. Because the acquisition and integration are not yet complete, this is exactly the kind of gap that acquisitions create and that closes only once integration governance catches up with the deal itself.
3. **That same connection point showed a plausible path toward the German subsidiary's operational technology (the systems that run physical equipment)**, though we deliberately stopped short of touching anything operational. We are not saying operational systems were breached; we are saying the door was found to be thinner than it should be, and it deserves a dedicated, careful look before anyone waits for an incident to prove the point.

Everything above was demonstrated safely, on a controlled evidence set, with no production system, customer data, or operational technology altered. We recommend the board treat the German subsidiary's integration as a named, time-bound risk item in the three-year strategic plan, fund a focused follow-up (described in Section 7), and use this report's country-by-country framing — rather than a single "EU compliance" label — when tracking NIS2 readiness across the group's five subsidiaries.

## 2. Context and methodology

Nordstrøm Power Group engaged us to assess the security posture of its holding company and five national subsidiaries (Norway offshore gas, Sweden hydro and wind, Denmark offshore wind and trading, Netherlands gas and hydrogen infrastructure, and the recently acquired Germany utility-scale solar business), with particular attention to the German subsidiary's incomplete integration and the group's upcoming NIS2 obligations.

The engagement was executed in two phases, reconstructed from a controlled, offline evidence bundle rather than live testing against production systems (see Section 8 for why, and what that does and does not limit).

**Phase 1 — public and peripheral surface.** We enumerated the group's public DNS footprint, correlated it against TLS certificate data, and probed public-facing hosts (the corporate site, investor relations portal, and apex domain) alongside one peripheral, third-party-facing system: the supplier onboarding portal. Assets tagged as belonging to deferred, OT-adjacent, or integration-tier scope (VPN, trading interfaces, hydro operations portal, gas integrator, telemetry gateway) were identified but deliberately not pursued, in line with the phase boundary agreed for this stage. This phase produced two confirmed results: the group's public attack surface was fully mapped, and a controlled, read-only foothold was reached on the supplier onboarding workflow with no destructive action taken.

**Phase 2 — targeted escalation.** Using the integration-tier asset identified in Phase 1 (the German subsidiary's solar telemetry integration API), we escalated in a controlled, read-only manner. This is the phase that matters most for the strategic plan: it moved from "what can be seen" to "what can be reached and what does that expose," on the one subsidiary the board has already flagged as higher-risk due to its recent acquisition. Two things were confirmed: the integration API returned real business and asset metadata (a data exposure), and that same metadata revealed enough about the associated operational telemetry gateway to validate a plausible pivot path toward OT — without any OT command being sent. The engagement closed with a logged cleanup pass, confirming every artefact or temporary access created during testing was removed and the environment was verified restored.

Methodology was adapted deliberately, not improvised: Phase 1 was bounded to public/peripheral surfaces to avoid touching higher-value flows before evidence justified escalation; the supplier portal was chosen as a commercially relevant but bounded proof point; the German integration API was selected for Phase 2 specifically because the acquisition integration makes it strategically important; identification (suspicion) was kept visibly separate from confirmed exploitation (proof) throughout, because a board cannot act on a maybe; and cleanup was logged and verified so the engagement's execution posture is demonstrably reversible and controlled.

## 3. Threat profile synthesis (post-execution)

Going into this engagement, the working assumption was a fairly generic one for a multi-national energy group: public-facing web assets carry low-to-medium risk, third-party integrations carry unknown risk pending testing, and OT environments carry high impact but were assumed to be well-segmented from IT, especially where cross-border and cross-subsidiary integration is involved.

Execution sharpened that picture in two ways:

- **The third-party/supply-chain surface is a real, demonstrated entry point, not a theoretical one.** The supplier onboarding portal was not just visible — it was usable read-only with no authentication friction. This elevates supplier and procurement-facing systems from "assumed low risk" to "confirmed governance gap" across the whole group, not just Germany.
- **The IT/OT boundary in the German subsidiary is thinner in practice than the group's general assumption of segmentation.** The pre-engagement assumption treated integration APIs as pure IT. Phase 2 evidence shows that assumption does not hold for the German subsidiary specifically: the same integration surface that exposes business metadata also leaks enough operational context (gateway labels, routing) to make an OT pivot plausible. This is a subsidiary-specific finding, driven by the recency and incompleteness of that acquisition's integration — it should not be generalised to Norway, Sweden, Denmark, or the Netherlands without separate evidence.

In short: the group-wide threat profile shifts from "OT is separated from IT by default" to "OT separation depends on integration maturity, and the newest, least-integrated subsidiary is the weakest point" — which is exactly the kind of finding a three-year strategic plan should be built around, rather than a document that gets revisited only after the next acquisition.

## 4. Scope delivered and deferred

**Delivered (tested and confirmed):**
- Full public DNS and certificate-based mapping of the group's public surface (holding company apex, corporate site, investor relations portal).
- Controlled, read-only foothold on the supplier onboarding portal (peripheral, third-party-facing).
- Controlled, read-only escalation on the German subsidiary's solar integration API, confirming a business/asset data exposure.
- Controlled validation (metadata/routing level only) of OT pivot potential via the telemetry gateway associated with that same API.
- Full cleanup and restoration, logged and verified.

**Deferred (identified, not tested — explicitly out of this engagement's boundary):**
- Authenticated-area testing of the investor relations portal (D-01) — visible during Phase 1 but held back as an authenticated-access decision point rather than tested blind.
- The VPN/remote-access surface, the Denmark trading interface, the Netherlands gas/hydrogen integrator, and the Sweden/Norway operations portals — all identified in reconnaissance but tagged out of this phase's boundary; none were probed beyond passive identification.
- Any direct OT command-level testing, anywhere in the group — by design, not by limitation of access. This engagement validated pivot *potential* only.

This split matters for the board: what was deferred was deferred on purpose, as a phased and controlled approach, not because it was overlooked.

## 5. Findings by subsidiary and IT/OT (environmental CVSS, prioritised)

CVSS scores below are environmental (context-adjusted for Nordstrøm's actual exposure and compensating factors observed), not vendor base scores, and will be revisited once Phase 3 and Phase 4 (Section 7) provide direct OT and deep-integration evidence.

### Group-wide (IT)

| ID | Finding | IT/OT | Environmental CVSS | Priority | Status |
|---|---|---|---|---|---|
| F-01 | Supplier onboarding portal reachable and usable read-only with no authentication friction | IT | Medium (~5.0–5.5) — peripheral access, but supplier trust and procurement governance are affected group-wide | Medium | Confirmed |
| D-01 | Investor portal authenticated-area depth not tested | IT | Not scored — tracked as deferred scope, not a confirmed finding | Deferred | Deferred |

### Germany (utility-scale solar, recently acquired — IT and IT/OT boundary)

| ID | Finding | IT/OT | Environmental CVSS | Priority | Status |
|---|---|---|---|---|---|
| F-02 | Solar integration API exposed internal business and asset metadata (site, asset class, maintenance windows, telemetry gateway label, business owner) | IT, with OT-adjacent relevance | High (~7.5–8.0) — acquisition integration status and operational metadata content increase business impact beyond a typical IT data-exposure finding | High | Confirmed |
| F-03 | OT pivot potential validated at the metadata/routing layer via the telemetry gateway reachable from the same integration API | OT-adjacent / IT-to-OT boundary | High, trending toward Critical depending on compensating controls not yet evidenced (~7.8–9.0 band); no OT command execution was attempted | High | Confirmed |

### Norway (offshore gas), Sweden (hydro and wind), Denmark (offshore wind and trading), Netherlands (gas and hydrogen infrastructure)

No confirmed findings from this engagement — these subsidiaries' deeper interfaces (trading systems, gas/hydrogen integration, hydro and offshore gas operations portals) were identified in reconnaissance but sat outside this engagement's tested boundary. This should be read as **untested**, not **clean**, and is addressed directly in Section 8.

**Prioritisation logic:** F-02 and F-03 are prioritised above F-01 because they combine confirmed technical proof with a live, board-relevant business driver — an incomplete acquisition integration — rather than because the underlying access mechanism is more sophisticated. Governance impact and acquisition timing, not just technical severity, drove the ranking.

## 6. Strategic-plan recommendations (country-specific NIS2)

These are framed as inputs to the three-year plan, not a remediation checklist for this quarter.

- **R-01 — Acquisition integration controls (Germany, Year 1 priority).** Make security integration a formal, gated milestone of any acquisition's integration plan, not a background IT task. F-02 and F-03 exist specifically because integration is incomplete; the fix is organisational as much as technical.
- **R-02 — Supplier and third-party governance (group-wide, Year 1).** Extend procurement and vendor governance to include a security posture check on any supplier-facing system before it goes live, and periodically thereafter. F-01 is a governance gap, not just a technical patch.
- **R-03 — IT/OT boundary assurance (subsidiary-by-subsidiary, Year 1–2).** Establish a recurring OT boundary assurance review, starting with Germany (via Phase 3, below) and extending to Norway, Sweden, Denmark, and the Netherlands on a rolling basis. Do not assume segmentation holds uniformly across subsidiaries with different acquisition histories and integration ages.
- **R-04 — NIS2-aware governance, country by country (Year 1–3, ongoing).** Norway, Sweden, Denmark, the Netherlands, and Germany each implement NIS2 differently, with different national expectations and, for Norway, EEA-linked alignment considerations rather than direct EU membership. The three-year plan should track NIS2 readiness per subsidiary against its own national implementation, not as one uniform "EU compliance" line item — a single compliance narrative will misstate real exposure in at least one direction for most of these subsidiaries.
- **R-05 — Continuation as a funded plan line item (Year 1).** Fund the Phase 3 and Phase 4 continuation proposed in Section 7 as a named line item, prioritising Germany and other OT-heavy subsidiaries first, rather than treating further testing as optional or reactive.

## 7. Engagement continuation proposal

- **Phase 3 — OT deep-dive.** A dedicated, safety-constrained assessment of OT environments across the group, starting with the German subsidiary's telemetry gateway (to convert F-03's validated *pivot potential* into a definitive segmentation verdict) and extending to Norway's offshore gas and Sweden's hydro/wind operations given their critical operational dependency. This phase would use OT-safe methodology throughout — no live command-level testing without the client's explicit, separately scoped authorisation.
- **Phase 4 — German subsidiary integration review.** A focused review of the German subsidiary's full integration architecture (not just the one API tested here), covering identity and access boundaries between the parent group and the subsidiary, data-sharing agreements, and whether the original acquisition's due-diligence findings were fully remediated or only partially closed. This is the natural, evidence-justified follow-up to F-02.
- **Retainer.** We propose a quarterly assurance retainer covering: (a) a lightweight repeat of the Phase 1 public/peripheral surface check group-wide, given how quickly DNS and certificate surfaces drift; (b) a standing check-in on German subsidiary integration progress against Phase 4's baseline; and (c) NIS2 readiness tracking updates per subsidiary, aligned to each country's national implementation timeline. This keeps the three-year plan grounded in current evidence rather than a single point-in-time report.

## 8. Limitations and uncertainty

We treat this section as part of the deliverable, not a disclaimer buried at the end.

- **This engagement used a controlled, offline evidence model, not live execution against Nordstrøm's actual perimeter.** Every finding above is real in the sense that it was demonstrated against a faithful, lab-modelled reconstruction of the group's environment, but it has not been re-validated against the live production estate. Treat this report as a strong, evidence-based starting point for prioritisation — not as a substitute for confirming these exact findings against production before remediation sign-off.
- **The investor portal's authenticated area remains untested (D-01)**, and is listed under deferred scope rather than scored as a finding.
- **No OT command execution was attempted anywhere in this engagement, by design.** F-03 should be read strictly as validated *pivot potential* at the metadata and routing layer — it is not evidence that OT systems themselves were reached, controlled, or are unprotected at the control layer. Overstating this to the board would be a worse error than the finding itself.
- **Environmental CVSS scores in Section 5 are context-adjusted estimates**, not vendor-issued or independently re-verified scores. We expect them to be revised — up or down — once Phase 3 (OT deep-dive) and Phase 4 (German subsidiary review) provide direct evidence rather than metadata-level inference.
- **Norway, Sweden, Denmark, and the Netherlands should be read as untested, not clean.** The absence of a confirmed finding for these subsidiaries reflects engagement scope and phasing, not a validated clean bill of health.

## 9. Appendices

### Appendix A — Detailed findings register

| ID | Finding | Subsidiary | Country | IT/OT | Evidence source | Status |
|---|---|---|---|---|---|---|
| F-01 | Peripheral supplier onboarding foothold | Group supplier onboarding | Group | IT | Phase 1 action log; supplier portal mirror | Confirmed |
| F-02 | German integration API data exposure | Germany utility-scale solar | Germany | IT, OT-adjacent relevance | Phase 2 action log; integration API evidence samples | Confirmed |
| F-03 | OT pivot potential via telemetry gateway metadata | Germany utility-scale solar | Germany | OT-adjacent / IT-to-OT boundary | Phase 2 action log; gateway routing evidence | Confirmed |
| D-01 | Investor portal authenticated testing deferred | Group investor relations | Group | IT | Phase 1 HTTP observations | Deferred |

### Appendix B — Subsidiary threat and NIS2 context

| Subsidiary | Country | Domain | Report note | NIS2 note |
|---|---|---|---|---|
| Norway offshore gas | Norway | Offshore gas | Critical operational dependency; handle OT conservatively | Do not flatten into generic EU compliance; treat EEA-linked alignment and national expectations explicitly |
| Sweden hydro and wind | Sweden | Hydro and wind | Availability and renewable generation resilience are strategic priorities | Frame through national implementation and energy-sector continuity |
| Denmark offshore wind and trading | Denmark | Offshore wind and trading | Trading interfaces and market data integrity affect operational and financial decisions | Include market-facing resilience and energy-sector governance |
| Netherlands gas and hydrogen infrastructure | Netherlands | Gas and hydrogen infrastructure | Cross-border infrastructure continuity matters | Treat infrastructure integration as a strategic risk |
| Germany utility-scale solar | Germany | Recently acquired solar | Integration in progress; strongest Phase 4 candidate | Use Phase 2 evidence to justify a dedicated German subsidiary integration review |

### Appendix C — Methodology adaptations applied

| ID | Adaptation | Reason |
|---|---|---|
| M-01 | Phase 1 constrained to public/peripheral surfaces | Avoid touching crown-jewel flows before evidence supported escalation |
| M-02 | Supplier portal selected as controlled foothold evidence | Commercially relevant but bounded peripheral proof point |
| M-03 | German integration API selected for Phase 2 | Recent acquisition integration is strategically important |
| M-04 | Identification kept explicitly separate from confirmed exploitation | The board must be able to distinguish suspicion from proof |
| M-05 | Cleanup logged and independently verified | Demonstrates a reversible, controlled execution posture |

### Appendix D — Recovered proof markers (for internal/intranet record)

- Phase 1: `flag{npg_phase1_public_surface_mapped}`, `flag{npg_phase1_supplier_portal_foothold}`
- Phase 2: `flag{npg_phase2_german_api_exposure}`, `flag{npg_phase2_ot_pivot_potential_validated}`, `flag{npg_phase2_cleanup_verified}`
