#!/usr/bin/env python3
"""
PySniffer - A tool to capture and save network traffic to PCAP.
"""

import argparse
from scapy.all import sniff, IP, TCP, UDP, ICMP
from scapy.utils import PcapWriter

# Qlobal dəyişən kimi PcapWriter-i təyin edirik
WRITER = None


def packet_handler(packet) -> None:
    """Identify protocol and save packet to file if requested."""
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

        # Əgər -w arqumenti verilibsə, paketi fayla yazırıq
        if WRITER:
            WRITER.write(packet)


def main() -> None:
    """Handle CLI arguments and start packet capture."""
    global WRITER
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface to sniff on")
    parser.add_argument("-f", "--filter", help="BPF filter string")
    parser.add_argument("-w", "--write", help="Output PCAP file name")
    args = parser.parse_args()

    # Əgər fayl adı verilibsə, Writer-i bir dəfə açırıq
    if args.write:
        WRITER = PcapWriter(args.write, append=True, sync=True)

    try:
        sniff(iface=args.interface, filter=args.filter, prn=packet_handler)
    except KeyboardInterrupt:
        if WRITER:
            WRITER.close()
        print("\n[INFO] Capture stopped and file saved.")


if __name__ == "__main__":
    main()
