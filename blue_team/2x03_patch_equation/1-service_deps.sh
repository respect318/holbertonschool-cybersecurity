#!/bin/bash

# Fayl yolları
OUTPUT_FILE="service_dependency_map.json"
CRIT_FILE="service_criticality.json"

# Nəticəni saxlayacağımız faylı sıfırlayırıq (hər işə düşəndə yenidən yazılsın)
> "$OUTPUT_FILE"

# 1. systemctl istifadə edərək aktiv service-ləri alırıq
active_services=$(systemctl list-units --type=service --state=active --no-legend | awk '{print $1}')

for service in $active_services; do
    
    # 2. Executable path-ı tapmaq üçün MainPID və ya ExecStart istifadə edirik
    exec_path=""
    main_pid=$(systemctl show -p MainPID --value "$service" 2>/dev/null)
    
    # Əgər PID 0 deyilsə, readlink və /proc/ vasitəsilə əsl yolu tapırıq
    if [ -n "$main_pid" ] && [ "$main_pid" -ne 0 ]; then
        exec_path=$(readlink -f /proc/$main_pid/exe 2>/dev/null)
    fi
    
    # Əgər MainPID kömək etmədisə, fallback olaraq ExecStart yoxlanılır
    if [ -z "$exec_path" ] || [ ! -f "$exec_path" ]; then
        exec_start=$(systemctl show -p ExecStart --value "$service" 2>/dev/null | grep -o 'path=[^ ;]*' | cut -d= -f2 | head -n 1)
        if [ -n "$exec_start" ] && [ -f "$exec_start" ]; then
            exec_path="$exec_start"
        fi
    fi
    
    # Executable path tapılmadısa, bu servisi atlayırıq
    if [ -z "$exec_path" ] || [ ! -f "$exec_path" ]; then
        continue
    fi

    # 3. Owning package-i dpkg -S ilə tapırıq
    owning_package=$(dpkg -S "$exec_path" 2>/dev/null | awk -F: '{print $1}' | awk '{print $1}')
    [ -z "$owning_package" ] && owning_package="unknown"

    # 4. ldd ilə dinamik kitabxanaları tapıb paketlərə çeviririk
    pkg_list="$owning_package"
    libs=$(ldd "$exec_path" 2>/dev/null | awk '{print $3}' | grep "^/")
    
    for lib in $libs; do
        lib_pkg=$(dpkg -S "$lib" 2>/dev/null | awk -F: '{print $1}' | awk '{print $1}')
        if [ -n "$lib_pkg" ]; then
            pkg_list="$pkg_list\n$lib_pkg"
        fi
    done

    # Paket siyahısını unikal hala gətirib JSON Array-ə çeviririk
    unique_pkgs=$(echo -e "$pkg_list" | grep -v "^unknown$" | sort -u)
    json_array=$(echo "$unique_pkgs" | jq -R . | jq -s -c .)
    [ -z "$json_array" ] && json_array="[]"

    # 5. service_criticality.json faylından criticality statusunu çəkirik
    criticality="low"
    if [ -f "$CRIT_FILE" ]; then
        crit_val=$(jq -r --arg srv "$service" '.[$srv] // empty' "$CRIT_FILE" 2>/dev/null)
        if [ -n "$crit_val" ] && [ "$crit_val" != "null" ]; then
            criticality="$crit_val"
        fi
    fi

    # 6. Default restart tələbi
    restart_required_on_patch="true"

    # 7. Checker-in tələb etdiyi struktura uyğun olaraq JSON formatında fayla yazırıq
    jq -n -c \
       --arg srv "$service" \
       --arg exec "$exec_path" \
       --arg own "$owning_package" \
       --argjson links "$json_array" \
       --arg crit "$criticality" \
       --argjson restart "$restart_required_on_patch" \
       '{
         service: $srv,
         exec_path: $exec,
         owning_package: $own,
         linked_packages: $links,
         criticality: $crit,
         restart_required_on_patch: $restart
       }' >> "$OUTPUT_FILE"

done
