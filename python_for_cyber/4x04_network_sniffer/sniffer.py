#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Captures packets continuously and extracts Layer 4 details for TCP.
"""

import os
import sys
from scapy.all import sniff, IP, TCP, UDP, ICMP


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    """
    if os.geteuid() != 0:
        print("[ERROR] PySniffer requires root privileges (sudo).")


def packet_handler(packet) -> None:
    """
    Identify and format the protocol, IP addresses, ports, and TCP flags.
    """
    if packet.haslayer(IP):
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst

        if packet.haslayer(TCP):
            sport = packet[TCP].sport
            dport = packet[TCP].dport
            flags = packet[TCP].flags

            msg = (f"[TCP] {src_ip}:{sport} -> "
                   f"{dst_ip}:{dport} | Flags: {flags}")
            print(msg)

        elif packet.haslayer(UDP):
            print(f"[UDP] {src_ip} -> {dst_ip}")
        elif packet.haslayer(ICMP):
            print(f"[ICMP] {src_ip} -> {dst_ip}")
        else:
            print(f"[IP] {src_ip} -> {dst_ip}")


def main() -> None:
    """
    Entry point for the PySniffer application.
    """
    check_permissions()
    try:
        # Sniff continuously without the count argument
        sniff(prn=packet_handler)
    except KeyboardInterrupt:
        # Handle Ctrl+C and exit cleanly
        print("[INFO] Stopping capture...")
        sys.exit(0)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
