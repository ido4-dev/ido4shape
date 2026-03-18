---
name: synthesize-spec
description: >
  This skill crystallizes a knowledge canvas into a strategic spec artifact. Use this skill
  when the user says "synthesize the spec", "create the artifact", "generate the spec file",
  "crystallize", "compose the spec", "we're ready to produce the spec", or when the
  /ido4shape:create-spec session determines that knowledge gathering is complete and the
  canvas is mature enough for composition.
allowed-tools: Read, Write, Edit, Glob
---

## Pre-Flight

Before composing, verify readiness by checking the canvas in the project workspace:

- The Understanding Assessment should show sufficient depth across dimensions — particularly Problem Depth, Solution Shape, and Boundary Clarity
- Multiple stakeholder perspectives should be represented (check stakeholders file) — a single-perspective spec is weaker than one shaped by PM + architect + UX
- Check the decisions file — structural decisions (group boundaries, scope, constraints) should be settled
- Check the tensions file — no active tensions that affect group boundaries or capability definitions
- Cross-cutting concerns should have substance — if the conversation surfaced performance targets, security requirements, or NFRs, they should be captured in the canvas

The readiness threshold for a strategic spec is different from an implementation-ready one: you don't need enough detail to estimate effort, but you DO need rich stakeholder perspectives, clear success conditions, and captured cross-cutting concerns. If the canvas is thin on stakeholder coverage or has empty cross-cutting concerns despite relevant conversations, suggest returning to `/ido4shape:create-spec` to fill gaps.

## Optional Pre-Composition Review

For complex specs (4+ groups, 10+ capabilities, multiple stakeholders), consider running `/ido4shape:review-spec` first. This launches parallel reviewers that catch issues when fixes are cheap.

## Composition

Delegate the reasoning-intensive composition to the `canvas-synthesizer` sub-agent. It runs on Opus for maximum reasoning depth in its own clean context window — important for holding the entire project structure in mind simultaneously.

The sub-agent reads the full workspace and produces the strategic spec artifact. After it completes:
- Verify the artifact was written to the project root as `[project-name]-spec.md`
- Verify it includes `format: strategic-spec | version: 1.0` in the project metadata
- Verify stakeholder attribution survived crystallization (names/roles appear in descriptions)
- Verify cross-cutting concerns section has substance, not template filler
- Run `/ido4shape:validate-spec` for independent quality verification
- If issues are found, offer to fix them via `/ido4shape:refine-spec`
