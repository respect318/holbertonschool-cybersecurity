#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Refactored to use Polymorphism for packet processing.
"""
import argparse
import scapy.all as scapy
from scapy.utils import PcapWriter


class PacketProcessor:
    """Base class for packet processing."""
    def process(self, packet):
        """Process the packet."""
        pass


class TCPProcessor(PacketProcessor):
    """Processor for TCP packets."""
    def process(self, packet):
        ip_layer = packet[scapy.IP]
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        tcp = packet[scapy.TCP]
        sport = getattr(tcp, 'sport', '')
        dport = getattr(tcp, 'dport', '')
        flags = getattr(tcp, 'flags', '')
        msg = (f"[TCP] {src}:{sport} -> "
               f"{dst}:{dport} | Flags: {flags}")
        print(msg)


class UDPProcessor(PacketProcessor):
    """Processor for UDP packets."""
    def process(self, packet):
        ip_layer = packet[scapy.IP]
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[UDP] {src} -> {dst}")


class ICMPProcessor(PacketProcessor):
    """Processor for ICMP packets."""
    def process(self, packet):
        ip_layer = packet[scapy.IP]
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[ICMP] {src} -> {dst}")


class IPProcessor(PacketProcessor):
    """Fallback processor for other IP packets."""
    def process(self, packet):
        ip_layer = packet[scapy.IP]
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[IP] {src} -> {dst}")


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
        # Dictionary mapping Scapy layers to their respective processors
        self.processors = {
            scapy.TCP: TCPProcessor(),
            scapy.UDP: UDPProcessor(),
            scapy.ICMP: ICMPProcessor()
        }
        self.default_processor = IPProcessor()

    def _process_packet(self, packet):
        """Process and display packet information dynamically."""
        if self.writer:
            self.writer.write(packet)

        # Safely check for IP layer to avoid mock test crashes
        if hasattr(packet, "haslayer") and packet.haslayer(scapy.IP):
            processed = False
            # Iterate through our strategies
            for proto, processor in self.processors.items():
                if packet.haslayer(proto):
                    processor.process(packet)
                    processed = True
                    break
            
            # Fallback if it's an IP packet but not TCP/UDP/ICMP
            if not processed:
                self.default_processor.process(packet)

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
