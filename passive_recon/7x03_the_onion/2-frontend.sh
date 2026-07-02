#!/bin/bash
#
# 2-frontend.sh
#
# PASSIVE RECON ONLY.
# No exploitation, no authentication bypass, no injection — this script
# only reads what the target (victim) host already serves publicly:
# the HTML page and the JS/CSS files it references. That is the whole
# point of "passive" recon: everything used here is information the
# server voluntarily hands to any normal browser.
#
# Target (victim) host: portal.otono.example
#
# What it does:
#   1) fetches the target's front page
#   2) inventories every JS/CSS dependency it loads
#   3) extracts the actually-loaded version of each dependency
#   4) compares it against the version the site declares (integrity
#      hash / sourceMappingURL / inline version banner)
#   5) reports:
#        - the critical library and its actually-loaded version
#        - the name of a dependency that is already outdated
#
# Usage: ./2-frontend.sh
#

TARGET="https://portal.otono.example"
UA="Mozilla/5.0 (compatible; DependencyForensics/1.0)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

CRITICAL_LIB="ExampleLib"
CRITICAL_LINE=""
OUTDATED_DEP=""

# ---------------------------------------------------------------------
# Step 1: fetch the portal HTML and pull out every JS/CSS resource URL
# (src=... for scripts, href=... for stylesheets)
# ---------------------------------------------------------------------
PAGE="$WORKDIR/index.html"
curl -s -A "$UA" "$TARGET" -o "$PAGE"

grep -oE '(src|href)="[^"]+\.(js|css)"' "$PAGE" \
    | sed -E 's/^(src|href)="//; s/"$//' \
    | sort -u > "$WORKDIR/resources.txt"

# ---------------------------------------------------------------------
# Step 2: walk each resource, download it, and try to determine:
#   - its declared version (integrity hash, sourceMappingURL, or an
#     explicit "@version" style header comment)
#   - its actually-loaded version (parsed out of the served file itself,
#     e.g. "/*! ExampleLib v3.0.0 */" or a filename like lib-3.0.0.min.js)
# ---------------------------------------------------------------------
while read -r resource; do
    [ -z "$resource" ] && continue

    # Build an absolute URL if the resource path was relative
    case "$resource" in
        http*) url="$resource" ;;
        /*)    url="${TARGET}${resource}" ;;
        *)     url="${TARGET}/${resource}" ;;
    esac

    fname="$(basename "$resource")"
    dep="$(echo "$fname" | sed -E 's/(\.min)?\.(js|css)$//; s/-[0-9]+(\.[0-9]+)*$//')"

    body="$WORKDIR/$fname"
    curl -s -A "$UA" "$url" -o "$body"

    # Declared version: look for an integrity attribute for this src/href
    # in the original page, or a sourceMappingURL comment inside the file.
    declared="$(grep -oE "integrity=\"[^\"]*\"" "$PAGE" | grep -A0 "$fname" 2>/dev/null)"
    [ -z "$declared" ] && declared="$(grep -oE 'sourceMappingURL=[^ ]+' "$body" 2>/dev/null | head -n1)"

    # Actually-loaded version: parsed straight out of the delivered file
    # (banner comment "vX.Y.Z" or filename embedding "-X.Y.Z")
    actual="$(grep -oE '[Vv]ersion[: ]+[0-9]+\.[0-9]+\.[0-9]+' "$body" 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    [ -z "$actual" ] && actual="$(echo "$fname" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

    if [ -n "$actual" ]; then
        # Flag the critical library's loaded version
        if [ "$dep" = "$CRITICAL_LIB" ] || echo "$dep" | grep -qi "$CRITICAL_LIB"; then
            CRITICAL_LINE="${CRITICAL_LIB}/${actual}"
        fi

        # Compare loaded vs declared (dissonance detection)
        if [ -n "$declared" ] && ! echo "$declared" | grep -q "$actual"; then
            echo "[dissonance] $dep: declared != loaded ($actual)" >&2
        fi

        # Compare loaded version against the latest published release
        # to flag already-outdated dependencies.
        latest="$(curl -s "https://registry.example.com/npm/${dep}/latest" \
                    | grep -oE '"version":"[0-9]+\.[0-9]+\.[0-9]+"' \
                    | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
        if [ -n "$latest" ]; then
            newest="$(printf '%s\n%s\n' "$actual" "$latest" | sort -V | tail -n1)"
            if [ "$newest" != "$actual" ] && [ -z "$OUTDATED_DEP" ]; then
                OUTDATED_DEP="$dep"
            fi
        fi
    fi
done < "$WORKDIR/resources.txt"

# ---------------------------------------------------------------------
# Report only what was actually observed on the target. No hardcoded
# guesses: if the target couldn't be reached, or the critical library
# / an outdated dependency wasn't found, say so on stderr and exit
# non-zero instead of printing a fabricated result.
# ---------------------------------------------------------------------
if [ -z "$CRITICAL_LINE" ]; then
    echo "error: could not determine loaded version of ${CRITICAL_LIB} from ${TARGET}" >&2
    exit 1
fi
if [ -z "$OUTDATED_DEP" ]; then
    echo "error: no outdated dependency detected on ${TARGET}" >&2
    exit 1
fi

echo "$CRITICAL_LINE"
echo "$OUTDATED_DEP"
