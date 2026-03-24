#!/usr/bin/env python3
"""Main entry point for Intel Broker."""
import asyncio
import json
import argparse
import time
import aiohttp
from models import TargetDossier
from api_client import query_virustotal, query_abuseipdb, query_shodan
from scanner import run_nmap_async, parse_nmap_xml
from utils import load_cache, save_cache


async def gather_intel(ip, verbose=False):
    """Orchestrates intelligence gathering."""
    cache = load_cache()
    now = time.time()
    if ip in cache:
        c = cache[ip]
        if now - c.get("cache_time", 0) < 3600:
            if verbose:
                print("[+] Loading from cache...")
            d = TargetDossier(ip)
            d.vt_data, d.abuse_data = c.get("vt", {}), c.get("abuse", {})
            d.shodan_data, d.nmap_ports = c.get("shodan", {}), c.get("ports", [])
            return d
    d = TargetDossier(ip)
    sem = asyncio.Semaphore(5)
    async with aiohttp.ClientSession() as session:
        v_t = query_virustotal(session, ip, sem, verbose)
        a_t = query_abuseipdb(session, ip, sem, verbose)
        s_t = query_shodan(session, ip, sem, verbose)
        n_t = run_nmap_async(ip, sem, verbose)
        res = await asyncio.gather(v_t, a_t, s_t, n_t)
        d.vt_data, d.abuse_data, d.shodan_data = res[0], res[1], res[2]
        d.nmap_ports = parse_nmap_xml(res[3])
    cache[ip] = {
        "cache_time": now, "vt": d.vt_data, "abuse": d.abuse_data,
        "shodan": d.shodan_data, "ports": d.nmap_ports
    }
    save_cache(cache)
    return d


async def main():
    """CLI logic."""
    p = argparse.ArgumentParser(description="Intel Broker")
    p.add_argument("ip", help="Target IP")
    p.add_argument("-o", "--output", help="Output JSON")
    p.add_argument("-v", "--verbose", action="store_true", help="Verbose")
    args = p.parse_args()
    dossier = await gather_intel(args.ip, args.verbose)
    report = dossier.to_dict()
    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2)
        if args.verbose:
            print(f"[SUCCESS] Report: {args.output}")
    else:
        print(json.dumps(report, indent=2))


if __name__ == "__main__":
    asyncio.run(main())
