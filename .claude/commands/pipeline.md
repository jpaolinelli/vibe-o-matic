---
description: Run one ticket through engineer, review, and QA
argument-hint: "<ticket ID>"
---

Run the full implement, review, QA pipeline for ticket: $ARGUMENTS

Each phase runs as an isolated subagent so this conversation stays small. You are the orchestrator: you delegate, pass handoffs along, and enforce the gates. You do not write code, review, or test yourself.

<!-- CUSTOMIZE: the retry budget (2 fix cycles per phase) and whether the
     pipeline ends by asking to merge are the two knobs worth tuning. -->

## Before starting

1. If `$ARGUMENTS` is empty, use the ticket ID from the current branch name, or ask.
2. Read the ticket's status with the `tickets` skill and enter the pipeline at the matching phase: `pending` or `in-progress` at Phase 1, `review` at Phase 2, `qa` at Phase 3. If it is `done`, say so and stop.
3. Confirm every ticket in `depends_on` is in `done`. If not, stop and say which.
4. Confirm the working tree is clean. If not, stop and ask.

## Phase 1: Implementation

Delegate to the **engineer** subagent with the ticket ID.

Wait for it to finish and capture both compact lines, **including the `HANDOFF:` line**. If it reports `gate:FAIL` or a blocker, **stop the pipeline** and surface it to the user.

## Phase 2: Code Review

Delegate to the **reviewer** subagent with the ticket ID, and **pass the engineer's `HANDOFF:` line in the delegation prompt**.

The reviewer runs only the static gates, then reads the diff: completeness against acceptance criteria, ground-rule sweep, security, reusability, code quality, and test quality judged by reading. It does not run test suites, so CHANGES REQUESTED never means "tests failed"; it means a defect, a violation, or an unmet criterion.

**If CHANGES REQUESTED:**

- Re-delegate to the engineer: fix the listed review issues on the ticket branch. Capture the new `HANDOFF:` line.
- Re-run the reviewer as a **scoped** re-review (v2+): pass the previously reviewed commit and the blocking-issue list.
- Maximum 2 fix-and-review cycles. If still CHANGES REQUESTED, stop and surface to the user.

**If APPROVED:** continue.

## Phase 3: QA

Delegate to the **qa-engineer** subagent with the ticket ID, and **pass the newest `HANDOFF:` line**.

If you know the test baseline on the base branch (passed, failed, total, and named accepted failures), pass it too, so QA does not rerun the base branch just to compute a difference. QA must still prove any "pre-existing" label itself.

**If QA FAIL:**

- Re-delegate to the engineer: make the named failing QA tests pass by fixing the implementation, without editing QA tests.
- Re-run the reviewer as a scoped re-review of the fix, then re-run QA.
- Maximum 2 fix cycles. If still failing, stop and surface to the user.

**If QA PASS:** continue. The ticket stays in `qa`.

Review and QA always run one after the other, never in parallel: both write to the same ticket file on the same branch.

## Phase 4: Final Report

```
## Pipeline Report: <TICKET>

### Implementation
- Branch: <name>   Commit: <sha>   PR: <url or none>
- Status: <complete | issues>

### Review
- Verdict: APPROVED (v<N>)   Issues fixed: <N>

### QA
- Verdict: QA PASS | QA FAIL
- QA tests written: <N>   Bugs filed: <list or none>

### Final Status
<all phases passed, ready to ship | action needed: ...>
```

Then, if every phase passed: with `Merge policy: ask`, ask the user whether to run `/ship <TICKET>` now; with `auto`, run it.

## Notes

- Only compact return lines (plus the `HANDOFF:` line) flow back here. Detailed reviews and QA reports live in the ticket file. Do not re-read what a subagent already summarized.
- Thread the newest `HANDOFF:` line into every review and QA delegation.
- Build outputs are incremental across phases; subagents must not wipe them.
- If any subagent asks a clarifying question, surface it to the user immediately and pause the pipeline.
- One ticket at a time. Never run two pipelines at once in the same checkout.
