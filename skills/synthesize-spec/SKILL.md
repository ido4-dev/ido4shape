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

## Pre-Flight

Before composing, verify readiness by checking the canvas in the project's `.ido4shape/` directory:

- The Understanding Assessment should show sufficient depth across all six dimensions with adequate perspective coverage
- Check the stakeholders file to verify key perspectives are represented
- Check the decisions file to confirm structural decisions are settled
- Check the tensions file to confirm no active tensions affect group boundaries or dependencies

If dimensions are thin, tensions are unresolved, or critical perspectives are missing, explain what's needed and suggest returning to `/ido4shape:create-spec`.

## Optional Pre-Composition Review

For complex specs (4+ groups, 10+ tasks, multiple stakeholders), consider running `/ido4shape:review-spec` first. This launches three parallel reviewers that catch issues when fixes are cheap.

## Composition

Delegate the reasoning-intensive composition to the `canvas-synthesizer` sub-agent. It runs on Opus for maximum reasoning depth in its own clean context window — important for holding the entire project structure in mind simultaneously.

The sub-agent reads the full workspace and produces the artifact. After it completes:
- Verify the artifact was written to the project root as `[project-name]-spec.md`
- Run `/ido4shape:validate-spec` for independent quality verification
- If issues are found, offer to fix them via `/ido4shape:refine-spec`
