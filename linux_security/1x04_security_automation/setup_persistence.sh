#!/bin/bash
sudo cp sentinel.service sentinel.timer /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now sentinel.timer
