#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming, Apache, and Syslog parsing using Regex.
"""

import argparse
import sys
import re
from typing import Generator, Optional, Dict

# Pre-compiled Regex for Apache Common Log Format
APACHE_PATTERN = re.compile(
    r'(?P<ip>\S+)\s+'                # IP Address (IPv4 or IPv6)
    r'\S+\s+\S+\s+\['                # Logname and User
    r'(?P<date>[^\]]+)\]\s+"'        # Date inside []
    r'(?P<method>[A-Z]+)\s+'         # HTTP Method
    r'(?P<path>[^\s"]+)\s+'          # Request Path
    r'HTTP/[0-9.]+"\s+'              # Protocol version
    r'(?P<status>\d{3})\s+'          # Status Code
    r'(?P<size>\d+|-)'               # Response Size
)

# Pre-compiled Regex for Syslog Format
# Handles 1 or 2 spaces for single-digit days with \s+
SYSLOG_PATTERN = re.compile(
    r'^(?P<date>[A-Z][a-z]{2}\s+\d{1,2}\s\d{2}:\d{2}:\d{2})\s+'  # Date
    r'(?P<host>\S+)\s+'                                          # Host
    r'(?P<process>[^:]+):\s+'                                    # Process
    r'(?P<message>.*)$'                                          # Message
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


def parse_syslog_line(line: str) -> Optional[Dict[str, str]]:
    """
    Parses a single Syslog line using Regex Named Groups.
    """
    match = SYSLOG_PATTERN.search(line)
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
        
        # 1. Try to parse as Apache format
        parsed_apache = parse_apache_line(line)
        if parsed_apache:
            apache_count += 1
        else:
            # 2. If Apache fails, try Syslog format
            parsed_syslog = parse_syslog_line(line)
            if parsed_syslog:
                syslog_count += 1

    if not has_data:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")


if __name__ == "__main__":
    main()
