#!/bin/bash
#
# 3-proxy.sh
#
# PASSIVE / BEHAVIOURAL RECON ONLY.
# No exploitation. Every probe below is a standard, harmless HTTP
# request (OPTIONS, TRACE, HEAD, a couple of GETs) sent to the target
# (victim) host. Nothing here modifies state, bypasses auth, or sends
# malicious payloads — it only observes how the target responds and
# how fast, then reasons about that behaviour.
#
# Goal: the Layer-1 declarative method (a header literally saying
# "I am a proxy") fails here — so we run a battery of behavioural
# probes whose convergence betrays a reverse proxy sitting in front
# of the real application servers:
#   - OPTIONS  : proxies often normalise / restrict the Allow list
#   - TRACE    : proxies frequently intercept or reject TRACE outright,
#                which differs from how the backend would answer it
#   - timing   : a request that must hop proxy -> backend -> proxy is
#                measurably slower / has different variance than one
#                served straight from a cache or edge node
#   - error provenance : a forced error page (404, etc.) often carries
#                the proxy's own signature (Server header, page banner)
#                rather than the backend framework's
#   - header ordering  : the order in which response headers are sent
#                is a fingerprintable trait of the software emitting
#                them; a proxy in front will often reorder or add to
#                the backend's original header sequence
#
# Usage: ./3-proxy.sh
#

TARGET="https://portal.otono.example"
UA="Mozilla/5.0 (compatible; ProxyForensics/1.0)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

SIGNALS=()          # collects every behavioural signal that fired
PROXY_LINE=""       # <ProxySoftware>/<version>

# ---------------------------------------------------------------------
# Probe 1: OPTIONS — inspect the Allow header and any Server banner
# ---------------------------------------------------------------------
curl -s -D "$WORKDIR/options.headers" -o /dev/null \
     -A "$UA" -X OPTIONS "$TARGET/"

allow_header="$(grep -i '^Allow:' "$WORKDIR/options.headers")"
options_server="$(grep -i '^Server:' "$WORKDIR/options.headers" | head -n1)"

# ---------------------------------------------------------------------
# Probe 2: TRACE — many reverse proxies intercept/reject TRACE
# differently than the backend would (405 vs 501 vs echoed body, etc.)
# ---------------------------------------------------------------------
trace_code="$(curl -s -o "$WORKDIR/trace.body" -w '%{http_code}' \
              -A "$UA" -X TRACE "$TARGET/")"

if [ "$trace_code" = "405" ] || [ "$trace_code" = "501" ] || [ "$trace_code" = "403" ]; then
    SIGNALS+=("trace-method-discrepancy")
fi

# ---------------------------------------------------------------------
# Probe 3: timing differential — hit a normal page repeatedly and
# compare time_total / time_starttransfer; a proxy hop tends to add
# a measurable, fairly consistent latency floor versus a direct
# backend response.
# ---------------------------------------------------------------------
> "$WORKDIR/timings.txt"
for i in 1 2 3 4 5; do
    curl -s -o /dev/null -A "$UA" \
         -w '%{time_starttransfer} %{time_total}\n' \
         "$TARGET/" >> "$WORKDIR/timings.txt"
done

avg_ttfb="$(awk '{sum+=$1; n++} END {if (n>0) printf "%.4f", sum/n}' "$WORKDIR/timings.txt")"
avg_total="$(awk '{sum+=$2; n++} END {if (n>0) printf "%.4f", sum/n}' "$WORKDIR/timings.txt")"

# A large, stable gap between time_starttransfer and time_total on a
# static-looking resource is consistent with a proxy layer doing
# buffering/relay work in front of the real backend.
gap="$(awk -v a="$avg_ttfb" -v b="$avg_total" 'BEGIN{printf "%.4f", (b-a)}')"
gap_over_threshold="$(awk -v g="$gap" 'BEGIN{print (g > 0.05) ? 1 : 0}')"
[ "$gap_over_threshold" = "1" ] && SIGNALS+=("timing-differential")

# ---------------------------------------------------------------------
# Probe 4: error provenance — force a 404 and inspect who "signs" it
# (Server header / footer banner) versus the Server header seen on
# normal 200 responses. A mismatch means the error page is generated
# by a different piece of software than the one serving real content.
# ---------------------------------------------------------------------
curl -s -D "$WORKDIR/notfound.headers" -o "$WORKDIR/notfound.body" \
     -A "$UA" "$TARGET/this-path-should-not-exist-$$"

curl -s -D "$WORKDIR/ok.headers" -o "$WORKDIR/ok.body" \
     -A "$UA" "$TARGET/"

error_server="$(grep -i '^Server:' "$WORKDIR/notfound.headers" | head -n1)"
ok_server="$(grep -i '^Server:' "$WORKDIR/ok.headers" | head -n1)"

if [ -n "$error_server" ] && [ -n "$ok_server" ] && [ "$error_server" != "$ok_server" ]; then
    SIGNALS+=("error-page-provenance-mismatch")
fi

# ---------------------------------------------------------------------
# Probe 5: header ordering signature — the sequence in which headers
# arrive is itself a fingerprint. Compare the header order of two
# independent requests (OPTIONS vs plain GET); if the ordering /
# header set diverges in a way inconsistent with a single origin
# server, that's evidence of an intermediary rewriting the response.
# ---------------------------------------------------------------------
order_options="$(grep -oE '^[A-Za-z-]+:' "$WORKDIR/options.headers" | tr -d ':' | tr '\n' ',' )"
order_ok="$(grep -oE '^[A-Za-z-]+:' "$WORKDIR/ok.headers" | tr -d ':' | tr '\n' ',' )"

if [ "$order_options" != "$order_ok" ]; then
    SIGNALS+=("header-order-mismatch")
fi

# ---------------------------------------------------------------------
# Derive the proxy software + version from whichever Server banner
# actually looks like a proxy (nginx, HAProxy, Envoy, Varnish, an
# internal codename, etc.) rather than an app-framework banner.
# ---------------------------------------------------------------------
for candidate in "$options_server" "$error_server" "$ok_server"; do
    name="$(echo "$candidate" | sed -E 's/^Server:[[:space:]]*//')"
    if echo "$name" | grep -qiE 'proxy|nginx|haproxy|envoy|varnish|traefik'; then
        version="$(echo "$name" | grep -oE '[0-9]+(\.[0-9]+)+' | head -n1)"
        proxy_name="$(echo "$name" | grep -oE '^[A-Za-z0-9_-]+')"
        [ -n "$proxy_name" ] && [ -n "$version" ] && PROXY_LINE="${proxy_name}/${version}"
        break
    fi
done

# ---------------------------------------------------------------------
# Report only what the probe battery actually found. No fabricated
# defaults: if nothing converged on a proxy identity or no behavioural
# signal fired, fail loudly on stderr instead of guessing.
# ---------------------------------------------------------------------
if [ -z "$PROXY_LINE" ]; then
    echo "error: could not derive reverse proxy software/version for ${TARGET}" >&2
    exit 1
fi
if [ "${#SIGNALS[@]}" -eq 0 ]; then
    echo "error: no behavioural signal betraying a distinct backend was found for ${TARGET}" >&2
    exit 1
fi

echo "$PROXY_LINE"
echo "${SIGNALS[0]}"
