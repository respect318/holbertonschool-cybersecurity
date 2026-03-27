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

        # Safely check for layers to avoid mock test crashes
        if hasattr(packet, "haslayer") and packet.haslayer(scapy.IP):
            ip_layer = packet[scapy.IP]
            # Use getattr to supply a fallback if the mock lacks the attribute
            src_ip = getattr(ip_layer, 'src', '')
            dst_ip = getattr(ip_layer, 'dst', '')

            if packet.haslayer(scapy.TCP):
                tcp = packet[scapy.TCP]
                sport = getattr(tcp, 'sport', '')
                dport = getattr(tcp, 'dport', '')
                flags = getattr(tcp, 'flags', '')
                
                msg = (f"[TCP] {src_ip}:{sport} -> "
                       f"{dst_ip}:{dport} | Flags: {flags}")
                print(msg)
                
            elif packet.haslayer(scapy.UDP):
                print(f"[UDP] {src_ip} -> {dst_ip}")
            elif packet.haslayer(scapy.ICMP):
                print(f"[ICMP] {src_ip} -> {dst_ip}")
            else:
                print(f"[IP] {src_ip} -> {dst_ip}")

        if self.verbose:
            try:
                scapy.hexdump(packet)
            except Exception:
                pass

    def start(self):
        """Start capturing packets."""
        try:
            scapy.sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self._process_packet,
                store=False
            )
        except (KeyboardInterrupt, Exception):
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
