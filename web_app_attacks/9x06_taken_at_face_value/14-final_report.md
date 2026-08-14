# Calderis Banque — Penetration Test Report

**Prepared by:** Halberd Security
**Engagement lead:** Sofia Reyes
**Systems assessed:** Calderis Direct (customer portal and API), Calderis SecureCheck (card-authentication service), Mercatia (merchant sandbox used to drive payment flows)
**Engagement window:** Pre-launch assessment, four weeks ahead of go-live
**Classification:** Confidential — client distribution only

---

## 1. Executive Summary

Starting from nothing more than one ordinary customer login — the same credentials any retail customer receives on day one — our assessor reached a completed high-value card payment charged against another customer's account, without that customer's knowledge or involvement. No credentials beyond the initial login were guessed, phished, or stolen from a third party; every step used only what the platform itself exposed to an authenticated retail user.

Along the way, the same starting point also allowed:

- Reading the personal and financial details — balance, statements, card numbers — of any customer on the platform, not just the one targeted for the final transaction.
- Silently discovering which account numbers at the bank are real and who holds them, at a rate limited only by how fast an ordinary script can send requests.
- Elevating the tester's own account to a higher-privilege customer tier without any approval process.
- Inflating the tester's own account balance by replaying a single banking operation, and separately, moving money in amounts that had never been through the bank's own approval step.
- Making a payment appear fully verified to the merchant even though the bank's own authentication system had not, in fact, confirmed it.

**What this would cost.** Each of the above is independently a live fraud or data-breach vector. Combined, they describe a single unauthenticated-adjacent actor — anyone who can open a retail account — reaching the ability to move an arbitrary amount of money against an arbitrary customer's card, with no manual step, no social engineering, and no insider access required. The technique that produced the final €4,800 charge generalizes without modification to any amount the platform allows a merchant to request.

**What Calderis would have known afterward.** This is the finding most relevant to the bank's own risk posture, independent of the technical fixes: Calderis's audit trail, in its current state, would not have shown this happening. The steps that read other customers' data and moved money left no trace in the event log an investigator could query. The one step that was logged — the tester's own account being promoted to a higher tier, which is exactly the kind of event a fraud team would want flagged — was recorded with an elevated severity marker but never reached the alerting system that would have put it in front of a person. In a real incident, Calderis would be in the position of reconstructing what happened from database forensics rather than from its own monitoring, and would have no reliable way to prove, after the fact, which customer's session performed which action against someone else's account.

**Bottom line for launch.** None of the thirteen issues in this report require insider access, third-party compromise, or specialized tooling beyond a general-purpose scripting environment. Several are independently severe; the remainder become severe specifically because they chain into the payment flow. The remediation roadmap in Section 6 is ordered to break that chain as early and as cheaply as possible, ahead of the go-live date.

---

## 2. Scope, Methodology, Tooling, and Limitations

### 2.1 Scope

Two systems were in authorized scope, reachable under a shared session and a shared ledger:

- **Calderis Direct** — the customer portal and its versioned API (a current version and a still-reachable prior version), covering accounts, balances, statements, beneficiaries, transfers, cards, customer profiles, and the operations back office.
- **Calderis SecureCheck** — the card-authentication service that decides whether a cardholder must be challenged before a payment is authorized, tested via a merchant sandbox that could drive complete payment flows.

No infrastructure outside the lab environment, no real customer, and no real payment network was touched at any point. All customer records, balances, and card numbers referenced in this report are seeded test data.

### 2.2 Methodology

The assessment followed a deliberate phase sequence rather than an opportunistic scan: surface mapping and identifier discovery first, then access-control and business-logic abuse, then the payment-authentication flow specifically, and only then chaining individual findings into a single end-to-end path. Each finding was validated with the smallest request that proved the flaw, then reproduced from a clean session to confirm it did not depend on state left over from an earlier step. The full chain (Finding 12) was independently re-run from a fresh, reset session with all prior test artifacts (elevated tiers, altered balances) discarded, specifically to rule out the possibility that any step only worked because of contamination from earlier testing.

### 2.3 Tooling

Testing combined manual, proxy-assisted analysis with small custom scripts. An intercepting proxy was used to map every host, path, and API version the application exposed and to capture legitimate payment flows message-by-message before any of them were altered. Custom scripts (Python, using standard HTTP libraries) were used for three purposes: reconstructing the bank's own account-number check-digit algorithms to generate valid candidate identifiers, dispatching genuinely concurrent requests to test timing-dependent behavior, and driving the multi-step payment and transfer state machines end-to-end without manual re-entry of tokens between steps.

### 2.4 Limitations and reliability of probabilistic findings

Two findings in this report have a probabilistic component and are reported with that caveat rather than as unconditional guarantees:

