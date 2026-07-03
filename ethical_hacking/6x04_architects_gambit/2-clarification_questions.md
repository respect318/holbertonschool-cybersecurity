# Clarification Questions, Nordstrøm Power Group

## Scope

1. Does the engagement scope cover OT/ICS environments (SCADA, RTUs, substation control networks) across all subsidiaries, or is it limited to corporate IT for the group and OT only for the Nordic parent?
   _Informs: whether the methodology needs an IT-only penetration test track or a parallel OT-safe assessment track with different tooling and rules of engagement._

2. Should third-party or vendor-managed systems connected to Nordstrøm's network (e.g., grid maintenance contractors, cloud SCADA historian providers) be treated as in-scope assets or as external dependencies to be documented but not tested?
   _Informs: the boundary drawn in the scope statement and whether a separate third-party risk section is needed in the report._

## Timeline

3. Is there a fixed board reporting date driving when fieldwork must conclude, and if so, how many weeks before that date does the board expect the final report in hand?
   _Informs: how the project timeline is sequenced backward from the deadline, including how much buffer is built in for retesting and report review cycles._

4. Do the subsidiaries need to be tested sequentially (one after another) or can testing run in parallel across the group?
   _Informs: staffing allocation and whether a single team rotates through subsidiaries or multiple teams are engaged simultaneously._

## Budget

5. Is the engagement priced as fixed-fee for the full group, or time-and-materials with a cap per subsidiary?
   _Informs: how contingency is built into the pricing model and whether scope creep in one subsidiary can be absorbed without renegotiation._

6. Is a remediation retest included in the current budget, or would it be scoped and billed as a separate follow-on engagement?
   _Informs: whether the proposal includes a retest phase in the deliverables list or flags it as an optional add-on._

## Constraints

7. Are there change-freeze or peak-load periods (e.g., winter demand season) during which live testing against production OT systems would be prohibited?
   _Informs: the testing calendar and whether OT testing must be shifted to a lab/replica environment instead of production during certain windows._

8. What level of access will testers be granted at the outset — credentialed assumed-breach access, or fully black-box external access?
   _Informs: the testing methodology chosen for Tasks 3-9 and how much time is allocated to initial reconnaissance versus deeper lateral-movement testing._

9. Given that the German subsidiary was acquired recently and its IT/OT integration with the parent group is still incomplete, should the assessment rely on the subsidiary's most recent independent audit findings, or must the team independently validate its security posture given the unresolved integration and the potential conflict of interest if the original auditor is still engaged by the subsidiary?
   _Informs: whether the German subsidiary is scoped for full independent testing, deferred to a later phase, or covered through evidence reliance with a documented reliance caveat in the report._

## Board expectations

10. What level of detail does the board expect in the final deliverable — a technical findings report, an executive risk summary, or both presented separately?
    _Informs: the structure and length of the reporting deliverable and whether a separate board-facing executive summary needs to be drafted alongside the technical report._

11. Does the board expect the results benchmarked against a specific regulatory or maturity framework (e.g., NIS2, IEC 62443, NERC CIP equivalents), or is a narrative risk rating sufficient?
    _Informs: whether the assessment methodology maps findings to a named control framework or uses an internally defined risk-rating scale._

## Technical preferences

12. Is there a preferred testing methodology or standard the group's security team already uses internally (e.g., PTES, NIST SP 800-115, MITRE ATT&CK for ICS)?
    _Informs: which methodology is cited in the proposal and how findings are categorized to align with the client's existing internal reporting language._
