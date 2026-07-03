# Resource Plan, Nordstrøm Power Group

## Team composition (count, seniority, skills)

A seven-person core team, deliberately not flat in seniority or skill — the mix mirrors the phased, multi-subsidiary scope architecture rather than a generic staffing template.

| Role | Seniority | Core skills / language | Primary responsibility |
|---|---|---|---|
| Engagement Partner | Senior | Scandinavian-language fluency (Norwegian/Swedish), board-level reporting | Client interface with Elin and the board, commercial ownership, holds the 90-day delivery commitment |
| Lead IT/OT Architect | Senior | PTES design authority, MITRE ATT&CK and ATT&CK for ICS | Owns the methodology, sequences findings across phases, sign-off on scope boundaries (e.g., no active exploitation of live safety-instrumented systems) |
| Senior IT/Web Penetration Tester | Mid-Senior | OWASP, ATT&CK, credential-path testing | Corporate IT across all five subsidiaries; leads Denmark's trading-platform testing and the Sweden AD/historian lateral-movement work |
| OT/ICS Specialist | Mid-Senior | GICSP-equivalent certification, ATT&CK for ICS, SCADA/PLC architecture review | Norway offshore gas, Netherlands hydrogen, Denmark turbine OEM channel, Sweden wind SCADA — the group's OT-aware capability |
| German-Speaking Security Consultant | Mid | German fluency, M&A/integration security review | Owns the entire Germany workstream: legacy-asset and vendor-contract inventory, admin-account deprovisioning review, and the Phase 3 independent assessment |
| Regulatory/NIS2 Analyst | Mid | NIS2 transposition awareness, NIST 800-53 control mapping | Maps findings to jurisdiction-specific reporting obligations (Ptil, MSB, Danish Energy Agency, Cyberbeveiligingswet, BSI/NIS2UmsuCG) and owns the control-mapping layer for Germany |
| Junior Security Analyst | Junior | OSINT, documentation, evidence handling | Supports intelligence gathering, testing logistics, and the split reporting cadence (interim baseline, subsidiary OT reports, Germany report) |

This is not a homogeneous team applied uniformly to a homogeneous client: OT capability, German-language capacity, and regulatory expertise are named roles because the alternative — discovering mid-engagement that nobody on the team reads German or understands NIS2 transposition differences — is exactly the change-order trap an architect is supposed to avoid.

## Weekly allocation and total consultant-days

Allocation is deliberately uneven by role and by phase — it follows the same value-first logic as the scope architecture rather than spreading everyone evenly across 16 weeks.

| Role | Phase 1 (wks 1–4, days/wk) | Phase 2 (wks 5–10, days/wk) | Phase 3 (wks 11–16, days/wk) | Total days |
|---|---|---|---|---|
| Engagement Partner | 1 | 1 | 1 | 16 |
| Lead IT/OT Architect | 3 | 3 | 2 | 42 |
| Senior IT/Web Pentester | 4 | 1 | 2 | 34 |
| OT/ICS Specialist | 0 | 4 | 1 | 30 |
| German-Speaking Consultant | 2 | 1 | 4 | 38 |
| Regulatory/NIS2 Analyst | 1.5 | 2 | 1 | 24 |
| Junior Security Analyst | 2.25 | 3 | 1.5 | 36 |
| **Phase total** | **55** | **90** | **75** | **220** |

The pattern is intentional, not filler: the OT/ICS Specialist is at zero in Phase 1 because no OT testing happens then; the German-Speaking Consultant ramps from light inventory work in Phase 1 to full-time in Phase 3, matching the scope architecture's decision to defer Germany's active assessment; and the Senior Pentester's Phase 2 dip reflects that IT exploitation work is largely complete by then, with effort shifting to OT-adjacent support. Total core-team effort across the three fixed-fee phases is **220 consultant-days**, consistent with the 55 / 90 / 75-day estimates set in the scope architecture. Phase 4 (retainer) is staffed separately at 20–30 days per quarter, drawn mainly from the Regulatory/NIS2 Analyst and Junior Analyst, scaled to remediation and notification volume rather than fixed in advance.

## External specialists (in / out, with rationale)

**External OT/ICS engineer subcontractor — IN, scoped narrowly to Phase 2, Netherlands hydrogen only.** The core team's OT/ICS Specialist is already carrying Norway, Denmark's turbine channel, and Sweden's wind SCADA at close to full-time load during Phase 2's six weeks. Hydrogen production and storage control is also the one OT environment in the group with no directly comparable prior engagement history for the team to draw on internally — it is genuinely novel infrastructure with distinct process-safety characteristics. Bringing in a short-term subcontractor (roughly 15–20 days, paired with the internal specialist) for the Netherlands review specifically is cheaper and lower-risk than either delaying the hydrogen assessment or having the internal specialist review an unfamiliar environment alone. The same case does not apply to Norway, Sweden, or Denmark, where the internal specialist's existing offshore-gas and SCADA experience is sufficient — so this is a targeted inclusion, not a blanket OT-subcontracting decision.

**External legal/NIS2 advisor — IN, engaged from Phase 3 through Phase 4, not embedded in Phases 1–2.** The internal Regulatory/NIS2 Analyst handles technical control-mapping and drafts jurisdiction-aware findings language, but two questions in this engagement are legal-determination questions, not technical ones: whether Germany's solar assets meet the KRITIS threshold post-acquisition (currently unresolved), and how Denmark's REMIT reporting obligations interact with any trading-platform findings. Neither question can be answered by a security consultant regardless of seniority — they require licensed counsel with standing in the relevant jurisdiction. Engaging the legal advisor starting in Phase 3, rather than from day one, matches when these determinations actually become load-bearing: Germany's KRITIS status matters once the Phase 3 independent assessment is producing reportable findings, not during the Phase 1 interim baseline. Keeping this as an external, hourly-engaged advisor rather than a core team seat also avoids pricing full-time legal capacity into a workstream that is genuinely intermittent.