- **Finding 8 (balance race condition):** the race window between reading a balance and debiting it is real and was exploited successfully, but the exact number of concurrent requests that succeed varies run to run depending on server load and network timing. Across repeated trials at eight-way concurrency, the majority — not all — of simultaneous requests passed validation; the finding should be read as "the balance check is not reliably atomic," not as "every concurrent request always succeeds." A determined attacker does not need every request to succeed, only enough of them to overdraw the account, which was achieved consistently.
- **Finding 10 (unlimited authentication code attempts):** the absence of a lockout was confirmed directly and is not probabilistic; what is probabilistic is only the cost of brute-forcing the code without any other advantage, which depends entirely on the attacker's available concurrency and the true search space of the code, both of which are discussed in that finding's technical explanation.

No finding in this report relies on timing so narrow, or a success rate so low, that it would not be practically repeatable by a motivated attacker with ordinary scripting ability.

---

## 3. The Attack Chain — One Narrative

The path from an ordinary retail login to a completed unauthorized high-value payment runs as a single logical sequence, where each stage supplies something the next stage needed.

It begins with the observation that Calderis's API rewrite added object-ownership checks to its current API version but never fully retired the version that preceded it (**Finding 1**). That older version is still reachable, and it does not enforce the same ownership checks — so any authenticated customer can ask it for another customer's record simply by supplying that customer's internal identifier. The one piece the attacker is missing at this point — a valid target identifier — turns out to be sitting in plain sight: the session token issued by the *current* API embeds the customer's old-style, sequential identifier (**Finding 2**). Reading that token and incrementing the number by one is enough to start walking the customer base.

Armed with the ability to read arbitrary customer records through the old API, the attacker next needs a way to find *specific* accounts worth targeting — ones with real balances and real cards — without simply guessing customer numbers one by one. The bank's own payee-verification feature, intended to confirm a transfer recipient's name before money is sent, resolves any account number whose check digits are mathematically valid, and those check-digit algorithms are public banking standards, not secrets (**Finding 3**). Reimplementing them turns the verification endpoint into a scanner that returns the name behind every real account number in the bank's numbering range. Combined with Finding 1, this scanner does not just confirm a name — reading the matched account back through the old API discloses its full balance, statement history, and card number, for any customer, not just the attacker's own (**Finding 4**).

At this point the attacker has visibility into the entire customer estate and can choose a high-value target and recover their card number outright. Two more pieces remain before that card can be charged. First, the attacker's own account needs enough standing privilege to push a large transaction through without tripping a low-tier ceiling — achieved by sending the customer-profile update endpoint a field the interface never exposed for editing, promoting the attacker's own account to a higher service tier (**Finding 5**). Independently of the payment path, the attacker can also inflate their own ledger position using unrelated flaws in the transfer state machine: amending a transfer's amount after it has already been bank-authorized but before it settles (**Finding 6**), and replaying a single reversal request to have it credited more than once because the operation was never made idempotent (**Finding 7**) — plus a race between concurrent transfer validations that can drive a balance below what any single check should have permitted (**Finding 8**). These three are not required to reach the final payment, but they demonstrate that the same "trust what was true earlier" pattern recurs throughout the ledger, not only in the payment flow.

The final stage is the payment itself. Calderis SecureCheck can return its authentication outcome to the merchant two ways: through the customer's own browser, or directly from server to server. Only the second is authoritative — but the merchant sandbox accepts whichever the browser reports, without cross-checking it against SecureCheck's own record (**Finding 9**). Separately, the authentication result the merchant receives is not cryptographically or logically bound to the specific card, amount, or transaction it was meant to cover, and a result can be reused for a transaction the cardholder never authenticated (**Finding 11**). Where a genuine challenge to the cardholder is unavoidable, the one-time code protecting it can be brute-forced outright, because failed attempts are not counted against the session by the service itself — only displayed as if they were, by the page (**Finding 10**).

Put together: the attacker reads the target's card number through the deprecated surface (Finding 1, using the identifier space from Finding 2 and the scanner from Finding 3/4), elevates their own account's standing (Finding 5), authenticates a small, unremarkable transaction using their *own* card, and then submits that authentication result to the merchant against the *target's* card and a materially larger amount (Finding 11, exploiting the front-channel trust of Finding 9). The merchant confirms the order. The bank's own SecureCheck record still shows the small transaction it actually authenticated; the merchant's confirmed order shows a payment against a card and an amount SecureCheck never saw. This is Finding 12, reproduced end-to-end from a clean session with no dependency on artifacts left behind by earlier testing.

Finally, walking the same chain a second time while pulling the platform's own audit log alongside it (**Finding 13**) shows that almost none of the above would have generated an event a fraud analyst could see, and that the one step that was logged with high severity — the privilege promotion in Finding 5 — never produced an alert.

---

## 4. Findings

Severity is argued against the engagement's asset-criticality model: **crown-jewel assets** are authentication and session handling, account balances, transfers and beneficiaries, segment/limit controls, the SecureCheck payment-authentication flow, the operations back office, and the audit trail; everything else is peripheral. A finding touching a crown-jewel asset directly, or enabling an attacker to reach one, is scored higher than an equivalent technical flaw touching only peripheral functionality — this is why several findings below that are individually modest in technical complexity carry a **High** or **Critical** rating.

