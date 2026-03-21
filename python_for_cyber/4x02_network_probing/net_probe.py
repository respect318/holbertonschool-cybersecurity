#!/usr/bin/env python3
"""
NetProbe - A custom network scanning and banner grabbing tool.
This module serves as the entry point for the network prober.
"""

import socket
import sys


def check_port(ip: str, port: int) -> bool:
    """
    Checks if a specific TCP port is open on a target IP or hostname.

    Args:
        ip (str): The target IP address or hostname.
        port (int): The target TCP port number to check.

    Returns:
        bool: True if the connection succeeds (port is open), False otherwise.
    """
    try:
        # Create a socket object (IPv4, TCP)
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
            # Set a 1-second timeout to prevent hanging on dropped packets
            sock.settimeout(1.0)
            # Try to connect to the target IP and port
            sock.connect((ip, port))
            return True
    except Exception:
        # Catch ANY exception (OSError, ValueError, OverflowError, etc.)
        # This handles invalid IPs, negative ports, or unreachable hosts gracefully
        return False


def main() -> None:
    """
    Main function to initialize and run the NetProbe tool.
    """
    try:
        print("NetProbe v1.0 initialized...")
        print(f"Port 80 is open: {check_port('google.com', 80)}")
        print(f"Port 81 is open: {check_port('google.com', 81)}")
    except KeyboardInterrupt:
        print("\n[!] Execution interrupted by user. Exiting.")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
