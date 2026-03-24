#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
This module captures packets and identifies protocols manually.
"""

import sys
import os
from scapy.all import sniff, Packet, IP, TCP, UDP, ICMP


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
    Identify and format the protocol and IP addresses of a packet.

    Args:
        packet (Packet): The Scapy packet object captured from the wire.
    """
    if packet.haslayer(IP):
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        proto = "IP"

        if packet.haslayer(TCP):
            proto = "TCP"
        elif packet.haslayer(UDP):
            proto = "UDP"
        elif packet.haslayer(ICMP):
            proto = "ICMP"

        print(f"[{proto}] {src_ip} -> {dst_ip}")


def main() -> None:
    """
    Entry point for the PySniffer application.
    Captures 5 packets and identifies their protocols.
    """
    try:
        check_permissions()
        print("[INFO] PySniffer initialized. Capturing 5 packets...")

        # Capture 5 packets using the manual dispatcher
        sniff(count=5, prn=packet_handler)

    except PermissionError:
        print("[ERROR] Permission denied. Please run with sudo.")
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
