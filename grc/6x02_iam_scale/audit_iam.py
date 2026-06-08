#!/usr/bin/env python3
"""
audit_iam.py — MedDefense IAM Audit Script
Processes accounts.csv, applies privilege and hygiene checks,
and writes severity-scored findings to iam_findings.json.
"""

import csv
import json
import datetime

DORMANCY_THRESHOLD_DAYS = 90
PRIVILEGED_GROUPS_HIGH = {"Domain Admins", "Server Admins"}
INPUT_FILE = "accounts.csv"
OUTPUT_FILE = "iam_findings.json"

_finding_counter = 0


def _next_id():
    global _finding_counter
    _finding_counter += 1
    return f"IAM-{_finding_counter:03d}"


def _groups(account):
    """Return a set of group names from the privileged_groups field."""
    raw = account.get("privileged_groups", "").strip()
    if not raw:
        return set()
    return {g.strip() for g in raw.split(";")}


def _evidence(account, extra=""):
    fields = [
        f"account_type={account['account_type']}",
        f"enabled={account['enabled']}",
        f"privileged_groups={account['privileged_groups']}",
        f"last_login_days_ago={account['last_login_days_ago']}",
        f"mfa_enrolled={account['mfa_enrolled']}",
        f"description={account['description']}",
    ]
    if extra:
        fields.append(extra)
    return "; ".join(fields)


# ---------------------------------------------------------------------------
# Check functions
# ---------------------------------------------------------------------------

def check_dormant_privileged(account, dormancy_threshold_days=90):
    """
    Flags user accounts in Domain Admins or Server Admins whose
    last_login_days_ago exceeds the threshold.
    Service accounts with last_login_days_ago > 365 are flagged as
    dormant_service_privileged.
    """
    findings = []
    try:
        days = int(account["last_login_days_ago"])
    except (ValueError, KeyError):
        return findings

    groups = _groups(account)
    is_privileged = bool(groups & PRIVILEGED_GROUPS_HIGH)
    atype = account["account_type"].lower()

    if atype == "user" and is_privileged and days > dormancy_threshold_days:
        findings.append({
            "finding_id": _next_id(),
            "account": account["username"],
            "check": "check_dormant_privileged",
            "severity": "High",
            "title": f"Dormant privileged user account ({days} days since last login)",
            "evidence": _evidence(account),
            "remediation": (
                "Disable the account immediately; remove privileged group membership; "
                "confirm with department manager whether the account is still needed; "
                "if confirmed active, require re-authentication and MFA enrolment before re-enabling."
            ),
        })

    if atype == "service" and is_privileged and days > 365:
        findings.append({
            "finding_id": _next_id(),
            "account": account["username"],
            "check": "check_dormant_privileged",
            "severity": "Critical",
            "title": f"Dormant privileged service account ({days} days since last login)",
            "evidence": _evidence(account),
            "remediation": (
                "Disable the service account immediately; audit all actions in the past 90 days; "
                "if no current function is confirmed, delete the account and remove all group memberships."
            ),
        })

    return findings


def check_mfa_coverage(account):
    """
    Flags enabled user accounts in Domain Admins or Server Admins
    where mfa_enrolled is FALSE.
    """
    findings = []
    if account["account_type"].lower() != "user":
        return findings
    if account["enabled"].upper() != "TRUE":
        return findings

    groups = _groups(account)
    if not (groups & PRIVILEGED_GROUPS_HIGH):
        return findings

    if account["mfa_enrolled"].upper() == "FALSE":
        findings.append({
            "finding_id": _next_id(),
            "account": account["username"],
            "check": "check_mfa_coverage",
            "severity": "High",
            "title": "Privileged user account without MFA enrolled",
            "evidence": _evidence(account),
            "remediation": (
                "Enrol MFA immediately; suspend console and VPN access until MFA is active; "
                "enforce MFA as a Conditional Access requirement for all Domain Admins and Server Admins."
            ),
        })

    return findings


def check_service_account_overpriv(account):
    """
    Flags service accounts with Domain Admins (Critical) or
    Server Admins (Medium) membership.
    """
    findings = []
    if account["account_type"].lower() != "service":
        return findings

    groups = _groups(account)

    if "Domain Admins" in groups:
        findings.append({
            "finding_id": _next_id(),
            "account": account["username"],
            "check": "check_service_account_overpriv",
            "severity": "Critical",
            "title": "Service account with Domain Admins membership",
            "evidence": _evidence(account),
            "remediation": (
                "Remove Domain Admins membership immediately; identify the minimum privilege "
                "required for the service function; replace with Vault-issued dynamic credentials "
                "scoped to required resources; audit all domain actions performed under this account."
            ),
        })
    elif "Server Admins" in groups:
        findings.append({
            "finding_id": _next_id(),
            "account": account["username"],
            "check": "check_service_account_overpriv",
            "severity": "Medium",
            "title": "Service account with Server Admins membership",
            "evidence": _evidence(account),
            "remediation": (
                "Evaluate whether Server Admins is required; replace with a scoped role or "
                "Vault-issued credential; document business justification if the group membership must remain."
            ),
        })

    return findings


