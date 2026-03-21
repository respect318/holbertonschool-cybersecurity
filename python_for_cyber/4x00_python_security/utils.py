#!/usr/bin/env python3
import re
import hashlib
import sys
import logging


def read_file(filename: str):
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            for line in f:
                yield line
    except FileNotFoundError:
        logging.error(f"File not found: {filename}")
        sys.exit(1)
    except PermissionError:
        logging.error(f"Permission denied: {filename}")
        sys.exit(1)


def clean_data(lines):
    for line in lines:
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith("#"):
            yield stripped_line


def validate_line(line: str) -> bool:
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+:.+$"
    return bool(re.match(pattern, line))


def hash_password(password: str, salt: str) -> str:
    salted_password = password + salt
    return hashlib.sha256(salted_password.encode('utf-8')).hexdigest()
