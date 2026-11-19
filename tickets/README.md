# Ticket Board

<!-- JIRA: if you use Jira, delete this folder. See
     .claude/skills/tickets/SKILL.jira.md for the switch instructions. -->

Each ticket is one markdown file. **The folder it sits in is its status.**

| Folder | Meaning |
|---|---|
| `epics/` | Large goals (`E-001`). They stay here and list their tickets. |
| `pending/` | Written and ready to be picked up. |
| `in-progress/` | An engineer is working on it, or fixing what review or QA sent back. |
| `review/` | Waiting for code review. |
| `qa/` | Review approved. Waiting for QA, or passed QA and waiting to be merged. |
| `done/` | Merged. |

```
pending -> in-progress -> review -> qa -> done
              ^             |        |
              +-------------+--------+     (sent back for fixes)
```

## Using the board

Agents manage the board for you (`/board`, `/pm`, `/arch`, `/pipeline`). To do something by hand, use the helper script rather than dragging files around; it keeps IDs unique and refuses moves that skip a stage.

```bash
bash .claude/skills/tickets/scripts/ticket.sh list
```

```bash
bash .claude/skills/tickets/scripts/ticket.sh new feature "Sign-up form" --epic E-001 --priority P2
```

```bash
bash .claude/skills/tickets/scripts/ticket.sh move T-001 in-progress --by me
```

```bash
bash .claude/skills/tickets/scripts/ticket.sh help
```

## Things worth knowing

- The `Activity` section at the bottom of each ticket is its history: moves, handoffs, review reports, and QA reports, oldest first.
- Ticket files are committed with the code. A ticket's move to `done` lands on the main branch in the same merge as its code.
- While a ticket is being worked on, its current status is on its branch (named after the ticket, for example `T-001`). On the main branch it still shows as `pending` until it merges.
- Work one ticket at a time.
