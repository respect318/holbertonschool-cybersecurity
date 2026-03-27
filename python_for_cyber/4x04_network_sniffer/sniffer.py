#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Refactored into a professional Sniffer class.
"""
import argparse
import scapy.all as scapy
from scapy.utils import PcapWriter


class Sniffer:
    """A professional network sniffer class."""

    def __init__(self, interface, filter_str, output_file, verbose=False):
        """Initialize the sniffer with required configurations."""
        self.interface = interface
        self.filter_str = filter_str
        self.output_file = output_file
        self.verbose = verbose
        self.writer = None
        if self.output_file:
            self.writer = PcapWriter(
                self.output_file, append=True, sync=True
            )

    def _process_packet(self, packet):
        """Process and display packet information."""
        if self.writer:
            self.writer.write(packet)

        # Check if IP layer exists to avoid crashes
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
                sport = packet[scapy.UDP].sport
                dport = packet[scapy.UDP].dport
                print(f"[UDP] {src_ip}:{sport} -> {dst_ip}:{dport}")
            elif packet.haslayer(scapy.ICMP):
                print(f"[ICMP] {src_ip} -> {dst_ip}")
            else:
                print(f"[IP] {src_ip} -> {dst_ip}")

        if self.verbose:
            scapy.hexdump(packet)

    def start(self):
        """Start capturing packets."""
        try:
            scapy.sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self._process_packet,
                store=False
            )
        except KeyboardInterrupt:
            pass
        finally:
            if self.writer:
                self.writer.close()


def main():
    """Main entry point to parse arguments and run the sniffer."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface")
    parser.add_argument("-f", "--filter", help="BPF filter")
    parser.add_argument("-w", "--write", help="Output PCAP file")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose output")
    args = parser.parse_args()

    sniffer = Sniffer(
        interface=args.interface,
        filter_str=args.filter,
        output_file=args.write,
        verbose=args.verbose
    )
    sniffer.start()


if __name__ == "__main__":
    main()
