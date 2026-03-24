#!/usr/bin/env python3
"""
Intelligence Broker API Client.
Refactored to use asyncio and aiohttp for parallel execution.
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
    """Queries the mock VirusTotal API using aiohttp."""
    url = f"http://localhost:5000/virustotal/{ip}"
    return await fetch_api(session, url)


async def query_abuseipdb(session, ip: str) -> dict:
    """Queries the mock AbuseIPDB API using aiohttp."""
    url = f"http://localhost:5000/abuseipdb/{ip}"
    return await fetch_api(session, url)


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
    """Main entry point for async execution."""
    if len(sys.argv) != 2:
        print("Usage: ./intel_broker.py <IP_ADDRESS>")
        sys.exit(1)

    target_ip = sys.argv[1]
    dossier = TargetDossier(target_ip)

    async with aiohttp.ClientSession() as session:
        # API sorğularını paralel işə salırıq
        vt_task = query_virustotal(session, target_ip)
        abuse_task = query_abuseipdb(session, target_ip)

        # Hər iki tapşırığın nəticəsini eyni anda gözləyirik
        dossier.vt_data, dossier.abuse_data = await asyncio.gather(
            vt_task, abuse_task
        )

    # Nmap hələlik sinxron (sequential) qalır
    nmap_xml = run_nmap(target_ip)
    dossier.nmap_ports = parse_nmap_xml(nmap_xml)

    print(f"--- Dossier for {dossier.ip} ---")
    print(f"VirusTotal Data: {dossier.vt_data}")
    print(f"AbuseIPDB Data: {dossier.abuse_data}")
    print(f"Open Ports: {dossier.nmap_ports}")


if __name__ == "__main__":
    asyncio.run(main())
