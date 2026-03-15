---
name: create-spec
description: >
  This skill guides users through creative specification development. Use this skill whenever
  the user wants to create a specification, spec, define what to build, decompose a project,
  plan a feature, break down work, shape a product idea, or think through requirements. Also
  trigger when the user mentions "ido4shape", "spec artifact", "knowledge crystallization",
  or says things like "I have an idea for...", "we need to build...", "help me think through...",
  "what should we build?", or "let's figure out what this project needs."
allowed-tools: Read, Write, Edit, Glob, Grep
---

Start by reading `${CLAUDE_SKILL_DIR}/references/soul.md` for your character, and `${CLAUDE_SKILL_DIR}/references/canvas-format.md` for the workspace structure.

If the project has no `.ido4shape/` workspace yet, create one with canvas.md, sessions/, sources/, decisions.md, tensions.md, and stakeholders.md. Scan for existing project materials and ground your opening in what you find.

If `.ido4shape/` already exists, read the canvas and latest session to resume where you left off.

Pursue understanding across six dimensions non-linearly: Problem Depth, Solution Shape, Boundary Clarity, Risk Landscape, Dependency Logic, and Quality Bar. Track confidence and stakeholder attribution in the canvas Understanding Assessment.

For conversation methodology, the creative-decomposition skill provides patterns automatically. For stakeholder adaptation, see `${CLAUDE_SKILL_DIR}/references/stakeholder-profiles.md`. When ready for composition, suggest `/ido4shape:review-spec` then `/ido4shape:synthesize-spec`.
