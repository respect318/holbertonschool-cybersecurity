#!/bin/bash

# 1. Bəyan edilmiş (declared) versiyaların olduğu JSON faylını çəkirik
deps=$(curl -s http://portal.otono.example/static/deps.json)

# 2. Portalın HTML-indən bütün JS fayllarının adlarını tapırıq
scripts=$(curl -s http://portal.otono.example | grep -oP '(?<=src=")[^"]+\.js')

# --- SƏTİR 1: Dissonansın tapılması ---
for script in $scripts; do
    # Faylın adından kitabxananın adını çıxarırıq (məs: vue.min.js -> vue)
    lib_name=$(basename "$script" .min.js)
    
    # Faylın içindəki həqiqi versiyanı tapırıq
    actual_ver=$(curl -s "http://portal.otono.example$script" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    
    if [ -n "$actual_ver" ]; then
        # JSON-dan elan edilmiş versiyanı çəkirik
        declared_ver=$(echo "$deps" | grep -i "\"$lib_name" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+")
        
        # Əgər fərqlənirlərsə, ekrana çap edib dövrü dayandırırıq
        if [ -n "$declared_ver" ] && [ "$actual_ver" != "$declared_ver" ]; then
            echo "$lib_name/$actual_ver"
            break
        fi
    fi
done

# --- SƏTİR 2: Köhnəlmiş kitabxananın tapılması ---
for script in $scripts; do
    lib_name=$(basename "$script" .min.js)
    actual_ver=$(curl -s "http://portal.otono.example$script" | grep -E -o "[0-9]+\.[0-9]+\.[0-9]+" | head -n 1)
    
    if [ -n "$actual_ver" ]; then
        # EOL API-yə müraciət edib ən son versiyanı alırıq
        latest_ver=$(curl -s "http://eol-api.otono.internal/api/${lib_name}.json" | grep -o '"latest":"[^"]*"' | cut -d'"' -f4)
        
        if [ -n "$latest_ver" ]; then
            # Həqiqi və API-dən gələn versiyaları müqayisə edirik
            lowest=$(printf '%s\n' "$actual_ver" "$latest_ver" | sort -V | head -n 1)
            if [ "$lowest" == "$actual_ver" ] && [ "$actual_ver" != "$latest_ver" ]; then
                echo "$lib_name"
                break
            fi
        fi
    fi
done
