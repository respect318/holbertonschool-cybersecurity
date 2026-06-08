#!/usr/bin/env python3
"""
enrich_ioc.py - IOC Enrichment Engine
Accepts an IP address or domain, classifies it using a local threat intel feed
and standard library network introspection, and returns a structured enrichment verdict.

Usage:
    python3 enrich_ioc.py 198.51.100.42
    python3 enrich_ioc.py --batch iocs.txt --output results.json
"""

import json
import socket
import ipaddress
import re
import argparse
from datetime import datetime, timezone


# Documentation IP ranges (not classified by ipaddress module as non-public)
DOCUMENTATION_RANGES = [
    ipaddress.ip_network("192.0.2.0/24"),
    ipaddress.ip_network("198.51.100.0/24"),
    ipaddress.ip_network("203.0.113.0/24"),
]

# Set default socket timeout globally
socket.setdefaulttimeout(3)


def detect_ioc_type(value: str) -> str:
    """
    Detect the type of an IOC value.
    Returns 'ipv4', 'ipv6', 'domain', or 'url'.
    For URLs, the hostname is extracted for further classification.
    """
    # Check for URL (has scheme)
    url_pattern = re.compile(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://')
    if url_pattern.match(value):
        return "url"

    # Try IPv4
    try:
        addr = ipaddress.ip_address(value)
        if addr.version == 4:
            return "ipv4"
        elif addr.version == 6:
            return "ipv6"
    except ValueError:
        pass

    # Otherwise treat as domain
    return "domain"


def extract_hostname(value: str) -> str:
    """
    Extract hostname from a URL, or return the value unchanged for IPs/domains.
    """
    url_pattern = re.compile(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://([^/:?#]+)')
    match = url_pattern.match(value)
    if match:
        return match.group(1)
    return value


def classify_ip(ip: str) -> str:
    """
    Classify an IP address.
    Returns 'private', 'loopback', 'link_local', 'documentation',
    'multicast', or 'public'.
    """
    try:
        addr = ipaddress.ip_address(ip)
    except ValueError:
        return "unknown"

    # Check documentation ranges explicitly (ipaddress does not distinguish these)
    for net in DOCUMENTATION_RANGES:
        if addr in net:
            return "documentation"

    if addr.is_loopback:
        return "loopback"
    if addr.is_private:
        return "private"
    if addr.is_link_local:
        return "link_local"
    if addr.is_multicast:
        return "multicast"

    return "public"


def reverse_dns(ip: str) -> str:
    """
    Perform reverse DNS lookup for an IP address.
    Returns the hostname on success, 'NXDOMAIN' on failure, 'TIMEOUT' on timeout.
    """
    try:
        result = socket.gethostbyaddr(ip)
        return result[0]
    except socket.herror:
        return "NXDOMAIN"
    except socket.timeout:
        return "TIMEOUT"
    except Exception:
        return "NXDOMAIN"


def check_feed(value: str, feed: dict) -> dict:
    """
    Look up a value in the threat intel feed.
    Checks malicious_ips, malicious_domains, benign_ips, and benign_domains.
    Returns a dict with keys: in_malicious_feed, in_benign_list,
    and feed entry data if found.
    """
    result = {
        "in_malicious_feed": False,
        "in_benign_list": False,
    }

    # Check malicious IPs
    malicious_ips = feed.get("malicious_ips", {})
    if value in malicious_ips:
        entry = malicious_ips[value]
        result["in_malicious_feed"] = True
        result.update(entry)
        return result

    # Check malicious domains
    malicious_domains = feed.get("malicious_domains", {})
    if value in malicious_domains:
        entry = malicious_domains[value]
        result["in_malicious_feed"] = True
        result.update(entry)
        return result

    # Check benign IPs
    benign_ips = feed.get("benign_ips", [])
    if value in benign_ips:
        result["in_benign_list"] = True
        return result

    # Check benign domains
    benign_domains = feed.get("benign_domains", [])
    if value in benign_domains:
        result["in_benign_list"] = True
        return result

    return result


def score_ioc(feed_result: dict, ip_class: str) -> tuple:
    """
    Score an IOC and return a verdict.
    Returns (score, verdict) where verdict is 'BLOCK', 'INVESTIGATE', or 'ALLOW'.

    Scoring logic:
      - Private or loopback IP: score 0, verdict 'ALLOW'
      - In benign list: score 0, verdict 'ALLOW'
      - In malicious feed with confidence >= 80: score = confidence, verdict 'BLOCK'
      - In malicious feed with confidence < 80: score = confidence, verdict 'INVESTIGATE'
      - Not in any feed, public IP or unknown domain: score 30, verdict 'INVESTIGATE'
    """
    # Private or loopback address
    if ip_class in ("private", "loopback"):
        return (0, "ALLOW")

    # In benign list
    if feed_result.get("in_benign_list"):
        return (0, "ALLOW")

    # In malicious feed
    if feed_result.get("in_malicious_feed"):
        confidence = feed_result.get("confidence", 0)
        if confidence >= 80:
            return (confidence, "BLOCK")
        else:
            return (confidence, "INVESTIGATE")

    # Not in any feed
    return (30, "INVESTIGATE")


def enrich_ioc(value: str, feed_path: str = "ioc_feed.json") -> dict:
    """
    Main enrichment function. Loads the feed, calls all helpers,
    and returns the complete enrichment result as a dict.
    """
    # Load the feed
    with open(feed_path, "r") as f:
        feed = json.load(f)

    # Detect type
    ioc_type = detect_ioc_type(value)

    # For URLs, extract the hostname for lookup
    lookup_value = extract_hostname(value) if ioc_type == "url" else value

    # Classify IP (if applicable)
    ip_class = None
    rdns = None
    if ioc_type in ("ipv4", "ipv6"):
        ip_class = classify_ip(lookup_value)
        rdns = reverse_dns(lookup_value)

    # Check feed
    feed_result = check_feed(lookup_value, feed)

    # Score
    score, verdict = score_ioc(feed_result, ip_class or "")

    # Build result
    result = {
        "ioc": value,
        "type": ioc_type,
    }

    if ip_class is not None:
        result["ip_class"] = ip_class
        result["reverse_dns"] = rdns

    result["feed_result"] = feed_result
    result["score"] = score
    result["verdict"] = verdict

    # Add note for private/loopback
    if ip_class in ("private", "loopback"):
        notes = {
            "private": "Private address range; internal network traffic",
            "loopback": "Loopback address; local host traffic",
        }
        result["note"] = notes[ip_class]

    result["enriched_at"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    return result


def main():
    parser = argparse.ArgumentParser(
        description="IOC Enrichment Engine - classify and score an IP or domain"
    )
    parser.add_argument(
        "ioc",
        nargs="?",
        help="Single IOC to enrich (IP address or domain)"
    )
    parser.add_argument(
        "--batch",
        metavar="FILE",
        help="Path to a file with one IOC per line for batch processing"
    )
    parser.add_argument(
        "--output",
        metavar="FILE",
        help="Output file for batch results (JSON array)"
    )
    parser.add_argument(
        "--feed",
        default="ioc_feed.json",
        metavar="FEED",
        help="Path to the IOC feed JSON file (default: ioc_feed.json)"
    )

    args = parser.parse_args()

    if args.batch:
        # Batch mode
        with open(args.batch, "r") as f:
            iocs = [line.strip() for line in f if line.strip()]

        results = []
        counts = {"BLOCK": 0, "INVESTIGATE": 0, "ALLOW": 0}

        for ioc in iocs:
            result = enrich_ioc(ioc, feed_path=args.feed)
            results.append(result)
            verdict = result.get("verdict", "INVESTIGATE")
            if verdict in counts:
                counts[verdict] += 1

        if args.output:
            with open(args.output, "w") as f:
                json.dump(results, f, indent=2)

        print(
            f"Processed: {len(iocs)} | "
            f"BLOCK: {counts['BLOCK']} | "
            f"INVESTIGATE: {counts['INVESTIGATE']} | "
            f"ALLOW: {counts['ALLOW']}"
        )

    elif args.ioc:
        # Single IOC mode
        result = enrich_ioc(args.ioc, feed_path=args.feed)
        print(json.dumps(result, indent=2))

    else:
        parser.print_help()


if __name__ == "__main__":
    main()
