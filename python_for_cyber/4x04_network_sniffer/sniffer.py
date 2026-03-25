#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Captures packets, filters them, and writes to a PCAP file.
"""

import argparse
import scapy.all as scapy
from scapy.utils import PcapWriter

# Qlobal yazıcı (writer) obyekti
WRITER = None


def packet_handler(packet) -> None:
    """Identify protocol and save all captured packets to PCAP."""
    # Hər bir paketi (IP olub-olmamasından asılı olmayaraq) fayla yazırıq
    if WRITER:
        WRITER.write(packet)

    # Ekrana isə əvvəlki kimi yalnız IP paketlərini və detallarını çıxarırıq
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
    """Main entry point to parse arguments and run the sniffer."""
    global WRITER
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface")
    parser.add_argument("-f", "--filter", help="BPF filter")
    parser.add_argument("-w", "--write", help="Output PCAP file")
    args = parser.parse_args()

    # Əgər -w arqumenti verilibsə, faylı qlobal olaraq açırıq
    if args.write:
        # sync=True parametri faylın testlər zamanı dərhal diskə yazılmasını təmin edir
        WRITER = PcapWriter(args.write, append=True, sync=True)

    try:
        scapy.sniff(
            iface=args.interface,
            filter=args.filter,
            prn=packet_handler
        )
    except KeyboardInterrupt:
        pass
    finally:
        # Proqram bitəndə (və ya test kəsiləndə) faylı təmiz bağlayırıq
        if WRITER:
            WRITER.close()


if __name__ == "__main__":
    main()
