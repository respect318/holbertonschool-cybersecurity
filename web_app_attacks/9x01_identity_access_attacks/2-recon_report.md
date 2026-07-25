# Reconnaissance Report, Westmark
For: Sofia Reyes and the engagement file

## 1. Endpoints and methods

The following endpoints were identified by browsing Westmark as each authorized test account (customer/user, manager, and administrator) and by replaying the resulting HTTP history in Repeater. Only hosts and paths inside the authorized scope for this engagement are listed; anything reachable outside that boundary was excluded, per Section 5's scope note below.

Public / unauthenticated:
- `GET /login`, `POST /login`
- `GET /register`, `POST /register`
- `GET /password-reset`, `POST /password-reset`, `GET /password-reset/confirm`

Authenticated, customer-facing:
- `GET /dashboard`
- `GET /account`, `POST /account/update`
- `GET /invoices`, `GET /invoices/{id}`
- `GET /orders`, `GET /orders/{id}`
- `GET /support`, `POST /support/tickets`

Authenticated, manager-facing:
- `GET /manager/dashboard`
- `GET /manager/orders`
- `GET /manager/customers/{id}`

Authenticated, administrator-facing:
- `GET /admin`
- `GET /admin/users`, `POST /admin/users/{id}/role`

Parallel `/api/*` surface (used by the same pages via XHR/fetch, observed in HTTP history alongside the browser-rendered routes):
- `GET /api/invoices`, `GET /api/invoices/{id}`
- `GET /api/orders`, `GET /api/orders/{id}`
- `GET /api/internal` (returned data before a browser-facing equivalent could be located; see Section 4 of the browser/API note below)
- `GET /api/users/{id}`, `POST /api/users/{id}/role`

Each endpoint above was requested with the method the application itself issues during normal navigation; no method beyond what the UI naturally produced (GET for reads, POST for the corresponding writes) was invented for this mapping pass.

## 2. Parameters

**Query parameters:** `id` on `/invoices/{id}`, `/orders/{id}`, `/manager/customers/{id}`, and their `/api/*` equivalents, always a small integer; `page` and `sort` on `/invoices` and `/orders` list views.

**Body parameters:**
- Login (`POST /login`): `username`, `password`.
- Registration (`POST /register`): `username`, `email`, `password`, `password_confirm`.
- Password reset request (`POST /password-reset`): `email`.
- Password reset confirm (`GET /password-reset/confirm`): `token`, carried as a query parameter, plus `POST` body fields `token`, `new_password` on the confirm submission.
- Account update (`POST /account/update`): `email`, `display_name`.
- Role change (`POST /admin/users/{id}/role`, mirrored at `POST /api/users/{id}/role`): `role`, sent as a plain string value (`user`, `manager`, `admin`).

**Cookie parameters:** a single session cookie, `westmark_session`, present on every authenticated request regardless of role.

**Header parameters:** the `/api/*` surface additionally accepts an `Authorization: Bearer <token>` header on some calls, observed when the manager dashboard's client-side script issued `/api/orders` requests; the browser-facing `/manager/orders` route relies on the session cookie alone. This split is analyzed further in Section 4.

## 3. Roles and access matrix

Three authorized accounts (`user`, `manager`, `admin`) were used to replay the same captured request against each sensitive endpoint, changing only the session cookie/token between replays and keeping the target resource identical, so that status codes are directly comparable.

