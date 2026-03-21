#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming, parsing, normalization, filtering,
GeoIP enrichment, bot detection, threat intelligence, attack detection,
and burst/rate-limit detection.
"""

import argparse
import sys
import re
from collections import Counter, defaultdict
from datetime import datetime, timedelta
from typing import Generator, Optional, Dict, Iterable

# Simulated GeoIP Database
GEOIP_DB = {
    '1.2.3.4': 'US',
    '5.6.7.8': 'RU'
}

# Known Bot Signatures
BOT_SIGNATURES = ['sqlmap', 'nikto', 'curl', 'python']

# Known Malicious IPs
BLACKLIST = {'10.0.0.1', '192.168.1.66'}

# SQL Injection Regex Patterns (Case-Insensitive)
SQLI_PATTERNS = [
    re.compile(r"union\s+select", re.IGNORECASE),
    re.compile(r"'\s*or\s*1=1", re.IGNORECASE),
    re.compile(r"--", re.IGNORECASE)
]

# XSS Regex Patterns (Case-Insensitive)
XSS_PATTERNS = [
    re.compile(r"<script>", re.IGNORECASE),
    re.compile(r"javascript:", re.IGNORECASE),
    re.compile(r"onload=", re.IGNORECASE),
    re.compile(r"onerror=", re.IGNORECASE)
]

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

    def __init__(
        self, ip: str = "", timestamp: str = "",
        service: str = "", message: str = "",
        raw_line: str = "", **kwargs
    ):
        self.ip = ip
        self.timestamp = timestamp
        self.service = service
        self.message = message
        self.raw_line = raw_line
        self.is_bot = False
        self.alert_level = 'LOW'
        self.attack_type = ''

        for key, value in kwargs.items():
            setattr(self, key, value)


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

        entry = LogEntry(
            ip, timestamp, service, message, raw_line,
            method=method,
            path=path,
            status=int(parsed_dict.get('status', 0)),
            user_agent=parsed_dict.get('user_agent', '')
        )
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
    """
    for entry in stream:
        status = getattr(entry, 'status', None)
        if status in status_codes:
            yield entry


def enrich_ip(log_entry: LogEntry) -> None:
    """
    Looks up the entry's IP in GEOIP_DB and adds a country attribute.
    """
    country = GEOIP_DB.get(log_entry.ip, 'UNKNOWN')
    log_entry.country = country


def analyze_user_agent(log_entry: LogEntry) -> None:
    """
    Detects known bot signatures in user_agent, message, or raw_line.
    Sets log_entry.is_bot to True if found.
    """
    log_entry.is_bot = False

    user_agent = getattr(log_entry, 'user_agent', '')
    message = getattr(log_entry, 'message', '')
    raw_line = getattr(log_entry, 'raw_line', '')

    combined_text = f"{user_agent} {message} {raw_line}".lower()

    for signature in BOT_SIGNATURES:
        if signature in combined_text:
            log_entry.is_bot = True
            break


def check_threat_intel(log_entry: LogEntry) -> None:
    """
    Checks if the IP is in the BLACKLIST.
    Sets alert_level to HIGH if malicious, LOW otherwise.
    """
    if log_entry.ip in BLACKLIST:
        log_entry.alert_level = 'HIGH'
    else:
        log_entry.alert_level = 'LOW'


def detect_sqli(log_entry: LogEntry) -> None:
    """
    Detects SQL Injection patterns in the path or message.
    Sets attack_type to 'SQLi' if a match is found.
    """
    path = getattr(log_entry, 'path', '')
    message = getattr(log_entry, 'message', '')
    target_text = f"{path} {message}"

    for pattern in SQLI_PATTERNS:
        if pattern.search(target_text):
            log_entry.attack_type = 'SQLi'
            break


def detect_xss(log_entry: LogEntry) -> None:
    """
    Detects Cross-Site Scripting (XSS) patterns in the path.
    Sets attack_type to 'XSS' if a match is found.
    Will not overwrite existing attack_type (e.g., SQLi).
    """
    if log_entry.attack_type:
        return

    path = getattr(log_entry, 'path', '')
    message = getattr(log_entry, 'message', '')
    target_text = f"{path} {message}"

    for pattern in XSS_PATTERNS:
        if pattern.search(target_text):
            log_entry.attack_type = 'XSS'
            break


def detect_bruteforce(
    entries: Iterable[LogEntry]
) -> Generator[dict, None, None]:
    """
    Detects volumetric authentication attacks (Brute Force).
    Counts IPs with HTTP 401 or 'Failed password' in message.
    """
    failures = Counter()
    for entry in entries:
        status = getattr(entry, 'status', None)
        message = getattr(entry, 'message', '')

        if str(status) == '401' or "Failed password" in message:
            if entry.ip:
                failures[entry.ip] += 1

    for ip, count in failures.most_common():
        if count > 5:
            yield {
                'ip': ip,
                'count': count,
                'alert_type': 'BRUTE_FORCE'
            }


