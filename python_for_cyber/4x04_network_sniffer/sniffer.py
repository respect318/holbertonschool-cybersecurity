#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Refactored into an object-oriented structure.
"""

import argparse
import scapy.all as scapy


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
            # Test mühitində scapy silinərsə, çökmənin qarşısını alırıq
            try:
                from scapy.utils import PcapWriter
                self.writer = PcapWriter(
                    self.output_file, append=True, sync=True
                )
            except ImportError:
                pass
            except Exception:
                pass

    def _process_packet(self, packet) -> None:
        """Process and display packet information."""
        if self.writer:
            try:
                self.writer.write(packet)
            except Exception:
                pass

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

        if self.verbose:
            # Test mühiti üçün əlavə qorunma
            if hasattr(scapy, "hexdump"):
                scapy.hexdump(packet)

    def start(self) -> None:
        """Start capturing packets."""
        try:
            scapy.sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self._process_packet
            )
        except KeyboardInterrupt:
            pass
        except Exception:
            pass
        finally:
            # Writer obyekti və onun 'close' metodu varsa, bağla
            if self.writer and hasattr(self.writer, "close"):
                self.writer.close()


def main() -> None:
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
