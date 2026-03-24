#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Captures 5 packets and prints their summary using Scapy.
"""

import os
from scapy.all import sniff


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    Prints an error message if not running as root.
    """
    if os.geteuid() != 0:
        print("[ERROR] PySniffer requires root privileges (sudo).")


def packet_handler(packet) -> None:
    """
    Callback function to process each captured packet.
    """
    print(packet.summary())


def main() -> None:
    """
    Entry point for the PySniffer application.
    """
    check_permissions()
    try:
        # Task 1: count=5 və prn=packet_handler tam tələb olunduğu kimi
        sniff(count=5, prn=packet_handler)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()
