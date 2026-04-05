---
name: validate-spec
description: >
  This skill validates a strategic spec artifact for format compliance and content quality. Use
  this skill when the user says "validate the spec", "check the spec", "review the artifact",
  "is this spec valid?", or wants to verify a spec file before sharing or downstream processing.
  Pass the file path as argument: /ido4shape:validate-spec path/to/spec.md
allowed-tools: Read, Glob, Grep, Bash
---

## What to Validate

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

## Two-Pass Validation

This skill performs validation in two passes. Both passes are required.

### Pass 1 — Structural Validation (deterministic)

Run the spec format parser against the artifact:

```bash
node "${CLAUDE_PLUGIN_DATA}/spec-validator.js" <path-to-spec.md>
```

The parser outputs JSON to stdout. Parse it and use the full output for intelligent interpretation.

If the CLI is not available (file not found or node error), skip this pass and note it in the report. Do NOT attempt to replicate the parser's structural checks manually — the whole point is deterministic validation.

#### Interpreting Parser Output

Do not just relay errors. Diagnose them. Every error has a root cause and a specific fix.

**Broken dependency references** (`depends on "X" which does not exist`):
- Look at the `groups` in the parser output to find which capability IDs DO exist
- Infer the intended target from the broken ref's prefix and the capability's description
- Example: NCO-03 depends on "NCO-99" — look at existing NCO-* capabilities, read NCO-03's description, suggest the correct dependency

**Circular dependencies** (`Circular dependency detected: A → B → A`):
- Read each capability's description to understand the intended data/control flow
- Identify which dependency direction is wrong — usually the one that reverses the natural flow (data model before routing, infrastructure before features)
- Suggest which specific edge to remove and why

**Duplicate capability refs** (`Duplicate capability ref: X`):
- Identify both capabilities with the same ref
- Suggest renaming the second one — derive the next available number in the group's sequence

**Missing format marker**:
- This means the first blockquote after the project heading is missing or malformed
- Show what the line should look like: `> format: strategic-spec | version: 1.0`

**Invalid metadata values** (wrong priority, risk, unknown keys):
- Show the allowed values
- If the value is close to a valid one (e.g., "critical" instead of "high"), suggest the correct mapping
- If implementation-level keys appear (effort, type, ai, size) — explain these belong in the technical spec, not the strategic spec

**Metric anomalies** — interpret the `metrics` object:
- Groups with 0 capabilities: the group was declared but nothing was added — likely an incomplete synthesis
- Orphan capabilities (outside any group): these need a home
- Unbalanced groups (one has 8, another has 1): consider merging the small group or splitting the large one
- Max dependency depth > 4: deep chains make decomposition harder — look for opportunities to parallelize
- Zero dependency edges with multiple capabilities: suspicious — most real systems have inter-capability dependencies

#### Completeness Checks

The parser emits the full structural model of the spec as JSON — not just errors. Read the non-error fields and apply ido4shape's completeness policy. These are structural failures, not content warnings:

**Stakeholders present** — If `project.stakeholders` is an empty array, the Stakeholders bold-label section is missing from the project metadata area, OR it was written as an H2 section (like `## Stakeholders` or `## Stakeholder Attribution`) which the parser treats as an unknown H2 and ignores. The fix is to place `**Stakeholders:**` as a bold label directly under the project description, before `## Cross-Cutting Concerns`, followed by a bullet list of contributors.

**Constraints present** — If `project.constraints` is an empty array, the Constraints bold-label section is missing. Every strategic spec should capture at least one hard constraint with rationale. An empty array usually means the section was written as an H2 instead of a bold label.

**Groups present and non-empty** — `groups.length === 0` means the spec has no capability groups at all. Any group with `capabilityCount === 0` means an empty group was declared. Both are structural failures.

**Project identity** — `project.name` must be non-empty and `project.format` must equal `"strategic-spec"`. A missing format marker means the `> format: strategic-spec | version: 1.0` metadata line is missing or malformed.

**Project description present** — If `project.description` is empty or shorter than 50 characters, the project description narrative is missing or malformed. The description lives as free-text prose directly below the format marker. If the synthesizer wrapped it in an H2 section (like `## Problem Statement`), the parser treats the H2 as an unknown section and returns empty description. The code-analyzer downstream depends on this field for project context during capability analysis — an empty description leaves it without orientation. Escalate as **FAIL**.

**Open questions present** — If `project.openQuestions` is an empty array, the `**Open questions:**` bold-label section is missing or its bullets weren't recognized (e.g., numbered list `1.` instead of bullets `-`). Open questions are informational context for downstream — missing them doesn't block decomposition but loses honest uncertainty signals. Escalate as **WARNING** (not FAIL).

Empty required fields are structural failures, not cosmetic drift. Silent content loss — where the synthesizer wrote content in the wrong place or structure, the parser can't find it, and downstream tools get nothing — is exactly what completeness checks exist to prevent.

### Pass 2 — Content Quality (LLM judgment)

Read the spec file and assess what only judgment can evaluate:

- Capability descriptions at least 200 characters with multi-stakeholder context
- Descriptions carry the WHY, not just the WHAT — stakeholder perspectives, not implementation approach
- Success conditions present, specific, independently verifiable, product-level
- Cross-cutting concerns have specific targets, not template filler
- Stakeholders section lists real contributors with real perspectives
- Constraints have rationale
- Priority calibration plausible (not everything is must-have)
- Strategic risk reflects actual unknowns, not guessed code complexity
- No implementation-level metadata (effort, type, ai, size)

#### Canvas Cross-Reference

If the workspace has a canvas, compare what was captured against what made it to the spec:

- Stakeholders in the canvas but missing from the spec's Stakeholders section
- Cross-cutting concerns discussed in conversations but absent from the spec
- Constraints or non-goals that were captured but lost during synthesis
- Stakeholder perspectives that appear in the canvas but not attributed in capability descriptions

This catches synthesis loss — insights that were gathered but didn't survive crystallization.

#### Downstream Awareness

Frame content quality findings in terms of what any consumer of the spec needs — whether that's a human team, an AI coding agent, or a decomposition pipeline:

- Thin descriptions make it harder for anyone acting on the spec to understand scope and intent
- Missing success conditions mean whoever builds this has to guess what "done" means
- Absent cross-cutting concerns lead to implementations that ignore NFRs
- Missing stakeholder attribution loses the "why" — consumers won't know which constraints come from which stakeholder

## Combined Report

Merge both passes into a single, actionable report:

**Summary:** counts from parser metrics — groups, capabilities, cross-cutting concerns, dependency edges, max depth

**Structural Validation:**
- Parser verdict (VALID / INVALID)
- For each error: what's wrong, where, and the specific fix
- For each warning: what it means and whether action is needed

**Content Quality:**
- Findings organized as errors (must fix), warnings (should fix), suggestions (could improve)
- Canvas cross-reference findings (if canvas exists)

**Dependency Graph:** from parser output, rendered as a readable list with critical path highlighted

**Verdict:** PASS / PASS WITH WARNINGS / FAIL

Any structural error from the parser OR completeness failure means FAIL. A missing required field — empty stakeholders, empty constraints, empty groups, or a group with no capabilities — is structural, not stylistic. Surface these as errors rather than filtering them out. Content warnings alone mean PASS WITH WARNINGS.

**When the verdict is FAIL**, offer to fix via `/ido4shape:refine-spec`. Rather than making judgment calls about what's "worth fixing," surface every structural finding and every completeness failure so the user can decide which to refine. For each issue, describe the specific edit needed (what section, what structure, where the content should live) so the user can approve it.
