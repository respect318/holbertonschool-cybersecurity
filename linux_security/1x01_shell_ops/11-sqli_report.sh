#!/bin/bash
grep -i 'UNION SELECT' /var/log/analysis/access.log | awk '{print substr($4,2) "," $1}' | sort -t, -k2,2 > sqli_report.csv

