# Writing Tickets

Read this before creating an epic, ticket, or bug. It applies whether tickets are files or Jira issues.

<!-- CUSTOMIZE: adjust sizing, priority meanings, and required sections to taste.
     If you add a required section, add it to templates/*.md as well. -->

## Quality bar

A ticket is ready for `pending` only when an engineer who has never spoken to the user could build it without guessing.

- **Summary** says what is delivered and why, in plain language.
- **Acceptance criteria** are discrete and checkable. Each one can be proven true or false by running something or reading something. Prefer "Given X, when Y, then Z".
  - Bad: "Login works well." "The page is fast."
  - Good: "Given a wrong password, when the user submits the form, then the response is 401 and the message 'Invalid email or password' is shown."
- **Failure behavior is specified**, not just the happy path: empty input, invalid input, missing permissions, the thing not existing.
- **Out of scope** names the nearby work this ticket deliberately skips.
- **Dependencies** are listed in `depends_on` by ID.
- **Context** points at the epic, the design doc section, and the code area. Never paste the whole design into the ticket.
- No placeholder text (`<...>`) is left in the file.

## Hierarchy

```
Epic (E-xxx): a user-facing goal, 1 to 4 weeks of work
  Ticket (T-xxx): one deliverable, half a day to 3 days
    Implementation Checklist: ordered steps inside the ticket
```

- One epic per feature. Small standalone work (a bug, a chore) needs no epic.
- Split a ticket when it has more than about 7 checklist steps, touches unrelated areas, or cannot be reviewed in one sitting.
- Each ticket must leave the project in a working state when merged on its own.
- Order tickets so that dependencies come first; give each a `depends_on` list.

## Types

| Type | Use for |
|---|---|
| `feature` | new or changed behavior a user can observe |
| `bug` | behavior that contradicts a ticket, the docs, or common sense |
| `chore` | refactors, tooling, dependencies, docs; no behavior change |
| `spike` | time-boxed research; the deliverable is a written answer, not code |

## Priority

| Priority | Meaning |
|---|---|
| `P1` | blocks other work or is broken for users now |
| `P2` | normal planned work (default) |
| `P3` | nice to have |

## Estimate

`S` (under half a day), `M` (up to a day), `L` (2 to 3 days). Anything larger gets split.

## Naming

- Epic: the feature, for example `User accounts and login`.
- Ticket: what is delivered, for example `Sign-up form with email and password`.
- Bug: `<Area>: <what goes wrong>`, for example `Sign-up: crash on empty email`.
- Checklist step: one action, for example `Add users table and migration`.

## After creating tickets

1. Add each new ticket to its epic's `Tickets` list.
2. Run the board check (`ticket.sh check`).
3. Present the hierarchy to the user:

```
# E-001: <Epic title>
- T-001: <title> (P2, M)
- T-002: <title> (P2, S, depends on T-001)
```
