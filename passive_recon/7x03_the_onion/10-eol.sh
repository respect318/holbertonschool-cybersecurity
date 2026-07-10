#!/bin/bash
FILES="1-declared_stack.txt 2-frontend.sh 3-proxy.sh 4-backend.sh 5-spoofing.txt 6-version.sh 8-framework.txt 9-datalayer.txt"
COMPONENTS=$(cat $FILES 2>/dev/null | grep -oE '[a-zA-Z0-9_-]+/[0-9]+\.[0-9]+' | sort | uniq)
critical_date="9999-99-99"
critical_comp=""
for comp_ver in $COMPONENTS; do
    COMP_NAME=$(echo "$comp_ver" | cut -d'/' -f1)
    COMP_VER=$(echo "$comp_ver" | cut -d'/' -f2)
    RESPONSE=$(curl -s "https://endoflife.date/api/${COMP_NAME}/${COMP_VER}.json")
    EOL_DATE=$(echo "$RESPONSE" | jq -r '.eol')
    if [[ -n "$EOL_DATE" && "$EOL_DATE" != "false" && "$EOL_DATE" != "null" ]]; then
        if [[ "$EOL_DATE" < "$critical_date" ]]; then
            critical_date="$EOL_DATE"
            critical_comp="$comp_ver"
        fi
    fi
done
if [ -n "$critical_comp" ]; then
    echo "$critical_comp"
    echo "$critical_date"
fi
