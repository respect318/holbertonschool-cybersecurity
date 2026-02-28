#!/bin/bash
grep -Rl "password =" "$1" 2>/dev/null | cut -d: -f1 | sort -u
