# Reach Plan — Halcyon Freight

## Building the network picture
I cannot see this network all at once, so I will treat each host as a
vantage point rather than a target in itself: on landing, I enumerate
interfaces, routes, ARP/neighbor tables, and active connections
(`ip a`, `ip route`, `arp -a`, `ss -tulpn`, `/etc/hosts`) before doing
anything else on that host. Each new address or route I find gets
added to a running network map, and I re-derive what segment I am
actually standing in rather than assuming it from the engagement
narrative. The map only grows forward from what I've directly
observed; I do not infer a segment exists until something on the
current host actually shows me a path into it.

## What root is worth here
Root on an intermediate host is not the objective and I will not treat
reaching it as a milestone in itself. Its only value is what it
unlocks toward the distant file: credentials it exposes, a service it
lets me bind or forward through, or a trust relationship (an SSH
known_hosts entry, an agent socket, an NFS export) that only root can
read or use. If root on a host does not change what I can reach next,
I log that it was obtained and move on rather than lingering on it.

## What I look for beyond privilege
On every host, independent of whatever privilege I do or don't have, I
check: which other hosts it can already reach (routes, ARP cache, open
connections), what trusts it carries (SSH keys, agent forwarding,
mounted shares, stored credentials), and what services on it another
host trusts implicitly. These are the things that move me forward;
privilege alone does not.

## Transport discipline
Every tunnel is hand-built with SSH forwarding (local, remote, or
dynamic) or a standalone tunneller — never a C2 pivot feature. Before
trusting any tunnel, I verify where it actually terminates, not where
I intended it to. I keep a running, numbered list of every active
tunnel/hop with its direction and the host pair it connects, so the
path from my attack box to my current position is always written down
somewhere, not held in memory.

## Logging
From my first command, every action, network observation, and tunnel
change is logged with a UTC timestamp, the host I was on, and the
result, in a single running plaintext log file I append to as I go —
never reconstructed afterward.
