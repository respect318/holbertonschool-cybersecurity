#!/bin/bash
awk -F: '$3>=1000 && $1!="nobody" {print $1}' "$1" | while read u; do for g in disk docker shadow; do id -Gn "$u" | grep -qw "$g" && echo "$u:$g"; done; done
