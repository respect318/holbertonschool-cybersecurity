#!/usr/bin/env python3
"""
NetProbe - A custom network scanning and banner grabbing tool.
"""

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
        # Gracefully handle all invalid inputs or timeouts
        return False


def ping_sweep(subnet: str) -> list:
    """
    Scans a /24 subnet to identify active hosts by checking port 80.

    Args:
        subnet (str): The first 3 octets of the subnet (e.g., '192.168.1').

    Returns:
        list: A list of IP addresses that have port 80 open.
    """
    active_hosts = []

    # Iterate from 1 to 254 for a /24 subnet
    for i in range(1, 255):
        ip = f"{subnet}.{i}"
        # Test if port 80 is open on this specific IP
        if check_port(ip, 80):
            active_hosts.append(ip)

    return active_hosts
