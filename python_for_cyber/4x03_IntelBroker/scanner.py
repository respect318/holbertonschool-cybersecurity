#!/usr/bin/env python3
"""Nmap scanner wrapper."""
import asyncio
import xml.etree.ElementTree as ET


async def run_nmap_async(ip, sem, verbose=False):
    """Executes Nmap asynchronously."""
    async with sem:
        if verbose:
            print("[+] Running Nmap scan...")
        cmd = ["nmap", "-p", "22,80", ip, "-oX", "-"]
        proc = await asyncio.create_subprocess_exec(
            *cmd,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, _ = await proc.communicate()
        if verbose:
            print("[+] Nmap finished.")
        return stdout.decode("utf-8", errors="ignore") if stdout else ""


def parse_nmap_xml(xml_data):
    """Parses Nmap XML output for open ports."""
    if not xml_data:
        return []
    ports = []
    try:
        root = ET.fromstring(xml_data)
        for p in root.findall(".//port"):
            st = p.find("state")
            if st is not None and st.get("state") == "open":
                pid = p.get("portid")
                if pid:
                    ports.append(int(pid))
    except (ET.ParseError, TypeError):
        pass
    return ports
