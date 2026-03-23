#!/usr/bin/env python3
"""
NetProbe - A custom network scanning and banner grabbing tool.
"""

import concurrent.futures
import socket


def check_port(ip: str, port: int) -> bool:
    """
    Checks if a specific TCP port is open on a target IP.

    Args:
        ip (str): Target IP address or hostname.
        port (int): Target TCP port number.

    Returns:
        bool: True if connection succeeds, False otherwise.
    """
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(1.0)
            sock.connect((ip, port))
            return True
    except Exception:
        return False


def ping_sweep(subnet: str) -> list:
    """
    Scans a /24 subnet concurrently to identify active hosts.

    Args:
        subnet (str): The first 3 octets of the subnet (e.g., '192.168.1').

    Returns:
        list: A list of IP addresses that have port 80 open.
    """
    active_hosts = []
    ips = [f"{subnet}.{i}" for i in range(1, 255)]

    def scan_ip(ip: str) -> str:
        """Helper function to return IP if port 80 is open."""
        if check_port(ip, 80):
            return ip
        return ""

    # Use ThreadPoolExecutor to scan multiple IPs at the same time
    with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
        # executor.map runs the scan_ip function for all IPs in parallel
        results = executor.map(scan_ip, ips)

    # Filter out empty strings and keep only active IPs
    for res in results:
        if res:
            active_hosts.append(res)

    return active_hosts
