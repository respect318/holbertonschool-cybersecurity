#!/bin/bash
#
# 2-frontend.sh
#
# Lab: The-Onion / passive_recon — Layer 1 continued.
# Target: portal.otono.example.
#
# Declared dependency versions live in /static/deps.json. Actually-
# loaded versions are extracted from each served file's own banner
# comment. The critical library is the one where declared != actual
# (a version dissonance). An outdated dependency is one whose actual
# version is older than the latest release reported by the lab's
# local EOL API. Bounded timeouts and a small per-request delay keep
# request rate low. Only the two requested flag values go to stdout.
#
# Usage: ./2-frontend.sh
#

set -u

TARGET="https://portal.otono.example"
EOL_API="http://eol-api.otono.internal"
UA="Mozilla/5.0 (compatible; DependencyForensics/1.0)"
CURL_OPTS=(-sk --max-time 8 --connect-timeout 4 -A "$UA")
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

declare -A DISPLAY_NAME=(
  [jquery]="jQuery"
  [vue]="Vue"
  [bootstrap]="Bootstrap"
  [lodash]="Lodash"
  [axios]="Axios"
  ["chart.js"]="Chart.js"
  [dompurify]="DOMPurify"
  [moment]="Moment"
)

CRITICAL_LINE=""
OUTDATED_DEP=""

PAGE="$WORKDIR/index.html"
curl "${CURL_OPTS[@]}" "$TARGET/" -o "$PAGE" 2>/dev/null

DEPS_JSON="$WORKDIR/deps.json"
curl "${CURL_OPTS[@]}" "$TARGET/static/deps.json" -o "$DEPS_JSON" 2>/dev/null

grep -oE '(src|href)="[^"]+\.(js|css)"' "$PAGE" 2>/dev/null \
    | sed -E 's/^(src|href)="//; s/"$//' \
    | sort -u > "$WORKDIR/resources.txt"

# Look up a declared version for a given dependency key in deps.json.
lookup_declared() {
    local key="$1"
    grep -oE "\"${key}\"[[:space:]]*:[[:space:]]*\"[0-9]+\.[0-9]+\.[0-9]+\"" "$DEPS_JSON" 2>/dev/null \
        | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1
}

while read -r resource; do
    [ -z "$resource" ] && continue
    sleep 0.3   # moderate request rate

    case "$resource" in
        http*) url="$resource" ;;
        /*)    url="${TARGET}${resource}" ;;
        *)     url="${TARGET}/${resource}" ;;
    esac

    fname="$(basename "$resource")"
    raw="$(echo "$fname" | sed -E 's/(\.min)?\.(js|css)$//')"

    body="$WORKDIR/$(echo "$fname" | md5sum | cut -d' ' -f1)"
    curl "${CURL_OPTS[@]}" "$url" -o "$body" 2>/dev/null

    # Actually-loaded version: whatever version number appears in the
    # file's own leading banner comment, regardless of exact banner
    # wording ("v3.4.1", "3.4.1", "moment.js 2.29.4", etc.)
    actual="$(head -n5 "$body" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
    [ -z "$actual" ] && continue

    # Match this resource to a deps.json key: try the raw name as-is,
    # with ".js" appended (e.g. chart -> chart.js), and the segment
    # before the first dot (e.g. bootstrap.bundle -> bootstrap).
    matched_key=""
    declared=""
    for candidate in "$raw" "${raw}.js" "${raw%%.*}"; do
        val="$(lookup_declared "$candidate")"
        if [ -n "$val" ]; then
            matched_key="$candidate"
            declared="$val"
            break
        fi
    done
    [ -z "$matched_key" ] && continue

    display="${DISPLAY_NAME[$matched_key]:-$matched_key}"

    # Dissonance: declared version != actually-loaded version.
    if [ "$declared" != "$actual" ] && [ -z "$CRITICAL_LINE" ]; then
        CRITICAL_LINE="${display}/${actual}"
    fi

    # Outdated check: compare actual against the local EOL API's
    # latest published release for this dependency.
    if [ -z "$OUTDATED_DEP" ]; then
        latest_json="$(curl -s --max-time 5 --connect-timeout 3 "${EOL_API}/api/${matched_key}.json" 2>/dev/null)"
        latest="$(echo "$latest_json" | grep -oE '"latest":"[0-9]+\.[0-9]+\.[0-9]+"' \
                    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -n1)"
        if [ -n "$latest" ]; then
            newest="$(printf '%s\n%s\n' "$actual" "$latest" | sort -V | tail -n1)"
            [ "$newest" != "$actual" ] && OUTDATED_DEP="$matched_key"
        fi
    fi
done < "$WORKDIR/resources.txt"

if [ -z "$CRITICAL_LINE" ] || [ -z "$OUTDATED_DEP" ]; then
    echo "error: insufficient signal from ${TARGET} to report both flags" >&2
    exit 1
fi

echo "$CRITICAL_LINE"
echo "$OUTDATED_DEP"
