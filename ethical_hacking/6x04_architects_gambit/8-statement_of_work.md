# Statement of Work, Vanguard Security x Nordstrøm Power Group

**Effective as of the date of countersignature below**

## 1. Parties

This Statement of Work ("SoW") is entered into between **Vanguard Security AB** ("Vanguard," "the Firm"), a cybersecurity advisory and testing firm, and **Nordstrøm Power Group AB** ("Nordstrøm," "the Client"), a Scandinavian energy holding company operating through its subsidiaries in Norway, Sweden, Denmark, the Netherlands, and Germany (together, "the Subsidiaries"). This SoW is issued under the Master Services Agreement between the parties and governs the engagement described below. Nordstrøm's primary point of contact is Elin, [title], acting with board sponsorship for this engagement; Vanguard's engagement is led by the Engagement Partner named in Section 6.

## 2. Confirmed scope

This engagement is phased and bounded by design; it is not a single exhaustive assessment of Nordstrøm's group-wide environment. The confirmed scope is:

- **Phase 1 — Group Risk Baseline**: corporate IT and trading/market systems across all five Subsidiaries; the Sweden shared Active Directory/historian domain, specifically its lateral-movement exposure; a non-invasive inventory of Germany's legacy internet-facing assets, administrator-account status, and inherited vendor relationships. No OT testing occurs in this phase, and no active testing of any kind occurs against the German environment.
- **Phase 2 — OT and Safety-Critical Assessment**: architecture and configuration review (non-destructive, no active exploitation) of Norway's offshore gas OT, the Netherlands' hydrogen production and storage control systems, Denmark's turbine OEM remote-access and firmware-update channel, and Sweden's wind SCADA. Germany's evidence-validation workstream begins in parallel but remains confined to document and access review.
- **Phase 3 — Germany Independent Assessment and Deep-Dive Retesting**: full IT and OT assessment of the German subsidiary, conducted independently of the pre-acquisition audit rather than relying on it; active, exploitation-based retesting of the highest-risk findings promoted from Phases 1–2.
- **Phase 4 — Remediation Retest and Regulatory Reporting Support**: retainer-based retesting of remediated findings and advisory support for jurisdiction-specific regulatory notifications, engaged separately per Section 8.

Each phase is a distinct, separately deliverable stage of work. Nordstrøm's agreement to Phase 1 is not an agreement to proceed with Phases 2–4; each subsequent phase is confirmed by written authorization referencing this SoW before work begins, consistent with the phased architecture Vanguard proposed and Nordstrøm reviewed.

## 3. Exclusions and assumptions

**Excluded from this engagement in all phases, absent a signed change order:**
- Active exploitation of any live, safety-instrumented OT system (offshore gas separation/export trains, hydrogen production/storage controls, hydro dam control, wind turbine control) at any point in the engagement.
- Physical or badge-access red-teaming at any Nordstrøm site.
- Social-engineering activity beyond one controlled phishing simulation per Subsidiary.
- Testing of third-party cloud environments not directly operated by Nordstrøm, and testing of Denmark's REMIT-regulated trading counterparties' own systems.
- Full IT or OT testing of the German subsidiary prior to Phase 3.

**Assumptions Vanguard relies on for pricing and scheduling in this SoW:**
- Each Subsidiary will designate a local point of contact able to provide access, credentials, and scheduling confirmation within five business days of the agreed start date for its testing window, per the risk register's subsidiary-cooperation mitigation.
- Nordstrøm will make available, or authorize Vanguard to request directly, any prior due-diligence or audit materials concerning the German subsidiary's acquisition, subject to the evidence-reliance review described in Section 5.
- No material change to the German subsidiary's KRITIS-applicability status or Denmark's REMIT posture occurs between contract signature and Phase 3; if one does, it is addressed under Section 9 (Change Management).

## 4. Deliverables

| Phase | Deliverable |
|---|---|
| 1 | Group-wide IT risk baseline report; Sweden AD/historian lateral-movement findings; Germany integration-risk memo (inventory-based, not a technical assessment) |
| 2 | Four subsidiary-level OT risk reports (Norway, Sweden, Denmark, Netherlands); IT/OT segmentation-gap register; Germany evidence-validation status memo |
| 3 | Germany-specific IT/OT assessment report, presented separately from the group report given its distinct evidentiary basis; consolidated deep-dive findings report for promoted Phase 1–2 items |
| 4 | Per-subsidiary retest attestation letters; jurisdiction-specific regulatory-notification support packs; a 12-month security-uplift roadmap for Germany's integration into group tooling |

