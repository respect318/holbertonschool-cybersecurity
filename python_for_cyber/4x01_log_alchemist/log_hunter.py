#!/usr/bin/env python3
"""
LogHunter - Log Analysis Engine
Task 0: The Stream
"""
import argparse
from typing import Iterator


def read_stream(file_path: str) -> Iterator[str]:
    """
    Reads a file line by line using a generator.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")


def main() -> None:
    """
    Main entry point for LogHunter.
    """
    parser = argparse.ArgumentParser(description="LogHunter Engine")
    parser.add_argument("file", help="Path to the log file")

    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    lines_read = 0
    for _ in read_stream(args.file):
        lines_read += 1

    if lines_read == 0:
        print("[!] No data to process. Exiting.")
    else:
        print(f"[*] Lines read: {lines_read}")


if __name__ == '__main__':
    main()
