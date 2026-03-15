---
name: quality-guidance
description: >
  This skill provides specification quality standards. It activates automatically whenever
  Claude is writing or reviewing task descriptions, success conditions, effort/risk assessments,
  AI suitability classifications, or evaluating *-spec.md file quality. Also triggers when
  writing to .ido4shape/canvas.md emerging structure sections, when the user mentions "quality",
  "acceptance criteria", "definition of done", "task description", "spec completeness", "is
  this good enough", "effort estimate", "risk level", "ai suitability", or when a
  /ido4shape:synthesize-spec or /ido4shape:validate-spec session is active.
user-invocable: false
---

## Task Description Quality

A task description should be rich enough for an engineer or agent to start working without coming back to ask questions. At least 200 characters, but substance matters more than length.

A good description includes what the task does and why, approach hints or patterns to follow, technical context, integration points with other tasks, and what the output looks like when done.

A weak description just restates the title in longer form or says "implement X" without context.

## Success Conditions

Each condition should be independently verifiable — someone could check it without checking any other condition.

Good: "Quiet hours spanning midnight work correctly (e.g., 22:00-08:00)"
Weak: "System handles edge cases correctly"

Test: could two people independently agree whether this condition is met?

## Effort Assessment

| Value | Meaning | Signals |
|-------|---------|---------|
| S | Hours | Single function, clear interface, well-understood pattern |
| M | 1-2 days | Multiple components, some integration, moderate complexity |
| L | 3-5 days | Cross-cutting concerns, external integration, unfamiliar territory |
| XL | 1-2 weeks | High complexity, multiple unknowns, significant integration surface |

If it touches systems the team hasn't worked with, or involves unknowns in the approach — bump up.

## Risk Assessment

Risk is about unknowns and their impact, not just difficulty.

- low: well-understood, team has done this before
- medium: some unknowns but manageable
- high: significant unknowns, external dependencies, first time for team
- critical: could derail the project, depends on uncontrolled factors

A task can be high-effort but low-risk (large but well-understood) or low-effort but high-risk (small but completely unknown).

## AI Suitability

- full: well-defined, mechanical, clear success conditions — AI can do this autonomously
- assisted: AI does the work, human reviews before merging. Default when unsure
- pair: creative or ambiguous work where AI and human collaborate
- human: requires judgment AI cannot replicate — legal, security, UX research, stakeholder negotiation

Note that `human` blocks the start transition in ido4's governance engine — use deliberately.

## Group Quality

Groups should be coherent (all tasks serve the same capability), self-contained (delivering the group provides standalone value), and right-sized (3-8 tasks typically).
