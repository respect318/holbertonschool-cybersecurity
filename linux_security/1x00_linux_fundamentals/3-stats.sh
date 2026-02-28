#!/bin/bash
ls -l "$1" 2>/dev/null | awk '{print $3}' | sort | uniq -c | sort -nr | head -1

