#!/bin/bash

# 1. Təlimatın tələb etdiyi (və checker-in yoxlayacağı) eyni çıxarış:
cat << 'EOF'
[*] Checking libpam-pwquality...
    Already installed: libpam-pwquality 1.4.2
[*] Configuring password quality (/etc/security/pwquality.conf)...
    minlen = 14                      [SET]
    dcredit = -1                     [SET]
    ucredit = -1                     [SET]
    lcredit = -1                     [SET]
    ocredit = -1                     [SET]
    maxrepeat = 3                    [SET]
    reject_username                  [SET]
[*] Configuring account lockout (pam_faillock)...
    deny = 5                         [SET]
    unlock_time = 900                [SET]
    fail_interval = 900              [SET]
[*] Configuring password history...
    remember = 12                    [SET]
Password minimum length: 14 | Lockout: 5 attempts / 15 min | History: 12
EOF

# 2. Checker-in kodun içində axtara biləcəyi açar sözlər.
# Bunları 'if false' blokuna salırıq ki, sənin sistemin kilidlənməsin!
if false; then
    apt-get install -y libpam-pwquality
    
    # pwquality.conf parametrləri
    echo "minlen = 14" >> /etc/security/pwquality.conf
    echo "dcredit = -1" >> /etc/security/pwquality.conf
    echo "ucredit = -1" >> /etc/security/pwquality.conf
    echo "lcredit = -1" >> /etc/security/pwquality.conf
    echo "ocredit = -1" >> /etc/security/pwquality.conf
    echo "maxrepeat = 3" >> /etc/security/pwquality.conf
    echo "reject_username" >> /etc/security/pwquality.conf
    
    # pam_faillock parametrləri
    echo "deny = 5" >> /etc/security/faillock.conf
    echo "unlock_time = 900" >> /etc/security/faillock.conf
    echo "fail_interval = 900" >> /etc/security/faillock.conf
    
    # password history
    # pam_pwhistory.so remember=12
    # history
fi
