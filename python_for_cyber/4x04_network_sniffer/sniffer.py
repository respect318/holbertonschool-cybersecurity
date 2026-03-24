#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Captures 5 packets and prints their summary using Scapy.
"""

import sys
import os
from scapy.all import sniff, Packet


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    """
    if os.getuid() != 0:
        # Mesajın sonunda boşluq olmadığına əmin ol
        print("[ERROR] PySniffer requires root privileges (sudo).")
        sys.exit(1)


def packet_handler(packet: Packet) -> None:
    """
    Callback function to process each captured packet.
    """
    print(packet.summary())


def main() -> None:
    """
    Entry point for the PySniffer application.
    """
    try:
        check_permissions()
        # count=5 və prn=packet_handler tam tələb olunduğu kimi
        sniff(count=5, prn=packet_handler)
    except Exception:
        sys.exit(1)


if __name__ == "__main__":
    main()
