# Code Review: Detailed Output Template

Read this at Step 8 of the `code-review-process` skill. Append the filled-in review to the ticket's Activity section (and to the pull request when pull requests are on). The invoker receives only the compact line.

<!-- CUSTOMIZE: add rows to the Ground-Rule Sweep table to match the numbered
     Ground Rules in CLAUDE.md, and file categories that match your layout. -->

```markdown
### <YYYY-MM-DD> reviewer: Review v<N> - <APPROVED | CHANGES REQUESTED>

**Ticket**: <ID>: <title>
**Reviewed commit**: <short sha>

#### Static Gates
build PASS/FAIL | format PASS/FAIL | lint PASS/FAIL | typecheck PASS/FAIL

#### Files Reviewed
| Category | Files | Lines changed |
|---|---|---|
| Source | N | N |
| Tests | N | N |
| Docs / config / other | N | N |

#### Completeness
| Criterion | Status | Evidence |
|---|---|---|
| <criterion> | PASS / WARN-LOW / WARN-MED / FAIL | <file, function, or test> |

Checklist items all present: yes/no. Out-of-scope changes: none / <list>.

#### Ground-Rule Sweep
| Rule | Status | Note |
|---|---|---|
| 1. <rule from CLAUDE.md> | PASS/FAIL | |

#### Security
<Findings, or "No issues found" with one line on what was checked.>

#### Reusability
<Duplication found, missed reuse, misplaced shared code, or "No issues found".>

#### Code Quality
<Findings, or "No issues found".>

#### Test Quality
<Which criteria lack a meaningful test; tests that could not fail; missing edge cases.>

#### Issues
1. **<Title>** (High | Medium | Low)
   - Where: <file:line>
   - Problem: <what is wrong and why it matters>
   - Fix: <what needs to change>

#### Verdict: <APPROVED | CHANGES REQUESTED>
<One or two sentences of justification. On CHANGES REQUESTED, list the blocking issue numbers.>
```
