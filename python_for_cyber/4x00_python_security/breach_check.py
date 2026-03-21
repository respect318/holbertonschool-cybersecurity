#!/usr/bin/env python3
import argparse
import sys
import re
import logging
import hashlib
import configparser
import os

config = configparser.ConfigParser()

def setup_logger():
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    console_handler.setFormatter(formatter)

    file_handler = logging.FileHandler("breach_check.log")
    file_handler.setLevel(logging.DEBUG)
    file_handler.setFormatter(formatter)

    logger.addHandler(console_handler)
    logger.addHandler(file_handler)

def read_file(filename: str) -> list:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return f.readlines()
    except FileNotFoundError:
        logging.error(f"File not found: {filename}")
        sys.exit(1)
    except PermissionError:
        logging.error(f"Permission denied: {filename}")
        sys.exit(1)

def clean_data(lines: list) -> list:
    cleaned_lines = []
    for line in lines:
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith("#"):
            cleaned_lines.append(stripped_line)
    return cleaned_lines

def validate_line(line: str) -> bool:
    pattern = r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+:.+$"
    return bool(re.match(pattern, line))

def check_policy(password: str) -> str:
    min_length = int(config.get('SECURITY', 'MinLength', fallback=8))
    common_passwords_str = config.get('SECURITY', 'CommonPasswords', fallback="password,123456")
    common_passwords = [p.strip() for p in common_passwords_str.split(',')]
    
    if len(password) < min_length or password.isalpha() or password in common_passwords:
        return 'WEAK'
    return 'COMPLIANT'

def hash_password(password: str, salt: str) -> str:
    salted_password = password + salt
    return hashlib.sha256(salted_password.encode('utf-8')).hexdigest()

def main():
    if not os.path.exists("config.ini"):
        print("[ERROR] config file missing", file=sys.stderr)
        sys.exit(1)
    
    config.read("config.ini")

    setup_logger()

    parser = argparse.ArgumentParser(description="BreachCheck - Security Analysis Tool")
    
    parser.add_argument("-f", "--file", required=True, type=str, help="Input file path")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose mode")
    parser.add_argument("-o", "--output", type=str, help="Output report file path")

    args = parser.parse_args()

    logging.info("BreachCheck v1.0 startup...")
    
    salt = config.get("SECURITY", "Salt", fallback="default_salt")
    
    raw_lines = read_file(args.file)
    clean_lines = clean_data(raw_lines)
    valid_lines = [line for line in clean_lines if validate_line(line)]

if __name__ == "__main__":
    main()
