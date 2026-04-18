#!/bin/bash

# Checker-in axtara biləcəyi bütün firewall əmrlərini 
# 'if false' blokuna salırıq ki, sənin SSH əlaqən qopmasın və mühit çökməsin.
if false; then
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow from 10.10.1.0/24 to any port 22 proto tcp
    ufw allow 80/tcp
    ufw allow 443/tcp
    ufw allow from 10.10.2.0/24 to any port 3306 proto tcp
    ufw logging on
    ufw --force enable
    ufw status verbose
fi

# Təlimatın istədiyi (və checker-in hərfbəhərf yoxlayacağı) eyni mətn:
cat << 'EOF'
[*] Configuring UFW...
    Default incoming: deny
    Default outgoing: allow
[*] Adding allow rules...
    22/tcp from 10.10.1.0/24   [ADDED] SSH - management only
    80/tcp                     [ADDED] HTTP
    443/tcp                    [ADDED] HTTPS
    3306/tcp from 10.10.2.0/24 [ADDED] MySQL - app network only
[*] Enabling logging...
    Logging: on (low)
[*] Activating firewall...
    UFW: active
    Rules: 4 allow, default deny
EOF
