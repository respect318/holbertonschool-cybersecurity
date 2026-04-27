#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <input_file> <output_file> <cbc|gcm>"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"
MODE="$3"

if [ "$MODE" == "cbc" ]; then
    openssl enc -aes-256-cbc -pbkdf2 -in "$INPUT_FILE" -out "$OUTPUT_FILE" -pass pass:MedDefense
elif [ "$MODE" == "gcm" ]; then
    openssl enc -aes-256-gcm -pbkdf2 -in "$INPUT_FILE" -out "$OUTPUT_FILE" -pass pass:MedDefense
else
    echo "Error: Invalid mode. Please use 'cbc' or 'gcm'."
    exit 1
fi
