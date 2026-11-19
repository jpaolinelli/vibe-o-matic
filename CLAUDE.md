# TODO: Project Name - Project Guide

<!--
HOW TO USE THIS FILE
Claude Code loads this file into every conversation and every agent. Keep it
short: it is the map, not the territory. Detail belongs in ./docs.

Fastest way to fill it in: open Claude Code in your project and run /setup.

Two markers are used across this repository; search for them to find every
place you might want to change:
  CUSTOMIZE:  project-specific choices
  JIRA:       what to change if you use Jira instead of markdown ticket files
      grep -rn "CUSTOMIZE:" CLAUDE.md .claude docs tickets
      grep -rn "JIRA:" CLAUDE.md .claude docs tickets

HTML comments like this one are for humans; Claude Code strips them from
CLAUDE.md before the model sees it, so they cost nothing.
-->

<!-- CUSTOMIZE: two or three sentences. What is this project, who is it for,
     and what state is it in (prototype, live with users, and so on)? -->
TODO: Describe the project in two or three sentences.

## Where Documentation Lives

All project documentation is in `./docs`. Read the relevant file before working in an area; do not guess at something a doc already answers. When your change makes a doc wrong, fix the doc in the same change.

| Need to know | Read |
|---|---|
| What the product is, who it is for, what is in and out of scope | `docs/product/overview.md` |
| Requirements for one feature (written by the product manager) | `docs/product/<feature>.md` |
| How the system fits together: components, data flow, where code lives | `docs/architecture.md` |
| The technical design for one feature (written by the architect) | `docs/design/<feature>.md` |
| How code is written here: naming, structure, error handling | `docs/conventions.md` |
| How code is tested here: frameworks, locations, who owns which tests | `docs/testing.md` |
| The index of everything else | `docs/README.md` |

<!-- CUSTOMIZE: add rows as your docs grow (runbooks, API reference, threat
     model, release notes). If a doc is not listed here, agents will not know
     to look for it. -->

## Architecture

<!-- CUSTOMIZE: a small diagram or five to ten lines. Stack, main components,
     and the direction data flows. The full version lives in
     docs/architecture.md. -->

```
TODO: sketch the main components and how they talk to each other
```

## Ground Rules (never violate)

<!-- CUSTOMIZE: these are swept one by one in every code review, and a
     violation always blocks approval. Keep the list short and absolute.
     Rules 1 to 5 are sensible defaults; add the rules that are specific to
     your project, for example:
       - "The payments provider is only ever called from src/billing."
       - "Every database table has a tenant_id and every query filters on it."
       - "Nothing user-visible ships without a feature flag, default off."
     If you add or renumber rules, mirror them in the Ground-Rule Sweep table
     in .claude/skills/code-review-process/review-template.md. -->

1. **No secrets in the repository.** No keys, tokens, or passwords in code, tests, fixtures, logs, or commits. Configuration comes from the environment.
2. **Never trust input.** Everything from outside the program (users, files, network, environment) is validated before it is used.
3. **No silent failures.** Errors are handled or surfaced. Nothing is swallowed, and nothing destructive happens without being asked for.
4. **Stay in scope.** A change does what its ticket says and nothing else. Other problems become new tickets.
5. **Tests ship with the change.** No behavior is added or fixed without a test that would fail if it broke.

## Commands

<!-- CUSTOMIZE: this table is the single source of truth for how to build,
     check, and test the project. Every agent reads it; nothing else in
     .claude repeats these commands. Use n/a when a tool does not exist.
     Add rows freely (migrations, code generation, docker, seed data). -->

| Purpose | Command |
|---|---|
| Install dependencies | `TODO` |
| Build | `TODO` |
| Format check | `TODO` |
| Format fix | `TODO` |
| Lint | `TODO` |
| Typecheck | `TODO` |
| Unit tests | `TODO` |
| Integration tests | `TODO` |
| QA tests for one ticket | `TODO` |
| Full test suite (everything) | `TODO` |
| Run the app locally | `TODO` |

