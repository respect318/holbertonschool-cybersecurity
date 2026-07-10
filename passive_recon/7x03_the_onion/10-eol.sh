#!/bin/bash

FILES="1-declared_stack.txt 2-frontend.sh 3-proxy.sh 4-backend.sh 5-spoofing.txt 6-version.sh 8-framework.txt 9-datalayer.txt"

COMPONENTS=$(cat $FILES 2>/dev/null | grep -oE '[a-zA-Z0-9_-]+/[0-9]+\.[0-9]+' | sort | uniq)

OLDEST_DATE="9999-99-99"
MOST_OUTDATED_COMP=""

for comp_ver in $COMPONENTS; do
    COMP_NAME=$(echo "$comp_ver" | cut -d'/' -f1)
    COMP_VER=$(echo "$comp_ver" | cut -d'/' -f2)
    
    RESPONSE=$(curl -s "https://endoflife.date/api/${COMP_NAME}/${COMP_VER}.json")
    
    # JSON-u jq ile oxuyuruq
    EOL_DATE=$(echo "$RESPONSE" | jq -r '.eol')
    
    if [[ -n "$EOL_DATE" && "$EOL_DATE" != "false" && "$EOL_DATE" != "null" ]]; then
        if [[ "$EOL_DATE" < "$OLDEST_DATE" ]]; then
            OLDEST_DATE="$EOL_DATE"
            MOST_OUTDATED_COMP="$comp_ver"
        fi
    fi
done

if [ -n "$MOST_OUTDATED_COMP" ]; then
    echo "$MOST_OUTDATED_COMP"
    echo "$OLDEST_DATE"
fi
