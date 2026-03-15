---
name: stakeholder-brief
description: >
  This skill generates a stakeholder-specific briefing from the current canvas. Use this skill
  when the user says "brief the architect", "prepare a summary for", "what should [role] know",
  "onboard [person] to this spec", "generate a briefing", or when preparing a stakeholder to
  join an existing specification project. Pass the target role as argument:
  /ido4shape:stakeholder-brief architect
allowed-tools: Read, Glob
---

<briefing-protocol>

Read `.ido4shape/canvas.md`, `.ido4shape/stakeholders.md`, `.ido4shape/decisions.md`, and `.ido4shape/tensions.md`.

The target role is `$ARGUMENTS` (e.g., "architect", "ux", "business", "qa"). If no argument, ask: "Who am I preparing this briefing for?"

## Briefing Structure

Generate a briefing tailored to the target role's perspective. Reference `${CLAUDE_SKILL_DIR}/../../references/stakeholder-profiles.md` for what each role cares about.

**For a Product Manager:**
Focus on progress, decisions, open questions, and timeline implications.

**For a Technical Architect:**
Focus on solution shape, technical assumptions made without validation, risk areas, dependency questions, and performance/scale constraints.

**For a UX Designer:**
Focus on user flows involved, interaction patterns assumed, edge cases in the UI, and where user experience decisions are needed.

**For a Business Stakeholder:**
Focus on scope, timeline implications, trade-offs being considered, and business constraints that need confirmation.

**For QA:**
Focus on success conditions quality, testability of requirements, non-functional requirements, and test environment needs.

## Output Format

```markdown
# Briefing for [Role]: [Project Name]

## The Problem (2-3 sentences)
[Concise problem statement from the role's perspective]

## What's Been Decided
[Key decisions this person should know about — not relitigate, just be aware of]

## Where We Need Your Perspective
[Specific dimensions/questions where this role's input would change the spec]

## Active Tensions
[Any unresolved tensions relevant to this role]

## What You Should Look At
[Specific sections of the canvas, source materials, or artifacts worth reading]
```

The briefing should be short enough to read in 3 minutes. A stakeholder should be able to walk into a session after reading this and immediately contribute.

</briefing-protocol>
