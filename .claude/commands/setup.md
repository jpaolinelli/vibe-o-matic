---
description: One-time setup - fit CLAUDE.md and docs/ to this project
---

Fit this workflow to the current project by filling in `CLAUDE.md` and the `docs/` skeleton. Do this inline, in conversation with the user. Do not write application code.

## Step 1: Look before asking

Inspect the repository without changing anything:

- What exists: languages, frameworks, package manifests (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `*.csproj`, and so on), `Makefile`, CI config, Docker files, README.
- How it is built, run, linted, formatted, typechecked, and tested. Run nothing destructive; reading scripts is enough, and `--help` or a dry run is fine.
- Whether tests exist, where they live, and which framework they use.
- Whether it is a git repository, what the default branch is, whether there is a remote, and whether `gh` is installed and authenticated.
- The directory layout, two levels deep.

## Step 2: Ask only what you could not find

Use `AskUserQuestion`. Typical gaps:

- One-paragraph description of what the project is and who it is for.
- Any rule that must never be broken (data that must never be deleted, a system that must never be written to, privacy constraints).
- Pull requests on or off; merge policy `ask` or `auto`.
- If there are no tests: which test framework to adopt. Recommend the conventional choice for the stack and explain the trade-off in one line.
- If there is no linter or formatter: whether to add one. Recommend the conventional choice.

## Step 3: Fill in CLAUDE.md

Replace every `TODO` and every placeholder in `CLAUDE.md`: project name and description, architecture sketch, ground rules, the Commands table, directory layout, test locations, and workflow settings. Keep the `CUSTOMIZE` and `JIRA` comments; they are invisible to agents and useful to humans.

Use `n/a` for a command that genuinely does not exist. Never leave a guess: verify each command by running it, unless it is slow or has side effects, in which case ask.

## Step 4: Fill in docs/

Write real content, based on what the code actually does, into:

- `docs/product/overview.md`: what the product is, who uses it, what it does today.
- `docs/architecture.md`: components, data flow, where things live.
- `docs/conventions.md`: the conventions the existing code actually follows (naming, error handling, structure). Where the code is inconsistent, say so and ask the user which way to standardize.
- `docs/testing.md`: frameworks, locations, how to run, and the developer versus QA test ownership split.

Mark anything you inferred but could not confirm with `(unverified)`.

## Step 5: Prepare the board

Run `bash .claude/skills/tickets/scripts/ticket.sh init`, then `check`. If the project is not a git repository, offer to run `git init` and explain that the ticket workflow relies on branches.

## Step 6: Create the missing foundations as tickets

Do not fix gaps yourself. For each gap found (no tests, no linter, no CI, secrets in the repository, no README), create a `chore` ticket in `pending` using the `tickets` skill, priority `P1` for anything that blocks the quality gate. A project with no test runner needs that ticket done first, because the engineer and QA agents cannot gate without one.

## Step 7: Report

Summarize: what was filled in, what is still `TODO` or `(unverified)`, the tickets created, and the suggested next command (`/pm <idea>`, `/arch <idea>`, or `/pipeline <first ticket>`).
