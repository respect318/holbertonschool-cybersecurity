#!/usr/bin/env python3
"""
playbook_phishing_triage.py - Phishing Email Triage Automation Playbook

Ingests a structured phishing alert, enriches all extracted IOCs,
applies decision logic and creates a case with a full audit trail.

Usage:
    python3 playbook_phishing_triage.py alerts/ALT-20260428-001.json
"""

import json
import sys
import re
import logging
from datetime import datetime, timezone

import enrich_ioc as enrich_ioc_module
import case_manager

# Configure audit log
logging.basicConfig(
    filename="playbook_audit.log",
    level=logging.INFO,
    format="%(message)s",
)
audit_logger = logging.getLogger("playbook_audit")


def _now() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def extract_hostname_from_url(url: str) -> str:
    """Extract hostname from a URL string."""
    match = re.match(r'^[a-zA-Z][a-zA-Z0-9+\-.]*://([^/:?#]+)', url)
    if match:
        return match.group(1)
    return url


def extract_iocs(alert: dict) -> list:
    """
    Extract IOCs from a phishing alert.
    Returns a list of (value, raw_label) tuples in extraction order.
    Deduplicates: each value is only returned once.
    """
    raw_log = alert.get("raw_log", {})
    seen = set()
    ioc_list = []  # list of dicts: {value, raw_label}

    def add(value, label):
        if value and value not in seen:
            seen.add(value)
            ioc_list.append({"value": value, "label": label})

    # 1. Sender IP
    from_ip = raw_log.get("from_ip")
    if from_ip:
        add(from_ip, "from_ip")

    # 2. Email domain from the From address
    from_addr = raw_log.get("from", "")
    if "@" in from_addr:
        domain = from_addr.split("@", 1)[1]
        add(domain, "email_domain")

    # 3. Hostnames from body URLs
    body_urls = raw_log.get("body_urls", []) or []
    for url in body_urls:
        try:
            hostname = extract_hostname_from_url(url)
            add(hostname, f"url:{url}")
        except Exception as e:
            print(f"[WARNING] Could not parse URL '{url}': {e}", file=sys.stderr)

    return ioc_list, seen


