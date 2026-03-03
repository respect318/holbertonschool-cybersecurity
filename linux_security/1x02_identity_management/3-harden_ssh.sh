#!/bin/bash
sed -i -e 's/.*PermitRootLogin.*/PermitRootLogin no/' -e 's/.*PasswordAuthentication.*/PasswordAuthentication no/' -e 's/.*PubkeyAuthentication.*/PubkeyAuthentication yes/' "$1" && sshd -t -f "$1" && systemctl reload ssh
