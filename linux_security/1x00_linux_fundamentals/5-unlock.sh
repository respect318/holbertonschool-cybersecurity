#!/bin/bash
chattr -i "$1" 2>/dev/null
rm -f "$1"
