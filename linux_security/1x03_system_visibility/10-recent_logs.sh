#!/bin/bash
date --date='30 minutes ago' '+%b %e %H:%M' | xargs -I{} grep "{}" $1 | grep sshd
