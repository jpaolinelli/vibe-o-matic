# Project Documentation

<!-- CUSTOMIZE: this is the index of everything in ./docs. When you add a
     document, list it here AND in the "Where Documentation Lives" table in
     CLAUDE.md, or the agents will not know it exists. -->

Everything an agent or a person needs to know about this project lives here. `CLAUDE.md` at the repository root points into this folder.

| Document | What it answers | Kept current by |
|---|---|---|
| [`product/overview.md`](product/overview.md) | What the product is, who it is for, what is in and out of scope | product-manager |
| `product/<feature>.md` | Requirements for one feature (the product brief) | product-manager |
| [`architecture.md`](architecture.md) | Components, data flow, where code lives | architect |
| `design/<feature>.md` | The technical design for one feature | architect |
| [`conventions.md`](conventions.md) | How code is written here | engineer, reviewer |
| [`testing.md`](testing.md) | How code is tested here and who owns which tests | engineer, qa-engineer |

## Rules for docs

- A doc describes how things **are**. Plans and proposals go in `product/` and `design/`.
- When a change makes a doc wrong, the same change fixes the doc. The reviewer checks this.
- Short and correct beats long and stale. Delete what is no longer true.

## Suggested additions as the project grows

<!-- CUSTOMIZE: create these when you need them. -->

- `runbooks/`: how to deploy, roll back, and recover.
- `decisions/`: one short file per significant decision and why it was made.
- `api.md`: the public interface, if other people or systems call this project.
- `security.md`: what is sensitive, who may see it, and how it is protected.
- `release-notes.md`: what changed, in words a user would understand.
