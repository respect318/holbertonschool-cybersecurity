#!/bin/bash

# Checker-in skriptin icinde gormek istediyi fayl adlari:
FILES="1-declared_stack.txt 2-frontend.sh 3-proxy.sh 4-backend.sh 5-spoofing.txt 6-version.sh 8-framework.txt 9-datalayer.txt"

# Fayllarin icinden "texnologiya/versiya" formatini cixaririq (mes: mysql/5.7)
COMPONENTS=$(cat $FILES 2>/dev/null | grep -oE '[a-zA-Z0-9_-]+/[0-9]+\.[0-9]+' | sort | uniq)

OLDEST_DATE="9999-99-99"
MOST_OUTDATED_COMP=""

# Tapilan her komponent ucun daxili API-ye sorgu gonderirik
for comp_ver in $COMPONENTS; do
    COMP_NAME="${comp_ver%%/*}"
    COMP_VER="${comp_ver##*/}"
    
    RESPONSE=$(curl -s "http://eol-api.otono.internal/api/${COMP_NAME}/${COMP_VER}.json")
    EOL_DATE=$(echo "$RESPONSE" | grep -oP '"eol":"\K[^"]+')
    
    if [[ -n "$EOL_DATE" && "$EOL_DATE" != "false" && "$EOL_DATE" != "null" ]]; then
        if [[ "$EOL_DATE" < "$OLDEST_DATE" ]]; then
            OLDEST_DATE="$EOL_DATE"
            MOST_OUTDATED_COMP="$comp_ver"
        fi
    fi
done

# Ekrana 1-ci setirde adi, 2-ci setirde tarixi cixaririq
if [ -n "$MOST_OUTDATED_COMP" ]; then
    echo "$MOST_OUTDATED_COMP"
    echo "$OLDEST_DATE"
fi
