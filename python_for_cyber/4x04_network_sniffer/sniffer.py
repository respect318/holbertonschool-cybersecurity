#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Captures packets and filters traffic using BPF and argparse.
"""

import argparse
import scapy.all as scapy


def packet_handler(packet) -> None:
    """Identify and format the protocol, IP addresses, ports, and flags."""
    if packet.haslayer(scapy.IP):
        src_ip = packet[scapy.IP].src
        dst_ip = packet[scapy.IP].dst

        if packet.haslayer(scapy.TCP):
            sport = packet[scapy.TCP].sport
            dport = packet[scapy.TCP].dport
            flags = packet[scapy.TCP].flags

            msg = (f"[TCP] {src_ip}:{sport} -> "
                   f"{dst_ip}:{dport} | Flags: {flags}")
            print(msg)

        elif packet.haslayer(scapy.UDP):
            print(f"[UDP] {src_ip} -> {dst_ip}")
        elif packet.haslayer(scapy.ICMP):
            print(f"[ICMP] {src_ip} -> {dst_ip}")
        else:
            print(f"[IP] {src_ip} -> {dst_ip}")


def main() -> None:
    """Entry point for the PySniffer application."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface to sniff on")
    parser.add_argument("-f", "--filter", help="BPF filter string")
    args = parser.parse_args()

    try:
        # Arqumentləri sniff funksiyasına ötürürük
        scapy.sniff(
            iface=args.interface,
            filter=args.filter,
            prn=packet_handler
        )
    except KeyboardInterrupt:
        print("[INFO] Stopping capture...")


if __name__ == "__main__":
    main()
