---
description: Merge a ticket that passed review and QA, and move it to done
argument-hint: "[ticket ID]"
---

Merge a finished ticket and move it to `done`. Do this inline; do not spawn a subagent.

<!-- CUSTOMIZE: add release steps here if merging should also deploy, tag a
     version, or update a changelog. -->

## Resolve the ticket

`$ARGUMENTS` if given, otherwise the ticket ID from the current branch name. If neither yields a ticket, ask.

## Verify the gates (all required)

Read the ticket with the `tickets` skill and check its Activity:

1. The ticket is in `qa`.
2. The newest review verdict is APPROVED.
3. The newest QA verdict is QA PASS.
4. No code commit is newer than the commit QA tested (`git log --oneline <tested-sha>..HEAD` shows only ticket-file commits).
5. The working tree is clean.
6. With pull requests on: CI is green and the pull request is mergeable.

If any gate fails, do not merge. Say exactly which gate failed and what the next command is.

## Confirm

If `Merge policy` in `CLAUDE.md` is `ask`, show the user the ticket, the two verdicts, and the diff stat, and ask for a yes before merging. If it is `auto`, proceed.

## Merge

Follow "Merging a finished ticket" in the `git-workflow` skill: move the ticket to `done` on the branch and commit, squash-merge into the base branch, delete the ticket branch, and run the full suite on the base branch.

If the suite fails on the base branch after the merge, stop and tell the user immediately. Do not start other work.

## Report

```
SHIPPED <TICKET> | merge:<short sha> | suite:<passed>/<total> | epic:<ID> <done>/<total tickets> | next:<ID of next ready ticket | none>
```

If this was the last open ticket of its epic, say so, and tick the epic's success criteria that can now be confirmed.
