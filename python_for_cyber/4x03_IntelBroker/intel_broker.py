#!/usr/bin/env python3
"""
Intelligence Broker API Client.
This module handles querying external Threat Intelligence APIs
and orchestrating local security tools like Nmap.
"""
import subprocess

import requests


def query_virustotal(ip: str) -> dict:
    """
    Queries the mock VirusTotal API for reputation data.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API as a dictionary.
    """
    url = f"http://localhost:5000/virustotal/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
        print(f"[ERROR] API returned status: {response.status_code}")
        return {}
    except requests.exceptions.ConnectionError:
        print("[ERROR] VT Connection error. Is mock_api.py running?")
        return {}
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return {}


def query_abuseipdb(ip: str) -> dict:
    """
    Queries the mock AbuseIPDB API for abuse confidence data.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API as a dictionary.
    """
    url = f"http://localhost:5000/abuseipdb/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
        print(f"[ERROR] API returned status: {response.status_code}")
        return {}
    except requests.exceptions.ConnectionError:
        print("[ERROR] AbuseIPDB error. Is mock_api.py running?")
        return {}
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return {}


def run_nmap(ip: str) -> str:
    """
    Executes a local Nmap scan on the target IP for ports 22 and 80.

    Args:
        ip (str): The target IP address.

    Returns:
        str: The raw XML output of the Nmap scan, or empty string.
    """
    command = ["nmap", "-p", "22,80", ip, "-oX", "-"]
    try:
        result = subprocess.run(command, capture_output=True, text=True)
        if result.returncode != 0:
            raise RuntimeError(f"Nmap failed with code {result.returncode}")
        return result.stdout
    except FileNotFoundError:
        print("[ERROR] Nmap binary not found. Is it installed?")
        return ""
    except Exception as e:
        print(f"[ERROR] {e}")
        return ""


if __name__ == "__main__":
    target = "1.2.3.4"
    print("--- VirusTotal ---")
    print(query_virustotal(target))
    print("--- AbuseIPDB ---")
    print(query_abuseipdb(target))
    print("--- Nmap XML Output ---")
    out = run_nmap(target)
    print(out[:150] + "..." if out else "No Nmap output.")
