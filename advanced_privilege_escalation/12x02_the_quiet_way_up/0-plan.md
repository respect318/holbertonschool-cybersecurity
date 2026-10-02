# Escalation Assessment Plan — FDS-ETL-02

## Finding more than one road
After the first path to root is confirmed, I will not stop there. I will
return to the same enumeration surface (SUID/SGID binaries, sudo rules,
capabilities, timers, cron, writable service files, group membership)
and ask which of the remaining findings still offer an *unused*
privilege boundary — one the first path did not already cross. A second
finding only counts as a genuinely independent road if it relies on a
different root cause: a different misconfigured permission, a different
trusted binary, or a different account/group path, not merely a
different command that reaches the same broken sudo rule or the same
writable file the first path already exploited. If two paths bottom out
at the same underlying flaw (e.g. the same writable binary reached via
two different invocations), they count as one road, not two.

## Assessing visibility per path
Technique knowledge alone cannot tell me whether Fenwick's monitoring
saw a given escalation — only their own records can. For each
confirmed path, immediately after execution, I will check `auditctl -l`
for the rules in effect, then `ausearch` filtered to the relevant
timestamp, UID, and syscall/executable to see whether that specific
action was captured. I will record the exact query and its result
alongside the path, not a general impression of whether the technique
is "typically logged."

## What I will not run
I will not install or run linpeas, LinEnum, linux-exploit-suggester, or
any automated enumeration framework. These generate heavy, bursty
filesystem and process activity that is exactly the kind of noise a
live SOC is tuned to flag, and running one would itself become the
loudest event in the log I am supposed to be assessing quietly.

## After root
Root is a milestone, not the finish line. Each confirmed path still
needs its visibility assessed and documented, and I continue searching
for additional independent roads until I can defend having three. Only
then do I compare all paths' audit footprints to identify the quietest.
