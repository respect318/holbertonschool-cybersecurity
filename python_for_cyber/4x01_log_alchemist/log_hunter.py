#!/usr/bin/env python3
"""
LogHunter - A high-performance log analysis engine.
This module handles log streaming, parsing, normalization, filtering,
GeoIP enrichment, bot detection, threat intelligence, attack detection,
burst/rate-limit detection, event correlation, reporting, and multiprocessing.
"""

import argparse
import json
import multiprocessing
import re
import sys
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

    try:
        dt = datetime.strptime(ts_str, '%d/%b/%Y:%H:%M:%S %z')
        return dt.replace(tzinfo=None)
    except ValueError:
        pass

    try:
        ts_norm = re.sub(r'\s+', ' ', ts_str.strip())
        dt = datetime.strptime(ts_norm, '%b %d %H:%M:%S')
        return dt.replace(year=datetime.now().year)
    except ValueError:
        pass

    return None


def detect_burst(
    entries: Iterable[LogEntry], window_seconds: int = 60, threshold: int = 10
) -> Generator[dict, None, None]:
    """
    Detects bursts of activity from a single IP.
    """
    window_tracker = defaultdict(list)
    alerted_ips = set()

    for entry in entries:
        dt = parse_timestamp(entry.timestamp)
        if not dt or not entry.ip:
            continue

        ip = entry.ip
        window_tracker[ip].append(dt)

        cutoff = dt - timedelta(seconds=window_seconds)
        window_tracker[ip] = [t for t in window_tracker[ip] if t >= cutoff]

        if len(window_tracker[ip]) >= threshold and ip not in alerted_ips:
            yield {
                'ip': ip,
                'count': len(window_tracker[ip]),
                'window': window_seconds,
                'alert_type': 'BURST'
            }
            alerted_ips.add(ip)


def correlate_events(
    entries: Iterable[LogEntry]
) -> Generator[dict, None, None]:
    """
    Correlates multiple log events to find chained attacks.
    """
    state = defaultdict(set)

    for entry in entries:
        if not entry.ip:
            continue

        status = getattr(entry, 'status', None)
        attack_type = getattr(entry, 'attack_type', '')

        if str(status) == '404':
            state[entry.ip].add('scanner')

        if attack_type == 'SQLi':
            state[entry.ip].add('sqli')

        if 'scanner' in state[entry.ip] and 'sqli' in state[entry.ip]:
            yield {
                'ip': entry.ip,
                'stages': ['scanner', 'sqli'],
                'alert_type': 'CRITICAL INCIDENT'
            }
            state[entry.ip].clear()


def export_report(alerts: list, filename: str, format: str = 'json') -> None:
    """
    Exports a list of alerts to a file.
    """
    output_data = []
    for item in alerts:
        if isinstance(item, dict):
            output_data.append(item)
        elif hasattr(item, '__dict__'):
            output_data.append(vars(item))
        else:
            output_data.append(str(item))

    if format == 'json':
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(output_data, f, indent=2)


def process_chunk(lines: list) -> list:
    """
    Worker function that processes a chunk of raw log lines.
    Returns a list of parsed, normalized, and enriched results.
    """
    results = []
    for line in lines:
        line_clean = line.strip()
        parsed_apache = parse_apache_line(line_clean)
        
        if parsed_apache:
            entry = normalize_entry(parsed_apache, 'apache', line_clean)
        else:
            parsed_syslog = parse_syslog_line(line_clean)
            if parsed_syslog:
                entry = normalize_entry(parsed_syslog, 'syslog', line_clean)
            else:
                entry = normalize_entry({}, 'unknown', line_clean)

        enrich_ip(entry)
        analyze_user_agent(entry)
        check_threat_intel(entry)
        detect_sqli(entry)
        detect_xss(entry)
        results.append(entry)

    return results


def parallel_analyze(
    file_path: str, num_workers: int, chunk_size: int = 10000
) -> list:
    """
    Reads the file, distributes chunks via multiprocessing.Pool.map.
    """
    results = []
    chunks = []

    with open(file_path, 'r', encoding='utf-8') as f:
        chunk = []
        for line in f:
            chunk.append(line)
            if len(chunk) == chunk_size:
                chunks.append(chunk)
                chunk = []
        if chunk:
            chunks.append(chunk)

    with multiprocessing.Pool(processes=num_workers) as pool:
        for chunk_res in pool.map(process_chunk, chunks):
            results.extend(chunk_res)

    return results


