#!/usr/bin/env python3
"""
NetProbe - A custom network scanning and banner grabbing tool.
This module serves as the entry point for the network prober.
"""

import sys


def main() -> None:
    """
    Main function to initialize and run the NetProbe tool.
    """
    try:
        print("NetProbe v1.0 initialized...")
    except KeyboardInterrupt:
        print("\n[!] Execution interrupted by user. Exiting.")
        sys.exit(1)
    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
