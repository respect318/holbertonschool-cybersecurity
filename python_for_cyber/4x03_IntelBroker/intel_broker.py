#!/usr/bin/env python3
"""
Intelligence Broker API Client.
Handles querying APIs, parsing Nmap XML, and aggregating data.
"""
import subprocess
import sys
import xml.etree.ElementTree as ET

import requests


class TargetDossier:
    """Represents a target dossier with aggregated intelligence."""

    def __init__(self, ip: str):
        """Initialize the dossier with an IP address."""
        self.ip = ip
        self.vt_data = {}
        self.abuse_data = {}
        self.nmap_ports = []


def query_virustotal(ip: str) -> dict:
    """Queries the mock VirusTotal API for reputation data."""
    url = f"http://localhost:5000/virustotal/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
    except requests.exceptions.ConnectionError:
        pass
    return {}


def query_abuseipdb(ip: str) -> dict:
    """Queries the mock AbuseIPDB API for abuse confidence data."""
    url = f"http://localhost:5000/abuseipdb/{ip}"
    try:
        response = requests.get(url, timeout=5)
        if response.status_code == 200:
            return response.json()
    except requests.exceptions.ConnectionError:
        pass
    return {}


def run_nmap(ip: str) -> str:
    """Executes a local Nmap scan and returns raw XML."""
    cmd = ["nmap", "-p", "22,80", ip, "-oX", "-"]
    result = subprocess.run(cmd, capture_output=True)

    if result.returncode != 0:
        raise RuntimeError("Nmap scan failed")

    out = result.stdout
    if isinstance(out, bytes):
        return out.decode("utf-8", errors="ignore")
    return str(out)


def parse_nmap_xml(xml_data: str) -> list:
    """Parses Nmap XML output and returns a list of open ports."""
    if not xml_data:
        return []

    open_ports = []
    try:
        root = ET.fromstring(xml_data)
        for port in root.findall(".//port"):
            state = port.find("state")
            if state is not None and state.get("state") == "open":
                portid = port.get("portid")
                if portid:
                    open_ports.append(int(portid))
    except ET.ParseError:
        pass

    return open_ports


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: ./intel_broker.py <IP_ADDRESS>")
        sys.exit(1)
    target_ip = sys.argv[1]
    dossier = TargetDossier(target_ip)
    dossier.vt_data = query_virustotal(target_ip)
    dossier.abuse_data = query_abuseipdb(target_ip)
    nmap_xml = run_nmap(target_ip)
    dossier.nmap_ports = parse_nmap_xml(nmap_xml)
    print(f"--- Dossier for {dossier.ip} ---")
    print(f"VirusTotal Data: {dossier.vt_data}")
    print(f"AbuseIPDB Data: {dossier.abuse_data}")
    print(f"Open Ports: {dossier.nmap_ports}")
