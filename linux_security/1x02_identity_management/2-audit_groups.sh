#!/bin/bash
awk -F: '$3>=1000 && $1!="nobody" {print $1}' "$1" | while read u; do id -Gn "$u" | grep -owE "disk|docker|shadow" | sed "s/^/$u:/"; done
