#!/bin/bash
grep "$2" "$1" | sed -n 's/.*cmd=\([^&]*\).*/\1/p' | sed 's/%3D/=/' | base64 --decode > "$3"

