#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Captures packets and identifies protocols manually.
"""

import os
from scapy.all import sniff, IP, TCP, UDP, ICMP


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    Prints an error message if not running as root.
    """
    if os.geteuid() != 0:
        print("[ERROR] PySniffer requires root privileges (sudo).")


def packet_handler(packet) -> None:
    """
    Identify and format the protocol and IP addresses of a packet.
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
    """
    check_permissions()
    try:
        # sniffer will wait for 5 packets and pass them to our new handler
        sniff(count=5, prn=packet_handler)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")


if __name__ == "__main__":
    main()
