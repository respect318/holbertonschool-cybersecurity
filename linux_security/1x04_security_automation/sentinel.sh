#!/bin/bash
[ -f sentinel.conf ] && source sentinel.conf && [ "${SERVICES+x}" ] && [ "${FILES_TO_WATCH+x}" ] || { echo "Config error"; exit 1; }
