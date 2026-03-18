---
name: validate-spec
description: >
  This skill validates a strategic spec artifact for format compliance and content quality. Use
  this skill when the user says "validate the spec", "check the spec", "review the artifact",
  "is this spec valid?", or wants to verify a spec file before handoff to ido4 MCP. Pass the
  file path as argument: /ido4shape:validate-spec path/to/spec.md
allowed-tools: Read, Glob, Grep
---

## What to Validate

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

## Format Checks

**Project header:** One `#` heading with `> format: strategic-spec | version: 1.0` in metadata blockquote. Problem description, Stakeholders section, Constraints, Non-goals, Open questions.

**Cross-Cutting Concerns:** `## Cross-Cutting Concerns` section with subsections. Not required if no cross-cutting concerns were discussed, but flag if the canvas shows they were captured but didn't make it to the spec.

**Groups:** `## Group: Name` format with `>` metadata containing priority from allowed set (must-have, should-have, nice-to-have).

**Capabilities:** `### PREFIX-NN: Title` where PREFIX is 2-5 uppercase letters and NN is 2-3 digits. Prefix matches parent group. Metadata with priority, risk (low/medium/high), depends_on.

**Dependencies:** All depends_on references point to existing capability IDs. No circular chains.

**Not present:** effort, type, ai, size — if these appear, flag as error. Strategic specs don't include implementation-level metadata.

## Content Quality

- Capability descriptions at least 200 characters with multi-stakeholder context
- Descriptions carry the WHY, not just the WHAT — stakeholder perspectives, not implementation approach
- Success conditions present, specific, independently verifiable, product-level
- Cross-cutting concerns have specific targets, not template filler
- Stakeholders section lists real contributors with real perspectives
- Constraints have rationale
- Priority calibration plausible (not everything is must-have)
- Strategic risk reflects actual unknowns, not guessed code complexity

## Report

Produce a structured report with: summary counts, errors (must fix), warnings (should fix), suggestions (could improve), dependency graph with critical path, and a verdict (PASS / PASS WITH WARNINGS / FAIL).

Classify precisely:
- **Error:** Structural problem that will prevent downstream consumption.
- **Warning:** Quality issue that weakens the spec's usefulness for technical decomposition.
- **Suggestion:** Could be better but not wrong.
