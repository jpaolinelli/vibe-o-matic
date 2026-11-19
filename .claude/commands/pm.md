---
description: Scope an idea into a product brief and an epic (what and why)
argument-hint: "[idea or feature description]"
---

Work out what to build and why. Delegate to the **product-manager** subagent; it owns discovery, the product brief, and the epic.

## Resolve the request

- If `$ARGUMENTS` describes an idea or feature, hand it over as the starting brief.
- If `$ARGUMENTS` names an existing epic or brief, the product manager revises it rather than starting a new one.
- If `$ARGUMENTS` is empty, the product manager opens by asking what problem the user wants solved.

## Delegate

Hand the request to the product-manager subagent: `$ARGUMENTS`

The product manager interviews the user, proposes the smallest useful first version, writes `docs/product/<feature>.md`, gets approval, and creates one epic. It does not design the solution or create engineering tickets.

If it asks a clarifying question, surface it to the user immediately. When it finishes, show its compact line and tell the user the next step is `/arch <EPIC-ID>`.