| Role    | GET /admin | GET /admin/users | POST /admin/users/{id}/role | GET /manager/orders | GET /invoices/{id} (own) | GET /invoices/{id} (other customer's) | GET /api/invoices | GET /api/internal |
| ------- | ---------- | ----------------- | ---------------------------- | -------------------- | -------------------------- | ---------------------------------------- | ------------------ | ------------------ |
| user    | 403        | 403                | 403                           | 403                   | 200                         | 200 (returned data — see 6.1)             | own only (200)      | 200 (unexpected — see 6.1) |
| manager | 403        | 403                | 403                           | 200                   | 200                         | 200 (returned data — see 6.1)             | broader set (200)   | 200 (unexpected — see 6.1) |
| admin   | 200        | 200                | 200                            | 200                   | 200                         | 200                                       | all (200)           | 200                 |

Read for `GET /invoices/{id}` on another customer's record: for `user` and `manager`, this was tested by replaying a `user`-authenticated request against an `id` value known (from the admin account's own browsing) to belong to a different customer, changing only the session cookie between the baseline and the replay. Both returned `200` with that other customer's invoice content rather than a `403`, which is recorded here as an observed status/behavior and carried into Section 6 as a hypothesis, not as a confirmed exploited finding beyond this single replay.

`GET /api/internal` returning `200` for `user` and `manager` sessions is likewise an observed status code from direct replay, not an assumption, and is treated as a hypothesis pending broader confirmation (Section 6).

## 4. Authentication and session flows

**Login:** `POST /login` accepts `username` and `password` in the request body. A successful response includes a `Set-Cookie: westmark_session=...` header and a redirect to `/dashboard`. A failed login with a nonexistent username and a failed login with a valid username but wrong password were compared side by side in Comparer; both currently return the same status code and near-identical body, which is a positive control worth re-confirming rather than a gap, but the comparison was only done for a handful of samples and is noted as incomplete.

**Registration:** `POST /register` takes `username`, `email`, `password`, and `password_confirm`. No email verification step was observed between registration and the account becoming usable at `/login` — the account was immediately able to authenticate after registering, which is recorded as an authentication-flow observation for Section 6 rather than assessed further here.

**Password reset:** `POST /password-reset` takes an `email` value and returns a generic "if that address exists, a reset link was sent" response regardless of whether the address is registered, which is the expected behavior for avoiding account enumeration through this specific endpoint. The reset link itself carries a `token` query parameter on `GET /password-reset/confirm`; the token observed during testing was long and did not resemble a small sequential value, but its expiry behavior, and whether it can be reused after a completed reset, were not tested during this phase and are flagged as open in Section 6.

**Session mechanism:** the `westmark_session` cookie set at login is the sole credential carried on every subsequent browser-facing request; Inspector shows it as an opaque token rather than a readably-structured value, so its internal claims (if any) could not be read directly the way a Base64 or JWT-style token could. The same cookie value continued to be honored, unchanged, when the `admin` test account navigated from `/dashboard` into `/admin`, and when the `manager` account navigated from `/manager/dashboard` into `/manager/orders` — no re-authentication or step-up challenge was observed at either privilege boundary. This lack of rotation or re-verification at a privilege transition is recorded as a session-mechanism observation and carried into Section 6.

## 5. Sensitive zones

The clearest sensitive zones, based on what each area exposes if access control does not hold, are: the administrator user-management area (`/admin/users` and its role-change endpoint), which can promote or demote any account's privileges; the invoice zone (`/invoices/{id}` and `/api/invoices*`), which exposes customer billing detail and, per Section 3, already showed a cross-customer read on replay; the order zone (`/orders/{id}`, `/manager/orders`, `/api/orders*`), which carries customer purchase and fulfillment detail visible to manager-level accounts and reachable via a parallel API path; the support-ticket zone (`/support/tickets`), which likely carries free-text customer communication and any attachments; and `/api/internal`, whose name and unexpected accessibility to non-admin roles make it the single most concerning item on the map even though its actual contents were only briefly reviewed. Any host or path noticed during crawling that was not on the authorized list for this engagement (in particular, a secondary marketing subdomain observed being linked from the footer) is explicitly excluded from this sensitive-zone list and from the plan below; it is out of scope and was not probed.

## 6. Prioritized hypotheses (each tagged A01 or A07, with endpoint, parameter, and how to test)

Ranked by the combination of likely impact and how directly reachable the hypothesis already is from the accounts already authorized for this engagement, not by the order things were discovered.

