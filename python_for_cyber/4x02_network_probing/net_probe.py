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

    with concurrent.futures.ThreadPoolExecutor(max_workers=100) as executor:
        results = executor.map(scan_ip, ips)

    for res in results:
        if res:
            active_hosts.append(res)

    return active_hosts


def get_banner(ip: str, port: int) -> str:
    """
    Connects to a port and retrieves its service banner.

    Args:
        ip (str): Target IP address.
        port (int): Target port number.

    Returns:
        str: The decoded banner string or "Unknown" if it fails.
    """
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            sock.settimeout(2.0)
            sock.connect((ip, port))

            try:
                # Try receiving banner immediately
                banner = sock.recv(1024).decode('utf-8', 'ignore').strip()
                if banner:
                    return banner
            except socket.timeout:
                pass

            # Send HTTP probe if no immediate banner
            sock.sendall(b"HEAD / HTTP/1.0\r\n\r\n")
            banner = sock.recv(1024).decode('utf-8', 'ignore').strip()

            if banner:
                # Extract the first line safely
                return banner.split('\n')[0].strip()

            return "Unknown"
    except Exception:
        return "Unknown"
