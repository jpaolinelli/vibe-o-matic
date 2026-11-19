---
description: Design a feature and break it into tickets (how)
argument-hint: "[epic ID | feature description | bug description]"
---

Plan and scope a feature into tickets. Delegate to the **architect** subagent; it owns requirements, design, and ticket creation.

## Resolve the request

- If `$ARGUMENTS` names an epic (for example `E-001`), the architect starts from that epic and its product brief.
- If `$ARGUMENTS` describes a feature, hand it over as the starting brief. For anything larger than a couple of tickets with no product brief yet, suggest `/pm` first, but proceed if the user prefers.
- If `$ARGUMENTS` describes a bug or a small change, the architect confirms the expected behavior and creates a single ticket with no design doc.
- If `$ARGUMENTS` is empty, the architect opens by asking what to build.

## Delegate

Hand the request to the architect subagent: `$ARGUMENTS`

The architect asks clarifying questions, researches the affected code, proposes a design with trade-offs, gets approval, writes `docs/design/<feature>.md`, then creates tickets in `pending` with testable acceptance criteria and presents the hierarchy. It does not write implementation code or create branches.

If it asks a clarifying question, surface it to the user immediately. When it finishes, show the ticket hierarchy and tell the user the next step is `/pipeline <TICKET-ID>` for one ticket or `/start` to work the whole queue.
