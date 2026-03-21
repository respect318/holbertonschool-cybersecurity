#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming and Apache log parsing using Regex.
"""

import argparse
import sys
import re
from typing import Generator, Optional, Dict

# Pre-compiled Regex for Apache Common Log Format with Named Groups
# We use a more flexible pattern to match various HTTP methods and status codes
APACHE_PATTERN = re.compile(
    r'(?P<ip>\d{1,3}(?:\.\d{1,3}){3})'       # IP
    r'\s+-\s+-\s+\['                         # Separator
    r'(?P<date>[^\]]+)\]\s+'                 # Date
    r'"(?P<method>[A-Z]+)\s+'                # Method
    r'(?P<path>[^ ]+)\s+'                    # Path
    r'HTTP/\d\.\d"\s+'                       # Protocol
    r'(?P<status>\d{3})\s+'                  # Status
    r'(?P<size>\d+|-)'                       # Size
)


def read_stream(file_path: str) -> Generator[str, None, None]:
    """
    Reads a file line by line using a generator.
    """
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")
        return


def parse_apache_line(line: str) -> Optional[Dict[str, str]]:
    """
    Parses a single Apache log line using Regex Named Groups.
    """
    match = APACHE_PATTERN.search(line)
    if match:
        return match.groupdict()
    return None


def main() -> None:
    """
    Main entry point for LogHunter.
    """
    parser = argparse.ArgumentParser(
        description="LogHunter - Log Analysis Engine"
    )
    parser.add_argument("file", help="Path to the log file to analyze")
    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    apache_count = 0
    syslog_count = 0

    log_gen = read_stream(args.file)
    has_data = False

    for line in log_gen:
        has_data = True
        parsed_apache = parse_apache_line(line)
        if parsed_apache:
            apache_count += 1

    if not has_data:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")


if __name__ == "__main__":
    main()
