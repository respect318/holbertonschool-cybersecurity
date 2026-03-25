#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
Runs continuously until interrupted by the user.
"""

from scapy.all import sniff, IP, TCP, UDP, ICMP


def packet_handler(packet) -> None:
    """Identify and format the protocol, IP addresses, ports, and flags."""
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
    """Entry point for the PySniffer application."""
    try:
        # count=5 silindi, proqram sonsuz işləyəcək
        sniff(prn=packet_handler)
    except KeyboardInterrupt:
        # Təlimatda istənilən tam dəqiq mesaj çap olunur
        print("[INFO] Stopping capture...")


if __name__ == "__main__":
    main()
