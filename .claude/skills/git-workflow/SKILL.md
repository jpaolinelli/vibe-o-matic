---
name: git-workflow
description: Use when you need to create a branch, write a commit message, push, open a pull request, or merge a finished ticket. Provides branch naming, commit message format, the pull request template, the merge procedure, and safety rules.
user-invocable: false
---

<!-- CUSTOMIZE:
     - Base branch, "Pull requests: on|off", and "Merge policy" are settings in
       CLAUDE.md under Workflow Settings. Change them there, not here.
     - Edit the commit and pull request templates below to match your style.
     JIRA: with Jira, add a link line to the pull request body, for example
       [<TICKET-ID>](https://<YOUR_SITE>.atlassian.net/browse/<TICKET-ID>) -->

# Git Workflow

`<base>` below means the base branch named in `CLAUDE.md` (usually `main`).

## Branching

One branch per ticket, named exactly after the ticket ID:

```bash
git checkout <base> && git pull --ff-only 2>/dev/null || true
git checkout -b T-012
```

Commands that take no argument work out the ticket from the branch name, so do not add a suffix. All work for the ticket, including review and QA commits and the ticket file moves, happens on this branch.

## Commit messages

```
<TICKET-ID>: <short imperative summary, under 72 characters>

- <what was implemented or changed>
- <what was implemented or changed>
```

Pass the message with a HEREDOC so formatting survives:

```bash
git commit -m "$(cat <<'EOF'
T-012: Add sign-up form with email and password

- Add users table and migration
- Add POST /signup with validation
- Add sign-up page and form tests
EOF
)"
```

Role-specific summaries:

- Engineer fix round: `T-012: Address review v1` or `T-012: Fix QA findings`
- Reviewer (ticket file only): `T-012: Review v1 APPROVED`
- QA: `T-012: QA tests and report (QA PASS)`

## Staging

Stage specific paths. Never `git add -A` or `git add .`; they pick up secrets and junk.

```bash
git add src/ tests/ docs/ tickets/
git status --short     # confirm nothing unexpected is staged
```

Always include the ticket file in the commit that goes with its move.

## Pull requests (only when "Pull requests: on" in CLAUDE.md)

```bash
git push -u origin T-012
gh pr create --title "T-012: <ticket title>" --body "$(cat <<'EOF'
## Summary
- <what was implemented>

## Ticket
tickets/review/T-012-<slug>.md

## Test Plan
- [ ] Build clean
- [ ] Format, lint, typecheck clean
- [ ] Developer tests pass
- [ ] Full suite passes
EOF
)"
```

With pull requests off, skip pushing unless the user asks; the ticket file is the record.

## Viewing branch changes

```bash
git diff --stat <base>...HEAD
git diff --name-only <base>...HEAD
git log --oneline <base>..HEAD
```

## Merging a finished ticket (orchestrator or human only)

Preconditions, all required: newest review verdict is APPROVED, newest QA verdict is QA PASS and is newer than the last code commit, the full suite passes on the branch head, and the working tree is clean.

1. Move the ticket to `done` on the branch and commit it (`T-012: Done`), so the code and the ticket status land together.
2. Merge:
   - Pull requests on: push, confirm CI is green and the pull request is mergeable, then `gh pr merge <number> --squash --delete-branch`, then `git checkout <base> && git pull`.
   - Pull requests off: `git checkout <base> && git merge --squash T-012 && git commit -m "T-012: <ticket title>"`, then `git branch -D T-012`.
3. Run the full suite on `<base>`. If it fails, stop and tell the user immediately.

Subagents (engineer, reviewer, QA) never merge.

## Safety rules

- Never force push. Never rewrite published history. Never amend a commit unless the user asks.
- Never commit directly to `<base>` except the squash merge above.
- Never commit `.env` files, credentials, keys, tokens, or large binaries.
- Never commit fixtures or test data containing real personal data.
- Never use `--no-verify` to skip hooks.
- If a merge conflicts, stop and ask; do not resolve conflicts in code you did not write for this ticket.
