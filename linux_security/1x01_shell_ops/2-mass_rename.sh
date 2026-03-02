#!/bin/bash
find "$1" -maxdepth 1 -type f -name "*.log" | xargs -I {} mv "{}" "{}.old"

