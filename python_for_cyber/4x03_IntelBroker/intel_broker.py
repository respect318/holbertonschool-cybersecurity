#!/usr/bin/env python3
"""
Intelligence Broker API Client.
This module handles querying APIs and parsing Nmap XML.
"""
import subprocess
import xml.etree.ElementTree as ET

import requests


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
        # XML mətnini strukturlu ağaca (tree) çeviririk
        root = ET.fromstring(xml_data)
        
        # Bütün 'port' elementlərini tapırıq
        for port in root.findall(".//port"):
            state = port.find("state")
            
            # Portun vəziyyəti 'open' (açıq) olub-olmadığını yoxlayırıq
            if state is not None and state.get("state") == "open":
                portid = port.get("portid")
                if portid:
                    open_ports.append(int(portid))  # Rəqəm (int) kimi əlavə edirik
    except ET.ParseError:
        # XML oxunmaz haldadırsa (məsələn Nmap xəta veribsə), boş siyahı qayıdır
        pass

    return open_ports


if __name__ == "__main__":
    # Test üçün
    target_ip = "127.0.0.1"
    xml_output = run_nmap(target_ip)
    ports = parse_nmap_xml(xml_output)
    print(f"Open ports for {target_ip}: {ports}")
