#!/bin/bash
set -e
cat <<EOF > /etc/sudoers.d/junior
$1 ALL=(ALL) /usr/bin/systemctl restart apache2, /usr/bin/journalctl
EOF
chmod 440 /etc/sudoers.d/junior
visudo -c
