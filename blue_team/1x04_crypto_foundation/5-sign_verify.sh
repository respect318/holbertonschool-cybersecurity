#!/bin/bash

if [ "$1" == "sign" ]; then
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 sign <file_path> <private_key_path>"
        exit 1
    fi
    FILE_PATH="$2"
    PRIVATE_KEY="$3"
    openssl dgst -sha256 -sign "$PRIVATE_KEY" -out "${FILE_PATH}.sig" "$FILE_PATH"

elif [ "$1" == "verify" ]; then
    if [ "$#" -ne 4 ]; then
        echo "Usage: $0 verify <file_path> <signature_path> <public_key_path>"
        exit 1
    fi
    FILE_PATH="$2"
    SIGNATURE_PATH="$3"
    PUBLIC_KEY="$4"
    openssl dgst -sha256 -verify "$PUBLIC_KEY" -signature "$SIGNATURE_PATH" "$FILE_PATH"

else
    echo "Error: Mode must be 'sign' or 'verify'"
    exit 1
fi
