#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
This module captures 5 packets and prints their default Scapy summary.
"""

import sys
import os
from scapy.all import sniff, Packet


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    Sniffing raw packets requires administrative access.
    """
    if os.getuid() != 0:
        print("[ERROR] PySniffer requires root privileges (sudo).")
        sys.exit(1)


def packet_handler(packet: Packet) -> None:
    """
    Callback function to process each captured packet.

    Args:
        packet (Packet): The Scapy packet object captured from the wire.
    """
    print(packet.summary())


def main() -> None:
    """
    Entry point for the PySniffer application.
    Initializes the sniffer to capture exactly 5 packets.
    """
    try:
        check_permissions()
        # Ensure count=5 and prn=packet_handler are exactly as requested
        sniff(count=5, prn=packet_handler)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
