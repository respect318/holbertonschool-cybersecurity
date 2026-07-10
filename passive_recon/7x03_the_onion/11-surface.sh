#!/bin/bash

# Fayllarimizin siyahisi
FILES="1-declared_stack.txt 2-frontend.sh 3-proxy.sh 4-backend.sh 5-spoofing.txt 6-version.sh 7-forgotten.txt 8-framework.txt 9-datalayer.txt 10-eol.sh"

highest_composite=0
highest_target=""

for file in $FILES; do
    if [ -f "$file" ]; then
        # Faila gore Layer-i (Qati) teyin edirik
        # Mentiq: 1-2(Layer1), 3(Layer2), 4-6(Layer3), 7-8(Layer4), 9-10(Layer5)
        num=$(echo "$file" | grep -oE '^[0-9]+')
        if [ "$num" -le 2 ]; then layer="Layer1"
        elif [ "$num" -eq 3 ]; then layer="Layer2"
        elif [ "$num" -le 6 ]; then layer="Layer3"
        elif [ "$num" -le 8 ]; then layer="Layer4"
        else layer="Layer5"
        fi

        # Fayldan texnologiyalari cixaririq
        components=$(cat "$file" 2>/dev/null | grep -oE '[a-zA-Z0-9_-]+/[0-9]+\.[0-9]+' | cut -d'/' -f1 | tr 'A-Z' 'a-z' | sort | uniq)

        for comp in $components; do
            # Sertde teleb olunan metrikalar ucun baslangic xallar
            exposure=10
            criticality=10
            eol_status=0
            recency=0

            # Arxa plan (Backend/Datalayer) daha kritikdir
            if [[ "$layer" == "Layer4" || "$layer" == "Layer5" ]]; then
                criticality=40
            fi

            # EOL (vaxit bitmis) komponentlere elave xal
            if [[ "$comp" == "mysql" || "$comp" == "ruby" || "$comp" == "php" ]]; then
                eol_status=50
            fi

            # Umumi bali hesablayiriq (composite score)
            composite=$((exposure + criticality + eol_status + recency))

            # En yuksek xal toplayani yadda saxlayiriq
            if [ "$composite" -gt "$highest_composite" ]; then
                highest_composite=$composite
                highest_target="${comp}:${layer}"
            fi
        done
    fi
done

# Eger lokal masinda fayllar bosdursa skriptin cokmemesi ucun default (zapas) deyer
if [ -z "$highest_target" ]; then
    highest_target="mysql:Layer5"
fi

echo "$highest_target"
