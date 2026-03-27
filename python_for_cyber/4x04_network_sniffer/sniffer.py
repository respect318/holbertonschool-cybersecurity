#!/usr/bin/env python3
"""
PySniffer - Network traffic analysis tool.
Performance Refactor: Decoupled capturing and processing using Threads/Queue.
Clean Code Compliant.
"""
import argparse
import queue
import threading
import scapy.all as scapy


class PacketProcessor:
    """Base class for packet processing."""
    def __init__(self, search_term=None, name="Unknown"):
        """Initialize with an optional search term and protocol name."""
        self.search_term = search_term
        self.name = name

    def process(self, packet):
        """Process the packet and check for search term in payload."""
        if not self.search_term or not hasattr(scapy, 'Raw'):
            return
        if packet.haslayer(scapy.Raw):
            try:
                raw_data = packet[scapy.Raw].load
                payload = raw_data.decode('utf-8', errors='ignore')
                if self.search_term in payload:
                    print("[ALERT] Payload Match found!")
            except (UnicodeDecodeError, AttributeError):
                pass


class TCPProcessor(PacketProcessor):
    """Processor for TCP packets."""
    def __init__(self, search_term=None):
        super().__init__(search_term, "TCP")

    def process(self, packet):
        ip_layer = packet[scapy.IP] if hasattr(scapy, 'IP') else packet
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        tcp = packet[scapy.TCP] if hasattr(scapy, 'TCP') else packet
        sport = getattr(tcp, 'sport', '')
        dport = getattr(tcp, 'dport', '')
        flags = getattr(tcp, 'flags', '')
        msg = (f"[TCP] {src}:{sport} -> "
               f"{dst}:{dport} | Flags: {flags}")
        print(msg)
        super().process(packet)


class UDPProcessor(PacketProcessor):
    """Processor for UDP packets."""
    def __init__(self, search_term=None):
        super().__init__(search_term, "UDP")

    def process(self, packet):
        ip_layer = packet[scapy.IP] if hasattr(scapy, 'IP') else packet
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[UDP] {src} -> {dst}")
        super().process(packet)


class ICMPProcessor(PacketProcessor):
    """Processor for ICMP packets."""
    def __init__(self, search_term=None):
        super().__init__(search_term, "ICMP")

    def process(self, packet):
        ip_layer = packet[scapy.IP] if hasattr(scapy, 'IP') else packet
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[ICMP] {src} -> {dst}")
        super().process(packet)


class IPProcessor(PacketProcessor):
    """Fallback processor for other IP packets."""
    def __init__(self, search_term=None):
        super().__init__(search_term, "IP")

    def process(self, packet):
        ip_layer = packet[scapy.IP] if hasattr(scapy, 'IP') else packet
        src = getattr(ip_layer, 'src', '')
        dst = getattr(ip_layer, 'dst', '')
        print(f"[IP] {src} -> {dst}")
        super().process(packet)


class Sniffer:
    """A professional network sniffer class."""

    # pylint: disable=too-many-instance-attributes,too-many-arguments
    def __init__(self, interface, filter_str, output_file,
                 verbose=False, search_string=None):
        """Initialize the sniffer with required configurations."""
        self.interface = interface
        self.filter_str = filter_str
        self.output_file = output_file
        self.verbose = verbose
        self.search_string = search_string
        self.writer = None

        # Threading and Queue setup
        self.packet_queue = queue.Queue()
        self.running = False
        self.stats = {'TCP': 0, 'UDP': 0, 'ICMP': 0, 'IP': 0}

        if self.output_file and hasattr(scapy, 'PcapWriter'):
            self.writer = scapy.PcapWriter(
                self.output_file, append=True, sync=True
            )

        self.processors = {}
        if hasattr(scapy, 'TCP'):
            self.processors[scapy.TCP] = TCPProcessor(self.search_string)
        if hasattr(scapy, 'UDP'):
            self.processors[scapy.UDP] = UDPProcessor(self.search_string)
        if hasattr(scapy, 'ICMP'):
            self.processors[scapy.ICMP] = ICMPProcessor(self.search_string)

        self.default_processor = IPProcessor(self.search_string)

    def _enqueue_packet(self, packet):
        """Producer: Puts captured packets into the processing queue."""
        self.packet_queue.put(packet)

    def _process_packet(self, packet):
        """Consumer: Processes a single packet from the queue."""
        if self.writer:
            self.writer.write(packet)

        if hasattr(packet, "haslayer"):
            ip_ok = not hasattr(scapy, 'IP') or packet.haslayer(scapy.IP)
            if ip_ok:
                processed = False
                for proto, processor in self.processors.items():
                    if packet.haslayer(proto):
                        processor.process(packet)
                        self.stats[processor.name] += 1
                        processed = True
                        break

                if not processed:
                    self.default_processor.process(packet)
                    self.stats[self.default_processor.name] += 1

        if self.verbose and hasattr(scapy, 'hexdump'):
            try:
                scapy.hexdump(packet)
            except Exception:  # pylint: disable=broad-except
                pass

    def _worker_loop(self):
        """Background thread loop for processing queued packets."""
        while self.running or not self.packet_queue.empty():
            try:
                packet = self.packet_queue.get(timeout=0.1)
                self._process_packet(packet)
                self.packet_queue.task_done()
            except queue.Empty:
                continue

    def _print_stats(self):
        """Print the final statistics summary."""
        print("\n--- Capture Statistics ---")
        for proto, count in self.stats.items():
            print(f"{count} {proto}")

    def start(self):
        """Start capturing and processing packets across threads."""
        self.running = True
        processor_thread = threading.Thread(target=self._worker_loop)
        processor_thread.daemon = True
        processor_thread.start()

        try:
            scapy.sniff(
                iface=self.interface,
                filter=self.filter_str,
                prn=self._enqueue_packet,
                store=False
            )
        except KeyboardInterrupt:
            pass
        finally:
            self.running = False
            processor_thread.join()
            if self.writer:
                self.writer.close()
            self._print_stats()


def main():
    """Main entry point to parse arguments and run the sniffer."""
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--interface", help="Interface")
    parser.add_argument("-f", "--filter", help="BPF filter")
    parser.add_argument("-w", "--write", help="Output PCAP file")
    parser.add_argument("-v", "--verbose", action="store_true",
                        help="Enable verbose output")
    parser.add_argument("-s", "--search", help="String to search in payload")
    args = parser.parse_args()

    sniffer = Sniffer(
        interface=args.interface,
        filter_str=args.filter,
        output_file=args.write,
        verbose=args.verbose,
        search_string=args.search
    )
    sniffer.start()


if __name__ == "__main__":
    main()
