---
description: Autonomous worker - drain the pending queue through the pipeline, one ticket at a time
---

Start the autonomous ticket-queue worker: take every ready ticket in `pending` through `/pipeline`, merging work that passes, until the queue is empty.

<!-- CUSTOMIZE: this merges without asking once review and QA pass, regardless
     of "Merge policy". If you want a human to approve each merge, delete
     Step 4's merge and have the loop stop after each pipeline instead.
     JIRA: Step 1 picks the next ticket with the tickets skill; with Jira that
     skill supplies the JQL, so only the wording of the status names changes. -->

Invoke the Skill tool now with `skill: "loop"` and **no interval** (self-paced), passing the entire **Loop Prompt** section below, verbatim, as the args. Do not paraphrase or shorten it. If the `loop` skill is not available, run the Loop Prompt as back-to-back iterations in this conversation instead.

## Loop Prompt

You are the autonomous ticket-queue worker for this project. Each time this prompt fires, advance the queue by exactly one step, then either schedule the next wakeup or end the loop. Every iteration is self-contained: re-derive the current state from the board and git; do not rely on memory of earlier iterations.

### Step 0: State check (cheap, do this first)

1. If a pipeline or its subagents from a previous iteration are still running, do not start anything new. Schedule a long wakeup (1800s) and end this iteration.
2. Run `git status --short` and `git branch --no-merged <base>`. If a ticket branch is unmerged, that ticket is in flight: check it out, read its status with the `tickets` skill, and resume it at Step 3 (the pipeline enters at the right phase) or Step 4 (if it already has QA PASS). Do not pull new work.
3. If the working tree is dirty on the base branch, stop and ask.

### Step 1: Pick the next ticket

Do this inline with the `tickets` skill: ask for the next ready ticket (lowest priority number, then lowest ID, all dependencies in `done`). If nothing is ready because everything left is blocked, report the blockers and END THE LOOP. If `pending` is empty, post a summary of everything merged this run and END THE LOOP (do not schedule another wakeup).

### Step 2: Announce

One line: which ticket is starting and how many remain.

### Step 3: Run the pipeline

Run `/pipeline <TICKET-ID>` and wait for it to finish completely. While waiting, use long wakeups (1800s); never poll on short intervals.

### Step 4: Merge gate

Merge only if all of these hold in the pipeline report and the ticket file:

- Review verdict: APPROVED
- QA verdict: QA PASS, on the current head
- With pull requests on: CI is green and the pull request is mergeable

If all gates pass, follow "Merging a finished ticket" in the `git-workflow` skill: move the ticket to `done` on the branch, squash-merge, delete the branch, and run the full suite on the base branch. Then report: ticket ID, merge commit, bugs filed, tickets remaining.

If any gate fails (CHANGES REQUESTED or QA FAIL after the pipeline's retry budget, CI red, merge conflict): do not merge. Leave the ticket where it is, report exactly what failed and why, ask the user how to proceed, and do not pull new tickets until they answer.

### Step 5: Continue

After a successful merge, schedule the next wakeup (60s) and repeat from Step 0.

### Step 6: Stranded-ticket sweep (every tenth iteration, and before ending the loop)

List the `in-progress`, `review`, and `qa` columns on the base branch. Anything sitting there with no unmerged branch behind it is stranded: nothing in this loop will ever pick it up again. For each, decide and report rather than leaving it: work that already merged should be moved to `done` (verify the commit is really on the base branch first); anything genuinely open is reported to the user. Run the board check and report any problem. Never move tickets in bulk without saying which.

### Token discipline (hard requirements)

- One ticket and one pipeline at a time. Never parallelize tickets.
- Do trivial board and git operations inline. Only the pipeline phases (engineer, reviewer, QA) run as subagents.
- Keep orchestration turns short: no exploratory reading, no redundant builds, no re-verifying what the pipeline already verified.
- While anything is running in the background, wakeups are 1800s minimum.
- If you see signs of rate limiting or usage limits, stop immediately and tell the user rather than retrying.

### Safety rules

- Never force push. Never merge with a failing gate. Never amend commits.
- Never deploy, publish, or touch production as part of this loop.
- If the base branch is broken after a merge (build or tests fail), stop the loop and tell the user immediately.
- If anything is ambiguous (ticket selection, unexpected repository state, a flaky test, a ticket with unclear criteria), stop and ask instead of guessing.
