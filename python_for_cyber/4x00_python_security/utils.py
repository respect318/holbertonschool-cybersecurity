#!/usr/bin/env python3
import re
import hashlib


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
