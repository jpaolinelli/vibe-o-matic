# vibe-o-matic

A drop-in Claude Code setup that turns "just vibe coding" into a small, disciplined software team: a product manager, an architect, an engineer, a code reviewer, and an adversarial QA engineer, coordinated through tickets that are plain markdown files.

No Jira, no servers, no dependencies beyond Claude Code, git, and bash.

## What you get

```
/pm       product-manager   what to build and why   -> product brief + epic
/arch     architect         how to build it         -> design doc + clean tickets
/imp      engineer          builds it, with tests   -> ticket goes to review
/review   reviewer          reads every changed line -> approves, or sends it back
/qa       qa-engineer       runs it and attacks it  -> passes, or sends it back
/ship     (you)             merge                   -> ticket goes to done
```

- **The reviewer** checks that the engineer did everything the ticket asked, then checks security, reusability, and code quality. It reads; it does not fix.
- **The QA engineer** builds and runs the real thing, runs every existing test, then writes new automated tests designed to break it: boundaries, bad input, injection, permissions, out-of-order actions, failures of things it depends on. Bugs it finds come back as failing tests.
- **Roles are separate on purpose.** Nobody approves their own work, and nobody weakens a test to get a pass.

Tickets move through folders, and the folder is the status:

```
tickets/pending -> in-progress -> review -> qa -> done
```

## Quick start

1. Copy this repository's contents into the root of your project:

   ```bash
   git clone https://github.com/jpaolinelli/vibe-o-matic.git
   ```

   ```bash
   cp -R vibe-o-matic/.claude vibe-o-matic/CLAUDE.md vibe-o-matic/docs vibe-o-matic/tickets /path/to/your-project/
   ```

   If your project already has a `CLAUDE.md`, a `docs/` folder, or a `.claude/` folder, merge by hand instead of overwriting.

2. Open Claude Code in your project and run:

   ```
   /setup
   ```

   It inspects the project, asks a few questions, fills in `CLAUDE.md` and `docs/`, and creates tickets for anything missing (for example, no test runner).

3. Build something:

   ```
   /pm I want users to be able to reset their password
   /arch E-001
   /pipeline T-001
   /ship T-001
   ```

   Or, once tickets exist, let it work the whole queue: `/start`.

## Commands

| Command | What it does |
|---|---|
| `/setup` | One-time: fit `CLAUDE.md` and `docs/` to your project |
| `/pm [idea]` | Interview you, write a product brief, create an epic |
| `/arch [epic or idea]` | Design the solution, create tickets with testable acceptance criteria |
| `/imp [ticket]` | Engineer implements one ticket and hands it to review |
| `/review [ticket]` | Code review: completeness, security, reusability, quality |
| `/qa [ticket]` | Adversarial QA: run it, attack it, write tests |
| `/pipeline <ticket>` | Engineer, then review, then QA, with fix loops |
| `/ship [ticket]` | Merge a ticket that passed review and QA; move it to done |
| `/start` | Autonomous: work every pending ticket through the pipeline and merge |
| `/board [column or ticket]` | Show the board |

For a small fix you can skip `/pm` and go straight to `/arch <describe the bug>`, which creates a single ticket.

## What is in the box

```
CLAUDE.md                      the project guide every agent reads; points into docs/
docs/                          project documentation (skeleton; /setup fills it in)
  product/overview.md            what the product is
  architecture.md                how it fits together
  conventions.md                 how code is written here
  testing.md                     how code is tested here
  design/                        per-feature designs, written by the architect
tickets/                       the board; folder = status
.claude/
  agents/                      the five roles
    product-manager.md  architect.md  engineer.md  reviewer.md  qa-engineer.md
  commands/                    the slash commands listed above
  skills/                      the methods the agents follow
    tickets/                     board rules, templates, helper script, Jira variant
    product-discovery/           how the product manager scopes
    planning-process/            how the architect designs and breaks down work
    implementation-process/      how the engineer builds
    code-review-process/         how the reviewer reviews
    qa-process/                  how QA tests
    quality-checks/              the gates and who runs them
    git-workflow/                branches, commits, pull requests, merging
  settings.json                a small, conservative permission allowlist
```

## Customizing

Every place you are expected to change is marked. Find them all with:

```bash
grep -rn "CUSTOMIZE:" CLAUDE.md .claude docs tickets
```

The ones that matter most:

| What | Where |
|---|---|
| Build, lint, and test commands (one table, read by every agent) | `CLAUDE.md`, Commands |
| Rules that must never be broken (swept in every review) | `CLAUDE.md`, Ground Rules |
| Base branch, pull requests on or off, merge policy | `CLAUDE.md`, Workflow Settings |
| Where developer tests and QA tests live | `CLAUDE.md`, Testing, and `docs/testing.md` |
| Coding conventions | `docs/conventions.md` |
| Which model each agent uses | `model:` in each file under `.claude/agents/` |
| Extra review checks for your stack | `.claude/skills/code-review-process/SKILL.md` |
| Extra attack categories for your domain | `.claude/skills/qa-process/SKILL.md` |
| Ticket templates and the quality bar | `.claude/skills/tickets/templates/` and `writing.md` |
| Commands Claude may run without asking | `.claude/settings.json` |

To add project knowledge that every engineer, reviewer, and QA run should have (a domain model, a tricky subsystem), put it in `docs/`, list it in the table at the top of `CLAUDE.md`, or create a skill under `.claude/skills/` and add its name to the `skills:` list of the agents that need it.

## Using Jira instead of markdown tickets

Only one skill knows that tickets are files. To switch:

```bash
grep -rn "JIRA:" CLAUDE.md .claude docs tickets
```

Then follow the steps at the top of `.claude/skills/tickets/SKILL.jira.md`: connect the Atlassian MCP server, fill in your cloud ID and project key, swap that file in as `SKILL.md`, and update the Tickets section of `CLAUDE.md`. The agents and commands only ever say "use the tickets skill", so they need no changes.

## Limits and trade-offs

- **One ticket at a time.** Ticket files are committed with the code on the ticket's branch, so a ticket's status is on its branch until it merges. That keeps code and status together in one merge, at the cost of parallel work. If you need several tickets in flight at once, use Jira.
- **It costs more tokens than vibe coding.** A full pipeline is at least three agent runs per ticket, more when review or QA sends work back. You are paying for the second and third pair of eyes. For a throwaway prototype, `/imp` alone is cheaper.
- **`/start` merges without asking.** It only merges work that passed review and QA, but it does not wait for you. Use `/pipeline` and `/ship` until you trust it on your project.
- **The quality gate is only as good as the project's tooling.** With no tests, linter, or typechecker, the agents have little to enforce. `/setup` creates tickets for those gaps; do them first.
- **Agents are not a substitute for reading your own code.** They catch a lot. They do not catch everything.

## Requirements

- [Claude Code](https://claude.com/claude-code)
- git, and bash (on Windows, Git Bash works)
- Optional: the GitHub CLI (`gh`), if you turn pull requests on

## License

MIT. See [LICENSE](LICENSE).
