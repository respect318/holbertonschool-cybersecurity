#!/usr/bin/env python3
import argparse
import sys
import logging
import configparser
import os
from utils import clean_data, validate_line, hash_password

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


def check_policy(password: str) -> str:
    min_length = int(config.get('SECURITY', 'MinLength', fallback=8))
    common_passwords_str = config.get('SECURITY', 'CommonPasswords', fallback="password,123456")
    common_passwords = [p.strip() for p in common_passwords_str.split(',')]
    
    if len(password) < min_length or password.isalpha() or password in common_passwords:
        return 'WEAK'
    return 'COMPLIANT'


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
    valid_lines = (line for line in clean_lines if validate_line(line))


if __name__ == "__main__":
    main()
