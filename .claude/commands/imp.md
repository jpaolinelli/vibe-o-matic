---
description: Implement one ticket (engineer only, no review or QA)
argument-hint: "[ticket ID]"
---

Implement a ticket end to end. Delegate to the **engineer** subagent; it owns the implementation workflow and keeps its detailed work out of this conversation.

## Resolve the ticket

- If `$ARGUMENTS` names a ticket (for example `T-012`), implement it.
- If `$ARGUMENTS` is empty, derive the ticket from the current branch name (`git rev-parse --abbrev-ref HEAD`); branches are named after their ticket. If the branch is the base branch or has no ticket ID, ask the user which ticket to implement. Do not guess.

Check the ticket's status with the `tickets` skill first:

- `pending`: a fresh implementation.
- `in-progress`: resume, or fix the newest review or QA findings recorded in the ticket's Activity. Pass those findings along.
- `review`, `qa`, or `done`: tell the user where it is and stop.

## Delegate

Hand the resolved ticket to the engineer subagent.

The engineer creates the branch, writes the code and developer tests, runs the quality gate, commits, moves the ticket to `review`, and returns two compact lines (`IMPL ...` and `HANDOFF: ...`). Surface those lines; do not re-read the diff it already produced. Tell the user the next step is `/review`.
