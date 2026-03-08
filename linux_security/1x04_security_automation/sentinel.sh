#!/bin/bash
[ -f sentinel.conf ] && . sentinel.conf && [ "${SERVICES+x}" ] && [ "${FILES_TO_WATCH+x}" ] || { echo "Config error"; exit 1; }
