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
        # Create a socket object (AF_INET for IPv4, SOCK_STREAM for TCP)
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            # Set a timeout of 1 second as requested
            sock.settimeout(1.0)
            # Try to connect to the IP/Port
            sock.connect((ip, port))
            return True
    except Exception:
        # Gracefully handle ALL invalid inputs, negative ports, or timeouts
        return False


if __name__ == "__main__":
    # Test cases from the project instructions
    print(f"Port 80 is open: {check_port('google.com', 80)}")
    print(f"Port 81 is open: {check_port('google.com', 81)}")
