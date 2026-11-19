---
name: product-discovery
description: Use when deciding what to build and why, before any technical design. Provides the method for interviewing the user, pinning down the problem, users, scope, and success criteria, and producing a product brief and an epic.
user-invocable: false
---

<!-- CUSTOMIZE: change the interview questions and the brief template to match
     how you like requirements written. Brief location: docs/product/. -->

# Product Discovery

## Philosophy

Describe the problem and the outcome, never the implementation. The output is a brief the architect can design from without asking the user to repeat themselves. If the user says "just build it", still pin down scope and success criteria; a five-minute interview is cheaper than a rebuilt feature.

## Step 1: Read what exists

Read `docs/product/overview.md` and any brief in `docs/product/` that touches this area. Check the board for epics and tickets that already cover part of the request. Do not write a second brief for something that already has one; update it.

## Step 2: Interview

Ask with `AskUserQuestion`, a few questions at a time, until each of these has an answer:

- **Problem**: what is painful or impossible today?
- **User**: who has this problem, and what are they trying to get done?
- **Outcome**: what can they do afterwards that they could not do before?
- **Scope**: what is the smallest version that is still useful?
- **Non-goals**: what nearby things are explicitly out?
- **Constraints**: deadlines, budget, platforms, data, privacy, accounts, existing behavior that must not change.
- **Success**: how will we know it worked? What would the user check by hand?
- **Failure cases**: what should happen when input is wrong, missing, or the user lacks permission?

Stop asking when further answers would not change the brief. Record anything unanswered under Open Questions rather than inventing an answer.

## Step 3: Prioritize

Sort requirements with MoSCoW:

- **Must**: the feature is pointless without it.
- **Should**: important, but the first version can ship without it.
- **Could**: nice to have.
- **Won't (this time)**: explicitly deferred.

Only Must and Should items go into the first epic.

## Step 4: Write the brief

Save to `docs/product/<feature-slug>.md`:

```markdown
# <Feature>: Product Brief

## Problem
## Users
## Outcome
## User Stories
- As a <user>, I want <goal>, so that <benefit>.
## Requirements
### Must
### Should
### Could
### Won't (this time)
## Non-Goals
## Constraints
## Success Criteria
## Open Questions
```

User stories describe intent. Acceptance criteria at this level are observable outcomes ("a signed-out visitor cannot see the dashboard"), not technical checks; the architect turns them into ticket-level criteria.

## Step 5: Confirm

Show the user a plain-language summary: what will be built, what will not, and how success is judged. Get an explicit yes before creating anything on the board.

## Step 6: Create the epic

Use the `tickets` skill to create one epic. Fill in Goal, Users, Requirements, Non-Goals, and Success Criteria from the brief, and link the brief. Leave `Design` and `Tickets` for the architect.

## Step 7: Hand off

Tell the user the next step is `/arch <EPIC-ID>`.
