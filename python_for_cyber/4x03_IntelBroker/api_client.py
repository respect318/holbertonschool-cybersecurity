#!/usr/bin/env python3
"""Async HTTP logic for querying APIs."""
import asyncio


async def fetch_api(session, url, sem, name, verbose=False):
    """Fetches API data with status messages and error handling."""
    async with sem:
        if verbose:
            print(f"[+] Querying {name}...")
        try:
            async with session.get(url, timeout=5) as response:
                if response.status == 200:
                    return await response.json()
        except Exception:
            pass
        return "unavailable"


async def query_virustotal(session, ip, sem, verbose=False):
    """Queries VirusTotal API."""
    url = f"http://localhost:5000/virustotal/{ip}"
    return await fetch_api(session, url, sem, "VirusTotal", verbose)


async def query_abuseipdb(session, ip, sem, verbose=False):
    """Queries AbuseIPDB API."""
    url = f"http://localhost:5000/abuseipdb/{ip}"
    return await fetch_api(session, url, sem, "AbuseIPDB", verbose)


async def query_shodan(session, ip, sem, verbose=False):
    """Queries Shodan API."""
    url = f"http://localhost:5000/shodan/{ip}"
    return await fetch_api(session, url, sem, "Shodan", verbose)
