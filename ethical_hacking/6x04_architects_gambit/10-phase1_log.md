# Phase 1 Action Log, Nordstrøm engagement

| Timestamp (UTC) | Phase | Action | Target | Observed result |
| --------------- | ----- | ------ | ------ | --------------- |
| 2026-04-21T09:00:52Z | Recon | Began passive DNS zone review of the Nordstrøm public lab domain | investor.npg-lab.example (npg-lab.example zone) | A/AAAA record resolved; asset tagged `public`/`web-app` in zone snapshot |
| 2026-04-21T09:01:02Z | Recon | Continued DNS zone review | www.npg-lab.example | CNAME resolved; asset tagged `public`/`web-frontdoor` — corporate front door identified |
| 2026-04-21T09:03:16Z | Recon | Reviewed apex domain records | npg-lab.example | SAN record observed; apex confirmed `public` scope, in-bounds for Phase 1 |
| 2026-04-21T09:05:44Z | Attack-surface identification | Reviewed DNS records for a non-core subdomain surfaced in the zone snapshot | supplier-portal.npg-lab.example | TXT record resolved; asset tagged `peripheral`/`supplier-onboarding` — candidate peripheral target for foothold testing |
| 2026-04-21T09:07:13Z | Attack-surface identification | Reviewed DNS records for telemetry-related subdomain | telemetry-gw-solar-de.npg-lab.example | Resolved but tagged `ot-adjacent`; noted as out of Phase 1 boundary and deferred to later-phase handling |
| 2026-04-21T09:07:50Z | Attack-surface identification | Correlated TLS certificate SAN entries against DNS findings | www.npg-lab.example, npg-lab.example | SAN entries confirm www and apex share certificate lineage; public surface boundary corroborated |
| 2026-04-21T09:07:56Z | Attack-surface identification | Issued GET request to the public front door | www.npg-lab.example | HTTP 200, corporate front door reachable, no authentication required |
| 2026-04-21T09:06:37Z\* | Attack-surface identification | Issued GET request to the peripheral supplier-onboarding host | supplier-portal.npg-lab.example | HTTP 200; supplier onboarding workflow reachable with a maintenance header enabled — flagged as a testing candidate |
| 2026-04-21T09:11:34Z | Attack-surface identification | Issued HEAD/GET probes to confirm supplier-portal behaviour under repeated requests | supplier-portal.npg-lab.example | Consistent HTTP 200/302/403 pattern across probes; workflow confirmed stable and in `peripheral` scope, cleared for a controlled foothold attempt |
| 2026-04-21T09:05:02Z\* | Attack-surface identification | Probed the integration-tier API host surfaced in DNS | api.solar-de.npg-lab.example | API help/metadata label visible; asset tagged `integration` scope — noted and deferred, out of Phase 1's public/peripheral boundary |
| 2026-04-21T09:47:25Z | Foothold | Requested the supplier onboarding confirmation workflow on the peripheral host | supplier-portal.npg-lab.example | Read-only onboarding confirmation page reached; no destructive action taken |
| 2026-04-21T09:47:33Z | Foothold | Re-confirmed the read-only foothold on the same peripheral workflow | supplier-portal.npg-lab.example | HTTP 200, confirmation page reached again; no production data or OT system touched. Proof marker recovered and decoded: `flag{npg_phase1_supplier_portal_foothold}` |
| 2026-04-21T09:52:06Z | Recon | Closed out public-surface mapping by correlating certificate SAN coverage across all confirmed public hosts | npg-lab.example; www.npg-lab.example; supplier-portal.npg-lab.example; api.solar-de.npg-lab.example | Combined SAN record confirms the mapped public surface is consistent across apex, front door, and peripheral/integration hosts. Proof marker recovered and decoded: `flag{npg_phase1_public_surface_mapped}` |

\* Rows are ordered by activity type for narrative clarity; timestamps remain the authoritative UTC ordering and are taken verbatim from the source evidence.

## Notes for Task 11 reconstruction

- Two Phase 1 proof markers were recovered and decoded, matching the "two or three flags" expectation for this phase:
  - `flag{npg_phase1_public_surface_mapped}`
  - `flag{npg_phase1_supplier_portal_foothold}`
- Assets tagged `ot-adjacent`, `integration`, or `deferred` (telemetry-gw-solar-de, api.solar-de beyond its help-label identification, vpn, hydro-se-ops, trading-dk, gas-nl-integrator) were identified during recon but intentionally **not** pursued further, per their `scope_zone`/`verdict` tags in the source data — they sit outside the Phase 1 public/peripheral boundary defined in Task 4.
- No live systems were scanned, attacked, or contacted. All rows above are reconstructed from the offline evidence bundle (`materials/artifacts`, `materials/logs`, `materials/mirrors`, `materials/utc`) per the project's `NO_LIVE_TESTING` and `SCOPE_AND_USE` guidance.
- Remember to submit both recovered flags on the intranet, as required by the task.