## Directory Layout

<!-- CUSTOMIZE: one line per top-level folder that matters. -->

```
TODO/                 - application source
tests/                - developer tests (owned by the engineer)
tests/qa/             - QA adversarial and regression tests (owned by QA)
docs/                 - all project documentation
tickets/              - the ticket board (folder = status)
.claude/              - agents, skills, and commands for the workflow
```

## Testing

<!-- CUSTOMIZE: set the two locations and the QA naming pattern to match your
     stack, and mirror them in docs/testing.md. Examples:
       JS/TS:   src/**/*.test.ts            and  tests/qa/qa-T-012-*.test.ts
       Python:  tests/test_*.py             and  tests/qa/test_qa_T_012_*.py
       .NET:    tests/App.UnitTests/        and  tests/App.QaTests/Qa_T_012_*.cs -->

- **Developer tests**: `tests/` (excluding `tests/qa/`). Written by the engineer alongside the code.
- **QA tests**: `tests/qa/`, named after the ticket, for example `qa_T-012_<area>`. Written only by the QA agent. The engineer never adds, edits, skips, or deletes them.
- QA never modifies developer tests.
- Detail, fixtures, and patterns: `docs/testing.md`.

## Tickets

<!-- JIRA: replace this section with your Jira details, for example:
       Tickets live in Jira. Project key ABC, cloud ID <id>,
       site https://<your-site>.atlassian.net.
       Statuses: To Do, In Progress, In Review, QA, Done.
     Then follow the switch instructions at the top of
     .claude/skills/tickets/SKILL.jira.md. -->

Tickets are markdown files in `./tickets`. **The folder a ticket is in is its status.**

```
tickets/epics/        E-001-<slug>.md   goals; do not move
tickets/pending/      T-001-<slug>.md   ready to start
tickets/in-progress/                    being built
tickets/review/                         waiting for code review
tickets/qa/                             approved; in or through QA
tickets/done/                           merged
```

Always go through the `tickets` skill and its helper script (`.claude/skills/tickets/scripts/ticket.sh`); never create or move ticket files by hand. Ticket moves are committed on the ticket's branch together with the work, so work one ticket at a time.

## Workflow Settings

<!-- CUSTOMIZE: agents read these four values. -->

- **Base branch**: `main`
- **Ticket system**: `files` <!-- JIRA: change to `jira` -->
- **Pull requests**: `off` <!-- CUSTOMIZE: `on` requires a GitHub remote and the gh CLI signed in. With `on`, reviews and QA reports are also posted to the pull request, and merges go through gh. -->
- **Merge policy**: `ask` <!-- CUSTOMIZE: `ask` = confirm with the human before each merge; `auto` = merge when review and QA have passed. /start always merges without asking. -->

## The Workflow

```
/pm       product-manager  what and why      -> docs/product/<feature>.md + epic
/arch     architect        how               -> docs/design/<feature>.md + tickets in pending
/imp      engineer         build + dev tests -> ticket moves to review
/review   reviewer         read the diff     -> APPROVED (to qa) or CHANGES REQUESTED (back to in-progress)
/qa       qa-engineer      run and attack it -> QA PASS (stays in qa) or QA FAIL (back to in-progress)
/ship     orchestrator     merge             -> ticket moves to done
```

- `/pipeline <ticket>` runs engineer, review, and QA for one ticket.
- `/start` works the whole pending queue through the pipeline, one ticket at a time.
- `/board` shows the board. `/setup` fits this file and `docs/` to the project.

Roles are separate on purpose: the engineer does not approve their own work, the reviewer does not fix what they find, and QA does not weaken a test to get a pass.

## Working Agreements

<!-- CUSTOMIZE: how you want Claude to behave in this project. -->

- If a requirement is ambiguous, ask. Do not guess.
- Explain the trade-off when proposing an approach.
- Ask before anything destructive: deleting data or files, rewriting history, changing a public interface.
- Report results honestly. A failing gate is reported as failing, with the output.
