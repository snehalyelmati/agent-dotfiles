---
name: ticket-review
description: Review one ticket against approved decisions and code, then apply only approved ticket corrections.
disable-model-invocation: true
---

# Ticket review

Ticket and design review with targeted code inspection. Not a security
audit, feature acceptance, or implementation. Read-only until ticket
edits are approved; run existing tests only when the invocation says so.

Input: a ticket URL or number. Optional: repository, spec links,
decision records to follow (e.g. `#91 #73 #80`), a session checkpoint.

## 1. Establish the baseline

Record the commit hash, working-tree state and time the review reflects.

Read the ticket body, comments, parent and dependencies with their live
state. Follow decision links (Wayfinder tickets, decision maps, ADRs,
approved plans) to the resolution text. Read the implementation docs
and the code, callers, config and tests each acceptance item touches.

Later explicitly approved revisions supersede earlier proposals. A newer
timestamp, existing code or a checkpoint is evidence, not approval.

Done when every acceptance item maps to a current decision or a named
missing/conflicting decision. If a gap forces a policy guess, finish
everything else, then ask.

## 2. Evidence

For each acceptance item, trace the real code path and label it
shipped, partial, missing or defective, with file:line.

Where one owner hands off to another, note which steps run
synchronously and which are spawned or deferred.

Follow each failure code from where it is raised to the text the user
sees.

For each test or journey the ticket relies on, check whether its
fixture bypasses the owner under test.

Reopen every cited line before quoting it. Mark sub-agent findings
"reported, not re-verified". Mark each defect "verified by reading" or
"reproduced".

## 3. Seven checks

1. Alignment: the ticket follows the current approved baseline.
2. Outcome: what users experience, and what counts as complete.
3. Constraints: which limits are approved policy and which are
   prototypes, old constants or implementation quirks. Prompt wording
   and numeric guidance count as policy.
4. Alternatives: a concrete simpler or safer replacement for each
   constraint worth changing.
5. Scope: dependencies and ownership are correct; each new behavior
   names its existing owner. Moving an in-scope obligation needs an
   explicit blocker and approval.
6. Safety: correctness, security, preservation, recovery and
   validation. Authorization, failure/retry, concurrency, restart,
   stale results, truthful status.
7. Reuse: which code and tests stay useful, which historical bugs or
   obsolete semantics must go.

Report substantive findings and state which checks passed and why.
A policy change shows original, replacement, reason, tradeoffs and
validation.

Done when each recommendation has a reopened file:line, a label from
§2 and one observable acceptance case.

## 4. Present

Every line answers "so what". Order and shape:

```
Verdict: two sentences. Is the ticket sound, and what is the real gap.
Dependencies: live state of blockers, one line each.
What the user gets: three lines, one per transition, plain language.
Already shipped (do not rebuild): one line per item, with ticket refs.
Defects (label per §2):
  N. One-line title.
     Why: mechanism, with file:line.
     User sees: the visible effect.
     Fix: one line.
  Top two defects in full; the rest one line each.
Ticket edits: keyed to the ticket's own section headers, each naming
  the defect it resolves.
Validation: proposed vs performed.
Checks passed. Policy changes: none or list. Deferred: none or list
  with reasons. Manual interaction: none or actions and affected data.
Inspected: sources and the §1 snapshot.
Approve these ticket edits?
```

## 5. Apply and verify

After approval: re-fetch; a conflict with the approved proposal returns
for clarification. Apply one focused body edit preserving unrelated
sections, references and handoffs; leave other tickets, links, labels
and state unchanged. Re-fetch and confirm the saved text matches.
Return the link and validation limitations, then stop.

Scoring two reviews of one ticket: see [RUBRIC.md](RUBRIC.md).

## Checkpoint (on request)

Repository and ticket, source links, verified edits, proposals awaiting
approval, unresolved gaps, next action. Project facts live in the
records, not here; the next session re-fetches.
