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

**Project description present** — If `project.description` is empty or shorter than 50 characters, either the description is missing OR the parser didn't recognize the format. The parser currently captures description only from blockquote lines (`> `) between the format marker and `**Stakeholders:**`. Plain-text paragraphs in that position are NOT captured (known parser/docs mismatch — the natural plain-text format isn't yet recognized by the parser). Escalate as **WARNING** (not FAIL) — content may be present in the file but invisible to the parser. Pass 2 reads the raw markdown directly and is the authoritative check on description substance.

**Open questions present** — If `project.openQuestions` is an empty array, the `**Open questions:**` bold-label section is missing or its bullets weren't recognized (e.g., numbered list `1.` instead of bullets `-`). Open questions are informational context for downstream — missing them doesn't block decomposition but loses honest uncertainty signals. Escalate as **WARNING** (not FAIL).

**Capability success conditions present** — For each capability in the parser output, check `successConditions.length`. If the array is empty, the synthesizer wrote success conditions inline in prose (e.g., "Success conditions: (1) X… (2) Y…") instead of under the required `**Success conditions:**` bullet sublabel. The content may be present in the capability body but is invisible to downstream JSON consumers — a decomposition agent parsing the spec gets no grounding for what "done" means for that capability. Any capability with empty successConditions → **FAIL per capability**. Fix: extract inline success-conditions text into a `**Success conditions:**` sublabel followed by bullet lists at the end of each capability body.

Empty required fields are structural failures, not cosmetic drift. Silent content loss — where the synthesizer wrote content in the wrong place or structure, the parser can't find it, and downstream tools get nothing — is exactly what completeness checks exist to prevent.

### Pass 2 — Content Quality (LLM judgment)

Read the spec file directly. Apply assertions about whether the content is fit for downstream decomposition — a code-analyzer agent that will read this spec, explore a codebase, and produce technical tasks. Each assertion is binary: satisfied or violated. Violations escalate to **FAIL** when they would break downstream decomposition, **WARNING** when they degrade usefulness without breaking it.

Pass 1 (parser) guards structure and presence. Pass 2 (this) guards substance. No character thresholds, no counting — assertions are answered by reading the spec as a decomposer would.

#### Project-level assertions

Read the project header, description, Stakeholders, Constraints, Non-goals, Open questions, and Cross-Cutting Concerns sections. Apply each assertion in turn:

**A1. Project description carries problem + stakes + stakeholder voice.** A decomposer reading only the description should understand what problem this addresses, who suffers, and why solving it now matters. Narrative, not summary.
- Violated → **FAIL** when: single summary sentence, pure feature enumeration, or no stakes named.
- Violated → **WARNING** when: present but stakeholder voice is thin or stakes aren't concrete.

**A2. Stakeholders carry real perspectives.** Each stakeholder entry states what perspective they brought — architectural concern, product lens, operational constraint — not just a role label.
- Violated → **WARNING** when: entries are role labels without perspective, or perspectives are generic ("cares about performance").

**A3. Constraints carry rationale.** Each constraint states why it's a constraint — a stakeholder concern, architectural reason, regulatory driver, or business reality.
- Violated → **WARNING** when: constraints listed without reasoning.

**A4. Cross-cutting concerns have substance.** Each concern section contains specific targets, stakeholder attribution, or concrete requirements — not template filler.
- Violated → **FAIL** when: section exists but contains only placeholder language or generic statements with no targets or attribution.
- Violated → **WARNING** when: substance thin but some content present.

#### Capability-level assertions

For each capability, read its description, metadata, success conditions, and dependencies. Apply each assertion in turn:

**A5. Description carries stakeholder WHY.** The description explains why this capability is needed and who needs it, not just what it does. A decomposer should understand the problem context and stakeholder perspective, not just the feature shape.
- Violated → **FAIL** when: description is pure WHAT (feature behavior, output specification) with no stakeholder context or problem framing.
- Violated → **WARNING** when: stakeholder context present but thin or implicit.

**A6. Success conditions are independently verifiable.** Someone who wasn't in the conversation should be able to read each condition and know whether it's been met.
- Violated → **FAIL** when: conditions are vague ("works correctly", "is reliable", "performs well") or circular ("X is done when X works").
- Violated → **WARNING** when: mix of specific and vague conditions.

**A7. Strategic risk reflects genuine unknowns.** The risk label (low/medium/high) matches actual uncertainty — external dependencies, stakeholder disagreement, unknown behavior, novel territory. Not code complexity or implementation difficulty.
- Violated → **WARNING** when: risk seems miscalibrated (high on a clear path, low on a fuzzy area).

**A8. Description does not prescribe implementation.** Descriptions describe what the capability provides and why, not how it should be built.
- Violated → **WARNING** when: description specifies technology choices, architectural patterns, or code structure.

#### Canvas cross-reference (mandatory when canvas exists)

