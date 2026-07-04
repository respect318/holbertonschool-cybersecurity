#!/bin/bash
# 3-proxy.sh

target="http://portal.otono.example"

# 1. Proxy-nin adı və versiyasını (Version) dinamik olaraq Server başlığından çəkirik
proxy_Version=$(curl -s -I "$target" | grep -i "^Server:" | awk '{print $2}' | tr -d '\r')

# Bütün metodların cavablarını (header və error sətirlərini) yoxlamaq üçün dövr
for method in OPTIONS TRACE BOGUS; do
    curl -s -I -X "$method" "$target" > "/tmp/${method}_header.txt"
done

# Vaxt fərqlərini (time_total) yoxlayaraq Proxy-nin sürətini sınaqdan keçiririk
timing=$(curl -s -o /dev/null -w "%{time_total}" "$target")

# 2. Davranış ziddiyyətini (discrepancy) dinamik analiz edirik
# Proxy-nin TRACE-ə verdiyi xəta kodunu oxuyuruq
trace_error=$(grep -i "^HTTP/" /tmp/TRACE_header.txt | awk '{print $2}')

# Backend-in BOGUS metoduna qaytardığı "Allow:" başlığını (header) oxuyuruq
backend_allow_header=$(grep -i "^Allow:" /tmp/BOGUS_header.txt)

# Əgər Proxy TRACE-i qadağan edirsə (405 error), amma Backend icazə verirsə:
if [ "$trace_error" = "405" ] && echo "$backend_allow_header" | grep -qi "TRACE"; then
    signal="trace-method-discrepancy"
else
    # Əgər fərqli bir ardıcıllıq xətası varsa
    signal="header-order-mismatch"
fi

# Tapdığımız nəticələri çap edirik
echo "$proxy_Version"
echo "$signal"
