---
name: planning-process
description: Use when designing how to build a feature and breaking it into tickets. Provides the method for gathering requirements, researching the codebase, designing a technical approach with trade-offs, getting approval, writing the design doc, and creating tickets.
user-invocable: false
---

<!-- CUSTOMIZE: add your own design principles and required design sections
     (for example feature flags, multi-tenancy, analytics) in Phase 3 and the
     Phase 5 template. Design docs live in docs/design/. -->

# Planning Process

## Philosophy

Produce a plan an engineer can follow without guessing. Every design decision is stated, every trade-off is acknowledged, every acceptance criterion is testable.

## Phase 0: Check what exists

- If given an epic ID, read the epic and its product brief in `docs/product/`.
- Read `docs/architecture.md` and any design in `docs/design/` that touches this area.
- Check the board for existing tickets that overlap. Deviations from an approved brief or design must be called out and approved.

## Phase 1: Requirements

If there is a product brief, start from it and ask only about what it leaves open. If there is none, ask (with `AskUserQuestion`): what, why, scope, constraints, dependencies, non-goals, who uses it, and what must not change.

Output: feature name plus one sentence, requirements, constraints and non-goals, open questions.

## Phase 2: Research

Explore the codebase: affected modules, existing patterns to follow, code that can be reused, integration points, and how this area is tested today. Note anything in the current code that the design will have to work around.

## Phase 3: Design

Cover: architecture and data flow, components and where they live, data model and migrations, interfaces (endpoints, function signatures, UI states), error handling, security considerations (input validation, authentication, authorization, secrets), testing strategy, trade-offs, and risks.

Principles:

- Minimize blast radius; change as little existing code as the feature allows.
- Follow existing patterns before introducing new ones.
- Reuse before writing new.
- Testable in isolation.
- Simple over clever. Explicit over implicit.
- Every ground rule in `CLAUDE.md` holds.

For each significant decision, name at least one alternative and say why it lost.

## Phase 4: Review with the user

Present a plain-language summary, the key decisions, the trade-offs, and the risks. Ask for explicit approval. Iterate until approved. Do not create tickets before approval.

## Phase 5: Design document

Save to `docs/design/<feature-slug>.md`:

```markdown
# <Feature>: Technical Design

## Summary
## Requirements
## Non-Goals
## Design
### Architecture
### Components
| Component | Location | Purpose |
### Data Model / Migrations
### Interfaces
### Error Handling
### Security
## Alternatives Considered
## Work Breakdown
| Ticket | Description | Estimate | Depends on |
## Testing Strategy
## Risks
## Acceptance Criteria
```

If the design changes how the system fits together, update `docs/architecture.md` in the same change.

## Phase 6: Create tickets

Use the `tickets` skill and read its `writing.md` first. One epic (reuse the product manager's if it exists), then one ticket per row of the work breakdown. Every ticket has testable acceptance criteria, a `depends_on` list, and a pointer to the design doc section. Link the design from the epic and list the tickets in the epic.

## Phase 7: Present

Show the complete hierarchy with IDs, priorities, estimates, and dependencies, and tell the user the next step is `/pipeline <TICKET-ID>` or `/start`.