If `.ido4shape/canvas.md` is present in the workspace, compare the canvas (and session summaries, decisions, stakeholders files) against the spec. These assertions catch synthesis loss — substance the conversation produced but the synthesizer dropped.

**A9. Canvas stakeholders preserved in spec.** Every stakeholder captured in the canvas or `stakeholders.md` appears in the spec's Stakeholders section with matching perspective. Merging or reframing is fine; silent omission is not.
- Violated → **FAIL** when: canvas stakeholders absent from spec's Stakeholders section.
- Violated → **WARNING** when: stakeholders present but their perspectives generalized or lost.

**A10. Canvas cross-cutting concerns preserved in spec.** Every concern discussed in the canvas appears in the spec's Cross-Cutting Concerns section. Merging two canvas concerns into one spec concern is fine; silent omission is not.
- Violated → **FAIL** when: concerns discussed in canvas but not represented in spec.

**A11. Canvas decisions reflected in spec.** Every decision from `decisions.md` appears as a constraint, non-goal, or shapes a capability description. Decisions that don't show up in the spec were effectively lost.
- Violated → **FAIL** when: decisions made but not encoded in spec.

**A12. Stakeholder perspectives attributed in capability descriptions.** Perspectives captured in session summaries appear in capability descriptions with attribution ("per the architect", "the PM flagged", "operations raised").
- Violated → **WARNING** when: perspectives present in canvas but not attributed in capabilities that depend on them.

#### Downstream awareness

Frame all Pass 2 findings in terms of what the downstream code-analyzer agent needs to produce good technical tasks:
- Thin descriptions mean capability analysis is thin — generated tasks will miss stakeholder concerns.
- Vague success conditions mean task decomposition has no grounding for "done."
- Canvas loss means the conversation's substance never reaches the codebase.
- Missing attribution means constraints travel through the pipeline without knowing which stakeholder they serve.

## Combined Report

The report is for the user, not a parser trace. The user needs to know: is my spec ready? If not, what's wrong in their own terms? What action should I take next?

Synthesize findings from both passes into a user-facing report. Describe problems in domain language, not parser field names. Lead with verdict and action. Keep technical trace short and last.

### Report structure

**Verdict (first, one line with plain-language summary):**
- PASS — "Spec is ready for downstream decomposition."
- PASS WITH WARNINGS — "Spec is usable but has N issues worth addressing."
- FAIL — "Spec has N blocking issues that prevent reliable decomposition."

**What's working (one paragraph):** Name the content strengths in plain language, informed by Pass 2 assertions that passed. Examples: "Problem framing is rich and stakeholder-grounded," "Cross-cutting concerns carry specific targets," "Canvas stakeholders and decisions are preserved." Do not list assertion IDs in this paragraph.

**What needs fixing (findings list, ordered FAIL first, then WARNING):** For each finding:
- State the issue in user terms, not parser internals. Example — YES: "Your 25 capabilities have success conditions written inline in prose instead of under a dedicated bullet list. Downstream tools that read the parsed format will see nothing for any capability." NO: "successConditions array is empty in 25 capabilities" or "parser expects `**Success conditions:**` sublabel."
- Cite the specific location (which capability, which section).
- One-sentence downstream impact (why it matters).
- The specific edit needed.

**Next step (clear action):**
- Findings exist → "Run `/ido4shape:refine-spec` to fix these."
- Clean spec with canvas → "Ready for `/ido4shape:stakeholder-brief` or downstream decomposition."
- Parser unavailable → note that structural validation was skipped, Pass 2 is the only signal.

**Supporting metrics (short, last):** Counts — groups, capabilities, cross-cutting concerns, dependency edges, max depth. Critical path if dependency depth > 3. One paragraph, reference material only.

### Verdict rollup rules

Roll up findings mechanically across both passes:
- Any structural error from the parser (Pass 1) → **FAIL**
- Any Pass 1 completeness failure (empty required fields, including per-capability failures) → **FAIL**
- Any Pass 2 assertion violated at FAIL severity → **FAIL**
- Only Pass 1 warnings and/or Pass 2 WARNING-grade violations, no FAILs → **PASS WITH WARNINGS**
- All Pass 1 checks clean, all Pass 2 assertions satisfied → **PASS**

Do not apply judgment-call filtering. Every finding — structural, completeness, assertion violation — surfaces to the user. The user decides what to refine. The assistant does not silently dismiss findings as "cosmetic" or "not worth fixing."

### Handoff to refine-spec

When the user accepts the offer to refine, pass each finding with its technical trace so refine-spec can act:
- The check or assertion ID (e.g., "A5" or "Pass 1: Capability success conditions present")
- The specific section or capability affected
- The structural edit needed (which section, which label, which format)

The user-facing report speaks user language. The refine-spec handoff speaks technical language. These are two different outputs from the same findings.
