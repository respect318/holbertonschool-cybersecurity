"""
Utility module for NetProbe.
Contains helper functions for delay, randomization, and DNS.
"""

import random
import socket
import time


def resolve_hostname(ip: str) -> str:
    """
    Resolves the hostname for a given IP address.

    Args:
        ip (str): Target IP address.

    Returns:
        str: The hostname if resolved, otherwise an empty string.
    """
    try:
        host, _, _ = socket.gethostbyaddr(ip)
        return host
    except Exception:
        return ""


def randomize_port_list(ports: list) -> list:
    """
    Randomizes the order of a port list.

    Args:
        ports (list): List of ports.

    Returns:
        list: Shuffled list of ports.
    """
    random.shuffle(ports)
    return ports


def sleep_delay(delay: float):
    """
    Pauses execution for a specified delay.

    Args:
        delay (float): Delay in seconds.
    """
    if delay > 0:
        print(f"[DEBUG] Sleeping {delay}s before next packet...")
        time.sleep(delay)
