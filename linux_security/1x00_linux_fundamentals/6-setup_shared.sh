#!/bin/bash
mkdir -p "$1" && chown :developers "$1" && chmod 2775 "$1" && chmod +t "$1"

