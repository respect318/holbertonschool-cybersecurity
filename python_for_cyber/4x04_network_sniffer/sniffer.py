#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Captures packets and saves them to a PCAP file using PcapWriter.
"""

import argparse
from scapy.all import sniff, IP, TCP, UDP, ICMP
from scapy.utils import PcapWriter

# Qlobal writer obyekti
WRITER = None


def packet_handler(packet) -> None:
    """Identify protocol and save every captured packet to PCAP."""
    # 1. Hər bir paketi (IP, ARP və s.) fayla yazırıq
    if WRITER:
        WRITER.write(packet)

    # 2. Ekrana yalnız IP paketlərini çap edirik
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
    """Main entry point."""
    global WRITER
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface")
    parser.add_argument("-f", "--filter", help="BPF filter")
    parser.add_argument("-w", "--write", help="Output file")
    args = parser.parse_args()

    # Fayl yazmaq istənilibsə, Writer-i açırıq
    if args.write:
        WRITER = PcapWriter(args.write, append=True)

    try:
        # sniff çağırışı tam olaraq bu ardıcıllıqla
        sniff(iface=args.interface, filter=args.filter, prn=packet_handler)
    except KeyboardInterrupt:
        pass
    finally:
        if WRITER:
            WRITER.close()


if __name__ == "__main__":
    main()
