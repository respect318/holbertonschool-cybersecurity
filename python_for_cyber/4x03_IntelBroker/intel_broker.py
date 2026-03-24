#!/usr/bin/env python3
"""
Intelligence Broker API Client.
Final version: Generates a structured JSON report for SOC ingestion.
"""
import asyncio
import sys
import json
import argparse
import xml.etree.ElementTree as ET
from datetime import datetime
import aiohttp


class TargetDossier:
    """Represents a target dossier with aggregated intelligence."""
    def __init__(self, ip=""):
        self.ip = ip
        self.vt_data = {}
        self.abuse_data = {}
        self.shodan_data = {}
        self.nmap_ports = []

    def to_dict(self):
        """Returns a structured dictionary for JSON export."""
        return {
            "target": self.ip,
            "timestamp": datetime.now().isoformat(),
            "intelligence": {
                "virustotal": self.vt_data,
                "abuseipdb": self.abuse_data,
                "shodan": self.shodan_data,
                "nmap_open_ports": self.nmap_ports
            }
        }


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


async def run_nmap_async(ip: str) -> str:
    """Executes Nmap asynchronously."""
    cmd = ["nmap", "-p", "22,80", ip, "-oX", "-"]
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE
    )
    stdout, _ = await proc.communicate()
    if proc.returncode != 0:
        return ""
    return stdout.decode("utf-8", errors="ignore")


def parse_nmap_xml(xml_data: str) -> list:
    """Parses Nmap XML output for open ports."""
    if not xml_data:
        return []
    open_ports = []
    try:
        root = ET.fromstring(xml_data)
        for port in root.findall(".//port"):
            st = port.find("state")
            if st is not None and st.get("state") == "open":
                pid = port.get("portid")
                if pid:
                    open_ports.append(int(pid))
    except (ET.ParseError, TypeError):
        pass
    return open_ports


async def gather_intel(ip: str) -> TargetDossier:
    """Gathers all intelligence in parallel."""
    dossier = TargetDossier(ip)
    async with aiohttp.ClientSession() as session:
        v_t = query_virustotal(session, ip)
        a_t = query_abuseipdb(session, ip)
        s_t = query_shodan(session, ip)
        n_t = run_nmap_async(ip)
        res = await asyncio.gather(v_t, a_t, s_t, n_t)
        dossier.vt_data = res[0]
        dossier.abuse_data = res[1]
        dossier.shodan_data = res[2]
        dossier.nmap_ports = parse_nmap_xml(res[3])
    return dossier


async def main():
    """Main function to handle arguments and execution."""
    parser = argparse.ArgumentParser(description="Intel Broker")
    parser.add_argument("ip", help="Target IP address")
    parser.add_argument("-o", "--output", help="Output JSON file")
    args = parser.parse_args()
    dossier = await gather_intel(args.ip)
    report = dossier.to_dict()
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)
    else:
        print(json.dumps(report, indent=2))


if __name__ == "__main__":
    asyncio.run(main())