def check_departed_or_transferred(account):
    """
    Scans the description field for keywords indicating the account
    holder has left, transferred, or that a migration is complete.
    """
    findings = []
    keywords = [
        "contract ended",
        "left organization",
        "transferred from",
        "migration complete",
    ]
    desc = account.get("description", "").lower()
    matched = [kw for kw in keywords if kw in desc]
    if not matched:
        return findings

    groups = _groups(account)
    is_privileged = bool(groups & PRIVILEGED_GROUPS_HIGH)
    severity = "Critical" if is_privileged else "High"

    findings.append({
        "finding_id": _next_id(),
        "account": account["username"],
        "check": "check_departed_or_transferred",
        "severity": severity,
        "title": f"Account flagged for manual review: departed or transferred ({', '.join(matched)})",
        "evidence": _evidence(account, f"matched_keywords={matched}"),
        "remediation": (
            "Confirm account status with HR; disable immediately if the employee has left or "
            "role has changed; remove all privileged group memberships; review audit logs for "
            "activity after the stated departure or transfer date."
        ),
    })

    return findings


def check_disabled_with_groups(account):
    """
    Flags disabled accounts that still have privileged_groups populated.
    """
    findings = []
    if account["enabled"].upper() != "FALSE":
        return findings

    groups = _groups(account)
    if not groups:
        return findings

    findings.append({
        "finding_id": _next_id(),
        "account": account["username"],
        "check": "check_disabled_with_groups",
        "severity": "Medium",
        "title": "Disabled account retains group memberships",
        "evidence": _evidence(account),
        "remediation": (
            "Remove all group memberships from the disabled account; if the account is to remain "
            "disabled long-term, document the retention reason; if no reason exists, delete the account."
        ),
    })

    return findings


def check_no_mfa_high_risk(account):
    """
    Flags enabled user accounts without MFA.
    Low severity; escalated to Medium if description references repeated
    security failures.
    """
    findings = []
    if account["account_type"].lower() != "user":
        return findings
    if account["enabled"].upper() != "TRUE":
        return findings
    if account["mfa_enrolled"].upper() != "FALSE":
        return findings

    # Skip accounts already caught by check_mfa_coverage (privileged groups)
    # to avoid duplicate findings — those are already High severity
    groups = _groups(account)
    if groups & PRIVILEGED_GROUPS_HIGH:
        return findings

    desc = account.get("description", "").lower()
    repeated_failure_keywords = ["phishing simulation failure", "security failure", "repeated"]
    escalate = any(kw in desc for kw in repeated_failure_keywords)

    severity = "Medium" if escalate else "Low"
    title = (
        "Enabled user without MFA — escalated due to repeated security failures"
        if escalate
        else "Enabled user without MFA enrolled"
    )

    findings.append({
        "finding_id": _next_id(),
        "account": account["username"],
        "check": "check_no_mfa_high_risk",
        "severity": severity,
        "title": title,
        "evidence": _evidence(account),
        "remediation": (
            "Enrol MFA immediately; if escalated due to repeated failures, require "
            "security awareness training before re-enabling full access; consider "
            "additional Conditional Access restrictions for this account."
        ),
    })

    return findings


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def run_audit(input_file=INPUT_FILE, output_file=OUTPUT_FILE):
    global _finding_counter
    _finding_counter = 0

    accounts = []
    with open(input_file, newline="", encoding="utf-8") as fh:
        reader = csv.DictReader(fh)
        for row in reader:
            accounts.append(row)

    all_findings = []
    checks = [
        check_service_account_overpriv,   # run first — highest severity, sets context
        check_dormant_privileged,
        check_mfa_coverage,
        check_departed_or_transferred,
        check_disabled_with_groups,
        check_no_mfa_high_risk,
    ]

    for account in accounts:
        for check_fn in checks:
            results = check_fn(account)
            all_findings.extend(results)

    severity_order = ["Critical", "High", "Medium", "Low"]
    counts = {s: 0 for s in severity_order}
    for f in all_findings:
        counts[f["severity"]] = counts.get(f["severity"], 0) + 1

    timestamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    output = {
        "audit_metadata": {
            "script_version": "1.0",
            "accounts_processed": len(accounts),
            "audit_timestamp": timestamp,
            "findings_count": counts,
        },
        "findings": all_findings,
    }

    with open(output_file, "w", encoding="utf-8") as fh:
        json.dump(output, fh, indent=2)

    # Human-readable summary
    print(f"Accounts processed : {len(accounts)}")
    for s in severity_order:
        label = f"{s} findings"
        print(f"{label:<20}: {counts[s]}")

    print()
    for severity in severity_order:
        sev_findings = [f for f in all_findings if f["severity"] == severity]
        if sev_findings:
            print(f"{severity}:")
            for f in sev_findings:
                print(f"  [{f['finding_id']}] {f['account']}: {f['title']}")
            print()

    return output


if __name__ == "__main__":
    run_audit()
