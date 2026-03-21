#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming, parsing, and normalization.
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
SYSLOG_PATTERN = re.compile(
    r'^(?P<date>[A-Z][a-z]{2}\s+\d{1,2}\s\d{2}:\d{2}:\d{2})\s+'  # Date
    r'(?P<host>\S+)\s+'                                          # Host
    r'(?P<process>[^:]+):\s+'                                    # Process
    r'(?P<message>.*)$'                                          # Message
)


class LogEntry:
    """
    Standardized Log Entry object to hold parsed log data uniformly.
    """

    def __init__(self, ip: str, timestamp: str, service: str,
                 message: str, raw_line: str):
        self.ip = ip
        self.timestamp = timestamp
        self.service = service
        self.message = message
        self.raw_line = raw_line

        # Additional optional attributes
        self.method = ""
        self.path = ""
        self.status = 0
        self.user_agent = ""


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


def normalize_entry(
    parsed_dict: Dict[str, str], log_type: str, raw_line: str = ''
) -> LogEntry:
    """
    Normalizes a parsed log dictionary into a LogEntry object.
    """
    if log_type == 'apache':
        ip = parsed_dict.get('ip', '')
        timestamp = parsed_dict.get('date', '')
        service = 'http'
        # Message for Apache can be a combination of method and path
        message = f"{parsed_dict.get('method', '')} {parsed_dict.get('path')}"

        entry = LogEntry(ip, timestamp, service, message, raw_line)
        entry.method = parsed_dict.get('method', '')
        entry.path = parsed_dict.get('path', '')
        entry.status = int(parsed_dict.get('status', 0))
        entry.user_agent = parsed_dict.get('user_agent', '')
        return entry

    elif log_type == 'syslog':
        timestamp = parsed_dict.get('date', '')
        service = 'ssh'
        message = parsed_dict.get('message', '')

        # Attempt to extract an IPv4 address from the syslog message
        ip = ""
        ip_match = re.search(r'\d{1,3}(?:\.\d{1,3}){3}', message)
        if ip_match:
            ip = ip_match.group(0)

        entry = LogEntry(ip, timestamp, service, message, raw_line)
        return entry

    # Fallback for unknown log types
    return LogEntry("", "", "unknown", "", raw_line)


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
    sample_entry = None

    log_gen = read_stream(args.file)
    has_data = False

    for line in log_gen:
        has_data = True
        line_clean = line.strip()

        # 1. Try to parse as Apache format
        parsed_apache = parse_apache_line(line_clean)
        if parsed_apache:
            apache_count += 1
            entry = normalize_entry(parsed_apache, 'apache', line_clean)
            if not sample_entry:
                sample_entry = entry
        else:
            # 2. If Apache fails, try Syslog format
            parsed_syslog = parse_syslog_line(line_clean)
            if parsed_syslog:
                syslog_count += 1
                entry = normalize_entry(parsed_syslog, 'syslog', line_clean)
                if not sample_entry:
                    sample_entry = entry

    if not has_data:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")

    if sample_entry:
        print("[*] Sample entry:")
        if sample_entry.service == 'http':
            print(f"    ip={sample_entry.ip} | service={sample_entry.service} "
                  f"| status={sample_entry.status} | path={sample_entry.path}")
        else:
            print(f"    ip={sample_entry.ip} | service={sample_entry.service} "
                  f"| message={sample_entry.message}")


if __name__ == "__main__":
    main()
