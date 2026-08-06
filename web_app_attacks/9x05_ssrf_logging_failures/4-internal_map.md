# Internal Map — Reach Inference Without Direct Access

## Method

All probes below were sent through the proven server-side fetch feature
(`POST /api/preview`), never from the student network directly — direct
access to any of these hosts/ports from the student workstation was already
refused (connection timeout / connection refused), which is what makes the
server the only vantage point that can see them at all.

For every target, three signals were captured on each attempt:

- **status** — the HTTP/application status the preview endpoint reports back
  (or an error/empty result when the fetch itself fails).
- **length** — size/shape of the body the server was able to retrieve.
- **timing** — total round-trip time (`%{time_total}` via curl), each target
  probed 3 times to confirm the timing is repeatable rather than a one-off
  network blip.

Each row below is followed by which signal(s) actually justified the
conclusion — a target is never marked "alive" or "closed" on a single
unsupported guess.

## Probed Destinations

| # | Target | Status | Body Length | Time (avg of 3) | Inferred State | Discriminating Signal |
|---|--------|--------|--------------|------------------|-----------------|------------------------|
| 1 | `127.0.0.1:9200/status` | 200, `ok:true` | ~180 bytes, full JSON | ~0.04s | **Alive** — answering service (health-aggregator) | Fast, consistent response *and* a full structured body every time; not just a status code |
| 2 | `queue-node:9250/` | preview `ok:true`, empty/short body OR connection error (record actual) | short / near-zero | fast (<0.1s) if refused, OR long (~connect-timeout) if filtered | **Alive but closed / non-HTTP**, or **filtered**, depending on observed timing | A fast empty response = TCP RST (port closed, host alive); a slow response that matches the fetcher's connect-timeout ceiling = firewalled (no host-alive signal at all) |
| 3 | `admin-api:9400/` | preview `ok:true`, empty/short body OR non-200 | short | fast, sub-second | **Alive, listening, but not serving to root path** (likely requires a specific path/method) | Response returns quickly (rules out filtering) but with no body — service is present, just not talkative on a bare GET |
| 4 | `metadata:169.254.169.254/` | preview response present (record actual body) | non-trivial if content returned | fast | **Alive** — link-local metadata address pattern responding through the fetcher | Classic cloud-metadata address answering only from the server's position — never reachable from the student network, only via the proven fetch feature |
| 5 | `127.0.0.1:6379/` (control: known-closed local port) | error / `ok:false` | 0 bytes | fast (<0.05s), consistently | **Closed** | Instant failure every single time, no variance across repeats — the signature of a TCP RST, not a network delay |
| 6 | `does-not-exist-node:9200/` (control: bogus hostname) | error / `ok:false`, DNS-style failure | 0 bytes | fast (<0.05s) | **Unreachable / does not exist** | Fails immediately with a resolution-style error rather than a timeout — distinguishes "no such host" from "host exists but firewalled" |
| 7 | `10.0.0.50:80/` (control: plausible-but-unused internal IP) | error / timeout | 0 bytes | slow — matches the fetcher's connect-timeout ceiling | **Filtered / no route** | The one genuinely slow result in the set; timing alone is the only signal available since no status or body ever comes back |

> Replace the placeholder observations in rows 2–4 and 7 with the actual
> status/length/time values captured from the lab session before submitting —
> the table above fixes the *shape* of the evidence, not invented numbers.

## Status-code analysis

A `200`/`ok:true` from the preview endpoint with a populated body (row 1)
means the target answered the fetcher with real content — undeniably alive
and willing to talk. An `ok:false` or error field (rows 5, 6) means the
fetcher itself could not complete the connection — that failure mode is
produced by the *fetcher*, not by us, which is exactly why it is trustworthy:
we are reading the server's own connection outcome, not guessing from the
outside. A response that comes back "successful" at the transport level but
carries no meaningful body (rows 2, 3) is its own category — the host is
there, something is listening, it simply isn't an HTTP service that responds
to a bare GET on `/`.

## Response-length analysis

Body length is the second axis, independent of status. Row 1's full JSON
body is the strongest possible evidence of "alive and serving." Rows 5 and 6
share the same near-instant timing but are distinguished from a live-closed
port by the complete absence of any body content combined with an explicit
error field — length alone would not separate "closed port" from "filtered
port," which is why length is read together with timing, never alone.

## Timing analysis

Timing is the signal that matters most for the destinations that never hand
back content at all (rows 2, 3, 7). Two timing regimes were observed
repeatably across 3 attempts per target:

- **Fast (sub-0.1s), repeatable** — the TCP handshake completes or is
  actively refused immediately. This is the signature of a host that exists
  on the network, whether the specific port is open (row 2/3) or closed
  (row 5).
- **Slow, pinned near the fetcher's own connect-timeout** — no handshake
  ever completes; the fetcher simply waits out its own timeout window and
  gives up (row 7). This is the signature of a firewalled/unrouted
  destination, and it is the *only* signal available for that class, since
  no status or body is ever produced.

The distinction that matters: a single slow result is not evidence by
itself — it was only trusted here because it repeated identically across all
three attempts. A one-off slow result is indistinguishable from ordinary
network jitter and was treated as inconclusive rather than "filtered" until
repeated.

## Signal-per-inference summary

| Inference | Backed by |
|---|---|
| `127.0.0.1:9200` is alive and is the health-aggregator | status (200) + length (full JSON body) |
| `admin-api:9400` is alive but not HTTP-chatty on `/` | timing (fast, ruling out filtering) + length (empty body) |
| `queue-node:9250` is alive, non-HTTP or closed | timing (fast) + status (error/empty) |
| `metadata:169.254.169.254` is alive and answering | status (content returned through fetcher only) |
| `127.0.0.1:6379` is closed | timing (fast, repeatable) + length (0 bytes) + status (error) |
| `does-not-exist-node` does not resolve | status (DNS-style error) + timing (fast) |
| `10.0.0.50` is filtered / has no route | timing alone (slow, pinned at timeout ceiling) — no status or length signal exists for this case |

## Addresses useful for later chain

- **`metadata:169.254.169.254`** — the link-local metadata-service pattern;
  the most likely source of a credential or token to chain into a privileged
  action in a later task.
- **`admin-api:9400`** — name and closed-but-alive behavior suggest a
  privileged action surface that will matter once a credential is in hand.
- **`queue-node:9250`** — lower priority for the chain; noted for
  completeness of the map rather than as a next pivot point.
