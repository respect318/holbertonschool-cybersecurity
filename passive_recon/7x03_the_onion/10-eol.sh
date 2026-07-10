#!/bin/bash

# Ən köhnə tarixi tapmaq üçün başlanğıc dəyərlər
OLDEST_DATE="9999-99-99"
MOST_OUTDATED_COMP=""

# Fərz edirik ki, tələbənin əvvəlki fayllarının içində "Komponent: mysql/5.7" kimi sətirlər var.
# Bütün .txt və .sh fayllarının içindən "texnologiya/versiya" formatında olan sözləri çıxarırıq:
# (Bu, regex ilə axtarışın ən bəsit formasıdır)
COMPONENTS=$(grep -oE '[a-z-]+/[0-9]+\.[0-9]+' *.txt *.sh 2>/dev/null | cut -d ':' -f 2 | sort | uniq)

# Əgər heç nə tapılmasa, skripti dayandır:
if [ -z "$COMPONENTS" ]; then
    exit 1
fi

# Tapılan hər bir komponent üçün daxili API-yə sorğu göndəririk:
for comp_ver in $COMPONENTS; do
    COMP_NAME="${comp_ver%%/*}"
    COMP_VER="${comp_ver##*/}"
    
    # CTF-in daxili API-sinə müraciət edirik (şərtdə verilən http://eol-api.otono.internal/)
    RESPONSE=$(curl -s "http://eol-api.otono.internal/api/${COMP_NAME}/${COMP_VER}.json")
    
    # JSON-dan tarixi çıxarırıq
    EOL_DATE=$(echo "$RESPONSE" | grep -oP '"eol":"\K[^"]+')
    
    # Əgər tarix keçərlidirsə, əvvəlki ilə müqayisə edirik
    if [[ -n "$EOL_DATE" && "$EOL_DATE" != "false" && "$EOL_DATE" != "null" ]]; then
        if [[ "$EOL_DATE" < "$OLDEST_DATE" ]]; then
            OLDEST_DATE="$EOL_DATE"
            MOST_OUTDATED_COMP="$comp_ver"
        fi
    fi
done

# Şərtdə istənilən formatda (Line 1: komponent, Line 2: tarix) çap edirik
if [ -n "$MOST_OUTDATED_COMP" ]; then
    echo "$MOST_OUTDATED_COMP"
    echo "$OLDEST_DATE"
fi
