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

<quality-standards>

## Task Description Quality

A task description must be rich enough for an agent (or engineer) to execute against without coming back to ask questions. Minimum 200 characters, but length alone isn't the bar — substance is.

**A good task description includes:**
- What the task does and WHY (not just "implement X" but "implement X because Y depends on it")
- Approach hints or patterns to follow
- Technical context (libraries, APIs, conventions to use)
- Integration points with other tasks (reference by ID)
- What the output looks like when done

**A bad task description:**
- "Implement the user preferences API" (too vague — what endpoints? what data model?)
- Just restates the title in longer form
- Focuses on HOW without explaining WHAT or WHY
- Lacks enough context for someone unfamiliar with the project

## Success Conditions

Each condition must be independently verifiable — a person could check it without checking any other condition.

**Good:** "Quiet hours spanning midnight work correctly (e.g., 22:00-08:00)"
**Bad:** "System handles edge cases correctly"

**Good:** "Schema validator returns all errors, not just the first"
**Bad:** "Validation works properly"

**Good:** "Preferences are cached with short TTL for routing engine performance"
**Bad:** "Performance is acceptable"

Test: Could two people independently agree whether this condition is met? If not, it's not specific enough.

## Effort Assessment

Be honest about effort. Common bias: underestimation.

| Value | Meaning | Signals |
|-------|---------|---------|
| S | Hours | Single function, clear interface, well-understood pattern |
| M | 1-2 days | Multiple components, some integration, moderate complexity |
| L | 3-5 days | Cross-cutting concerns, external integration, unfamiliar territory |
| XL | 1-2 weeks | High complexity, multiple unknowns, significant integration surface |

**Calibration questions:**
- Does this touch systems the team has never worked with? -> bump up
- Are there unknowns in the approach? -> bump up
- Has the team done exactly this before? -> probably accurate
- Does this require coordination with external teams? -> bump up

## Risk Assessment

Risk is about unknowns and their potential impact, not just difficulty.

| Value | Meaning |
|-------|---------|
| low | Well-understood, team has done this before, no external dependencies |
| medium | Some unknowns but manageable, team has related experience |
| high | Significant unknowns, external dependencies, first time for team |
| critical | Could derail the project, depends on uncontrolled factors, novel territory |

A task can be high-effort but low-risk (large but well-understood) or low-effort but high-risk (small but completely unknown).

## AI Suitability

This is a product judgment about how suitable a task is for AI agent execution:

| Value | When to use |
|-------|------------|
| full | Well-defined, mechanical, clear success conditions. An AI agent can do this autonomously. |
| assisted | AI can do the work but a human should review before merging. Default when unsure. |
| pair | Creative or ambiguous work where AI and human collaborate. UX decisions, architecture choices. |
| human | Requires human judgment that AI cannot replicate. Legal review, security audit, stakeholder negotiation, UX research with real users. |

**Common mistakes:**
- Marking everything as `full` (over-optimistic about AI capabilities)
- Marking everything as `human` (under-utilizing AI)
- Not considering that `pair` is often the best choice for complex tasks
- Ignoring that `human` blocks the `start` transition in ido4's BRE — use deliberately

## Group Quality

Groups should be:
- **Coherent:** All tasks serve the same business capability
- **Self-contained:** Delivering the group provides standalone value
- **Right-sized:** 3-8 tasks typically. 1 task isn't a group. 15+ tasks are probably two groups.
- **Naturally bounded:** The boundary should feel obvious, not forced

</quality-standards>
