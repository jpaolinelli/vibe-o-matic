# Architecture

<!-- CUSTOMIZE: /setup fills this in from the existing code. The architect
     agent reads it before designing and updates it when a design changes the
     shape of the system. Per-feature designs live in docs/design/<feature>.md.
     CLAUDE.md carries only a short sketch; this is the full version. -->

## Stack

TODO: languages, frameworks, database, hosting, and the versions that matter.

## Components

| Component | Location | Responsibility |
|---|---|---|
| TODO | `TODO/` | TODO |

## Data Flow

TODO: how a typical request or action moves through the components, from the user to storage and back.

```
TODO: diagram
```

## Data Model

TODO: the main entities and how they relate. Where the schema and migrations live.

## External Services

| Service | Used for | Where it is called from | What happens when it is down |
|---|---|---|---|
| TODO | TODO | TODO | TODO |

## Dependency Rules

TODO: which parts may depend on which (for example: UI may call the API layer; the API layer may not import from the UI).

## Configuration and Secrets

TODO: where configuration comes from, which environment variables exist (names only, never values), and how secrets are supplied.

## Known Weak Spots

TODO: areas that are fragile, slow, or due for a rewrite. Engineers should tread carefully here; QA should attack here first.
