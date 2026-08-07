# Visibility Gaps — Would They Have Seen You

## Method

Three log sources were inspected against the exact attacks already run in this
engagement: the internal-reach probe (Task 3, hitting `127.0.0.1:9200/status`),
the blind SSRF confirmed out of band (Task 7, the webhook-to-canary hit), and
the privileged internal action (Task 9, `refresh-cache` via the chained
metadata token). Each log was read specifically for what it recorded about
these three events, not browsed generally.

- **`app.log`** — application-level events: which authenticated session
  triggered which feature (preview/avatar/thumbnail/webhook/report).
- **`proxy.log`** — the outbound requests the server itself made, including
  the ones that never appear anywhere else because they never returned
  content to a human.
- **`internal.log`** — what the internal-only services (status node, admin
  API) themselves recorded about the inbound calls they received.

> Replace the bracketed placeholders below with the exact log lines pulled
> from the lab session — the structure and each diagnosis is fixed; the
> quoted evidence is what needs to come from the real files.

## Gap 1 — Lost actor attribution

`internal.log` records every inbound hit to the status node and the admin
API as coming from the application server itself — e.g.:

```
[internal.log] source=clarion-app-server target=127.0.0.1:9200 path=/status
```

There is no session ID, username, or request-origin field anywhere in that
line. The initiating actor (`analyst.mina`, the session in `cj`) is present
in `app.log` at the moment the feature was invoked, but that identity is
never carried forward into the outbound call the server makes on the
victim's behalf. Once the request leaves the application layer and becomes
a server-to-server call, the only actor `internal.log` can name is the
server — because the server is, from the internal service's point of view,
telling the truth: it really is the one connecting. The *human* behind that
connection is the information that gets dropped.

This matters for investigation, not just neatness: if two different analyst
sessions both trigger internal-reach requests in the same minute, nothing in
`internal.log` today can tell which session caused which line. Attribution
is lost at the exact hop where trust is exploited — which is also exactly
the hop SSRF exploits.

**→ This is the gap Task 11 (Give the Log a Name) repairs.**

## Gap 2 — No rule for internal/link-local reach

`proxy.log` and `internal.log` both contain the outbound request to
`127.0.0.1:9200/status` (Task 3) and to `169.254.169.254/...` (Task 8) as
plain entries — they were logged. But nothing in the workbench's existing
rule set treats "the server's own fetch feature targeted a loopback or
link-local address" as a distinguishable event. It sits in the log at the
same priority as a legitimate external URL preview. A human would have to
already know to look for `127.0.0.1` or `169.254.169.254` by eye to notice
it — there is no rule that flags server-originated requests whose
destination falls inside private, loopback, or link-local ranges.

This is the precise distinction between logging and detection: the line
exists, but no rule recognizes it as meaningful, so no analyst is ever
pointed at it.

**→ This is the gap Task 12 (server-to-internal detection rule) repairs.**

## Gap 3 — Privileged action unclassified, therefore unalerted

The `refresh-cache` action from Task 9 appears in `internal.log` as a
successful, unremarkable entry:

```
[internal.log] action=refresh-cache executed=true source=clarion-app-server
```

It is logged exactly like any other internal housekeeping call. Nothing
marks it as privileged, nothing assigns it a severity, and as a result
nothing raises an alert — even though this is the single event in the whole
chain that represents actual impact, not just reach. A read of internal
data (Task 3, Task 8) and an executed admin action (Task 9) are currently
indistinguishable in the log's own eyes; both are "just an entry." The gap
is not that the action wasn't recorded — it was — the gap is that recording
without severity classification never escalates into something a human
gets paged for.

**→ This is the gap Task 13 (severity-classified alerting) repairs.**

## Blind request vs. available telemetry

The webhook request in Task 7 returned nothing to the caller —
`{"delivered":true,"http_status":204}` — by design, blind. The only reason
it could be confirmed at all was the in-lab canary: the out-of-band hit
recorded `server_confirmed:true` with `user_agent:"Clarion-Signal-Fetcher/1.0"`,
proving the server itself made the call. Checking `app.log`, `proxy.log`,
and `internal.log` for the same window shows [describe here whether the
webhook attempt appears at all, and if so, with what — or without —
confirmation of server origin]. The canary is an external, independent
witness that Clarion's own telemetry does not have; without it, this class
of attack leaves Clarion no native way to confirm — only to suspect — that
the request ever executed. That asymmetry (canary saw it, Clarion's own
stack didn't) is the concrete answer to the question Clarion asked: no, as
configured today, they would not have seen this one.

## Plaintext secret in the logs — a failure, not a find

The service token retrieved in Task 8 (`CLRN-IMDS-a91f7c2e5d`) appears in
plaintext in [name which log — likely `proxy.log` or `app.log`, wherever the
full fetched URL/response body gets recorded]. This is logged here as what
it is: a **logging failure** — sensitive credential material is being
persisted in cleartext, in a log an over-broad set of people could plausibly
read, with no redaction. It is reported the way a real engagement would
report it, as a finding for Clarion to fix (redact tokens before writing to
any log), not treated as a usable credential beyond what Task 8 already
scoped and stopped at.

## Logging vs. detection vs. alerting

All three gaps above share the same shape, worth stating once, plainly: an
event **written to a log** is not the same as an event that is **detected**
(a rule has to recognize the pattern and say "this matters"), and detection
is not the same as **response** (an alert has to actually reach a human who
can act). Clarion's stack today does the first thing consistently — nothing
in this engagement went unlogged — and stops there. The internal-reach
request, the blind webhook, and the privileged action were all *recorded*.
None of them were *recognized*, and none of them *paged anyone*. That three-
step gap — log, then detect, then alert — is the throughline the next three
tasks close one link at a time.

## Summary — gap-to-task map

| Gap | Where it shows | Task that fixes it |
|---|---|---|
| Actor attribution lost at the server hop | `internal.log` names the server, not the initiating session | Task 11 |
| No rule for internal/link-local reach | `proxy.log` / `internal.log` log it, nothing flags it | Task 12 |
| Privileged action unclassified | `internal.log`, logged with no severity, no alert | Task 13 |
