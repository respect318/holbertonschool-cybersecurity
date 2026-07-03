# Scope Architecture, Nordstrøm Power Group

## In scope / Out of scope (per subsidiary, IT and OT)

| Subsidiary | IT | OT |
|---|---|---|
| **Norway** (offshore gas) | In scope, all phases: corporate IT, offshore-connected DMZ, historian | In scope from Phase 2: engineering workstations, PLC/SCADA for separation and export trains, via passive/architecture-review methodology only — no active exploitation against live safety-instrumented systems, ever, in any phase |
| **Sweden** (hydro and wind) | In scope, all phases: corporate IT, shared AD forest | In scope Phase 1 (lateral-movement path only, since AD/historian domain sharing is the group's clearest quick-win finding) and Phase 2 (full ICS review) |
| **Denmark** (offshore wind and trading) | In scope, all phases: trading platform, market-operations systems | In scope from Phase 2, limited to OEM remote-access and firmware-update-channel review (passive); active turbine-control testing explicitly deferred to Phase 3, contingent on OEM sign-off |
| **Netherlands** (gas and hydrogen) | In scope, all phases: ERP, corporate IT | In scope from Phase 2: hydrogen production/storage control review, passive/architecture-review methodology only, given Seveso major-hazard exposure — no active exploitation of safety-critical setpoints in any phase |
| **Germany** (integration) | **Excluded from Phase 1 active testing.** Phase 1 limited to non-invasive inventory: legacy internet-facing assets, admin-account deprovisioning status, inherited vendor remote-access agreements. Full IT assessment begins Phase 3 | **Excluded until Phase 3.** Solar-plant monitoring and inverter-management platforms are not tested until the pre-acquisition vendor stack and audit evidence have been independently validated |

Explicitly **out of scope for the full engagement** unless a change order is agreed: physical/badge-access red-teaming at any site; social-engineering campaigns beyond a single controlled phishing simulation per subsidiary; any active exploitation of live offshore, hydro-dam, or hydrogen safety-instrumented systems; third-party cloud environments not directly operated by Nordstrøm (e.g., SaaS vendors' own infrastructure); and Denmark's REMIT-regulated trading counterparties' systems, which sit outside Nordstrøm's environment entirely.

## Phase 1 — Group Risk Baseline and Board-Ready Interim Position
- **Perimeter**: Corporate IT and trading/market systems across all five subsidiaries; the Sweden AD/historian shared-domain lateral-movement path specifically; non-invasive Germany inventory (legacy assets, admin accounts, vendor contracts) only. No OT testing in Norway, Netherlands, or Denmark; no active testing of any kind in Germany.
- **Methodology depth**: External and internal IT vulnerability assessment plus targeted credential/lateral-movement testing on the Sweden AD/historian boundary; document and configuration review (not testing) for Germany.
- **Deliverable**: Interim board briefing with a group-wide risk baseline, the Sweden finding, and a Germany integration-risk memo, delivered inside the board's window rather than at the very end of a single 90-day block.
- **Duration**: 4 weeks (days 1–28).
- **Indicative consultant-days**: 55.
- **Commercial rationale**: Elin's board needs a defensible, evidence-based position inside the 90-day cycle; a single 90-day all-in engagement would deliver nothing presentable until the deadline itself, which is the exact trap Henrik's discipline exists to avoid. Phase 1 is priced and scoped to produce a genuinely board-ready interim deliverable at low technical risk (IT-only, no safety-critical OT), while explicitly not claiming Germany or OT coverage it hasn't earned — protecting Nordstrøm from a false assurance and protecting the firm from over-promising in the proposal.

## Phase 2 — OT and Safety-Critical Assessment (Norway, Netherlands, Denmark, Sweden)
- **Perimeter**: Norway offshore gas OT (architecture review, no active exploitation), Netherlands hydrogen OT (architecture review, no active exploitation), Denmark turbine OEM remote-access and firmware-channel review (passive), Sweden full ICS review. Germany remains excluded from active testing; the Germany evidence-validation workstream runs in parallel starting this phase.
- **Methodology depth**: ATT&CK for ICS-aligned architecture and configuration review, network segmentation testing at IT/OT boundaries, vendor remote-access audit; explicitly non-destructive against live production and safety-instrumented systems, consistent with the severity findings in the strategic threat profile.
- **Deliverable**: Subsidiary-level OT risk reports (four), a segmentation-gap register, and a Germany evidence-validation status memo confirming whether the prior audit can be relied upon or requires independent retesting.
- **Duration**: 6 weeks (days 29–70), run partly in parallel with the tail of Phase 1 reporting.
- **Indicative consultant-days**: 90, including ICS-qualified specialist time.
- **Commercial rationale**: This is where the real safety and regulatory exposure sits — Norway and the Netherlands carry the group's highest-severity findings in the threat profile, and both are on national regulatory clocks (Ptil, Seveso/Cyberbeveiligingswet) independent of the board's internal deadline. Pricing this as a distinct phase, after the board has an interim position, lets Nordstrøm fund the specialist ICS work deliberately rather than compressing it into the same 90-day window as everything else, where it would either be rushed or would blow the deadline for all subsidiaries at once.

## Phase 3 — Germany Independent Assessment and Deep-Dive Retesting
- **Perimeter**: Full Germany IT and OT (solar-plant monitoring, inverter-management platforms) assessment, now that legacy accounts and inherited vendor access have been inventoried and the prior-audit reliance question is resolved; active, exploitation-based retesting of the highest-risk findings surfaced in Phases 1–2 (e.g., the Sweden lateral-movement path, any Denmark OEM firmware-channel weakness cleared for active testing).
- **Methodology depth**: Full penetration testing, including active exploitation, for Germany and for the specific Phase 1/2 findings promoted to deep-dive status; independent validation methodology for Germany rather than reliance on the pre-acquisition audit, given the incomplete integration and unresolved conflict-of-interest question around who performed that audit.
- **Deliverable**: Germany-specific report addressed separately from the group report (given its distinct evidentiary basis and, potentially, distinct KRITIS applicability), plus a consolidated deep-dive findings report for the promoted items.
- **Duration**: 6 weeks (days 71–112) — deliberately extending past the board's 90-day internal deadline.
- **Indicative consultant-days**: 75.
- **Commercial rationale**: Germany is not "just another workstream" — its threat picture is dominated by transitional, inherited exposure rather than steady-state risk, and rushing it into the same 90-day window as the other four subsidiaries would mean either skipping the account-deprovisioning and vendor-contract review that actually matters there, or delivering findings built on audit evidence the firm hasn't independently verified. Extending Germany past the board's internal deadline is the deliberate, visible trade-off: Nordstrøm gets a board position on time for the four established subsidiaries, and a defensible, non-inherited position on Germany slightly later, rather than a rushed answer on all five that collapses under scrutiny.

## Phase 4 — Remediation Retest and Regulatory Reporting Support (retainer, not fixed-fee)
- **Perimeter**: Retest of remediated findings across all five subsidiaries; support drafting jurisdiction-specific NIS2/BSI/Ptil notifications where findings cross reporting thresholds; group-wide SOC/EDR extension advisory for Germany's newly onboarded environment.
- **Methodology depth**: Targeted retesting against prior findings only, not a fresh full assessment; advisory support rather than technical testing for the regulatory-reporting workstream.
- **Deliverable**: Retest attestation letters per subsidiary; a regulatory-notification support pack per jurisdiction; a 12-month security-uplift roadmap for Germany's integration into group tooling.
- **Duration**: Ongoing, structured as a retainer rather than a fixed block.
- **Indicative consultant-days**: 20–30 per quarter, scaled to remediation volume.
- **Commercial rationale**: Deliberately not committed as fixed-fee, fixed-scope work in this proposal — remediation timelines and regulatory-notification needs depend on what Phases 1–3 actually find, and pricing this phase precisely now would mean guessing. Offering it as a retainer keeps the proposal honest about what can and cannot be estimated today, which is itself part of the architect's discipline this pack is meant to demonstrate.
