# Knowledge Canvas Format

The canvas is the central document of the knowledge gathering phase. It lives at `.ido4shape/canvas.md` in the project workspace.

## Structure

The canvas evolves organically. Don't force structure early — let it emerge. But always include the Understanding Assessment.

### Early Canvas (After Initial Conversation)

```markdown
# [Project Name] — Knowledge Canvas

## Understanding Assessment
- Problem Depth: [signal] — [brief explanation]
- Solution Shape: [signal] — [brief explanation]
- Boundary Clarity: [signal] — [brief explanation]
- Risk Landscape: [signal] — [brief explanation]
- Dependency Logic: [signal] — [brief explanation]
- Quality Bar: [signal] — [brief explanation]

## Problem Understanding

[Narrative — rich with specifics, quotes, examples. Who suffers, how, why now.]

## Initial Solution Concepts

[Fuzzy, directional. What capabilities might need to exist.]

## Constraints & Non-Goals

**Constraints:**
- [Hard constraint with rationale]

**Non-goals:**
- [What we're NOT doing and why]

## Open Questions

- [Genuine unknowns that affect direction]

## Key Insights

- [Things discovered that changed understanding]
```

### Mature Canvas (Ready for Review)

```markdown
# [Project Name] — Knowledge Canvas

## Understanding Assessment
- Problem Depth: deep — can articulate from 3 stakeholder perspectives
- Solution Shape: clear — 4 capability clusters identified, boundaries feel natural
- Boundary Clarity: solid — constraints locked, 1 open question remains
- Risk Landscape: mapped — 2 high-risk areas identified with mitigation thoughts
- Dependency Logic: visible — critical path traced, cross-group deps documented
- Quality Bar: defined — success conditions discussed for all major work areas

## Problem Understanding

[Multi-perspective, rich. Technical and business dimensions both covered.]

## Solution Architecture

### Capability Cluster: [Name]
[Description. What it delivers. Why these capabilities belong together.]

Work areas:
- [Proto-task: description, estimated complexity, risk notes]
- [Proto-task: ...]

### Capability Cluster: [Name]
[...]

## Dependencies

[How clusters relate. What must exist before what. Critical path.]

## Risk Assessment

[Specific risks with severity and potential mitigation.]

## Constraints & Non-Goals

[Locked in — these are guardrails for the spec.]

## Resolved Tensions

- [Tension] — resolved by [what/who]: [outcome]

## Open Questions

- [Remaining genuine unknowns]

## Key Decisions

- [Decision]: [rationale]
```

## Update Rules

- The canvas represents CURRENT understanding. When new input changes the picture, update in place.
- Don't preserve old versions in the canvas — that's what session summaries handle.
- Update the Understanding Assessment after every substantive exchange.
- Use honest language in confidence signals: "deep", "forming", "solid", "thin", "not started", "emerging", "clear", "uncertain".
- Proto-tasks in capability clusters should include enough detail that they could become real tasks, but they're not formal yet.

## Session Summary Format

Session summaries go in `.ido4shape/sessions/session-NNN-[role].md`:

```markdown
# Session NNN — [Role] (e.g., PM, Architect)

**Date:** YYYY-MM-DD

## Key Insights
- [What was learned that mattered]

## Decisions Made
- [Decision]: [rationale]

## Tensions Surfaced
- [Tension]: [status — active/parked]

## Notable Statements
- "[Direct quote that captures something important]"

## Next Session Focus
- [What to explore next based on thinnest understanding dimensions]
```