**6.1 — [A01] Cross-customer invoice access via `id`.**
Endpoint: `GET /invoices/{id}` and `GET /api/invoices/{id}`. Parameter: `id`. Expected control: the server should reject or scope the request to invoices owned by the requesting account. Test: as the authorized `user` account, request an `id` known to belong to a different customer, changing only that value from a known-good baseline request, and confirm whether the returned invoice content belongs to that other customer on a second, independent sample beyond the single replay already recorded in Section 3.

**6.2 — [A01] Unrestricted read on `/api/internal` from non-admin sessions.**
Endpoint: `GET /api/internal`. Parameter: session cookie only (no per-request parameter). Expected control: this path should require an admin-level session, matching the browser-facing `/admin` behavior. Test: replay the same `GET /api/internal` request under `user`, `manager`, and unauthenticated sessions, changing only the session cookie each time against the same baseline request, and record whether content is returned and what it contains, without pulling the full response into this report until authorized to do so.

**6.3 — [A01] Browser/API authorization mismatch on internal and order data.**
Endpoint: `/api/internal` and `/api/orders` versus their browser-facing counterparts (`/manager/dashboard`, `/manager/orders`). Parameter: none beyond the session cookie/`Authorization` header. Expected control: the `/api/*` surface should enforce the same role check as the page that consumes it. Test: for each browser-facing sensitive page, locate its corresponding `/api/*` calls in HTTP history, then replay each `/api/*` call independently under every role, comparing the resulting status/content against what that role sees on the browser-facing route for the same data, one endpoint at a time.

**6.4 — [A01] Privilege escalation via the role-change endpoint's `role` parameter.**
Endpoint: `POST /admin/users/{id}/role` and `POST /api/users/{id}/role`. Parameter: `role`. Expected control: only an `admin` session should be able to call this successfully, and it should not accept arbitrary role strings. Test: as `manager`, replay a captured admin role-change request unchanged except for swapping in the `manager` session cookie, and separately, as `admin`, test whether `role` accepts unexpected values beyond the three observed ones, changing only that field between attempts.

**6.5 — [A07] No re-authentication or session rotation at privilege transitions.**
Endpoint: transition from `/dashboard` to `/admin` (admin account) and from `/manager/dashboard` to `/manager/orders` (manager account). Parameter/claim: the `westmark_session` cookie value itself. Expected control: a session used to reach a materially more sensitive area should be re-verified or rotated, reducing the value of a stolen token. Test: capture the exact `westmark_session` value immediately before and immediately after each transition for both accounts, and confirm byte-for-byte whether it changes; if it does not, this is treated as a firm session-hygiene finding.

**6.6 — [A07] No account-lockout or throttling signal observed on repeated failed logins.**
Endpoint: `POST /login`. Parameter: `password`. Expected control: repeated failed attempts against the same `username` should eventually be throttled or the account temporarily locked. Test: using a small, throttled Intruder run limited to a handful of attempts against a single authorized test account with a fixed known-invalid password, observe whether response behavior (status, wording, timing) changes after a threshold, stopping well short of anything that could lock or disrupt the account for actual use.

**6.7 — [A07] Password-reset token reuse and expiry not yet verified.**
Endpoint: `GET /password-reset/confirm`, `POST` confirm submission. Parameter: `token`. Expected control: a reset token should expire promptly and become unusable after a single successful reset. Test: request a reset token, complete one reset with it, then attempt to reuse the same token value on a second confirm submission, and separately let a freshly requested token sit unused to test whether it still succeeds after a defined wait period.

**6.8 — [A07] No email verification gap between registration and authenticated access.**
Endpoint: `POST /register` followed immediately by `POST /login`. Parameter: `email`. Expected control: an account should ideally not gain full authenticated access before its email address is confirmed, particularly if email is used anywhere as an identity or reset artifact. Test: register a fresh authorized test account, attempt to log in immediately without following any verification step, and confirm whether full dashboard access is granted, then check whether the same unverified email can also be used to trigger and complete a password reset.
