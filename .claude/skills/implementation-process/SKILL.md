---
name: implementation-process
description: Use when implementing a ticket. Provides the step-by-step process for understanding the ticket, coding each checklist step, writing tests, passing the quality gate, and handing off to review, plus how to handle review and QA feedback.
user-invocable: false
---

<!-- CUSTOMIZE: under "2. Implement", add the build order for your stack
     (for example: schema, then API, then UI) and any rule every change must
     follow (feature flags, generated clients, migrations). -->

# Implementation Process

## Before writing code

1. Read the ticket (see the `tickets` skill): every acceptance criterion, the checklist, out of scope, the epic, and the design doc section it points at.
2. Read `docs/conventions.md` and `docs/testing.md`. Read `docs/architecture.md` if you do not already know where this change belongs.
3. Find the code you will touch and the nearest existing example of the same kind of thing. **Search for existing helpers, components, and utilities before writing new ones.**
4. If any criterion is ambiguous or conflicts with the code or the design, stop and ask. Do not guess.

## Per checklist step

### 1. Understand

Identify the files to create or modify for this step. If the ticket has no checklist, write your own ordered steps into the ticket's `Implementation Checklist` before starting.

### 2. Implement

- Follow the patterns in neighbouring files and `docs/conventions.md`.
- Keep the change inside the ticket's scope. If you find a bug or mess outside scope, note it in your handoff; do not fix it here.
- Handle the failure paths the ticket specifies, not only the happy path.
- Validate anything that comes from outside the program (user input, files, network, environment).
- No secrets, keys, or passwords in code or tests. Use configuration.
- No dead code, commented-out code, debug prints, or TODOs without a ticket ID.

### 3. Test

- Write tests alongside the code, in the developer test location from `CLAUDE.md`.
- Cover each acceptance criterion with at least one test that would fail if the criterion were not met.
- Cover the edges: empty, one, many, invalid, missing, duplicate, unauthorized.
- Fixing a bug: first write a test that reproduces it and fails, then make it pass.
- **Do not add or change files in the QA-owned test location.**
- Do not write trivial tests to raise coverage. A test that cannot fail is noise.

### 4. Tick the step

Mark the checklist item `- [x]` in the ticket.

## Finalization (after all steps)

1. Run the full pre-commit gate from the `quality-checks` skill. Do not continue if any step fails.
2. Re-read each acceptance criterion and confirm you can point at the code and the test that satisfy it.
3. Update `docs/` if behavior, setup, or architecture changed.
4. Move the ticket to `review` (`tickets` skill).
5. Commit code, tests, docs, and the ticket file together (`git-workflow` skill).
6. With pull requests on: push and open the pull request.
7. Append the handoff to the ticket's Activity, then stop and wait for review.

## Handling review or QA feedback

The ticket is back in `in-progress` with a report in its Activity section.

1. Read the newest report. Address every blocking issue; do not argue with one by ignoring it. If you believe an issue is wrong, say why in your handoff.
2. A QA failure comes with a failing test in the QA test location. Make it pass by fixing the implementation. **Never edit, skip, or delete a QA test to make it pass.**
3. Re-run the full gate.
4. New commit (never amend), move the ticket back to `review`, append a handoff that lists each issue and how it was resolved.

## When to ask the user

- An acceptance criterion is ambiguous or untestable.
- There are several valid approaches with different trade-offs.
- The ticket conflicts with existing code, the design, or a ground rule.
- You would need to change code outside the ticket's scope.
- The change would delete data, alter a public interface, or add a new dependency the design did not mention.
