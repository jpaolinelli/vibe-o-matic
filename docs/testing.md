# Testing Guide

<!-- CUSTOMIZE: /setup fills this in. Keep the two test locations here in
     step with the Testing section of CLAUDE.md. The commands themselves live
     only in the Commands table in CLAUDE.md. -->

## Test Suites

| Suite | Location | Owner | Purpose |
|---|---|---|---|
| Unit | `TODO` | engineer | pure logic, fast, no network or database |
| Integration | `TODO` | engineer | real database, filesystem, or several modules together |
| End to end | `TODO` | engineer and QA | the running app, through its real interface |
| QA | `tests/qa/` | **QA only** | adversarial and regression tests, named after the ticket |

**Ownership is strict.** The engineer never adds, edits, skips, or deletes QA tests. QA never modifies developer tests. A failing QA test is fixed by fixing the implementation.

## Frameworks and Tools

TODO: test runner, assertion library, mocking approach, browser automation, coverage tool.

## Naming

TODO: file and test naming for developer tests.

QA tests are named after the ticket and the attack, for example file `qa_T-012_signup` with a test called `rejects_email_longer_than_254_characters`.

## Fixtures and Helpers

TODO: shared fixtures, builders, fake data, and how to get a clean database or app instance for a test.

## What Every Change Needs

- A test for each acceptance criterion that would fail if the criterion were not met.
- The edges: empty, one, many, invalid, missing, duplicate, unauthorized.
- At least one test through the real path for anything that touches storage or the network.
- For a bug fix: a test that fails without the fix.

## What QA Adds

Boundaries, invalid input, injection, authentication and authorization, state and ordering, concurrency, dependency failure, data volume, idempotency. See the `qa-process` skill for the full list.

<!-- CUSTOMIZE: list the attack surfaces specific to this project that QA
     should always probe (for example: tenant isolation, payment rounding,
     time zones, file uploads). -->

## Running Tests

See the Commands table in `CLAUDE.md`.

## Known Flaky or Slow Tests

TODO: list by name, with the ticket ID that tracks fixing each. An unlisted flaky test is a finding, not an excuse.