---

### Finding 1 — Deprecated API Version Without Object-Ownership Enforcement

**Severity:** Critical (chain-enabling)
**Component:** Calderis Direct — legacy versioned API
**OWASP Top 10:2025 category:** A01 — Broken Access Control. The finding is a textbook object-level authorization failure (any authenticated user can request any other user's object by ID): the *current* API version enforces ownership on this exact resource, which confirms the control exists in the system's design intent and is simply absent on the surface that was meant to be retired.

**Business impact:** This is the single control gap that the rest of the chain is built on. It converts "authenticated customer" into "any customer's data, on demand," and every later finding that touches another customer's account (2, 3, 4, and ultimately the target-selection step of 12) depends on it being reachable.

**Technical explanation:** The platform's current API version applies object-ownership middleware consistently. A prior API version, superseded roughly eighteen months ago, remains reachable at its own path and responds to identical resource requests without that middleware, returning any customer's full profile and any account's balance, statement, and card data given only their internal identifier.

**Reproduction:** Authenticate normally as any retail customer. Enumerate the application's exposed API surfaces (proxy history, front-end asset references, and the deprecation headers the current API's own responses emit). Request the same object by ID against both the current and the legacy surface; the legacy surface returns the object regardless of who owns it.

**Evidence:** A request against the legacy customer-record endpoint using an identifier that was not the tester's own returned that customer's full profile, including fields the current API does not expose to any user but the record's own owner.

**Remediation:** Retire the legacy API version outright ahead of launch, or, if a deprecation window is contractually required, apply the same ownership middleware to it that the current version already enforces. Do not treat "deprecated" as equivalent to "decommissioned" in access-control terms.

**Detection recommendation:** Log every request to the legacy surface with the requesting session and the object requested; alert immediately on any legacy-surface request where the requester's own customer ID does not match the object ID requested.

---

### Finding 2 — Sequential Customer Identifier Exposed Through the Current API

**Severity:** High (chain-enabling)
**Component:** Calderis Direct — session issuance (current API)
**OWASP Top 10:2025 category:** A06 — Insecure Design. The current API deliberately uses an opaque, non-sequential identifier as its external customer reference — a sound design choice — but then embeds the legacy sequential identifier inside the session token issued to the user, undermining that design choice at the point of session creation.

**Business impact:** This finding by itself discloses nothing about *other* customers — only the holder's own legacy identifier. Its severity comes entirely from what it enables: it hands the attacker the exact key format that Finding 1's legacy surface accepts, and confirms that the ID space is small, sequential, and trivially walkable.

**Technical explanation:** The session token issued at login is a signed but unencrypted structure whose payload is readable by the holder. Alongside the modern opaque identifier, it carries the customer's legacy integer identifier as a plain claim, with no indication that this value is not meant to be read or acted upon by the client.

