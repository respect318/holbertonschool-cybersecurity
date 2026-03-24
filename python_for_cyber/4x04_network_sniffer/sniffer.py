#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Captures packets with BPF filters and interface selection.
"""

import argparse
from scapy.all import sniff, IP, TCP, UDP, ICMP


def packet_handler(packet) -> None:
    """Identify and format the protocol, IP addresses and ports."""
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
    """Entry point for the network sniffer."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface")
    parser.add_argument("-f", "--filter")
    args = parser.parse_args()

    try:
        # iface və filter parametrləri tam olaraq bu ardıcıllıqla olmalıdır
        sniff(iface=args.interface, filter=args.filter, prn=packet_handler)
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
