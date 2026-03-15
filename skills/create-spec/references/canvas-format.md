# Knowledge Canvas Format

The canvas is the central document of the knowledge gathering phase. It lives at `.ido4shape/canvas.md` in the project workspace.

## Structure

The canvas evolves organically. Don't force structure early — let it emerge. But always include the Understanding Assessment with perspective tracking.

### Early Canvas (After Initial Conversation)

```markdown
# [Project Name] — Knowledge Canvas

## Understanding Assessment
- Problem Depth: [signal] ([stakeholders]) — [brief explanation]
- Solution Shape: [signal] ([stakeholders]) — [brief explanation]
- Boundary Clarity: [signal] ([stakeholders]) — [brief explanation]
- Risk Landscape: [signal] ([stakeholders]) — [brief explanation]
- Dependency Logic: [signal] ([stakeholders]) — [brief explanation]
- Quality Bar: [signal] ([stakeholders]) — [brief explanation]

### Missing Perspectives
- [Dimension]: would benefit from [role] input because [reason]

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
- Problem Depth: deep (PM, architect, UX) ████████████ — multi-perspective, validated
- Solution Shape: clear (PM, architect) ██████████░░ — UX hasn't reviewed interaction model
- Boundary Clarity: solid (PM, business) ████████████ — constraints confirmed by business
- Risk Landscape: mapped (architect, PM) ██████████░░ — business risks not assessed
- Dependency Logic: clear (architect) █████████░░░ — single-perspective but technically sound
- Quality Bar: defined (PM, UX) ██████████░░ — QA hasn't reviewed testability

### Missing Perspectives
- Quality Bar: QA perspective on testability would strengthen success conditions
- Solution Shape: UX review of interaction model before groups crystallize

### Stakeholder Contributions
| Stakeholder | Sessions | Primary Dimensions | Last Active |
|-------------|----------|--------------------|-------------|
| PM (Sarah) | 1, 2, 4 | Problem, Boundaries, Quality | Mar 12 |
| Architect (James) | 3 | Risk, Dependencies, Solution | Mar 13 |
| UX (Maria) | 5 | Quality, Solution (UI) | Mar 14 |

## Problem Understanding

[Multi-perspective, rich. Technical and business dimensions both covered.]
[Attribution where it matters: "The architect noted that..." / "From the PM's perspective..."]

## Solution Architecture

### Capability Cluster: [Name]
[Description. What it delivers. Why these capabilities belong together.]
[Which stakeholder perspectives shaped this cluster.]

Work areas:
- [Proto-task: description, estimated complexity, risk notes]
- [Proto-task: ...]

### Capability Cluster: [Name]
[...]

## Dependencies

[How clusters relate. What must exist before what. Critical path.]

## Risk Assessment

[Specific risks with severity, source stakeholder, and potential mitigation.]

## Cross-Stakeholder Tensions

| Tension | Stakeholders | Status | Resolution |
|---------|-------------|--------|------------|
| [Description] | PM vs Architect | Active/Resolved | [How resolved or resolution paths] |

## Constraints & Non-Goals

[Locked in — these are guardrails for the spec.]

## Open Questions

- [Remaining genuine unknowns]

## Key Decisions

- [Decision]: [rationale] — decided by [who] in session [N]
```

## Update Rules

- The canvas represents CURRENT understanding. When new input changes the picture, update in place.
- Don't preserve old versions in the canvas — that's what session summaries handle.
- Update the Understanding Assessment after every substantive exchange, including perspective attribution.
- Use honest language in confidence signals: "deep", "forming", "solid", "thin", "not started", "emerging", "clear", "uncertain".
- The heat map bars (████░░░░) are a quick visual: filled = covered perspectives, empty = missing.
- Track which stakeholder contributed which insight — this matters when tensions surface.
- When a new stakeholder session reshapes existing understanding, note what changed and why.

## Stakeholders File

`.ido4shape/stakeholders.md` tracks all contributors:

```markdown
# Stakeholders

## Sarah Chen — Product Manager
- Role: PM
- First session: 2026-03-10
- Sessions: 1, 2, 4
- Communication style: Thinks in stories and scenarios. Prefers open-ended exploration.
- Key contributions: Problem framing, user personas, scope boundaries, success criteria from user perspective.

## James Park — Technical Architect
- Role: Architect
- First session: 2026-03-13
- Sessions: 3
- Communication style: Direct, prefers specific technical questions. Values efficiency.
- Key contributions: Infrastructure feasibility, async architecture recommendation, APNs risk identification, dependency graph.
```

## Session Summary Format

Session summaries go in `.ido4shape/sessions/session-NNN-[role].md`:

```markdown
# Session NNN — [Role]: [Name]

**Date:** YYYY-MM-DD

## Key Insights
- [What was learned that mattered]

## Decisions Made
- [Decision]: [rationale]

## Tensions Surfaced
- [Tension]: [status — active/parked] — [stakeholders involved]

## Perspective Shifts
- [What changed in the canvas because of this stakeholder's input]

## Notable Statements
- "[Direct quote that captures something important]"

## Next Session Focus
- [What to explore next based on thinnest dimensions and missing perspectives]
```
