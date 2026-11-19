---
description: Adversarial QA on a ticket, or drain the qa column
argument-hint: "[ticket ID | column]"
---

Run adversarial QA on a ticket. Delegate to the **qa-engineer** subagent; it owns the QA method and keeps its detailed work out of this conversation.

## Resolve the target

- If `$ARGUMENTS` names a ticket (for example `T-012`), QA that ticket. Make sure its branch is checked out.
- If `$ARGUMENTS` is `column` or `drain`, work the `qa` column one ticket at a time, oldest ID first, checking out each ticket's branch in turn.
- If `$ARGUMENTS` is empty, target the current branch (`git rev-parse --abbrev-ref HEAD`). If the branch name is a ticket ID, QA that ticket. Otherwise tell the user QA needs a ticket (it verifies acceptance criteria) and ask which one.

The ticket should be in `qa` with an APPROVED review newer than the last code change. If it is not, tell the user and ask before continuing.

## Delegate

Hand the resolved target to the qa-engineer subagent. Pass the engineer's `HANDOFF:` line if available, and the known test baseline on the base branch if you have it (passed, failed, total, and any accepted failures by name), so QA does not have to recompute it.

The QA engineer builds and runs the code, runs the full suite, writes adversarial and regression tests, verifies every acceptance criterion, files bug tickets for out-of-scope defects, writes the detailed report into the ticket, and returns one compact verdict line. Surface that line plus any bug IDs; do not re-run what QA already covered.

Next step: `/ship` on QA PASS, `/imp` on QA FAIL.
