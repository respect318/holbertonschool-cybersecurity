#!/usr/bin/env python3
"""
Network Probing Module

This module provides functionalities to probe network targets using standard
TCP sockets. It allows checking if specific ports are open and handles
socket connections gracefully.
"""

import socket


def check_port(ip: str, port: int) -> bool:
    """
    Checks if a specific TCP port is open on a target IP or hostname.

    This function attempts to establish a TCP Three-Way Handshake with the
    target. If the connect() call succeeds within the timeout period, the
    port is considered open.

    Args:
        ip (str): The target IP address or hostname.
        port (int): The target port number to check.

    Returns:
        bool: True if the port is open, False if connection is refused,
              timed out, or if an error occurs.
    """
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            s.settimeout(1.0)
            s.connect((ip, port))
            return True
    except Exception:
        # Silently return False for ALL errors (invalid port, timeout)
        # NO print statements here to avoid length mismatches.
        return False