All deliverables are provided in English, with the Germany-specific report also provided in German upon request under Section 6's language provisions.

## 5. Milestones and timeline

Recognizing the board's internal 90-day planning cycle, this engagement is structured to deliver a board-presentable position inside that window without collapsing the full five-subsidiary, IT/OT scope into it:

- **Day 1**: Kickoff, authorization confirmation per Subsidiary, evidence-reliance review commenced for Germany.
- **Day 28 (end of Phase 1)**: Interim board-ready baseline delivered — inside the board's 90-day window.
- **Day 70 (end of Phase 2)**: Subsidiary OT reports and segmentation-gap register delivered.
- **Day 112 (end of Phase 3)**: Germany report and deep-dive findings report delivered — deliberately beyond the 90-day mark, a trade-off Vanguard has flagged to Elin directly: Germany's independent-validation requirement is not compatible with a rushed timeline, and Nordstrøm receives a defensible interim board position on time rather than an unqualified answer on all five Subsidiaries that would not withstand scrutiny.
- **Phase 4**: Ongoing on a quarterly retainer cadence following Phase 3 close, per Section 8.

## 6. Team composition

Vanguard staffs this engagement with the following core team, consistent with the resource plan reviewed with Nordstrøm:

- **Engagement Partner** (Senior) — Scandinavian-language fluency, client and board interface, overall delivery accountability.
- **Lead IT/OT Architect** (Senior) — methodology ownership, phase sequencing, scope-boundary sign-off.
- **Senior IT/Web Penetration Tester** (Mid-Senior) — corporate IT, Denmark's trading-platform testing, Sweden's AD/historian work.
- **OT/ICS Specialist** (Mid-Senior) — Norway, Netherlands, Denmark turbine channel, Sweden wind SCADA; supplemented in Phase 2 by a pre-identified external OT/ICS subcontractor for the Netherlands hydrogen review specifically.
- **German-Speaking Security Consultant** (Mid) — owns the Germany workstream end to end.
- **Regulatory/NIS2 Analyst** (Mid) — jurisdiction-specific notification-obligation tracking, control mapping.
- **Junior Security Analyst** — intelligence gathering, testing support, reporting.

An external legal/NIS2 advisor is engaged from Phase 3 onward for the German KRITIS-applicability and Danish REMIT determinations described in Section 5 of the underlying risk register; this advisor is not a Vanguard employee and is engaged under a separate arrangement disclosed to Nordstrøm.

## 7. Pricing structure

Phases 1–3 are priced on a **fixed-fee basis per phase**, calculated against the consultant-day estimates in the resource plan (55 / 90 / 75 days respectively, 220 days total). A fixed fee is appropriate here because the phased scope architecture already bounds each phase's perimeter and depth precisely enough to price with confidence, and because Nordstrøm's board benefits from cost certainty against its internal budget cycle rather than open-ended time-and-materials exposure. Phase 4 is priced on a **time-and-materials retainer basis**, because remediation volume and regulatory-notification needs cannot be estimated accurately before Phases 1–3 findings exist; committing Phase 4 to a fixed fee now would require Vanguard to either overprice for a worst case or underprice against real risk.

## 8. Payment terms

- Phase 1: 50% invoiced on signature of this SoW, 50% invoiced on delivery of the Day 28 interim baseline. Net 30 days.
- Phase 2 and Phase 3: 40% invoiced on written authorization to proceed, 60% invoiced on delivery of the respective phase report. Net 30 days.
- Phase 4: invoiced monthly in arrears against actual consultant-days delivered that quarter, capped at the agreed quarterly ceiling of 20–30 days absent a change order. Net 30 days.
- Late payment beyond 30 days accrues interest at the statutory commercial rate applicable under Swedish law and may, after written notice, result in suspension of active testing until the account is current.

## 9. Change management process

