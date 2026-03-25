#!/bin/bash

LOG_FILE="/var/log/hardening/baseline-$(date +%Y%m%d).txt"

echo "Running Lynis audit..."

# log directory yarat
sudo mkdir -p /var/log/hardening

# lynis audit run et və outputu saxla
sudo lynis audit system > /tmp/lynis_output.txt

# əsas məlumatları çıxart
HARDENING_INDEX=$(grep "Hardening index" /tmp/lynis_output.txt | awk '{print $3}')
TESTS=$(grep "Tests performed" /tmp/lynis_output.txt | awk '{print $3}')
WARNINGS=$(grep "Warnings" /tmp/lynis_output.txt | awk '{print $2}')
SUGGESTIONS=$(grep "Suggestions" /tmp/lynis_output.txt | awk '{print $2}')

echo ""
echo "Hardening Index: $HARDENING_INDEX"
echo "Tests Performed: $TESTS"
echo "Warnings: $WARNINGS"
echo "Suggestions: $SUGGESTIONS"
echo ""

echo "Critical Findings:"
grep "\[WARNING\]" /tmp/lynis_output.txt

# fayla yaz
sudo cp /tmp/lynis_output.txt $LOG_FILE

echo ""
echo "Baseline saved to: $LOG_FILE"
