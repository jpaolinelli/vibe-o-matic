---
name: qa-process
description: Use when performing QA on a ticket. Provides the method for running the real thing, executing the full regression suite, writing adversarial and regression tests designed to break the implementation, verifying each acceptance criterion, classifying findings, and filing bugs.
user-invocable: false
---

<!-- CUSTOMIZE:
     - Step 2: how to start your app or stack for QA (commands live in CLAUDE.md).
     - Step 5: add attack categories specific to your domain (for example
       multi-tenant isolation, feature flags off, third-party API faults,
       money rounding, time zones, offline mode).
     - Step 9: severity definitions.
     JIRA: Step 10 files bugs through the tickets skill, so it needs no change. -->

# QA Process

## Philosophy

QA runs the code and tries to break it. Every function, endpoint, and screen is guilty until proven innocent. A reviewer reads; QA executes. "It looks right" is not a QA result.

## What QA does not do

- Does not fix implementation bugs. It proves them with a failing test and sends the ticket back.
- Does not modify or delete developer tests. If a developer test is wrong, that is a finding.
- Does not review style. That is the reviewer's job.
- Does not weaken, skip, or delete a QA test to get to PASS.
- Does not touch production systems or real user data.

## Step 1: Understand the ticket

Read the ticket (`tickets` skill). Turn every acceptance criterion into a testable claim. For each claim ask: what input breaks it, where are the boundaries, and what should happen on failure?

## Step 2: Build and run

Using the commands in `CLAUDE.md`: install if needed, build, and start the app or the part of it this ticket touches. If it does not build or start, that is an immediate QA FAIL.

## Step 3: Regression run (do this before writing anything)

Run the **full** existing test suite on the branch. Compare with the known baseline if one was handed to you.

- Any test that fails on the branch and passes on the base branch is a regression: Critical or High.
- Do not accept "pre-existing" or "flaky" on anyone's word. Prove it: the test and the code it covers are untouched in `git diff --name-only <base>...HEAD`, **and** the test's whole file or class fails the same way on the base branch. A single test passing in isolation proves nothing.

## Step 4: Read the implementation as an attacker

`git diff --name-only <base>...HEAD`, and read only those files. You are looking for bugs, not style: unvalidated inputs, unchecked return values and errors, missing authorization checks, off-by-one boundaries, unhandled empty or null, race conditions, resource leaks, assumptions about ordering, time zones, encodings, and sizes.

## Step 5: Write adversarial tests

Write them in the QA-owned test location from `CLAUDE.md`, named after the ticket (for example `qa_T-012_signup`). One attack per test, a descriptive name that states the attack, and an assertion on a specific expected outcome.

Attack categories; use every one that applies:

- **Boundaries**: zero, one, two, maximum, maximum plus one, negative, empty string, whitespace only, very long, very large numbers.
- **Invalid input**: wrong type, malformed format, missing required fields, extra unexpected fields, null, mixed encodings, unicode, emoji, control characters.
- **Injection**: SQL, shell, path traversal (`../`), HTML and script, template syntax, in every field that accepts text.
- **Authentication and authorization**: no credentials, expired credentials, another user's ID, a lower-privilege role, direct access to a URL or function that the UI hides.
- **State and ordering**: do the steps out of order, twice, or halfway; submit the same request twice; act on something already deleted; go back after completing.
- **Concurrency**: two actors doing the same thing at once; an update during a read.
- **Dependency failure**: the database, network, file, or external service is slow, down, returns an error, or returns garbage.
- **Data volume**: empty collections, one item, thousands of items, pagination edges.
- **Idempotency and retries**: the same operation repeated gives the same result with no duplicates.
- **Persistence**: data survives a restart; a failed operation leaves nothing half-written.
- **User interface** (when there is one): keyboard only, tiny and huge viewport, double-click on submit, slow network, back and refresh mid-flow, error states actually render.

If the project has no automated UI testing, exercise the UI by hand (or with the browser tools available to you) and record exactly what you did and saw.

## Step 6: Write regression tests

- For every acceptance criterion that the developer tests do not genuinely prove, add a QA test that does.
- For every bug you find, the failing test you wrote **is** the regression test. It stays in the suite permanently.
- For a `bug` ticket: confirm a test exists that fails without the fix and passes with it. Check by reading the test against the pre-fix behavior; if in doubt, revert the fix locally, watch it fail, then restore.

## Step 7: Run the QA tests

Run the ticket's QA tests, then the full suite once more with them included. Every QA test either passes (the implementation survived the attack) or fails (a finding). A QA test that fails because the test itself is wrong must be fixed before reporting.

## Step 8: Verify acceptance criteria

| Criterion | Test(s) | Verified | Notes |
|---|---|---|---|

A criterion is verified only by a passing test you ran or a manual check you performed and recorded. "The code appears to" is not verification.

## Step 9: Classify findings

- **Critical**: data loss or corruption, security hole, secret or private data exposed, crash on a normal path, regression in existing behavior.
- **High**: acceptance criterion not met, crash on a plausible edge case, wrong results.
- **Medium**: edge-case failures with a workaround, validation gaps without security impact, confusing error handling.
- **Low**: cosmetic.

## Step 10: Handle findings

- **Defect in this ticket's work** (any Critical or High): verdict is QA FAIL. The ticket goes back to `in-progress` with the findings and the names of the failing tests in its Activity. Do not file a separate bug.
- **Defect outside this ticket's scope** (already broken on the base branch): file a `bug` ticket in `pending` through the `tickets` skill, using the bug template, and name the reproducing test. It does not fail this ticket.
- **Medium and Low**: report only. File a bug for a Medium if the user would plausibly hit it.

A failing QA test for an out-of-scope bug must not break the suite for everyone: mark it as an expected failure or skip it with the bug ID in the reason, using your test framework's mechanism, and say so in the bug ticket.

## Step 11: Commit

Commit the QA tests and the ticket file to the ticket branch (`git-workflow` skill). With pull requests on, push.

## Step 12: Report

Fill in the report from [`templates.md`](templates.md) and append it to the ticket's Activity (and the pull request when on). Return only the compact line to whoever invoked you.

## Verdict

- **QA PASS**: builds and runs; full suite green with no regressions; every acceptance criterion verified; no Critical or High findings. The ticket **stays in `qa`**; merging and `done` belong to the orchestrator or the human.
- **QA FAIL**: anything else. Move the ticket to `in-progress`.