def run_playbook(alert_path: str) -> int:
    """
    Run the phishing triage playbook against a single alert file.
    Returns 0 on success, 1 on unrecoverable error.
    """
    # Load alert
    try:
        with open(alert_path) as f:
            alert = json.load(f)
    except (json.JSONDecodeError, OSError) as e:
        print(f"[ERROR] Could not load alert file '{alert_path}': {e}", file=sys.stderr)
        return 1

    alert_id = alert.get("alert_id", "UNKNOWN")
    rule_name = alert.get("rule_name", "unknown")
    ts = _now()

    # Extract IOCs
    ioc_entries, _seen = extract_iocs(alert)

    # Enrich each IOC
    enriched = []
    dedup_skipped = []

    # Track which values were already enriched (dedup label is for display)
    enriched_values = set()

    raw_log = alert.get("raw_log", {})
    body_urls = raw_log.get("body_urls", []) or []

    # Rebuild with dedup tracking for display
    seen_values = set()
    display_iocs = []  # (value, label, result_or_None, skipped_bool)

    from_ip = raw_log.get("from_ip")
    if from_ip:
        if from_ip not in seen_values:
            seen_values.add(from_ip)
            try:
                result = enrich_ioc_module.enrich_ioc(from_ip)
            except Exception as e:
                print(f"[WARNING] Enrichment failed for {from_ip}: {e}", file=sys.stderr)
                result = {"ioc": from_ip, "type": "ipv4", "verdict": "INVESTIGATE",
                          "score": 30, "feed_result": {"in_malicious_feed": False, "in_benign_list": False}}
            enriched.append(result)
            display_iocs.append((from_ip, "ipv4", result, False))
        else:
            display_iocs.append((from_ip, "ipv4", None, True))

    from_addr = raw_log.get("from", "")
    if "@" in from_addr:
        domain = from_addr.split("@", 1)[1]
        if domain not in seen_values:
            seen_values.add(domain)
            try:
                result = enrich_ioc_module.enrich_ioc(domain)
            except Exception as e:
                print(f"[WARNING] Enrichment failed for {domain}: {e}", file=sys.stderr)
                result = {"ioc": domain, "type": "domain", "verdict": "INVESTIGATE",
                          "score": 30, "feed_result": {"in_malicious_feed": False, "in_benign_list": False}}
            enriched.append(result)
            display_iocs.append((domain, "domain", result, False))
        else:
            display_iocs.append((domain, "domain", None, True))

    for url in body_urls:
        try:
            hostname = extract_hostname_from_url(url)
        except Exception as e:
            print(f"[WARNING] Could not parse URL '{url}': {e}", file=sys.stderr)
            continue
        if hostname not in seen_values:
            seen_values.add(hostname)
            try:
                result = enrich_ioc_module.enrich_ioc(hostname)
            except Exception as e:
                print(f"[WARNING] Enrichment failed for {hostname}: {e}", file=sys.stderr)
                result = {"ioc": hostname, "type": "domain", "verdict": "INVESTIGATE",
                          "score": 30, "feed_result": {"in_malicious_feed": False, "in_benign_list": False}}
            enriched.append(result)
            display_iocs.append((hostname, result.get("type", "domain"), result, False))
        else:
            display_iocs.append((hostname, "domain", None, True))

    # Tally verdicts
    verdict_counts = {"BLOCK": 0, "INVESTIGATE": 0, "ALLOW": 0}
    for r in enriched:
        v = r.get("verdict", "INVESTIGATE")
        verdict_counts[v] = verdict_counts.get(v, 0) + 1

    # Apply decision ladder
    if verdict_counts["BLOCK"] > 0:
        playbook_verdict = "ESCALATE"
        case_severity = "Critical"
        case_status = "escalated"
        resolution = None
    elif verdict_counts["INVESTIGATE"] > 0:
        playbook_verdict = "REVIEW"
        case_severity = "High"
        case_status = "open"
        resolution = None
    else:
        playbook_verdict = "CLOSE"
        case_severity = "Low"
        case_status = "closed"
        resolution = "no_indicators_of_compromise"

    # Build case IOCs list
    iocs_for_case = [
        {
            "ioc_value": r.get("ioc", ""),
            "ioc_type": r.get("type", ""),
            "verdict": r.get("verdict", ""),
            "score": r.get("score", 0),
        }
        for r in enriched
    ]

    # Case title
    case_title = f"Phishing: {rule_name.replace('_', ' ').title()} - {playbook_verdict}"
    case_description = (
        f"Automated phishing triage for alert {alert_id}. "
        f"Playbook verdict: {playbook_verdict}. "
        f"Rule: {rule_name}."
    )

    # Create case
    try:
        case_id = case_manager.create_case(
            alert_id=alert_id,
            severity=case_severity,
            title=case_title,
            description=case_description,
            iocs=iocs_for_case,
        )
    except Exception as e:
        print(f"[ERROR] Database write failure: {e}", file=sys.stderr)
        return 1

    # Post-creation actions
    if playbook_verdict == "CLOSE":
        case_manager.close_case(case_id, resolution)

    elif playbook_verdict == "ESCALATE":
        case_manager.update_case_status(case_id, "escalated")
        # Build note summarizing the triggering IOC(s)
        block_iocs = [
            f"{r['ioc_value']} ({r['verdict']}/{r['score']})"
            for r in iocs_for_case if r["verdict"] == "BLOCK"
        ]
        investigate_iocs = [
            f"{r['ioc_value']} ({r['verdict']}/{r['score']})"
            for r in iocs_for_case if r["verdict"] == "INVESTIGATE"
        ]
        allow_iocs = [
            f"{r['ioc_value']} ({r['verdict']}/{r['score']})"
            for r in iocs_for_case if r["verdict"] == "ALLOW"
        ]
        note_parts = [f"Playbook verdict: {playbook_verdict}."]
        ioc_summary_parts = []
        for r in iocs_for_case:
            ioc_summary_parts.append(f"{r['ioc_value']} ({r['verdict']}/{r['score']})")
        note_parts.append(f"IOCs: {', '.join(ioc_summary_parts)}")
        case_manager.add_case_note(case_id, " ".join(note_parts))

    elif playbook_verdict == "REVIEW":
        case_manager.update_case_status(case_id, "open")
        ioc_summary_parts = []
        for r in iocs_for_case:
            ioc_summary_parts.append(f"{r['ioc_value']} ({r['verdict']}/{r['score']})")
        note = f"Playbook verdict: {playbook_verdict}. IOCs: {', '.join(ioc_summary_parts)}"
        case_manager.add_case_note(case_id, note)

    # Audit log
    audit_line = (
        f"{ts} | PHISHING_TRIAGE | {alert_id} | "
        f"IOCs:{len(enriched)} | "
        f"BLOCK:{verdict_counts['BLOCK']},INVESTIGATE:{verdict_counts['INVESTIGATE']},ALLOW:{verdict_counts['ALLOW']} | "
        f"Verdict:{playbook_verdict} | Case:{case_id} | Severity:{case_severity}"
    )
    audit_logger.info(audit_line)

    # Stdout summary
    print(f"[{ts}] PHISHING TRIAGE PLAYBOOK")
    print(f"Alert      : {alert_id}")
    print(f"Rule       : {rule_name}")
    print(f"IOCs       : {len(display_iocs)} extracted, {len(enriched)} enriched")
    for (value, ioc_type, result, skipped) in display_iocs:
        if skipped:
            print(f"  {value:<22} [dedup, skipped]")
        else:
            v = result.get("verdict", "")
            s = result.get("score", 0)
            feed = result.get("feed_result", {})
            tags = feed.get("tags", [])
            cat = feed.get("category", "")
            tag_str = ", ".join(tags) if tags else cat
            extra = f"({tag_str})" if tag_str else ""
            print(f"  {value:<22} {ioc_type:<7} {v:<12} score={s:<4} {extra}")
    print(f"Verdict    : {playbook_verdict}")
    status_display = case_status
    print(f"Case       : {case_id}  Severity: {case_severity}  Status: {status_display}")
    if playbook_verdict == "ESCALATE":
        print("Action     : SOC notification queued for on-call analyst")
    elif playbook_verdict == "REVIEW":
        print("Action     : Queued for manual analyst review")
    else:
        print("Action     : Case closed automatically (no indicators of compromise)")

    return 0


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 playbook_phishing_triage.py <alert_file.json>")
        sys.exit(1)

    alert_path = sys.argv[1]
    sys.exit(run_playbook(alert_path))


if __name__ == "__main__":
    main()
