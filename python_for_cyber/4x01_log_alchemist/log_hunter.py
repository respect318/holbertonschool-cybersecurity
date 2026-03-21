#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming, parsing, normalization, filtering,
and GeoIP enrichment.
"""

import argparse
import sys
import re
from typing import Generator, Optional, Dict, Iterable

# Simulated GeoIP Database
GEOIP_DB = {
    '1.2.3.4': 'US',
    '5.6.7.8': 'RU'
}

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
        # Dynamically added later: status, method, path, country


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
        method = parsed_dict.get('method', '')
        path = parsed_dict.get('path', '')
        message = f"{method} {path}"

        entry = LogEntry(ip, timestamp, service, message, raw_line)
        entry.method = method
        entry.path = path
        entry.status = int(parsed_dict.get('status', 0))
        entry.user_agent = parsed_dict.get('user_agent', '')
        return entry

    elif log_type == 'syslog':
        timestamp = parsed_dict.get('date', '')
        service = 'ssh'
        message = parsed_dict.get('message', '')

        ip = ""
        ip_match = re.search(r'\d{1,3}(?:\.\d{1,3}){3}', message)
        if ip_match:
            ip = ip_match.group(0)

        entry = LogEntry(ip, timestamp, service, message, raw_line)
        return entry

    return LogEntry("", "", "unknown", "", raw_line)


def filter_logs(
    stream: Iterable[LogEntry], status_codes: list = [404, 500]
) -> Generator[LogEntry, None, None]:
    """
    Filters log entries, yielding only those with matching status codes.
    Entries without a status attribute are silently skipped.
    """
    for entry in stream:
        status = getattr(entry, 'status', None)
        if status in status_codes:
            yield entry


def enrich_ip(log_entry: LogEntry) -> None:
    """
    Looks up the entry's IP in GEOIP_DB and adds a country attribute.
    Defaults to 'UNKNOWN' if the IP is not found.
    """
    country = GEOIP_DB.get(log_entry.ip, 'UNKNOWN')
    log_entry.country = country


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
    parsed_entries = []

    log_gen = read_stream(args.file)
    has_data = False

    for line in log_gen:
        has_data = True
        line_clean = line.strip()

        # Try Apache first
        parsed_apache = parse_apache_line(line_clean)
        if parsed_apache:
            apache_count += 1
            entry = normalize_entry(parsed_apache, 'apache', line_clean)
            parsed_entries.append(entry)
        else:
            # Try Syslog second
            parsed_syslog = parse_syslog_line(line_clean)
            if parsed_syslog:
                syslog_count += 1
                entry = normalize_entry(parsed_syslog, 'syslog', line_clean)
                parsed_entries.append(entry)

    if not has_data:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")

    # Enrichment Section
    known_ips_count = 0
    for entry in parsed_entries:
        enrich_ip(entry)
        if entry.country != 'UNKNOWN':
            known_ips_count += 1

    print("--- Enrichment ---")
    print(f"[*] GeoIP: {len(parsed_entries)} entries enriched "
          f"({known_ips_count} known IPs)")

    # Filtering Section (Keeping it as requested in Task 4)
    suspicious_entries = list(filter_logs(parsed_entries))
    print("--- Filtering ---")
    print(f"[*] Suspicious (404, 500): {len(suspicious_entries)}")


if __name__ == "__main__":
    main()
