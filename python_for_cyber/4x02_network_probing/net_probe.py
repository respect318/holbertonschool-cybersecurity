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
        # Create a socket using IPv4 (AF_INET) and TCP (SOCK_STREAM)
        # A context manager ensures the socket closes automatically
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            # Set a timeout of 1 second as per requirements
            s.settimeout(1.0)

            # Attempt to connect to the IP and Port
            s.connect((ip, port))

            # If connect() succeeds without an exception, port is open
            return True

    except (socket.timeout, ConnectionRefusedError):
        # The port is closed or filtered
        return False
    except socket.gaierror:
        # Address-related error (e.g., hostname could not be resolved)
        print(f"[ERROR] Failed to resolve hostname: {ip}")
        return False
    except Exception as e:
        # Catch unexpected errors gracefully to prevent raw tracebacks
        print(f"[ERROR] Error checking port {port}: {e}")
        return False


if __name__ == "__main__":
    try:
        print(f"Port 80 is open: {check_port('google.com', 80)}")
        print(f"Port 81 is open: {check_port('google.com', 81)}")
    except KeyboardInterrupt:
        print("\n[ERROR] Execution interrupted by user.")
    except Exception as e:
        print(f"[ERROR] Main execution failed: {e}")
