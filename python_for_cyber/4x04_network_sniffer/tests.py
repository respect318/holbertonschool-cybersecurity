#!/usr/bin/env python3
"""
Unit tests for the PySniffer project.
Validates packet parsing logic without requiring a live network.
"""
import unittest
import io
import sys
import scapy.all as scapy
from sniffer import TCPProcessor


class TestTCPProcessor(unittest.TestCase):
    """Test cases for the TCPProcessor class."""

    def test_tcp_processing(self):
        """Test that TCPProcessor extracts correct IP and Port."""
        # Arrange: Create a fake Scapy packet
        pkt = scapy.IP(src="1.1.1.1", dst="8.8.8.8")
        pkt /= scapy.TCP(sport=54321, dport=80, flags="S")

        # Initialize the processor
        processor = TCPProcessor()

        # Capture standard output (console)
        captured_output = io.StringIO()
        sys.stdout = captured_output

        try:
            # Act: Pass the fake packet to the processor
            processor.process(pkt)
        finally:
            # Always restore standard output, even if the test fails!
            sys.stdout = sys.__stdout__

        # Assert: Verify the extracted data is in the printed output
        output = captured_output.getvalue().strip()

        # Check for specific IP:Port combinations and flags
        self.assertIn("1.1.1.1:54321", output)
        self.assertIn("8.8.8.8:80", output)
        self.assertIn("Flags: S", output)
        self.assertTrue(output.startswith("[TCP]"))


if __name__ == "__main__":
    unittest.main()
