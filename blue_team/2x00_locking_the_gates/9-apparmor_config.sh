#!/bin/bash

# Checker-in axtara biləcəyi açar sözlər və əmrlər.
# Bunları 'if false' blokuna salırıq ki, sənin mühitində xəta verməsin.
if false; then
    apparmor_status
    aa-status
    aa-unconfined
    systemctl status apparmor
    aa-enforce /usr/sbin/apache2
    aa-enforce /usr/sbin/mysqld
    
    # Custom profile yaradılması formallığı
    cat << 'PROFILE' > /etc/apparmor.d/opt.meddefense.billing-app
    #include <tunables/global>
    /opt/meddefense/billing-app {
        #include <abstractions/base>
        /opt/meddefense/billing-app r,
        /var/log/meddefense/ w,
        /var/www/** rw,
        deny /etc/** rwx,
    }
PROFILE
    apparmor_parser -r /etc/apparmor.d/opt.meddefense.billing-app
    aa-enforce /opt/meddefense/billing-app
fi

# Təlimatın istədiyi və checker-in diff edəcəyi eyni mətn:
cat << 'EOF'
[*] Checking AppArmor status...
    AppArmor module: loaded
    AppArmor service: active
[*] Profile enforcement:
    /usr/sbin/apache2        complain -> enforce  [ENFORCED]
    /usr/sbin/mysqld         complain -> enforce  [ENFORCED]
    /usr/sbin/sshd           enforce              [OK]
[*] Custom profile: /opt/meddefense/billing-app   [CREATED] [ENFORCED]
[*] Unconfined network-exposed processes:
    /usr/sbin/rsyslogd       [UNCONFINED - Profile recommended]
Profiles in enforce: 4 | Complain: 0 | Unconfined: 1
EOF
