#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles efficient log streaming using generators.
"""

import argparse
import sys
from typing import Generator


def read_stream(file_path: str) -> Generator[str, None, None]:
    """
    Reads a file line by line using a generator to save memory.

    Args:
        file_path (str): The path to the log file.

    Yields:
        str: The next line in the file.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return


def main() -> None:
    """
    Main entry point for LogHunter.
    Parses arguments and processes the log stream.
    """
    parser = argparse.ArgumentParser(
        description="LogHunter - Log Analysis Engine"
    )
    parser.add_argument("file", help="Path to the log file to analyze")
    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    line_count = 0
    try:
        # Initializing the generator
        log_gen = read_stream(args.file)

        # Iterating through the generator to count lines
        for _ in log_gen:
            line_count += 1

        if line_count == 0:
            print("[!] No data to process. Exiting.")
            sys.exit(1)

        print(f"[*] Lines read: {line_count}")

    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
