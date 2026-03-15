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

## Briefing

Read the canvas, stakeholders file, decisions file, and tensions file from the project's `.ido4shape/` directory.

The target role is `$ARGUMENTS` (e.g., "architect", "ux", "business", "qa"). If no argument, ask who the briefing is for.

Generate a briefing tailored to the target role's perspective. See `${CLAUDE_SKILL_DIR}/../../references/stakeholder-profiles.md` for what each role cares about.

## Output Format

The briefing should be readable in 3 minutes:

- **The Problem** (2-3 sentences from the role's perspective)
- **What's Been Decided** (key decisions they should know, not relitigate)
- **Where We Need Your Perspective** (specific questions their expertise can answer)
- **Active Tensions** (unresolved tensions relevant to this role)
- **What to Look At** (specific canvas sections or source materials worth reading)
