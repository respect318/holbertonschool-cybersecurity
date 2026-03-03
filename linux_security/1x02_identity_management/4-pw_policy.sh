#!/bin/bash
apt-get install -y libpam-pwquality && sed -i 's/.*pam_pwquality.*/password requisite pam_pwquality.so retry=3 minlen=12 minclass=3/' "$2"
