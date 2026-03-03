#!/bin/bash
ps -eo pid,comm --sort=-%cpu | awk 'NR==2 {print $1, $2}'
