#!/usr/bin/env python3
import argparse
import sys
from typing import Iterator

def read_stream(file_path: str) -> Iterator[str]:
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return

def main() -> None:
    parser = argparse.ArgumentParser(description="LogHunter - Log Analysis Engine")
    parser.add_argument("file", help="Path to the log file")
    
    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    lines_read = 0
    stream = read_stream(args.file)
    
    for _ in stream:
        lines_read += 1

    if lines_read == 0:
        print("[!] No data to process. Exiting.")
    else:
        print(f"[*] Lines read: {lines_read}")

if __name__ == '__main__':
    main()