def parse_timestamp(ts_str: str) -> Optional[datetime]:
    """
    Parses Apache and Syslog timestamps into naive datetime objects.
    """
    if not ts_str:
        return None

    # Apache format: 11/Feb/2026:14:01:24 +0000
    try:
        dt = datetime.strptime(ts_str, '%d/%b/%Y:%H:%M:%S %z')
        return dt.replace(tzinfo=None)
    except ValueError:
        pass

    # Syslog format: Feb 11 14:31:24
    try:
        ts_norm = re.sub(r'\s+', ' ', ts_str.strip())
        dt = datetime.strptime(ts_norm, '%b %d %H:%M:%S')
        # Syslog doesn't include year, default to current year
        return dt.replace(year=datetime.now().year)
    except ValueError:
        pass

    return None


def detect_burst(
    entries: Iterable[LogEntry], window_seconds: int = 60, threshold: int = 10
) -> Generator[dict, None, None]:
    """
    Detects bursts of activity from a single IP.
    Yields an alert if an IP sends >= threshold requests within the window.
    """
    window_tracker = defaultdict(list)
    alerted_ips = set()

    for entry in entries:
        dt = parse_timestamp(entry.timestamp)
        if not dt or not entry.ip:
            continue

        ip = entry.ip
        window_tracker[ip].append(dt)

        # Sürüşən pəncərə (Sliding window): pəncərədən köhnə vaxtları silirik
        cutoff = dt - timedelta(seconds=window_seconds)
        window_tracker[ip] = [t for t in window_tracker[ip] if t >= cutoff]

        # Əgər cəhdlərin sayı threshold-u keçibsə və xəbərdarlıq edilməyibsə
        if len(window_tracker[ip]) >= threshold and ip not in alerted_ips:
            yield {
                'ip': ip,
                'count': len(window_tracker[ip]),
                'window': window_seconds,
                'alert_type': 'BURST'
            }
            alerted_ips.add(ip)


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
                entry = normalize_entry(
                    parsed_syslog, 'syslog', line_clean
                )
                parsed_entries.append(entry)

    if not has_data:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")

    # Enrichment & Detection Section Variables
    known_ips_count = 0
    bots_count = 0
    high_alerts_count = 0
    sqli_count = 0
    xss_count = 0

    for entry in parsed_entries:
        # IP Enrichment
        enrich_ip(entry)
        if getattr(entry, 'country', 'UNKNOWN') != 'UNKNOWN':
            known_ips_count += 1

        # Bot Analysis
        analyze_user_agent(entry)
        if entry.is_bot:
            bots_count += 1

        # Threat Intel
        check_threat_intel(entry)
        if entry.alert_level == 'HIGH':
            high_alerts_count += 1

        # Attack Detection Pipeline
        detect_sqli(entry)
        detect_xss(entry)

        if entry.attack_type == 'SQLi':
            sqli_count += 1
        elif entry.attack_type == 'XSS':
            xss_count += 1

    print("--- Enrichment ---")
    print(f"[*] GeoIP: {len(parsed_entries)} entries enriched "
          f"({known_ips_count} known IPs)")
    print(f"[*] Bots detected: {bots_count}")

    # Threat Intelligence Section
    print("--- Threat Intelligence ---")
    print(f"[*] HIGH alerts: {high_alerts_count} "
          f"entries from blacklisted IPs")

    # Attack Detection Section
    print("--- Attack Detection ---")
    print(f"[*] SQLi attempts: {sqli_count}")
    print(f"[*] XSS attempts:  {xss_count}")

    # Brute Force Section
    bf_alerts = list(detect_bruteforce(parsed_entries))
    print("--- Brute Force ---")
    print(f"[*] BRUTE_FORCE alerts: {len(bf_alerts)}")
    for alert in bf_alerts:
        print(f"    {alert['ip']}: {alert['count']} failures")

    # Burst Detection Section
    burst_alerts = list(detect_burst(parsed_entries))
    print("--- Burst Detection ---")
    print(f"[*] BURST alerts: {len(burst_alerts)}")
    for alert in burst_alerts:
        print(f"    {alert['ip']}: {alert['count']} requests in "
              f"{alert['window']}s window")

    # Filtering Section
    suspicious_entries = list(filter_logs(parsed_entries))
    print("--- Filtering ---")
    print(f"[*] Suspicious (404, 500): {len(suspicious_entries)}")


if __name__ == "__main__":
    main()