Any request to expand scope beyond a phase's confirmed perimeter — additional Subsidiaries, deeper OT testing, earlier Germany access, or added deliverables — is submitted in writing to the Engagement Partner and evaluated against the current phase's consultant-day budget and timeline. Vanguard provides a written change-order proposal, including revised fee and schedule impact, within five business days. No expanded work begins until the change order is countersigned by an authorized Nordstrøm representative. This process exists specifically to prevent the scope-creep exposure identified in Vanguard's engagement risk register, where board or subsidiary pressure to "cover everything now" would otherwise erode the phased pricing and delivery logic this SoW is built on.

## 10. Confidentiality and intellectual property

Each party will treat the other's confidential information, including all testing findings, credentials, and Nordstrøm's internal systems data, as strictly confidential, disclosed only to personnel with a need to know and bound by equivalent confidentiality obligations. Raw findings concerning the German subsidiary are held under jurisdiction-tagged access controls and are not consolidated into the group-wide evidence repository ahead of the Section 5 evidence-reliance review, consistent with Vanguard's cross-border evidence-handling risk mitigation. Vanguard retains ownership of its underlying testing methodologies, tools, and proprietary frameworks (including its ATT&CK-aligned assessment templates); Nordstrøm receives a perpetual, non-exclusive license to use, reproduce, and act upon the deliverables themselves for its internal risk-management and regulatory-reporting purposes. Nothing in this section restricts a Subsidiary's ability to share relevant findings with a competent national regulator where a legal notification obligation applies.

## 11. Liability and limitation

Vanguard's liability arising from this SoW, whether in contract, tort, or otherwise, is limited in aggregate to the fees paid for the specific phase giving rise to the claim, except in cases of gross negligence, willful misconduct, or breach of confidentiality, where no such limitation applies. Vanguard is not liable for any operational disruption, safety incident, or production loss arising from OT-adjacent testing conducted within the agreed rules of engagement and methodology boundaries set out in Section 3; Nordstrøm acknowledges that the deliberate exclusion of active exploitation against live safety-instrumented systems is itself the primary control against such loss. Neither party is liable for indirect, consequential, or reputational damages, save where such exclusion is not permitted under mandatory law in the relevant Subsidiary's jurisdiction.

## 12. Termination

Either party may terminate this SoW for material breach not cured within 30 days of written notice. Nordstrøm may terminate for convenience at the close of any phase, upon 15 business days' written notice, with payment due for work performed and deliverables completed through the effective termination date; no further phases are then authorized. Vanguard may suspend or terminate work on a specific Subsidiary's workstream, without terminating the SoW as a whole, if that Subsidiary's local leadership fails to provide required access within the timeframe set out in Section 3's assumptions, following the escalation path defined in Vanguard's engagement risk register.

## 13. Governing law and dispute resolution

This SoW, and the Master Services Agreement it is issued under, is governed by the laws of Sweden, reflecting Nordstrøm's holding-company domicile and the Engagement Partner's primary client relationship. Disputes arising from this SoW are to be resolved by binding arbitration under the Rules of the Arbitration Institute of the Stockholm Chamber of Commerce (SCC), seated in Stockholm, conducted in English. This choice is deliberate rather than a default: it gives Nordstrøm's board a single, predictable forum for group-level commercial disputes rather than five separate national court systems.

This governing-law clause does not, and cannot, displace mandatory local law in the Subsidiaries' own jurisdictions. Specifically: (a) any statutory notification obligation under Germany's BSI IT-Sicherheitsgesetz 2.0 or NIS2UmsuCG, the Netherlands' Cyberbeveiligingswet, or equivalent Norwegian, Swedish, or Danish transpositions of NIS2 applies according to its own terms regardless of this clause; (b) any data-protection matter concerning German personal data remains subject to German and EU data-protection law and the jurisdiction of the competent German supervisory authority, notwithstanding the Swedish/SCC forum for commercial disputes between the parties; and (c) any dispute concerning REMIT-regulated conduct in Denmark's trading operations is addressed through the applicable Danish and EU regulatory channels rather than commercial arbitration. Vanguard has flagged this layered structure to Nordstrøm precisely because a single generic governing-law clause would be unenforceable, or worse, misleading, across an engagement spanning five distinct national regimes.
