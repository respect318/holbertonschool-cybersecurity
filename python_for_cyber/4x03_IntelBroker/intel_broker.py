#!/usr/bin/env python3
"""
Intelligence Broker API Client.
Optimized with asyncio.gather for parallel intelligence gathering.
"""
import asyncio
import subprocess
import sys
import xml.etree.ElementTree as ET

import aiohttp


class TargetDossier:
    """Represents a target dossier with aggregated intelligence."""

    def __init__(self, ip=""):
        self.ip = ip
        self.vt_data = {}
        self.abuse_data = {}
        self.shodan_data = {}
        self.nmap_ports = []


async def fetch_api(session, url):
    """Asynchronous function to fetch data from an API."""
    try:
        async with session.get(url, timeout=5) as response:
            if response.status == 200:
                return await response.json()
    except Exception:
        pass
    return {}


async def query_virustotal(session, ip: str) -> dict:
    """Queries the mock VirusTotal API."""
    url = f"http://localhost:5000/virustotal/{ip}"
    return await fetch_api(session, url)


async def query_abuseipdb(session, ip: str) -> dict:
    """Queries the mock AbuseIPDB API."""
    url = f"http://localhost:5000/abuseipdb/{ip}"
    return await fetch_api(session, url)


async def query_shodan(session, ip: str) -> dict:
    """Queries the mock Shodan API."""
    url = f"http://localhost:5000/shodan/{ip}"
    return await fetch_api(session, url)


async def gather_intel(ip: str) -> TargetDossier:
    """Launches all API tasks together and returns a populated dossier."""
    dossier = TargetDossier(ip)
    async with aiohttp.ClientSession() as session:
        # Üç API sorğusunu paralel başladırıq
        vt_task = query_virustotal(session, ip)
        abuse_task = query_abuseipdb(session, ip)
        shodan_task = query_shodan(session, ip)

        # Hamısının bitməsini eyni anda gözləyirik
        results = await asyncio.gather(vt_task, abuse_task, shodan_task)
        
        dossier.vt_data = results[0]
        dossier.abuse_data = results[1]
        dossier.shodan_data = results[2]
        
    return dossier


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


async def main():
    """Main entry point for the script."""
    if len(sys.argv) != 2:
        print("Usage: ./intel_broker.py <IP_ADDRESS>")
        sys.exit(1)

    target_ip = sys.argv[1]
    
    # Kəşfiyyatı paralel toplayırıq
    dossier = await gather_intel(target_ip)
    
    # Nmap hələlik sinxron qalır
    nmap_xml = run_nmap(target_ip)
    dossier.nmap_ports = parse_nmap_xml(nmap_xml)

    print(f"--- Dossier for {dossier.ip} ---")
    print(f"VirusTotal Data: {dossier.vt_data}")
    print(f"AbuseIPDB Data: {dossier.abuse_data}")
    print(f"Shodan Data: {dossier.shodan_data}")
    print(f"Open Ports: {dossier.nmap_ports}")


if __name__ == "__main__":
    asyncio.run(main())
