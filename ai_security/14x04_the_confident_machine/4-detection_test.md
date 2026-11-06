# 4 — Detection test for DET-GAP-41 (T1003.001 LSASS Memory)

Priya's instruction was not to review the rule but to run it. I did.

## The rule, as the assistant gave it (R-1)

```yaml
title: LSASS Memory Access by Non-System Process
id: 1bfb3b4e-d01c-445e-eb4c-3afed9f2a390
status: experimental
description: Detects a non-system process opening LSASS with access rights typical of credential dumping tools.
references:
    - https://attack.mitre.org/techniques/T1003/001/
author: Rainier SOC Assistant
date: 2026/04/17
tags:
    - attack.credential_access
    - attack.t1003.001
logsource:
    category: process_access
    product: windows
detection:
    selection:
        TargetImage|endswith: '\lsass.exe'
        GrantedAccess|contains:
            - '0x1010'
            - '0x1410'
            - '0x1438'
            - '0x143a'
            - '0x1fffff'
    filter_system:
        SourceImage|startswith:
            - 'C:\Windows\System32\'
            - 'C:\Program Files\Windows Defender\'
    condition: selection and not filter_system
falsepositives:
    - Security products and crash handlers
level: high
```

## The command I ran and the raw result

$ sigma-run rule.yml -v
rule : LSASS Memory Access by Non-System Process (1bfb3b4e-d01c-445e-eb4c-3afed9f2a390)
logsource : category=process_access product=windows
malicious : 0/12 matched
benign : 0/60 matched
RESULT: malicious_matched=0 malicious_total=12 benign_matched=0 benign_total=60 attest=0293c785b2d2afa3


## What that result means

The rule fires on **nothing**: 0 of 12 malicious samples and 0 of 60 benign.
It is not a noisy rule or a slightly-off rule — it is inert. It reads perfectly
and catches zero instances of the technique it names. Per Priya, that is worse
than no rule, because it would show as "coverage in place" while catching nothing.

## Why it fails, in terms of MITRE ATT&CK (not the rule's comment)

The rule looks for the wrong **event entirely**. Its `logsource` is
`category: process_access` (Sysmon Event ID 10), and its selection keys on
`TargetImage` and `GrantedAccess` — fields that only exist on a ProcessAccess
event, i.e. one process **opening a handle** into LSASS.

But the malicious samples are **ProcessCreate events** (`"EventID":1`), with
fields `Image`, `CommandLine`, `ParentImage` — and no `TargetImage` or
`GrantedAccess` field at all. So the rule's selection can never match them.
Concretely, the samples carry out T1003.001 by **dumping LSASS memory to disk**
with living-off-the-land tools:
- `rundll32.exe C:\Windows\System32\comsvcs.dll, MiniDump 556 ...lsa0.dmp full`
- `procdump64.exe -accepteula -ma lsass.exe ...p1.dmp`
- `powershell -c "rundll32 ...comsvcs.dll MiniDump (Get-Process lsass).Id ...l2.dmp full"`

MITRE ATT&CK defines **T1003.001 OS Credential Dumping: LSASS Memory** to cover
both ways of reaching LSASS credentials: opening the LSASS process to read its
memory (the handle-access path the rule targets) **and** dumping LSASS memory to
a file with tools such as comsvcs.dll MiniDump, ProcDump or Task Manager (the
command-line path the samples use). The assistant's rule covers only the first
sub-behaviour, and the red team here exercised the second. The rule's comment
claims it "covers the technique"; measured against MITRE's own definition of the
technique, it covers one sub-path and misses the one present in the environment —
which is why it catches nothing.

A rule that actually closed this gap would key on ProcessCreate (EID 1) and the
LSASS-dumping command lines (comsvcs.dll + MiniDump, procdump + lsass, etc.), or
combine both event types, rather than process_access alone.
