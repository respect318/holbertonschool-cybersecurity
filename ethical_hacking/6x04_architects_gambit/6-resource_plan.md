# Resource Plan, Nordstrøm Power Group

## Team composition (count, seniority, skills)

The core team is 6 consultants, structured to cover both IT/OT technical delivery and the group's regulatory and language surface without over-staffing the engagement.

| Role | Seniority | Count | Core skill(s) |
|---|---|---|---|
| Engagement Lead / Architect | Partner-level | 1 | Overall design authority, board-facing reporting, quality assurance across all subsidiaries |
| Senior Penetration Tester (IT) | Senior | 1 | Corporate network, cloud, and Active Directory attack paths across the holding and subsidiaries |
| Senior OT/ICS Specialist | Senior | 1 | OT-aware testing methodology (safe-testing protocols for SCADA/RTU environments, IEC 62443 familiarity) |
| Mid-level Consultant, DACH region | Mid-level | 1 | German-speaking; leads on-site liaison and testing coordination for the German subsidiary |
| Mid-level Consultant, Nordics region | Mid-level | 1 | Scandinavian-language capability (Swedish/Norwegian/Danish working fluency); primary interface with the Nordstrøm holding company and board secretariat |
| Junior Consultant | Junior | 1 | Evidence collection, findings documentation, retest support, shadowing senior staff for skills transfer |

This gives a 1 lead : 2 senior : 2 mid : 1 junior mix — senior-heavy enough to carry the technical risk of OT testing, but with mid-level language coverage built in rather than bolted on, so the German subsidiary and the Nordic holding company each have a native-fluent point of contact from day one instead of relying on translated status updates.

Skills coverage across the team as a whole:
- **OT-aware testing:** covered by the Senior OT/ICS Specialist, with safe rules-of-engagement input reviewed by the Engagement Lead before any live OT touch.
- **NIS2 / EU cyber-regulatory expertise:** covered by the Engagement Lead, who maps findings to NIS2 risk-management and incident-reporting obligations, supported by the external legal specialist below for jurisdiction-specific interpretation.
- **German-speaking capability:** covered by the DACH-region Mid-level Consultant, who conducts interviews and status calls with the German subsidiary's local IT staff in German where needed.
- **Scandinavian-language / holding interface:** covered by the Nordics-region Mid-level Consultant, who is the preferred-language point of contact for the parent holding company's board secretariat and steering committee.

## Weekly allocation and total consultant-days

Engagement length: 8 weeks, structured in four phases.

| Phase | Weeks | Lead | Sr. IT | Sr. OT | DACH Mid | Nordics Mid | Junior | Days this phase |
|---|---|---|---|---|---|---|---|---|
| 1. Scoping & mobilization | 1–2 | 5 | 3 | 3 | 3 | 3 | 5 | 22 |
| 2. IT & holding-company testing | 2–4 | 5 | 15 | 3 | 5 | 10 | 10 | 48 |
| 3. OT + German subsidiary testing | 4–7 | 8 | 8 | 15 | 15 | 5 | 10 | 61 |
| 4. Reporting, board readout, retest window | 7–8 | 8 | 3 | 3 | 3 | 5 | 5 | 27 |

**Total consultant-days: 158 days** across the 8-week engagement.

Allocation logic: Phase 1 is deliberately light and lead/junior-heavy (scoping, access provisioning, safety briefings). Phase 3 is the heaviest phase because it concentrates the two highest-risk workstreams — live OT testing and the German subsidiary's still-incomplete-integration environment — and pairs the OT Specialist with the DACH consultant so language and technical coverage overlap exactly when both are needed most. Phase 4 keeps the Nordics consultant weighted higher than other mid-level roles to support the board-facing readout.

## External specialists (in / out, with rationale)

**Legal NIS2 Advisor — Included.**
The engagement spans a Nordic holding company and a German subsidiary, meaning findings must be framed against both the general NIS2 transposition and any member-state-specific incident-reporting timelines and penalty regimes that differ between Norway/Sweden-type frameworks and Germany's implementation. Getting this wrong in the board-facing report creates real legal exposure for Nordstrøm and reputational exposure for us, and it is not a skill any consultant on the core team holds at advisory quality. We include this specialist for a bounded scope: reviewing the regulatory-mapping section of the final report and advising on the German subsidiary's specific reporting obligations, rather than a general seat on the engagement.

**OT Engineer Subcontractor — Excluded.**
The core team already carries a Senior OT/ICS Specialist with safe-testing methodology experience, and the RFP's likely scope treats OT testing as assessment-level (safety-constrained, non-disruptive) rather than deep engineering work such as PLC logic review or physical relay reconfiguration. Bringing in a dedicated OT engineering subcontractor would add cost and an additional onboarding/NDA cycle without a clearly defined task that the existing OT Specialist cannot already perform. We flag this as a decision to revisit only if scoping clarifies that deep OT engineering-level testing (rather than OT-aware IT-side assessment) is required — at which point a subcontractor should be added as a change order rather than staffed speculatively now.
