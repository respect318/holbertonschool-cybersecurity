# Engagement Scope — Calderis Banque

**Client:** Calderis Banque
**Firm:** Halberd Security
**Lead:** Sofia Reyes
**Tester:** Student, Halberd Security

## Authorized Targets

Two systems are in scope, both reachable on the lab host under a shared session and ledger:

- **Calderis Direct** — the customer online-banking portal and its API (v2). Covers accounts, balances, statements, beneficiaries, wire transfers, cards, customer profiles, and the operations back office.
- **Calderis SecureCheck** — the card-authentication service that decides whether to challenge a cardholder and produces the authentication result a payment is authorized against. A merchant checkout sandbox (Mercatia) is provided to drive full payment flows against it.

No target outside this lab host is in scope. No other customer, system, or third party is authorized.

## Exploitation Boundary

All testing is authorized, controlled, and reversible. Concretely:

- Exploitation is limited to actions that demonstrate impact, not actions that maximize it. One successful request proving a flaw is sufficient; no bulk data extraction beyond what a milestone requires.
- Actions are minimal: the smallest lab amount, the smallest data set, the smallest number of accounts touched, needed to prove the point.
- Nothing destructive is performed against another seeded customer's data beyond what a task explicitly calls for, and nothing leaves the lab environment.
- Recovered identifiers (card numbers, IBANs, flags) are treated as lab-only and are never reused outside the lab.
- The lab reset endpoint (`POST /api/lab/reset`) is used between attempts to return to a clean, seeded state when needed.

## Asset Criticality Model

Assets are ranked by whether they move money or change authority, not by ease of discovery:

**Crown jewels (critical):**
- Authentication and session handling
- Account balances
- Wire transfers and beneficiaries
- Segment and limit controls
- The SecureCheck payment-authentication flow
- The operations back office
- The audit trail

**Peripheral (lower priority):**
- Cosmetic profile fields, static content, and anything that does not move money, does not change authority, and cannot be chained into a crown-jewel flow.

A finding's severity is judged by what it enables downstream — an information leak is scored by what it unlocks four steps later, not by the leak itself.

## Phase Plan

1. **Reconnaissance & surface mapping** — enumerate endpoints across the portal, SecureCheck, and the merchant sandbox with Burp; identify the deprecated/legacy API version alongside v2.
2. **Identifier discovery & enumeration** — map object identifiers (customer numbers, card references, transfer/beneficiary IDs) and test how they are validated or leaked.
3. **Access-control abuse** — test object- and property-level authorization across accounts, cards, and back-office functions.
4. **Business-logic exploitation** — test state-machine transitions, mass assignment, idempotency, and time-of-check/time-of-use races in transfers and segment/limit logic.
5. **Payment-flow attack** — test what each SecureCheck message actually proves and whether the authentication result is bound to its transaction (amount, merchant, currency).
6. **Chaining** — combine findings across phases into a single path from ordinary customer login to a completed high-value payment on a card that is not the tester's own.
7. **Validation & reporting** — confirm each flag's evidence is reproducible from the tester's own session, then compile the single end-of-engagement report with OWASP 2025 mapping (A01, A04, A06, A07, A08, A09).

## Lab Access Confirmation

SSH access to the workstation and the web/code-editor terminals is confirmed. Burp Suite is configured and proxying all three lab surfaces before any testing begins:

- Calderis Direct — `http://10.42.51.233/`
- Calderis SecureCheck — `http://10.42.51.233/securecheck/`
- Mercatia checkout sandbox — `http://10.42.51.233/checkout/` (and `/mercatia/`)

Testing begins only once proxy history confirms traffic is captured on all three.
