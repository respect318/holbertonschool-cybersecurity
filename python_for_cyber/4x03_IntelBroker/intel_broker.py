#!/usr/bin/env python3
"""
Intelligence Broker API Client.
This module handles querying external Threat Intelligence APIs.
"""
import requests


def query_virustotal(ip: str) -> dict:
    """
    Queries the mock VirusTotal API for reputation data.

    Args:
        ip (str): The IP address to query.

    Returns:
        dict: The JSON payload returned by the API as a dictionary,
              or an empty dictionary if an error occurs.
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
        dict: The JSON payload returned by the API as a dictionary,
              or an empty dictionary if an error occurs.
    """
    url = f"http://localhost:5000/abuseipdb/{ip}"

    try:
        response = requests.get(url, timeout=5)

        if response.status_code == 200:
            return response.json()

        print(f"[ERROR] API returned status: {response.status_code}")
        return {}

    except requests.exceptions.ConnectionError:
        print("[ERROR] AbuseIPDB Connection error. Is mock_api.py running?")
        return {}
    except Exception as e:
        print(f"[ERROR] Unexpected error: {e}")
        return {}


if __name__ == "__main__":
    # Test the functions with a sample IP
    target = "1.2.3.4"
    print(query_virustotal(target))
    print(query_abuseipdb(target))
