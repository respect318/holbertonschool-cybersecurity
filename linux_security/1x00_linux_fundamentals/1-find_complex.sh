#!/bin/bash
find /var/log -type f -size +1M -mtime -1 ! -name "*.gz"

