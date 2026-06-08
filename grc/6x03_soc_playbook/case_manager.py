#!/usr/bin/env python3
"""
case_manager.py - Security Case Management Module and CLI
Creates and manages security cases in a local SQLite database.
The database cases.db is created in the current directory on first import.

Usage:
    python3 case_manager.py list
    python3 case_manager.py list --status escalated
    python3 case_manager.py get CASE-20260428-001
    python3 case_manager.py close CASE-20260428-001 "benign; confirmed newsletter sender"
"""

import sqlite3
import json
import argparse
from datetime import datetime, timezone

VALID_STATUSES = {"open", "investigating", "escalated", "closed"}


def _now() -> str:
    """Return current UTC timestamp in ISO 8601 format."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _connect(db_path: str = "cases.db") -> sqlite3.Connection:
    """Open a connection to the SQLite database."""
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


def init_db(db_path: str = "cases.db") -> None:
    """
    Create the database and all three tables if they do not already exist.
    Called automatically on module import.
    """
    conn = _connect(db_path)
    with conn:
        conn.execute("""
            CREATE TABLE IF NOT EXISTS cases (
                case_id     TEXT PRIMARY KEY,
                alert_id    TEXT NOT NULL,
                severity    TEXT NOT NULL,
                title       TEXT NOT NULL,
                description TEXT,
                status      TEXT NOT NULL DEFAULT 'open',
                created_at  TEXT NOT NULL,
                updated_at  TEXT NOT NULL,
                resolution  TEXT
            )
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS case_notes (
                note_id     INTEGER PRIMARY KEY AUTOINCREMENT,
                case_id     TEXT NOT NULL,
                note        TEXT NOT NULL,
                created_at  TEXT NOT NULL,
                FOREIGN KEY (case_id) REFERENCES cases(case_id)
            )
        """)
        conn.execute("""
            CREATE TABLE IF NOT EXISTS case_iocs (
                ioc_id      INTEGER PRIMARY KEY AUTOINCREMENT,
                case_id     TEXT NOT NULL,
                ioc_value   TEXT NOT NULL,
                ioc_type    TEXT NOT NULL,
                verdict     TEXT NOT NULL,
                score       INTEGER NOT NULL,
                FOREIGN KEY (case_id) REFERENCES cases(case_id)
            )
        """)
    conn.close()


def generate_case_id(db_path: str = "cases.db") -> str:
    """
    Generate a unique case ID in the format CASE-YYYYMMDD-NNN.
    NNN is zero-padded and sequential within the current day.
    """
    today = datetime.now(timezone.utc).strftime("%Y%m%d")
    conn = _connect(db_path)
    try:
        cursor = conn.execute(
            "SELECT COUNT(*) FROM cases WHERE case_id LIKE ?",
            (f"CASE-{today}-%",)
        )
        count = cursor.fetchone()[0]
    finally:
        conn.close()
    seq = count + 1
    return f"CASE-{today}-{seq:03d}"


def create_case(
    alert_id: str,
    severity: str,
    title: str,
    description: str,
    iocs: list,
    db_path: str = "cases.db"
) -> str:
    """
    Create a new case in the database.
    Inserts one row into cases and one row per IOC into case_iocs.
    Returns the generated case_id.
    """
    case_id = generate_case_id(db_path)
    now = _now()
    conn = _connect(db_path)
    with conn:
        conn.execute(
            """INSERT INTO cases
               (case_id, alert_id, severity, title, description, status, created_at, updated_at)
               VALUES (?, ?, ?, ?, ?, 'open', ?, ?)""",
            (case_id, alert_id, severity, title, description, now, now)
        )
        for ioc in iocs:
            conn.execute(
                """INSERT INTO case_iocs
                   (case_id, ioc_value, ioc_type, verdict, score)
                   VALUES (?, ?, ?, ?, ?)""",
                (
                    case_id,
                    ioc.get("ioc_value", ioc.get("ioc", "")),
                    ioc.get("ioc_type", ioc.get("type", "")),
                    ioc.get("verdict", ""),
                    ioc.get("score", 0),
                )
            )
    conn.close()
    return case_id


def add_case_note(case_id: str, note: str, db_path: str = "cases.db") -> bool:
    """
    Add a note to an existing case. Updates cases.updated_at.
    Returns True on success, False if the case does not exist.
    """
    conn = _connect(db_path)
    try:
        row = conn.execute(
            "SELECT case_id FROM cases WHERE case_id = ?", (case_id,)
        ).fetchone()
        if row is None:
            return False
        now = _now()
        with conn:
            conn.execute(
                "INSERT INTO case_notes (case_id, note, created_at) VALUES (?, ?, ?)",
                (case_id, note, now)
            )
            conn.execute(
                "UPDATE cases SET updated_at = ? WHERE case_id = ?",
                (now, case_id)
            )
        return True
    finally:
        conn.close()


def update_case_status(case_id: str, status: str, db_path: str = "cases.db") -> bool:
    """
    Update the status of a case.
    Valid statuses: open, investigating, escalated, closed.
    Returns False for invalid status values without raising an exception.
    """
    if status not in VALID_STATUSES:
        return False
    conn = _connect(db_path)
    try:
        row = conn.execute(
            "SELECT case_id FROM cases WHERE case_id = ?", (case_id,)
        ).fetchone()
        if row is None:
            return False
        now = _now()
        with conn:
            conn.execute(
                "UPDATE cases SET status = ?, updated_at = ? WHERE case_id = ?",
                (status, now, case_id)
            )
        return True
    finally:
        conn.close()


def close_case(case_id: str, resolution: str, db_path: str = "cases.db") -> bool:
    """
    Close a case with a resolution string.
    Returns True on success, False if the case does not exist.
    """
    conn = _connect(db_path)
    try:
        row = conn.execute(
            "SELECT case_id FROM cases WHERE case_id = ?", (case_id,)
        ).fetchone()
        if row is None:
            return False
        now = _now()
        with conn:
            conn.execute(
                """UPDATE cases SET status = 'closed', resolution = ?, updated_at = ?
                   WHERE case_id = ?""",
                (resolution, now, case_id)
            )
        return True
    finally:
        conn.close()


def get_case(case_id: str, db_path: str = "cases.db") -> dict:
    """
    Return a full dict representation of a case including notes and IOCs.
    Returns None if the case does not exist.
    """
    conn = _connect(db_path)
    try:
        row = conn.execute(
            "SELECT * FROM cases WHERE case_id = ?", (case_id,)
        ).fetchone()
        if row is None:
            return None

        case = dict(row)

        notes_rows = conn.execute(
            "SELECT note, created_at FROM case_notes WHERE case_id = ? ORDER BY note_id",
            (case_id,)
        ).fetchall()
        case["notes"] = [dict(r) for r in notes_rows]

        ioc_rows = conn.execute(
            "SELECT ioc_value, ioc_type, verdict, score FROM case_iocs WHERE case_id = ? ORDER BY ioc_id",
            (case_id,)
        ).fetchall()
        case["iocs"] = [dict(r) for r in ioc_rows]

        return case
    finally:
        conn.close()


def list_cases(status: str = None, db_path: str = "cases.db") -> list:
    """
    Return a list of case summary dicts (no notes, no IOCs).
    If status is provided, filters by that status.
    Each dict contains: case_id, alert_id, severity, title, status, created_at.
    """
    conn = _connect(db_path)
    try:
        if status is not None:
            rows = conn.execute(
                """SELECT case_id, alert_id, severity, title, status, created_at
                   FROM cases WHERE status = ? ORDER BY created_at""",
                (status,)
            ).fetchall()
        else:
            rows = conn.execute(
                """SELECT case_id, alert_id, severity, title, status, created_at
                   FROM cases ORDER BY created_at"""
            ).fetchall()
        return [dict(r) for r in rows]
    finally:
        conn.close()


# --- CLI ---

def _print_table(cases: list) -> None:
    """Print cases as a formatted table."""
    if not cases:
        print("No cases found.")
        return

    col_widths = {
        "case_id": 19,
        "alert_id": 19,
        "severity": 8,
        "title": 38,
        "status": 11,
    }

    def row_str(vals):
        return (
            f"| {vals[0]:<{col_widths['case_id']}} "
            f"| {vals[1]:<{col_widths['alert_id']}} "
            f"| {vals[2]:<{col_widths['severity']}} "
            f"| {vals[3]:<{col_widths['title']}} "
            f"| {vals[4]:<{col_widths['status']}} |"
        )

    sep = (
        "+-" + "-" * col_widths["case_id"] + "-"
        "+-" + "-" * col_widths["alert_id"] + "-"
        "+-" + "-" * col_widths["severity"] + "-"
        "+-" + "-" * col_widths["title"] + "-"
        "+-" + "-" * col_widths["status"] + "-+"
    )

    print(sep)
    print(row_str(["Case ID", "Alert ID", "Severity", "Title", "Status"]))
    print(sep)
    for c in cases:
        title = c["title"]
        if len(title) > col_widths["title"]:
            title = title[:col_widths["title"] - 1] + "…"
        print(row_str([c["case_id"], c["alert_id"], c["severity"], title, c["status"]]))
    print(sep)
    print(f"{len(cases)} cases")


def main():
    parser = argparse.ArgumentParser(description="Security Case Manager CLI")
    subparsers = parser.add_subparsers(dest="command")

    # list
    list_p = subparsers.add_parser("list", help="List cases")
    list_p.add_argument("--status", help="Filter by status")

    # get
    get_p = subparsers.add_parser("get", help="Get a full case")
    get_p.add_argument("case_id")

    # close
    close_p = subparsers.add_parser("close", help="Close a case")
    close_p.add_argument("case_id")
    close_p.add_argument("resolution")

    args = parser.parse_args()

    if args.command == "list":
        cases = list_cases(status=args.status)
        _print_table(cases)

    elif args.command == "get":
        case = get_case(args.case_id)
        if case is None:
            print(f"Case {args.case_id} not found.")
        else:
            print(json.dumps(case, indent=2))

    elif args.command == "close":
        success = close_case(args.case_id, args.resolution)
        if success:
            print(f"Case {args.case_id} closed: {args.resolution}")
        else:
            print(f"Case {args.case_id} not found.")

    else:
        parser.print_help()


# Initialize the database on import
init_db()

if __name__ == "__main__":
    main()
