#!/usr/bin/env python3
import argparse
import sys

def read_file(filename: str) -> list:
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            return f.readlines()
    except FileNotFoundError:
        print(f"[ERROR] File not found: {filename}", file=sys.stderr)
        sys.exit(1)
    except PermissionError:
        print(f"[ERROR] Permission denied: {filename}", file=sys.stderr)
        sys.exit(1)

def clean_data(lines: list) -> list:
    cleaned_lines = []
    for line in lines:
        stripped_line = line.strip()
        if stripped_line and not stripped_line.startswith("#"):
            cleaned_lines.append(stripped_line)
    return cleaned_lines

def main():
    parser = argparse.ArgumentParser(description="BreachCheck - Security Analysis Tool")
    
    parser.add_argument("-f", "--file", required=True, type=str, help="Input file path")
    parser.add_argument("-v", "--verbose", action="store_true", help="Enable verbose mode")
    parser.add_argument("-o", "--output", type=str, help="Output report file path")

    args = parser.parse_args()

    print("BreachCheck v1.0 startup...")
    
    raw_lines = read_file(args.file)
    clean_lines = clean_data(raw_lines)

if __name__ == "__main__":
    main()
