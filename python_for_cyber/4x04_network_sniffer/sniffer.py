#!/usr/bin/env python3
"""
PySniffer - A lightweight network traffic analysis tool.
This module initializes the sniffer and verifies environment requirements.
"""

import sys
import os


def check_permissions() -> None:
    """
    Check if the script is running with root privileges.
    Sniffing raw packets requires administrative access.
    """
    if os.geteuid() != 0:
        print("[ERROR] PySniffer requires root privileges (sudo).")
        sys.exit(1)


def main() -> None:
    """
    Entry point for the PySniffer application.
    Initializes the tool and confirms readiness.
    """
    try:
        # Permission check is crucial for Scapy's sniff() functionality later
        check_permissions()
        print("[INFO] PySniffer initialized.")
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
