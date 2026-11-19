---
description: Code review a ticket or the current branch
argument-hint: "[ticket ID]"
---

Review a ticket or the current branch. Delegate to the **reviewer** subagent; it owns the review method and keeps its detailed work out of this conversation.

## Resolve the target

- If `$ARGUMENTS` names a ticket (for example `T-012`), that is the target. Make sure its branch is checked out.
- If `$ARGUMENTS` is empty, target the current branch (`git rev-parse --abbrev-ref HEAD`):
  - If the branch name is a ticket ID, review that ticket against its acceptance criteria.
  - Otherwise review the raw diff against the base branch for ground rules, security, reusability, and quality, with no acceptance criteria and no ticket move. If there is no diff, tell the user there is nothing to review.

The ticket should be in `review`. If it is elsewhere, tell the user its status and ask before continuing.

## Delegate

Hand the resolved target to the reviewer subagent. If the engineer's `HANDOFF:` line is available in this conversation or in the ticket's Activity, pass it along. For a re-review, pass the previously reviewed commit and the earlier blocking issues.

The reviewer reads only the diff, runs the static gates, writes the detailed review into the ticket, moves the ticket (`qa` on APPROVED, `in-progress` on CHANGES REQUESTED), and returns one compact verdict line. Surface that line; do not re-read the diff or the files the reviewer already covered.

Next step: `/qa` on APPROVED, `/imp` on CHANGES REQUESTED.
