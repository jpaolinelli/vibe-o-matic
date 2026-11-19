# Coding Conventions

<!-- CUSTOMIZE: /setup fills this in from what the existing code actually
     does. The engineer follows it; the reviewer enforces it. Write rules as
     short imperatives with an example. If this file grows past a couple of
     hundred lines, consider turning it into a project skill in
     .claude/skills and listing that skill in the agents' frontmatter. -->

Follow these when writing or reviewing code. When a rule here disagrees with the code around you, follow the rule and say so in your handoff.

## Language and Formatting

TODO: language version, formatter, and linter. The formatter's output is final; do not hand-format.

## Naming

TODO: files, functions, variables, types, constants, database tables and columns, tests.

## Structure

TODO: where new code goes; how big a file or function should get before it is split; what belongs in shared code versus a feature folder.

## Error Handling

TODO: how expected failures are represented (exceptions, result types, error codes), how unexpected ones are surfaced, and what is shown to the user versus logged.

## Input Validation

TODO: where validation happens and with what tool. Nothing from outside the program is used before it is validated.

## Logging

TODO: the logger, the levels, and what must never be logged (secrets, personal data).

## Data Access

TODO: how the database or storage is reached; migration naming; rules such as "never edit an applied migration".

## Interfaces

TODO: API style, status codes, error shape, versioning. UI component and state conventions if there is a frontend.

## Dependencies

TODO: how a new dependency is approved. Default: none are added without being named in the design or justified in the handoff.

## Comments and Docs

TODO: default is to comment why, not what; public interfaces get a short doc comment; no commented-out code.

## General

- Small changes, one ticket per branch, ticket ID in every commit message.
- No dead code, debug output, or TODO without a ticket ID.
- Fake names and data only in tests and fixtures.
