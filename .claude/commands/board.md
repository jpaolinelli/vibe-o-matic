---
description: Show the ticket board
argument-hint: "[pending | in-progress | review | qa | done | epics | ticket ID]"
---

Show the ticket board. Do this inline; do not spawn a subagent.

<!-- JIRA: with Jira, replace the script calls below with the standard JQL
     queries from the tickets skill, grouped by status. -->

- If `$ARGUMENTS` is a ticket ID: run `bash .claude/skills/tickets/scripts/ticket.sh show $ARGUMENTS` and present the ticket in the display format from the `tickets` skill.
- If `$ARGUMENTS` is a column name: run `bash .claude/skills/tickets/scripts/ticket.sh list $ARGUMENTS`.
- If `$ARGUMENTS` is empty: run `bash .claude/skills/tickets/scripts/ticket.sh list`, then `bash .claude/skills/tickets/scripts/ticket.sh check`.

After the listing, add at most three lines:

- which ticket is next ready (`ticket.sh next`), or why nothing is ready;
- any ticket branches in flight (`git branch --no-merged <base>`), since their status lives on the branch;
- any problem `check` reported.

Do not read ticket bodies unless asked.
