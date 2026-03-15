---
name: synthesize-spec
description: >
  This skill crystallizes a knowledge canvas into a formal spec artifact. Use this skill
  when the user says "synthesize the spec", "create the artifact", "generate the spec file",
  "crystallize", "compose the spec", "we're ready to produce the spec", or when the
  /ido4shape:create-spec session determines that knowledge gathering is complete and the
  canvas is mature enough for composition.
allowed-tools: Read, Write, Edit, Glob
---

<synthesis-protocol>

This is a reasoning-intensive operation, not a formatting job. Every decision must trace back to the knowledge canvas.

## Pre-Flight Check

Before composing, verify readiness:

1. Read `.ido4shape/canvas.md` — the Understanding Assessment must show sufficient depth across all six dimensions WITH adequate perspective coverage
2. Read `.ido4shape/stakeholders.md` — verify key perspectives are represented
3. Read `.ido4shape/decisions.md` — all structural decisions should be settled
4. Read `.ido4shape/tensions.md` — no active tensions that affect group boundaries or dependencies
5. Check the Missing Perspectives section of the canvas — if critical perspectives are absent, warn before proceeding

If any dimension is thin, tensions are unresolved, or critical perspectives are missing, do NOT proceed — explain what's missing and suggest returning to `/ido4shape:create-spec`.

## Optional: Pre-Composition Review

If the spec is complex (4+ groups, 10+ tasks, multiple stakeholders contributed), recommend running `/ido4shape:review-spec` first. This launches three parallel reviewers (technical feasibility, scope alignment, dependency audit) that catch issues before composition, when fixes are cheap.

## Composition

Delegate the reasoning-intensive composition to the `canvas-synthesizer` sub-agent. This agent runs on Opus for maximum reasoning depth and operates in its own clean context window — critical for a task that requires holding the entire project structure in mind simultaneously.

The sub-agent reads the full `.ido4shape/` workspace (canvas, sessions, decisions, tensions, stakeholders) and produces the artifact. It follows the soul.md character in composition mode: precise, every word matters, descriptions rich enough to build from.

After the sub-agent completes, review the output:
- Verify the artifact is written to `[project-name]-spec.md` in the project root
- Run `/ido4shape:validate-spec` for independent quality verification
- If the spec-reviewer agent flags issues, offer to fix them via `/ido4shape:refine-spec`

</synthesis-protocol>
