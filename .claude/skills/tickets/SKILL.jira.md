---
name: tickets
description: Use whenever you need to find, read, create, move, or comment on a ticket. Tickets live in Jira. Provides the project identifiers, status flow, who is allowed to make each transition, standard JQL, and the exact MCP calls to use.
user-invocable: false
---

<!--
JIRA: this file is the drop-in replacement for SKILL.md when you use Jira
instead of markdown files. It is inert until you activate it.

To switch:
  1. Connect the Atlassian MCP server to Claude Code and sign in.
  2. Fill in every <PLACEHOLDER> below (cloud ID, project key, site URL).
  3. Rename SKILL.md to SKILL.files.md, then rename this file to SKILL.md.
  4. In CLAUDE.md, set "Ticket system" to jira and update the Tickets section.
  5. Delete ./tickets and scripts/ticket.sh (optional, they are simply unused).
  6. Run: grep -rn "JIRA:" .claude CLAUDE.md   and apply each remaining note.
  7. In .claude/settings.json, allow the Jira MCP tools you want to run
     without a prompt.

Your Jira workflow needs these statuses (rename below if yours differ):
  To Do, In Progress, In Review, QA, Done
-->

# Tickets (Jira)

## Project

- Cloud ID: `<JIRA_CLOUD_ID>` (constant; never rediscover it)
- Project key: `<PROJECT_KEY>`
- Site: `https://<YOUR_SITE>.atlassian.net`

## Status mapping

| Board status used by the agents | Jira status |
|---|---|
| pending | To Do |
| in-progress | In Progress |
| review | In Review |
| qa | QA |
| done | Done |

Wherever an agent or command says "move the ticket to `review`", transition the Jira issue to the mapped status.

## Operations

| Need | Call |
|---|---|
| Read a ticket | `getJiraIssue` |
| Children of an epic or story | `searchJiraIssuesUsingJql` with `parent = <KEY> ORDER BY key ASC` |
| Move a ticket | `getTransitionsForJiraIssue`, then `transitionJiraIssue` |
| Comment (notes, review and QA reports) | `addCommentToJiraIssue` |
| Create | `createJiraIssue` with `issueTypeName` of `Epic`, `Story`, `Task`, `Bug`, or `Subtask`, and `parent` where needed |
| Edit description | `editJiraIssue` |

Do trivial Jira operations inline. A status read or a transition is two or three calls; do not spawn a subagent for it.

Make Jira MCP calls one at a time rather than in parallel, and confirm each created key by reading it back before recording it. In one project that used this setup, parallel calls returned responses matched to the wrong request.

Once you have looked up the transition IDs for this project, record them here so nobody has to look them up again:

- To In Progress: `<id>`
- To In Review: `<id>`
- To QA: `<id>`
- To Done: `<id>`

## Standard JQL

- Next ready ticket: `project = <PROJECT_KEY> AND status = "To Do" AND issuetype NOT IN (Epic, Subtask) ORDER BY rank ASC`
- In progress: `project = <PROJECT_KEY> AND status = "In Progress" AND issuetype NOT IN (Epic, Subtask) ORDER BY rank ASC`
- Awaiting review: `project = <PROJECT_KEY> AND status = "In Review" ORDER BY key ASC`
- Awaiting QA: `project = <PROJECT_KEY> AND status = "QA" ORDER BY key ASC`

Respect a `Depends on:` line in the description: skip a ticket whose dependencies are not Done.

## Status flow and who moves what

| Transition | Who | When |
|---|---|---|
| create in To Do | product-manager, architect, qa-engineer (bugs) | ticket is fully written |
| To Do -> In Progress | engineer | work starts |
| In Progress -> In Review | engineer | quality gate passed and work pushed |
| In Review -> QA | reviewer | verdict APPROVED |
| In Review -> In Progress | reviewer | verdict CHANGES REQUESTED |
| QA -> In Progress | qa-engineer | verdict QA FAIL |
| QA -> Done | orchestrator or human only | QA PASS recorded and the pull request is merged |

A ticket must not move to Done until its pull request is merged. Subagents never set Done. When a parent moves to Done, close its subtasks too; nothing else will.

## Hierarchy

Jira has real subtasks, so the `Implementation Checklist` in the ticket templates can become Subtask issues when a story has three or more independent steps. Otherwise keep the checklist in the description.

## Reading a ticket

1. `getJiraIssue` for the key.
2. Fetch children with the `parent =` query and read each one.
3. Extract every item under "Acceptance Criteria" (or "AC", "Definition of Done") as a separate, checkable claim.
4. Follow any link to a design doc under `docs/design/`.

## Writing to a ticket

- Notes, handoffs, review reports, and QA reports are Jira comments.
- With pull requests on, post the detailed review and QA reports to the pull request and add a short comment on the issue linking to it.
- Never change acceptance criteria after work has started; ask the user.

## Creating tickets

Read [`writing.md`](writing.md) for the quality bar and sizing. Use the section layouts in `templates/` as the issue description (drop the YAML frontmatter; Jira fields replace it).

## Showing a ticket to the user

```
# <KEY>: <Summary>
Status: <status> | Type: <type> | Priority: <priority> | Epic: <key or none>
Link: https://<YOUR_SITE>.atlassian.net/browse/<KEY>

## Acceptance Criteria
- [ ] ...
```
