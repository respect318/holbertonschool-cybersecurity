#!/usr/bin/env python3
"""
Intelligence Broker API Client.
This module handles querying external Threat Intelligence APIs.
"""
import subprocess

import requests


def query_virustotal(ip: str) -> dict:
    """
    Queries the mock VirusTotal API for reputation data.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API.
    """
    url = f"http://localhost:5000/virustotal/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
    except requests.exceptions.ConnectionError:
        pass
    return {}


def query_abuseipdb(ip: str) -> dict:
    """
    Queries the mock AbuseIPDB API for abuse confidence data.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API.
    """
    url = f"http://localhost:5000/abuseipdb/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
    except requests.exceptions.ConnectionError:
        pass
    return {}


def run_nmap(ip: str) -> str:
    """
    Executes a local Nmap scan on the target IP for ports 22 and 80.

    Args:
        ip (str): The target IP address.

    Returns:
        str: The raw XML output of the Nmap scan.
    """
    cmd = ["nmap", "-p", "22,80", ip, "-oX", "-"]
    result = subprocess.run(cmd, capture_output=True)

    if result.returncode != 0:
        raise RuntimeError("Nmap scan failed")

    out = result.stdout
    if isinstance(out, bytes):
        return out.decode("utf-8", errors="ignore")
    return str(out)


if __name__ == "__main__":
    print(query_virustotal("1.2.3.4"))
