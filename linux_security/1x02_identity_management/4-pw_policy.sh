#!/bin/bash
apt-get install -y libpam-pwquality && sed -i '/pam_unix.so/i password requisite pam_pwquality.so minlen=12 minclass=3' "$2"
