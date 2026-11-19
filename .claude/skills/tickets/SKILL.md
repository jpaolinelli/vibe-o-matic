---
name: tickets
description: Use whenever you need to find, read, create, move, or comment on a ticket. Tickets are markdown files in ./tickets and the folder a ticket sits in is its status. Provides the board layout, the allowed status moves, who is allowed to make each move, and the helper script that performs them.
user-invocable: false
---

<!--
JIRA: this whole skill is the only place that knows tickets are files.
To use Jira instead, replace this file with SKILL.jira.md (same folder),
fill in its placeholders, and delete ./tickets. Agents and commands only
say "use the tickets skill", so nothing else needs rewriting.
CUSTOMIZE: to rename statuses or add one (for example "blocked"), change
the table below AND the STATUSES / allowed() definitions in scripts/ticket.sh.
-->

# Tickets (file-based board)

## The board

```
tickets/
  epics/         E-001-<slug>.md   large goals; never move
  pending/       T-001-<slug>.md   ready to be picked up
  in-progress/                     an engineer is working on it
  review/                          waiting for code review
  qa/                              review approved; waiting for or passed QA
  done/                            merged
```

- **The folder is the status.** There is no status field inside the file. Never record status anywhere else.
- One file per ticket. The ID (`T-001`) never changes; the slug is only for humans.
- Epics (`E-001`) hold the goal and the list of tickets. Tickets point at their epic with `epic:` in the frontmatter.
- There are no subtasks. A ticket's `Implementation Checklist` plays that role.

## Always use the helper script

Do not create, rename, or move ticket files by hand. The script keeps IDs unique and refuses moves that skip a stage.

```bash
T=.claude/skills/tickets/scripts/ticket.sh

bash $T list                      # whole board
bash $T list pending              # one column
bash $T show T-001                # status + path + full text
bash $T status T-001              # just the status
bash $T next                      # next ready pending ticket (priority, then ID, dependencies done)
bash $T new feature "Title" --epic E-001 --priority P2 --depends T-001 --estimate M
bash $T new bug "Title" --priority P1
bash $T new epic "Title"
bash $T move T-001 review --by engineer
bash $T log T-001 engineer "one line note"
bash $T check                     # duplicate IDs, misplaced files
```

`new` prints the path of the file it created. Open that file and replace every `<placeholder>` before you tell anyone the ticket exists.

## Status flow and who moves what

```
pending -> in-progress -> review -> qa -> done
              ^             |        |
              +-------------+--------+     (sent back for fixes)
```

| Move | Who | When |
|---|---|---|
| (create in) `pending` | product-manager, architect, qa-engineer (bugs) | ticket is fully written |
| `pending -> in-progress` | engineer | work starts, on the ticket branch |
| `in-progress -> review` | engineer | quality gate passed and work committed |
| `review -> qa` | reviewer | verdict APPROVED |
| `review -> in-progress` | reviewer | verdict CHANGES REQUESTED |
| `qa -> in-progress` | qa-engineer | verdict QA FAIL |
| `qa -> done` | orchestrator or human only | QA PASS recorded and the branch is being merged |

A ticket with QA PASS **stays in `qa/`** until the merge step moves it. Subagents never move a ticket to `done`.

The script rejects any other move. `--force` exists for humans cleaning up; an agent uses it only when the user explicitly says so.

## Ticket state travels with the branch

Ticket files are committed like code. A move made on branch `T-001` is visible on the base branch only after that branch merges, at which point the ticket lands in `done/` in the same merge as the code. Consequences:

- Work **one ticket at a time**. Two branches each creating tickets can produce the same ID.
- On the base branch, an in-flight ticket still shows as `pending`. `git branch --no-merged <base>` shows what is in flight.
- Always commit the ticket move together with the work it describes.

## Reading a ticket

1. `bash $T show <ID>`.
2. Extract every item under `Acceptance Criteria` as a separate, checkable claim.
3. If `epic:` is set, read the epic file for the goal and non-goals.
4. If the ticket names a design doc under `docs/design/`, read the section it points at.
5. Check `depends_on`. If any dependency is not in `done/`, stop and say so.

## Writing to a ticket

The `Activity` section at the bottom is the comment thread. It is append-only and chronological.

- One-line notes: `bash $T log <ID> <agent> "<note>"`.
- Longer reports (review, QA): append a block at the very end of the file with the Edit tool:

```markdown
### 2026-01-31 reviewer: Review v1 - CHANGES REQUESTED
<report body>
```

- Tick acceptance criteria and checklist boxes (`- [x]`) as they are completed. Only the engineer ticks checklist items; only the reviewer and QA confirm acceptance criteria in their reports.
- Never rewrite or delete earlier Activity entries. Never change acceptance criteria after work has started; if they are wrong, stop and ask the user.

## Creating tickets

Read [`writing.md`](writing.md) before creating any ticket. It has the quality bar and sizing rules. Templates live in `templates/`.

## Showing a ticket to the user

```
# <ID>: <Title>
Status: <status> | Type: <type> | Priority: <priority> | Epic: <epic or none>

## Acceptance Criteria
- [ ] ...

## Implementation Checklist
- [ ] ...
```
