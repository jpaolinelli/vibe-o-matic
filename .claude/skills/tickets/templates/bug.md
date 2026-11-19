---
id: {{ID}}
title: "{{TITLE}}"
type: {{TYPE}}
priority: {{PRIORITY}}
epic: {{EPIC}}
depends_on: [{{DEPENDS}}]
estimate: {{ESTIMATE}}
severity: <Critical | High | Medium | Low>
created: {{DATE}}
---

# {{ID}}: {{TITLE}}

## Found During

<QA of T-xxx, review of T-xxx, or how a human noticed it.>

## Description

<What is wrong, in one or two sentences.>

## Steps to Reproduce

1. <step>
2. <step>

## Expected

<What should happen.>

## Actual

<What happens instead. Include the error text or wrong output.>

## Reproducing Test

<Path and name of the failing test that demonstrates the bug, or "none yet".>

## Acceptance Criteria

- [ ] The reproducing test passes
- [ ] A regression test covers this case and stays in the suite
- [ ] No regressions: the full test suite passes

## Activity

