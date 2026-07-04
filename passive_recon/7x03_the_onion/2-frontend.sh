#!/bin/bash
# 2-frontend.sh
# Extracts actually-loaded dependency version and compares with declared version.
# Evaluates sourceMappingURL, integrity, or JSON declarations.
# Finds outdated frontend resources.

portal_url="http://portal.otono.example"
deps_json=$(curl -s "$portal_url/static/deps.json")

# Discover loaded front-end resources (search for src in .js)
scripts=$(curl -s "$portal_url" | grep -oP '(?<=src=")[^"]+\.js')

# --- LINE 1: Find dissonance between actual loaded version and declared version ---
for script in $scripts; do
    lib_name=$(basename "$script" .min.js)
    
    # Extract actually-loaded version
    actual_version=$(curl -s "$portal_url$script" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    
    if [ -n "$actual_version" ]; then
        declared_version=$(echo "$deps_json" | grep -i "\"$lib_name" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+")
        
        if [ -n "$declared_version" ] && [ "$actual_version" != "$declared_version" ]; then
            # Output the dissonance
            echo "${lib_name^}/$actual_version"
            break
        fi
    fi
done

# --- LINE 2: Find outdated dependency ---
for script in $scripts; do
    lib_name=$(basename "$script" .min.js)
    
    actual_version=$(curl -s "$portal_url$script" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    
    if [ -n "$actual_version" ]; then
        latest_version=$(curl -s "http://eol-api.otono.internal/api/${lib_name}.json" | grep -o '"latest":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$latest_version" ]; then
            # Compare versions using sort -V
            lowest=$(printf '%s\n' "$actual_version" "$latest_version" | sort -V | head -n 1)
            if [ "$lowest" == "$actual_version" ] && [ "$actual_version" != "$latest_version" ]; then
                # Output the outdated library name
                echo "$lib_name"
                break
            fi
        fi
    fi
done
