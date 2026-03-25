#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Captures packets, filters them, writes to PCAP, and supports hexdump.
"""

import argparse
import scapy.all as scapy

WRITER = None
VERBOSE = False


def packet_handler(packet) -> None:
    """Identify protocol and save/print packets based on verbosity."""
    if WRITER:
        WRITER.write(packet)

    if hasattr(packet, "haslayer") and packet.haslayer(scapy.IP):
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

    # VERBOSE yoxlaması IP blokundan kənara çıxarıldı!
    if VERBOSE:
        scapy.hexdump(packet)


def main() -> None:
    """Main entry point to parse arguments and run the sniffer."""
    global WRITER, VERBOSE
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface")
    parser.add_argument("-f", "--filter", help="BPF filter")
    parser.add_argument("-w", "--write", help="Output PCAP file")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose output")
    args = parser.parse_args()

    if args.write:
        from scapy.utils import PcapWriter
        WRITER = PcapWriter(args.write, append=True, sync=True)

    if args.verbose:
        VERBOSE = True

    try:
        scapy.sniff(
            iface=args.interface,
            filter=args.filter,
            prn=packet_handler
        )
    except KeyboardInterrupt:
        pass
    finally:
        if WRITER:
            WRITER.close()


if __name__ == "__main__":
    main()
