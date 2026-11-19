---
name: code-review-process
description: Use when performing a code review. Provides the structured review method - completeness against acceptance criteria, ground-rule sweep, security, reusability, code quality, and test quality - plus the verdict rules and re-review process.
user-invocable: false
---

<!-- CUSTOMIZE: Step 3 sweeps the Ground Rules in CLAUDE.md, so project rules
     belong there, not here. Add stack-specific checks to Steps 4 to 6 (for
     example: N+1 queries, React server/client boundaries, accessibility). -->

# Code Review Process

The review answers four questions, in this order: Did the engineer do everything the ticket asked? Is it safe? Does it reuse what already exists? Is it well made?

## Step 1: Read all changed files

```bash
git diff --name-only <base>...HEAD
git diff --stat <base>...HEAD
```

`<base>` is the base branch from `CLAUDE.md`. Before reading, run the **static gates only** (build, format check, lint, typecheck) from the `quality-checks` skill. Do not run test suites; see Step 7.

Read every changed file completely. Read outside the diff only to check for an existing helper the change should have reused or a caller the change might break.

## Step 2: Completeness (acceptance criteria cross-check)

| Criterion | Status | Evidence |
|---|---|---|
| text of the criterion | PASS / WARN-LOW / WARN-MED / FAIL | file, function, component, or test name |

- Every acceptance criterion in the ticket appears in the table. None may be omitted.
- Every `Implementation Checklist` item is ticked and actually present in the diff.
- Nothing in the diff is outside the ticket's scope. Unrequested changes are a finding.
- Docs were updated if behavior, setup, or architecture changed.
- The engineer's handoff matches what the diff really contains.

## Step 3: Ground-rule sweep (blocking if violated)

Check each numbered Ground Rule in `CLAUDE.md` against the diff and record PASS or FAIL for each. Any FAIL is blocking, whatever the size of the change.

## Step 4: Security

- **Input**: everything from outside the program is validated before use. No string-built SQL, shell commands, file paths, or HTML from untrusted input.
- **Authentication and authorization**: every new entry point checks who is calling and whether they may do this. Check that one user cannot reach another user's data by changing an ID.
- **Secrets**: no keys, tokens, or passwords in code, tests, fixtures, logs, or error messages. Nothing sensitive returned by an endpoint that does not need to return it.
- **Data exposure**: errors do not leak internals (stack traces, queries, file paths). Logs contain no personal data or credentials.
- **Dependencies**: any new dependency is necessary, maintained, and was named in the design or justified in the handoff.
- **Destructive operations**: deletes and overwrites are intentional, scoped, and reversible or confirmed.
- **Defaults**: new features fail closed; debug or bypass switches are not left on.

## Step 5: Reusability

- Does the diff duplicate something that already exists in the codebase? Search before deciding.
- Is the same logic written more than once inside the diff?
- Is new shared logic placed where the next person would look for it, or buried in a feature file?
- Is anything generalized beyond what the ticket needs? Unused flexibility is a finding too.
- Does it follow the project's existing patterns rather than introducing a parallel way of doing the same thing?

## Step 6: Code quality

Correctness, error handling, null and empty handling, edge cases, naming, function size, readability, concurrency and async correctness, resource cleanup, performance traps (work inside loops, unbounded queries), dead code, leftover debug output, and consistency with `docs/conventions.md`.

## Step 7: Test quality

**Read the tests; do not run them.** Suite execution belongs to the engineer's gate and to QA. For each test ask:

- Does it assert what the acceptance criterion actually claims, or only that the happy path does not throw?
- Would it fail if the implementation were wrong?
- Does it cover the failure mode as well as the success?
- Are edges covered: empty, one, many, invalid, missing, duplicate, unauthorized?

A green suite tells a reviewer nothing that reading cannot.

**Never inherit a failure classification.** "Pre-existing" and "known flake" are claims to verify, not facts to accept, whether they come from the engineer, a handoff line, or the orchestrator. Verify both ways: `git diff --name-only <base>...HEAD` shows the test and the code it covers are untouched, **and** the test's whole file or class fails the same way on the base branch. Running a single test in isolation proves nothing; an order-dependent regression passes alone and fails beside its siblings.

## Step 8: Output

Write the detailed review using [`review-template.md`](review-template.md) and append it to the ticket's Activity section. With pull requests on, also post it as a pull request comment. Return only the compact line to whoever invoked you.

## Severity

- **High**: wrong behavior, unmet criterion, ground-rule or security violation, data loss risk, missing test for a criterion. Blocking.
- **Medium**: real defect in an edge case, meaningful duplication, weak test that would not catch a regression. Two or more are blocking.
- **Low**: naming, style, minor clarity. Never blocking.

## Verdict rules

- **APPROVED**: all criteria PASS or WARN-LOW; ground rules clean; no High; at most one Medium.
- **CHANGES REQUESTED**: any High, any ground-rule or security violation, any criterion FAIL, or two or more Medium.

Then move the ticket (`tickets` skill): APPROVED moves it to `qa`; CHANGES REQUESTED moves it back to `in-progress`. Commit the ticket file.

## Re-review

Reviews are numbered v1, v2, and so on. v2+ is scoped: trust the earlier verdict on everything the fix did not touch. Read only the delta (`git diff <previously-reviewed-sha>...HEAD`) plus the code the earlier blocking issues named, re-run the static gates, confirm each prior issue is resolved, and scan the delta for new problems.
