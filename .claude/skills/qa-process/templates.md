# QA Process: Templates

<!-- CUSTOMIZE: add report sections for domain-specific checks you added to
     Step 5 of the qa-process skill. -->

## QA Report (Step 12)

Append to the ticket's Activity section.

```markdown
### <YYYY-MM-DD> qa-engineer: QA Report - <QA PASS | QA FAIL>

**Ticket**: <ID>: <title>
**Tested commit**: <short sha>

#### Build and Run
build PASS/FAIL | app starts PASS/FAIL | how it was run: <command or steps>

#### Regression Run
Full suite before QA tests: <passed>/<total>, <failed> failed
Regressions against base branch: none / <test names>
Failures proven pre-existing: none / <test names and how proven>

#### QA Tests Written
| File | Test | Category | Result |
|---|---|---|---|
| <path> | <name stating the attack> | boundary / invalid input / injection / auth / state / concurrency / dependency failure / volume / regression / ui | PASS/FAIL |

Full suite with QA tests: <passed>/<total>

#### Manual Checks
<What was exercised by hand, the exact steps, and what was observed. "None" if everything is automated.>

#### Acceptance Criteria Verification
| Criterion | Test(s) or manual check | Verified | Notes |
|---|---|---|---|

#### Findings
1. **<Title>** (Critical | High | Medium | Low)
   - Where: <file:line or screen>
   - What happens: <actual>
   - Expected: <expected>
   - Reproduce: <failing test name, or steps>
   - In scope of this ticket: yes / no (bug filed: <ID>)

#### Bugs Filed
- <ID>: <title>   (or "none")

#### Verdict: <QA PASS | QA FAIL>
<One or two sentences. On QA FAIL, list what the engineer must make pass.>
```

## Bug Ticket (Step 10)

Create with the `tickets` skill (`new bug "<Area>: <what goes wrong>" --priority <P1|P2|P3>`), then fill in the bug template: Found During, Description, Steps to Reproduce, Expected, Actual, Reproducing Test, severity.

Priority from severity: Critical or High is `P1`, Medium is `P2`, Low is `P3`.