def main() -> None:
    """
    Main entry point for LogHunter.
    """
    parser = argparse.ArgumentParser(
        description="LogHunter - Log Analysis Engine"
    )
    parser.add_argument("file", help="Path to the log file to analyze")
    parser.add_argument(
        "--report", help="Export alerts to a JSON file", type=str
    )
    parser.add_argument(
        "--workers",
        help="Number of worker processes (0 = single-threaded)",
        type=int,
        default=0
    )
    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")

    if args.workers > 0:
        print(f"[*] Reading: {args.file} "
              f"(parallel: {args.workers} workers)")
        parsed_entries = parallel_analyze(args.file, args.workers)
    else:
        print(f"[*] Reading: {args.file}")
        parsed_entries = []
        log_gen = read_stream(args.file)
        for line in log_gen:
            line_clean = line.strip()
            parsed_apache = parse_apache_line(line_clean)
            
            if parsed_apache:
                entry = normalize_entry(
                    parsed_apache, 'apache', line_clean
                )
            else:
                parsed_syslog = parse_syslog_line(line_clean)
                if parsed_syslog:
                    entry = normalize_entry(
                        parsed_syslog, 'syslog', line_clean
                    )
                else:
                    entry = normalize_entry({}, 'unknown', line_clean)

            enrich_ip(entry)
            analyze_user_agent(entry)
            check_threat_intel(entry)
            detect_sqli(entry)
            detect_xss(entry)
            parsed_entries.append(entry)

    if not parsed_entries:
        print("[!] No data to process. Exiting.")
        sys.exit(1)

    apache_count = 0
    syslog_count = 0
    known_ips_count = 0
    bots_count = 0
    high_alerts_count = 0
    sqli_count = 0
    xss_count = 0

    for entry in parsed_entries:
        if getattr(entry, 'service', '') == 'http':
            apache_count += 1
        elif getattr(entry, 'service', '') == 'ssh':
            syslog_count += 1

        if getattr(entry, 'country', 'UNKNOWN') != 'UNKNOWN':
            known_ips_count += 1
        if getattr(entry, 'is_bot', False):
            bots_count += 1
        if getattr(entry, 'alert_level', 'LOW') == 'HIGH':
            high_alerts_count += 1
        if getattr(entry, 'attack_type', '') == 'SQLi':
            sqli_count += 1
        elif getattr(entry, 'attack_type', '') == 'XSS':
            xss_count += 1

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")

    print("--- Enrichment ---")
    print(f"[*] GeoIP: {len(parsed_entries)} entries enriched "
          f"({known_ips_count} known IPs)")
    print(f"[*] Bots detected: {bots_count}")

    print("--- Threat Intelligence ---")
    print(f"[*] HIGH alerts: {high_alerts_count} "
          f"entries from blacklisted IPs")

    print("--- Attack Detection ---")
    print(f"[*] SQLi attempts: {sqli_count}")
    print(f"[*] XSS attempts:  {xss_count}")

    bf_alerts = list(detect_bruteforce(parsed_entries))
    print("--- Brute Force ---")
    print(f"[*] BRUTE_FORCE alerts: {len(bf_alerts)}")
    for alert in bf_alerts:
        print(f"    {alert['ip']}: {alert['count']} failures")

    burst_alerts = list(detect_burst(parsed_entries))
    print("--- Burst Detection ---")
    print(f"[*] BURST alerts: {len(burst_alerts)}")
    for alert in burst_alerts:
        print(f"    {alert['ip']}: {alert['count']} requests in "
              f"{alert['window']}s window")

    correlated_alerts = list(correlate_events(parsed_entries))
    if correlated_alerts:
        print("--- Correlation ---")
        print("[*] CRITICAL INCIDENTS:")
        for alert in correlated_alerts:
            stages_str = " -> ".join(alert['stages'])
            print(f"    {alert['ip']}: {stages_str}")

    suspicious_entries = list(filter_logs(parsed_entries))
    print("--- Filtering ---")
    print(f"[*] Suspicious (404, 500): {len(suspicious_entries)}")

    all_alerts = bf_alerts + burst_alerts + correlated_alerts
    print("")
    if args.report:
        export_report(all_alerts, args.report)
        print(f"[*] Report exported: {args.report} ({len(all_alerts)} alerts)")
    else:
        print(f"[*] Total alerts: {len(all_alerts)}")
        print("[*] Use --report <file> to export.")


if __name__ == "__main__":
    main()
