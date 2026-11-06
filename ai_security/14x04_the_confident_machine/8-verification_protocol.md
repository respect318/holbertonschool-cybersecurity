# 8. Protocol: checking an AI claim before you act on it

Fluency is not evidence. A confident, well-formatted answer only tells you the
model produced probable-sounding text; it tells you nothing about whether the
text is true. Before acting on any assistant output, run it through three
questions in order: what kind of claim is this, what would settle it, and what
do I do when nothing available settles it. The steps below are keyed to the
*kind* of claim, not the job you are doing, so they still work the first time
the assistant fails in a way you have not seen before.

## Step 1 — Name the class of claim

1. **Fabrication.** A specific fact the model may simply not have: an identifier,
   an indicator, a name, a number, a citation. Settle it against an authoritative
   list that is independent of the model — a reference index, a corpus, a
   register. If the item is not in the source of record, it does not exist for
   you, however confidently it is stated.
2. **Plausible-but-wrong.** Output that is valid and reads exactly like the thing
   it names but does the wrong thing: a rule, a query, a script, a config.
   Reading it only tests your own mental model, not the data. Run it against
   known-good and known-bad inputs and read the result.
3. **Omission / over-reach.** A verdict that is confident because it leaves
   something out, or a firm conclusion drawn from evidence that does not carry
   it. Re-read the input itself, field by field, against what the entity
   involved is supposed to be (the baseline), and ask what the evidence actually
   supports versus what the output asserts.
4. **Miscalibration.** A true raw fact wrapped in a stronger claim than it earns
   ("confirmed", "high confidence", "the attacker"). Separate the fact from the
   verdict: count or quote what is actually there, and write the version the
   evidence supports.
5. **Unsafe-by-construction.** The fast, efficient path sends data somewhere it
   must not go. This is not about truth at all — check *where the data is going*
   before you send it, not after.

## Step 2 — Decide what would settle it

Every class above points at a different source of truth: a reference list for a
fact, the log itself for what happened, a baseline for what a host is, a test
run for whether a rule fires, the contract for where data may go. The rule is
the same each time: the thing that settles a claim is a source **independent of
the model** that you can check directly. Use it. Do not let the model confirm
its own claim (asking it for its source is not verification), and do not treat
the absence of a contradiction as proof.

## Step 3 — When nothing available settles it

Some claims are genuinely open. When no independent source settles one, say so:
label it unverified, keep it out of anything that asserts it as fact, lower the
confidence of the deliverable, and escalate to the person who owns the source
rather than guessing. Do not accept it because it sounds right, and do not throw
it out because you cannot check it — both are failures.

## What the protocol costs, and where the line is

Verifying every output is not a protocol; it is a refusal with steps, and the
floor will stop using it by Tuesday. The cost of a check is real: a lookup is
minutes, a test run is longer, and doing it to everything would hand back the
exact speed the tool exists to give you.

**The check is mandatory when:**
- the output leaves the building — a client report, an indicator set someone
  will hunt on;
- it triggers an action that is hard to undo — isolating a host, disabling an
  account, holding a wire;
- the claim is a specific fact that cannot be self-evident — an identifier, an
  attribution, a count that appears in a report, a date;
- the output is a detection or a fix you will rely on to tell you you are
  covered;
- **always** before regulated or client data goes anywhere near a third party.

**Speed is worth the risk when** the output is a restructuring of your own notes,
a draft you will rewrite anyway, a plain restatement you can confirm against the
input in seconds, or something low-stakes and easily reversed. Reworking a
correct answer there costs you the speed the tool exists for, and that
over-distrust is a measured failure, not a safe default — an analyst who
distrusts everything is just a slow one who is also sometimes wrong.

## Keep score

Log every output you evaluate, the accepted ones included, and compute both
edges — what you missed and what you rejected that was right. Tone is not a
signal: the wrong outputs read exactly as confidently as the right ones, so only
the source check separates them. The log is how you tune the rate you check at,
because a check rate is only worth keeping if it catches what actually matters.