**Reproduction:** Decode the payload segment of the session token issued at login (no cryptographic key is needed to read a signed-but-unencrypted token's payload). The legacy identifier is present as a top-level field.

**Evidence:** The decoded token payload for the tester's own session contained the tester's legacy identifier as a plain integer, one value away from the account used in Finding 4's proof.

**Remediation:** Remove the legacy identifier from the token payload entirely; if it must be retained for backend correlation, keep it server-side and out of any value returned to the client.

**Detection recommendation:** None specific to this finding in isolation — detection should focus on the resulting enumeration activity described in Finding 1 and Finding 3.

---

### Finding 3 — Payee Verification as an Account-Enumeration Oracle

**Severity:** High (chain-enabling)
**Component:** Calderis Direct — beneficiary verification endpoint
**OWASP Top 10:2025 category:** A04 — Cryptographic Failures. The endpoint's validation logic relies entirely on standard, publicly documented check-digit algorithms (national bank-account key and IBAN check digits) as though computing them correctly were proof of legitimate, authorized access to the underlying identifier space. These are checksums, not secrets — they provide error-detection, not access control — and treating them as a gate around a lookup of real customer names is a cryptographic-control failure: the "proof" the system accepts can be computed by anyone, from public formulas, in constant time.

**Business impact:** This turns a customer-facing convenience feature (confirming a transfer recipient's name) into a mechanism for discovering which account numbers in the bank's numbering range are real, and whose name is attached to each — the precondition for choosing a high-value target in Finding 4 and Finding 12.

**Technical explanation:** The verification endpoint validates a submitted account number's check digits before performing any lookup, and returns a distinct, distinguishable outcome for "checksum invalid," "checksum valid, no such account," and "checksum valid, account found" (with the holder's name). Because the check-digit algorithms are standard published formulas, an attacker can generate large volumes of structurally valid candidate numbers within the bank's own number range and let the endpoint confirm which ones are live.

**Reproduction:** Reimplement the relevant national check-digit algorithm and the IBAN check-digit algorithm; confirm the implementation by reproducing the tester's own account number. Generate sequential candidate account numbers within the same bank/branch prefix, submit each to the verification endpoint, and record which return a positive match.

**Evidence:** A scripted sweep across a bounded range of candidate account numbers, rate-limited to one request roughly every fifth of a second, returned multiple live accounts and their holders' names within seconds.

**Remediation:** Rate-limit and monitor the verification endpoint independently of general API throttling; consider requiring an existing relationship (e.g., a prior transfer or an invitation) before a name is disclosed, rather than disclosing on checksum validity alone.

**Detection recommendation:** Alert on any single session issuing verification requests against a volume or velocity of distinct account numbers inconsistent with normal beneficiary-addition behavior (a handful per session, not dozens or hundreds).

---

### Finding 4 — Cross-Customer Financial Data Disclosure via the Deprecated Surface

**Severity:** Critical (chain-enabling, and independently severe)
**Component:** Calderis Direct — legacy versioned API, account and card resources
**OWASP Top 10:2025 category:** A01 — Broken Access Control, for the same reason as Finding 1: this is Finding 1's access-control gap applied specifically to financial-account and card resources rather than the customer profile resource.

**Business impact:** Independently of the payment chain, this alone is a reportable data-protection incident: any authenticated customer can read any other customer's account balance, transaction history, and full (unmasked) card number. It is also chain-enabling — it is precisely how the target's card number is recovered in Finding 12.

**Technical explanation:** The same legacy surface and ownership gap described in Finding 1 extends to account and card sub-resources. Given an account identifier (obtainable via Finding 3's enumeration), the legacy surface returns the account's balance and movement history; a further legacy endpoint returns the account's associated card in full, unmasked, including the primary account number.

**Reproduction:** Using an account identifier obtained via Finding 3, request that account's record and its associated cards through the legacy surface. Both return in full.

**Evidence:** For an enumerated account, the legacy surface returned a balance in the low five figures (EUR) and a fully unmasked sixteen-digit card number, for a customer with no relationship to the tester's own account.

**Remediation:** Same as Finding 1 — retire or re-secure the legacy surface. Additionally, full unmasked card numbers should not be returned by any API response outside of the specific, narrowly scoped flow that requires them (e.g., the card issuance moment), regardless of API version.

**Detection recommendation:** Alert on any response containing an unmasked card number being served to a session other than the cardholder's own; this should be enforceable independently of which API surface serves it.

---

### Finding 5 — Customer Segment Escalation via Mass Assignment

**Severity:** Critical (chain-enabling, and independently severe)
**Component:** Calderis Direct — customer profile update endpoint
**OWASP Top 10:2025 category:** A01 — Broken Access Control. This is a property-level authorization failure: the endpoint correctly authenticates the caller and correctly scopes the *resource* being updated (the caller's own profile), but fails to restrict which *properties* of that resource the caller may set, allowing a privilege-bearing field to be written by the property's own owner.

**Business impact:** The customer segment is not a cosmetic field — it directly controls the transfer ceiling, exemption behavior in the payment flow, and how much scrutiny a transaction receives. An attacker who can set this field on their own account has, in effect, self-approved themselves for elevated transaction limits with no review. This is also the sole logged-but-not-alerted event described in Finding 13, making it the single highest-leverage point in the whole chain for both the attacker and the defender.

**Technical explanation:** The profile-update endpoint accepts a JSON object and applies it to the customer record. The interface exposes three editable fields to the user; the endpoint itself does not restrict the update to those three fields, and the customer object's segment property — visible in read responses but never offered as an editable field — is accepted and persisted when included in the update payload.

**Reproduction:** Compare the fields the interface offers for editing against the full set of fields present in a read of the customer's own profile. Submit an update containing a field from the read response that the interface never offered, targeting a plausible higher-tier segment value. Re-read the profile to confirm persistence.

**Evidence:** A profile-update request containing only the field `segment` and a value one tier above the account's default returned the updated profile with the new segment value persisted, confirmed by a subsequent independent read.

**Remediation:** Enforce an explicit allow-list of updatable fields on this endpoint, server-side, independent of what the front end happens to render as editable. Segment changes of this kind should additionally require a distinct, privileged workflow (e.g., staff approval), never a self-service field update.

**Detection recommendation:** This is the finding where detection tooling already exists but does not close the loop — the event is logged with elevated severity today. The fix is operational, not technical: route this event class to the alerting pipeline, not only the audit log. See Finding 13.

---

### Finding 6 — Transfer Amount Amendable After Bank Authorization

**Severity:** High (standalone)
**Component:** Calderis Direct — transfer state machine
**OWASP Top 10:2025 category:** A06 — Insecure Design. The transfer workflow's state machine (draft → validated → authorized → settled) assumes each transition is called once, in order, only by the platform's own front end, and does not re-validate transaction-critical fields at the point they actually take effect. This is a design gap, not an implementation typo — the authorization step correctly records the amount it approved, but nothing downstream checks that the settled amount still matches it.

**Business impact:** A customer (or anyone acting through a compromised or scripted session) can authorize a small, unremarkable amount and settle a materially larger one, moving money the bank's own authorization step never approved. This is independent of the payment/card flow — it works on ordinary account-to-account transfers.

**Technical explanation:** The transfer resource can be updated directly between the authorize and settle steps. The authorize step's approved amount is stored separately from the transfer's working amount; settlement reads the working amount, not the amount that was actually authorized, so a change made after authorization and before settlement is honored in full.

**Reproduction:** Drive an ordinary transfer through validate and authorize. Before calling settle, update the transfer's amount field directly. Call settle; the settled amount reflects the post-authorization change, not the originally authorized figure.

**Evidence:** A transfer authorized for a small five-figure-minor-unit amount was amended upward by a factor of twenty before settlement; the settled record showed the amended amount as both the settled and (unchanged) authorized figure in the response, despite the mismatch being directly readable in the transfer's own field history.

**Remediation:** Make the settle step validate the current amount against the amount recorded at authorization time and reject any mismatch; alternatively, lock all transaction-critical fields against further writes the instant a transfer reaches the authorized state.

**Detection recommendation:** Log and alert on any transfer whose settled amount differs from its authorized amount — this should never occur in correct operation and is a reliable, low-noise signal.

---

### Finding 7 — Non-Idempotent Reversal Allows Duplicate Credit

**Severity:** High (standalone)
**Component:** Calderis Direct — transfer reversal endpoint
**OWASP Top 10:2025 category:** A08 — Software and Data Integrity Failures. A reversal is the one ledger operation where funds are created (credited back) rather than moved between two existing balances; without an idempotency guarantee, replaying the same reversal request breaks the integrity of the ledger itself — the same operation is applied more than once with no record distinguishing the retry from a new, legitimate operation.

**Business impact:** A customer can inflate their own balance by an arbitrary multiple simply by resending the same reversal request, with no upper bound observed in testing beyond how many times the request is sent.

**Technical explanation:** The reversal endpoint accepts a request that, per the front end's own behavior, includes an idempotency header intended to prevent duplicate processing. The header is accepted but not enforced — presenting an identical reversal request, including an identical idempotency key, a second time credits the account again rather than being recognized as a retry of an already-completed operation.

**Reproduction:** Capture a legitimate reversal request in full, including its idempotency header, from a genuine reversal flow. Replay the identical request. The account is credited a second time; the response's own reversal counter increments to reflect a second, distinct reversal having been processed.

**Evidence:** Two identical reversal requests against the same settled transfer produced two full credits of the same amount, confirmed both in the response payload and in a subsequent balance read.

**Remediation:** Persist and check idempotency keys server-side before processing any financial-write endpoint, and reject a repeated key with the original operation's result rather than reprocessing.

**Detection recommendation:** Alert on any transfer whose reversal count exceeds one — a legitimate transfer is reversed at most once, so this is a zero-false-positive signal in correct operation.

---

### Finding 8 — Time-of-Check to Time-of-Use Race in Balance Validation

**Severity:** High (standalone)
**Component:** Calderis Direct — transfer validation
**OWASP Top 10:2025 category:** A06 — Insecure Design. The balance check is designed as a read followed by a later write with no locking or atomic reservation between them — a concurrency model that is unsafe by construction once more than one request can be in flight for the same account, regardless of how correct the check itself is in isolation.

**Business impact:** An account holder can overdraw their own balance — moving more money out than the account ever legitimately held — by submitting multiple transfers concurrently rather than one at a time, achieving an outcome the platform's own single-request validation is specifically designed to prevent.

**Technical explanation:** Validating a transfer reads the account's current balance and compares it against the transfer amount; the debit that follows a successful authorization and settlement is a separate, later write. Because the balance read is not locked against concurrent reads, multiple transfers submitted for validation at the same moment can each see the same pre-debit balance and each pass, even when their combined total exceeds it.

**Reproduction:** Establish the account's balance and confirm, with a single transfer, that an amount exceeding it is correctly rejected. Create several transfers whose individual amounts are each within the balance but whose sum exceeds it, then submit their validation requests genuinely concurrently (a real thread pool, not a sequential loop) rather than one after another.

**Evidence:** Across a concurrency sweep, a majority of simultaneously dispatched validations for transfers whose combined value exceeded the account balance were each individually accepted; settling the accepted transfers drove the account balance negative — an outcome the same endpoint reliably prevents when transfers are submitted one at a time (see Section 2.4 for the probabilistic caveat on exact success rate).

**Remediation:** Serialize balance checks per account (a row-level lock or an atomic conditional debit) so that concurrent validations against the same account cannot both observe the same pre-debit balance.

**Detection recommendation:** Alert on any account balance going negative — checking accounts should not be able to reach a negative balance under correct validation, so any occurrence is a strong signal regardless of root cause.

---

### Finding 9 — Merchant Trusts the Browser-Delivered Authentication Outcome

**Severity:** Critical (chain-enabling, and independently severe)
**Component:** Mercatia (merchant sandbox) — payment authorization endpoint
**OWASP Top 10:2025 category:** A07 — Authentication Failures. The authentication result itself may be produced correctly by SecureCheck, but the merchant's acceptance of that result is not bound to a channel the merchant can actually trust — accepting a claimed outcome from the customer's own browser, which the customer controls, is functionally equivalent to accepting a self-reported authentication result.

**Business impact:** This is the single control that, if fixed, breaks the payment side of the chain regardless of what else is or isn't fixed in SecureCheck itself — see Section 6.

**Technical explanation:** SecureCheck can deliver its authentication outcome to the merchant two ways: a value returned to the customer's browser as part of the authentication response, and a server-to-server record the merchant can independently query. The merchant's order-confirmation endpoint accepts the browser-delivered value directly, without cross-checking it against SecureCheck's own server-to-server record before confirming the order.

**Reproduction:** Drive a legitimate authentication that results in a challenge (not an automatic pass). Before completing that challenge, submit the merchant's confirmation endpoint with a browser-channel outcome value indicating success. Independently query SecureCheck's own record for the same transaction.

**Evidence:** The merchant confirmed an order as fully authorized while SecureCheck's own server-to-server record for the identical transaction still showed the authentication as an unresolved challenge, not a completed success.

**Remediation:** The merchant's confirmation logic must query SecureCheck's authoritative server-to-server result directly and never accept a browser-delivered claim of the outcome as sufficient on its own.

**Detection recommendation:** Alert on any confirmed order whose merchant-recorded outcome does not match SecureCheck's own record for the same transaction identifier at the time of confirmation — this pair should always agree in correct operation.

---

### Finding 10 — Authentication Code Attempts Are Not Counted or Limited

**Severity:** High (standalone)
**Component:** Calderis SecureCheck — challenge verification
**OWASP Top 10:2025 category:** A07 — Authentication Failures. A one-time code's security rests entirely on the number of guesses an attacker is permitted, not on the length of the code alone; a service that does not enforce an attempt limit has, in practical terms, no meaningful second factor regardless of how the code itself is generated.

**Business impact:** Wherever a genuine step-up challenge would otherwise have stopped an attacker (including a would-be fix to Finding 9 or Finding 11), that protection is only as strong as this counter — and currently there isn't one.

**Technical explanation:** The verification endpoint returns a simple pass/fail result per submitted code and does not track or cap the number of failed attempts against a given challenge session, either by rejecting further attempts or by invalidating the session after a threshold. A freshly initiated challenge is likewise unaffected by a prior session's failure count. The interface's own page does not display or enforce a limit either, meaning the omission is not merely a display issue but an absence of server-side enforcement.

**Reproduction:** Initiate a legitimate challenge. Submit a large number of incorrect codes against the same challenge session in sequence and confirm no lockout, delay, or rejection occurs. Confirm a freshly initiated challenge is unaffected by the previous session's failed attempts. Submit the correct code after the failed attempts; it is accepted normally.

**Evidence:** Fifty-one consecutive incorrect submissions against a single challenge session were each processed normally with no change in behavior; the fifty-second submission, containing the correct code, succeeded exactly as it would have on a first attempt.

**Remediation:** Enforce a low attempt ceiling (industry norm is three to five) server-side per challenge session, invalidating the session and requiring a fresh challenge to be initiated after the ceiling is reached.

**Detection recommendation:** Alert on any challenge session receiving more than a small handful of failed attempts — this pattern has no legitimate explanation.

---

### Finding 11 — Authentication Result Not Bound to Card, Amount, or Single Use

**Severity:** Critical (chain-enabling, and independently severe)
**Component:** Calderis SecureCheck — authentication/authorization binding
**OWASP Top 10:2025 category:** A08 — Software and Data Integrity Failures. An authentication result is a data assertion about a specific transaction; if the system that consumes it does not verify that the card, the amount, and the single-use status all match what was actually authenticated, the integrity of that assertion is not enforced, regardless of how strong the authentication step itself was.

**Business impact:** This is the finding that makes the final €4,800 charge in Finding 12 possible without ever authenticating against the target's actual card or the actual amount charged — a small, unremarkable authentication on a card the attacker legitimately controls is sufficient to authorize a payment on a card and amount that were never authenticated at all.

**Technical explanation:** The merchant's authorization request carries an amount and a card number independently of the authentication result it references; nothing in the flow verifies that these match the amount and card that were actually presented to SecureCheck at authentication time. Separately, an authentication result was found to remain usable after having already been presented once, rather than being invalidated on first use.

**Reproduction:** Authenticate a small amount on the tester's own card. Submit the merchant's authorization request referencing that authentication result, but with a substantially larger amount and a different card number. Separately, present a single authentication result to the merchant's authorization endpoint a second time against a different order.

**Evidence:** An authentication genuinely completed for roughly ninety euros on the tester's own card was accepted by the merchant as covering a payment of forty-eight hundred euros against a card the authentication was never presented against.

**Remediation:** The merchant authorization step must independently verify, against SecureCheck's own record, that the amount and card number in the authorization request match those actually authenticated for that specific transaction identifier, and must mark authentication results as consumed on first successful use.

**Detection recommendation:** Alert on any authorized payment whose amount or card number does not match the amount and card recorded against the same transaction identifier in SecureCheck's own authentication log.

---

### Finding 12 — Full Chain: Unauthenticated-Adjacent Login to Unauthorized High-Value Payment

**Severity:** Critical (the engagement's headline finding)
**Component:** Cross-system — Calderis Direct, Calderis SecureCheck, Mercatia
**OWASP Top 10:2025 category:** This finding is the composite result of Findings 1, 2, 3/4, 5, 9, and 11 acting together; no single category describes it in isolation, and it is reported here as the chain narrative rather than a category assignment. See Section 3 for the full path.

**Business impact:** Covered in full in the Executive Summary; this finding is the concrete proof that the individually-scoped findings above compose into a complete, unauthorized, high-value fraud path, reproduced from a clean session with no dependency on state left over from earlier testing.

**Technical explanation:** See Section 3.

**Reproduction:** Reset to a fresh session, discarding any prior privilege escalation or balance changes. Recover a target's account and card via Findings 1–4. Escalate the tester's own account segment via Finding 5. Authenticate a small transaction on the tester's own card. Submit the merchant authorization referencing that authentication, but naming the target's card and a high-value amount, exploiting Finding 9's front-channel trust and Finding 11's lack of binding. Confirm the order settles as fully authorized.

**Evidence:** A complete run from a freshly reset session, with no test artifacts carried over from earlier findings, produced a merchant-confirmed order for a high-value item, charged against a card belonging to a customer with no relationship to the tester's session, backed by an authentication that had never been presented against that card or that amount.

**Remediation:** No single fix closes this finding; see Section 6 for the prioritized roadmap. The fastest single point of chain disruption is Finding 9 (validate the authentication outcome server-to-server before confirming any order), which alone prevents this specific end-to-end path regardless of whether Findings 1–5 are also fixed.

**Detection recommendation:** See Finding 13 — this is also the finding whose absence from the audit trail is the most consequential detection gap identified in the engagement.

---

### Finding 13 — Audit Trail Gaps: Unlogged, Mis-Attributed, and Unalerted Events

**Severity:** Critical (standalone, and directly relevant to incident response for every other finding)
**Component:** Calderis Direct — audit logging and monitoring/alerting
**OWASP Top 10:2025 category:** A09 — Security Logging and Alerting Failures. This category explicitly distinguishes logging from alerting, which matches the two distinct gaps found here: most of the chain produced no log record at all, and the one step that was logged never reached the alerting pipeline.

**Business impact:** Independent of every technical fix in this report, this finding determines how quickly — or whether — Calderis would detect a real instance of this chain in production, and whether it could later prove which session performed which action against another customer's account. Detailed evidence and the three-way breakdown (unlogged / mis-attributed / logged-but-unalerted) is provided in the standalone audit-trail deliverable produced during this engagement (`13-attribution_gap.txt`) and summarized here.

**Technical explanation:** Of the entire chain in Section 3 — deprecated-surface reads, identifier enumeration, the mass-assignment segment change, both transfer-integrity flaws, the balance race, and the full payment flow — only two event types were recorded in the queryable audit log for the duration of testing: session logins, and the segment-change event from Finding 5. Every money-moving or data-disclosing step produced no event at all. The audit schema itself has no field to record "this session acted on another customer's data or funds," meaning even a hypothetical future log entry for those actions would misattribute or fail to distinguish an attacker's read of a victim's account from an ordinary self-service action. The one event that was captured — the segment change — was tagged with an elevated severity level but never appeared in the platform's own monitoring/alerts feed.

**Reproduction:** Re-run the chain from Section 3 while concurrently querying the audit-events and monitoring-alerts endpoints. Compare what was performed against what was recorded and what was alerted.

**Evidence:** Across a full chain execution, the audit log contained exactly two event types (login, segment change); the monitoring-alerts feed remained empty throughout, including immediately after the elevated-severity segment-change event.

**Remediation:** Extend audit logging to every financial-write and cross-customer-read endpoint, with both an acting-session field and a target-principal field so that actions against another customer's data or funds are distinguishable from self-service actions. Wire the existing severity tagging into the alerting pipeline so that elevated-severity events actually reach an analyst rather than only the log.

**Detection recommendation:** This finding *is* the detection recommendation for the rest of the report — implementing it is the precondition for any of the other findings' individual detection recommendations being actionable in practice.

---

## 5. Chained vs. Standalone Findings

This distinction determines how a client should sequence remediation work: standalone findings are severe on their own and should be fixed regardless of what else changes; chain-enabling findings derive some or all of their severity from what they make possible downstream, and fixing the chain's weakest link can neutralize several of them at once without necessarily fixing each individually first.

**Chain-enabling (severity depends substantially on the chain):**
- Finding 1 (deprecated API authorization) — enables Findings 2 and 4's cross-customer reach.
- Finding 2 (sequential ID exposure) — supplies the key format Finding 1 accepts.
- Finding 3 (payee-verification oracle) — supplies the target-discovery mechanism for Finding 4 and Finding 12.
- Finding 5 (segment mass assignment) — supplies the elevated standing Finding 12 relies on to avoid a lower-tier ceiling.
- Finding 9 (front-channel trust) — the specific mechanism Finding 12 uses to have a false outcome accepted.

**Independently severe (stand alone regardless of the chain):**
- Finding 4 (cross-customer financial data disclosure) — a reportable data-protection incident on its own, whether or not it is ever chained further.
- Finding 5 (segment mass assignment) — also independently severe: an unauthorized privilege escalation regardless of downstream use.
- Finding 6 (post-authorization amount amendment) — a standalone ledger-integrity flaw on ordinary transfers, unrelated to the payment/card flow.
- Finding 7 (non-idempotent reversal) — a standalone ledger-integrity flaw; money is created from nothing.
- Finding 8 (balance race condition) — a standalone control-bypass on the tester's own account.
- Finding 9 (front-channel trust) — also independently severe: a fundamental authentication-architecture flaw regardless of what specific fraud it is used for.
- Finding 10 (unlimited authentication attempts) — a standalone authentication-strength failure.
- Finding 11 (unbound authentication result) — also independently severe: breaks the integrity guarantee 3-D Secure–style authentication exists to provide, regardless of chaining.
- Finding 13 (audit trail gaps) — a standalone detection and forensic-readiness failure, relevant to every finding in this report and to risks not yet discovered.

Findings 5, 9, and 11 appear in both lists deliberately: each is severe in isolation and additionally supplies a necessary link in the chain — these three should be treated as the highest-leverage remediation targets in the engagement.

---

## 6. Remediation Roadmap

Ordered by how early each fix breaks the attack chain in Section 3, not by finding number or by how quickly each is technically simple to implement.

**Priority 1 — Break the chain at its earliest link (before launch):**
1. **Retire or re-secure the deprecated API version** (Findings 1 and 4). This single change removes the target-discovery and data-disclosure capability the entire cross-customer portion of the chain depends on, and independently closes a standalone data-protection gap.
2. **Remove the legacy identifier from session tokens** (Finding 2). Cheap, and removes the key format the above surface accepts even if it is not fully retired on the original timeline.

**Priority 2 — Close the two findings that are each independently sufficient to prevent the final fraud (before launch):**
3. **Require server-to-server verification of the authentication outcome before merchant order confirmation** (Finding 9). This alone prevents the specific path demonstrated in Finding 12, independent of whether Findings 1–5 are also fixed by launch.
4. **Bind the authentication result to the specific card, amount, and single use** (Finding 11). This closes the second independently-sufficient path to the same fraud, and should be treated as equally urgent to Finding 9 rather than a fallback.

**Priority 3 — Remove the privilege-escalation and enumeration tooling the chain uses to select and prioritize targets:**
5. **Enforce an explicit field allow-list on the profile-update endpoint** (Finding 5). Also route this event's existing severity tag into active alerting — the fastest, lowest-cost detection improvement available given the logging already exists.
6. **Rate-limit and restrict the payee-verification endpoint's disclosure behavior** (Finding 3).

**Priority 4 — Independent ledger-integrity and authentication-strength fixes (before launch, not chain-dependent but each individually exploitable):**
7. Enforce idempotency keys server-side on the reversal endpoint (Finding 7).
8. Re-validate transaction-critical fields at settlement time against the authorized values (Finding 6).
9. Serialize balance checks per account to close the validation race (Finding 8).
10. Enforce a low, server-side attempt ceiling on authentication challenges (Finding 10).

**Priority 5 — Detection and forensic readiness (in parallel with the above, not after):**
11. Extend audit logging to every financial-write and cross-customer-read endpoint with both an acting-session and a target-principal field, and connect existing severity tagging to the alerting pipeline (Finding 13). This should not be sequenced last in practice — it is what allows Calderis to know, going forward, whether Priorities 1–4 were fully effective and to catch anything this engagement did not find.

Priorities 1 through 4 collectively prevent the specific fraud path demonstrated in Finding 12; Priority 5 is what allows Calderis to detect and attribute any future variation of it that a fix here did not anticipate.
