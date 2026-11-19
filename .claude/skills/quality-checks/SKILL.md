---
name: quality-checks
description: Use when you need to run the project's quality tools - install, build, format check, lint, typecheck, tests - or decide whether work is allowed to be committed. Provides the gate definitions, which role runs which gate, and how to interpret failures.
user-invocable: false
---

<!-- CUSTOMIZE: the actual commands live in ONE place: the "Commands" table in
     CLAUDE.md. Do not copy them here. Edit this file only to add extra gates
     (for example a migration check, a generated-code freshness check, a
     security scanner) or to change which role runs what. -->

# Quality Checks

## Where the commands are

Every command comes from the **Commands** table in `CLAUDE.md`. If a row you need still says `TODO`:

1. Detect it from the project (`package.json` scripts, `Makefile`, `pyproject.toml`, `Cargo.toml`, `*.csproj`, CI config).
2. If you cannot determine it with confidence, ask the user.
3. Record the answer in the `CLAUDE.md` table so nobody has to detect it again.

If a tool genuinely does not exist for this project (for example no typechecker), the row says `n/a` and the gate is skipped. If the project has **no tests at all**, say so plainly; do not report a test gate as passing.

## Gates

| Gate | Commands (rows in CLAUDE.md) | Run by |
|---|---|---|
| **Static** | build, format check, lint, typecheck | engineer, reviewer, QA |
| **Developer tests** | unit tests (plus integration tests when the change touches storage, network, or more than one module) | engineer |
| **Full suite** | every test in the project, including QA tests | engineer before handoff, QA, merge step |
| **QA tests** | the QA-owned tests for one ticket | QA |

The reviewer runs the static gate only. Reading the tests is the reviewer's job; running them is the engineer's and QA's.

## Build reuse

- Builds are incremental. Never delete build output, caches, or dependency folders to "start clean" unless a failure clearly points at a stale artifact.
- Do not reinstall dependencies unless the lockfile changed.
- Do not restart running services unless one is unhealthy.

## Interpreting results

- **A warning is a failure** if the project treats warnings as errors. Otherwise report new warnings introduced by the diff.
- **Format check failing**: run the formatter, then re-run the check. Never hand off unformatted code.
- **A failing test is yours until proven otherwise.** To call it pre-existing you need both: the test and the code it covers are untouched by the branch, and the test's whole file or class fails the same way on the base branch.
- **Flaky**: a test that passes on re-run without a code change. Report it by name; do not silently retry until green.
- Never disable, skip, or loosen a check to get past a gate. If a check is wrong, say so and ask.

## Pre-commit checklist (engineer)

1. Build succeeds with no new warnings.
2. Format check clean.
3. Lint clean.
4. Typecheck clean.
5. Developer tests pass.
6. Full suite passes.
7. No secrets, debug output, or stray files in the diff (`git status`, `git diff --stat`).

Never commit if any step fails. Report the gate as `PASS` only if every applicable step passed in this session; otherwise `FAIL` with the step and the output.
