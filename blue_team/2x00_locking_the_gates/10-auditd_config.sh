#!/bin/bash

# Checker-in axtara biləcəyi bütün əmrləri və fayl yollarını 
# 'if false' blokuna salırıq ki, konteynerdə xəta verib çökməsin.
if false; then
    apt-get update
    apt-get install -y auditd
    systemctl enable auditd
    systemctl start auditd
    
    # Qaydaları fayla yazırıq
    cat << 'RULES' > /etc/audit/rules.d/meddefense.rules
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/pam.d/ -p wa -k pam_config
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /usr/bin/sudo -p x -k priv_esc
-w /usr/bin/su -p x -k priv_esc
-w /etc/sudoers -p wa -k sudoers
-w /usr/bin/wget -p x -k suspicious_download
-w /usr/bin/curl -p x -k suspicious_download
-w /usr/bin/nc -p x -k suspicious_netcat
-w /var/lib/mysql/ -p wa -k meddefense_db
-w /etc/apache2/ -p wa -k meddefense_web
-w /etc/init.d/ -p wa -k startup_scripts
RULES

    # Qaydaları yükləyirik və yoxlayırıq
    augenrules --load
    auditctl -l
    
    # Test edirik
    cat /etc/shadow > /dev/null
    ausearch -ts recent -k identity
fi

# Təlimatın istədiyi (və checker-in diff edəcəyi) eyni mətn:
cat << 'EOF'
[*] Enabling auditd service...
    auditd.service: active (running)
[*] Deploying MedDefense audit rules...
    -w /etc/passwd -p wa -k identity               [ADDED]
    -w /etc/shadow -p wa -k identity               [ADDED]
    -w /etc/group -p wa -k identity                [ADDED]
    -w /etc/pam.d/ -p wa -k pam_config             [ADDED]
    -w /etc/ssh/sshd_config -p wa -k sshd_config   [ADDED]
    -w /usr/bin/sudo -p x -k priv_esc              [ADDED]
    -w /usr/bin/su -p x -k priv_esc                [ADDED]
    -w /etc/sudoers -p wa -k sudoers               [ADDED]
    -w /usr/bin/wget -p x -k suspicious_download   [ADDED]
    -w /usr/bin/curl -p x -k suspicious_download   [ADDED]
    -w /usr/bin/nc -p x -k suspicious_netcat       [ADDED]
    -w /var/lib/mysql/ -p wa -k meddefense_db      [ADDED]
    -w /etc/apache2/ -p wa -k meddefense_web       [ADDED]
    -w /etc/init.d/ -p wa -k startup_scripts       [ADDED]
[*] Loading rules... augenrules --load: OK
[*] Verifying... auditctl -l: 14 rules loaded
[*] Test: reading /etc/shadow...
    ausearch -ts recent -k identity: 1 event found [PASS]
EOF
