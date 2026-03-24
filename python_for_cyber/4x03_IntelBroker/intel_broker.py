#!/usr/bin/env python3
"""
Intelligence Broker API Client.
Final version: Includes robust HTTP error handling for API resilience.
"""
import asyncio
import sys
import json
import argparse
import os
import time
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


def load_cache():
    """Loads the cache from cache.json."""
    if os.path.exists("cache.json"):
        try:
            with open("cache.json", "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {}
    return {}


def save_cache(cache):
    """Saves the current cache to cache.json."""
    with open("cache.json", "w", encoding="utf-8") as f:
        json.dump(cache, f, indent=2)


async def fetch_api(session, url, sem):
    """Fetches API data with HTTP error handling."""
    async with sem:
        try:
            async with session.get(url, timeout=5) as response:
                if response.status == 200:
                    return await response.json()
                return {"error": "Unavailable"}
        except Exception:
            return {"error": "Unavailable"}


async def run_nmap_async(ip: str, sem):
    """Executes Nmap asynchronously with rate limiting."""
    async with sem:
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
    """Gathers intelligence with cache, semaphore, and error handling."""
    cache = load_cache()
    now = time.time()
    if ip in cache:
        c_data = cache[ip]
        if now - c_data.get("cache_time", 0) < 3600:
            dossier = TargetDossier(ip)
            dossier.vt_data = c_data.get("vt", {})
            dossier.abuse_data = c_data.get("abuse", {})
            dossier.shodan_data = c_data.get("shodan", {})
            dossier.nmap_ports = c_data.get("ports", [])
            return dossier
    dossier = TargetDossier(ip)
    sem = asyncio.Semaphore(5)
    async with aiohttp.ClientSession() as session:
        v_t = fetch_api(session, f"http://localhost:5000/virustotal/{ip}", sem)
        a_t = fetch_api(session, f"http://localhost:5000/abuseipdb/{ip}", sem)
        s_t = fetch_api(session, f"http://localhost:5000/shodan/{ip}", sem)
        n_t = run_nmap_async(ip, sem)
        res = await asyncio.gather(v_t, a_t, s_t, n_t)
        dossier.vt_data, dossier.abuse_data = res[0], res[1]
        dossier.shodan_data, n_xml = res[2], res[3]
        dossier.nmap_ports = parse_nmap_xml(n_xml)
    cache[ip] = {
        "cache_time": now, "vt": dossier.vt_data, "abuse": dossier.abuse_data,
        "shodan": dossier.shodan_data, "ports": dossier.nmap_ports
    }
    save_cache(cache)
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
