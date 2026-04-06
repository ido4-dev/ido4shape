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

## Source Material Reconciliation

Before invoking the synthesizer, check for source materials in the project folder — plans, design documents, architecture docs, meeting notes, anything the user brought into the session. Compare their substantive content against what's captured in the canvas.

If source materials exist and contain substantive content not reflected in the canvas:
1. List the items that weren't contradicted by conversation but also weren't captured in the canvas
2. Present the list to the user: "These items from your source materials weren't discussed — should they be included in the spec, excluded, or discussed before synthesis?"
3. For items the user confirms should be included, add them to the canvas before synthesis

This prevents content loss. The synthesizer works primarily from the canvas — anything not in the canvas is at risk of being lost. Source materials that were extensively discussed in conversation are already in the canvas. But specific mechanisms, metrics, or design details that were implicitly endorsed (not contradicted) may not be.

## Pre-Composition Review

For specs with 4+ groups or 10+ capabilities, run `/ido4shape:review-spec` before synthesis. The dependency auditor catches structural issues that are expensive to fix after the spec is written. If review-spec hasn't been run, tell the user: "Independent review hasn't been run yet. The dependency auditor catches issues the synthesizer often misses. Run `/ido4shape:review-spec` first?"

## Composition

Delegate the reasoning-intensive composition to the `canvas-synthesizer` sub-agent. It runs on Opus for maximum reasoning depth in its own clean context window — important for holding the entire project structure in mind simultaneously.

The sub-agent reads the full workspace and produces the strategic spec artifact. After it completes:
- Verify the artifact was written to the project root as `[project-name]-spec.md`
- Verify it includes `format: strategic-spec | version: 1.0` in the project metadata
- Run `/ido4shape:validate-spec` for independent quality verification

## Post-Validation

The user didn't write the spec — the synthesizer did. Format drift (wrong section headings, inline success conditions, numbered lists instead of bullets, missing metadata labels) is the system's problem. Content quality (thin descriptions, vague conditions, synthesis loss) is the user's domain.

### Auto-fix format findings (Pass 1)

If Pass 1 reports structural or completeness failures, fix them directly via edits to the spec file. These are mechanical: restructure labels, convert list formats, add missing metadata markers, fix broken dependency references. Re-run validate-spec to confirm fixes landed. Do not show format findings to the user unless a fix is genuinely ambiguous (e.g., circular dependency where the correct direction isn't clear from context — that needs user judgment).

### Present content findings (Pass 2) to user

If Pass 2 reports content assertion violations (A1-A12), present these to the user. Content quality and synthesis integrity are their domain:

- Thin descriptions, vague success conditions, missing stakeholder context → the user decides whether to refine
- Canvas content lost during synthesis (stakeholders, concerns, decisions dropped) → the user needs to know what didn't survive
- Ambiguous risk calibration or missing attribution → the user has the context to judge

Present content findings in plain language. If format auto-fixes were applied, mention them in one sentence ("4 format issues were fixed automatically"). Propose the next step: `/ido4shape:refine-spec` to address content issues. Wait for the user to decide.

### Clean spec

If both passes are clean (after format auto-fixes), tell the user the spec is ready. Name what's strong — content quality, synthesis integrity, canvas preservation. Propose next step: `/ido4shape:stakeholder-brief` for sharing, or downstream decomposition.
