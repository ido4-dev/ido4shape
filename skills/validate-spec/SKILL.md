---
name: validate-spec
description: >
  This skill validates a strategic spec artifact for format compliance and content quality. Use
  this skill when the user says "validate the spec", "check the spec", "review the artifact",
  "is this spec valid?", or wants to verify a spec file before handoff to ido4 MCP. Pass the
  file path as argument: /ido4shape:validate-spec path/to/spec.md
allowed-tools: Read, Glob, Grep, Bash
---

## What to Validate

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

## Two-Pass Validation

This skill performs validation in two passes. Both passes are required.

### Pass 1 — Structural Validation (deterministic)

Run the spec format parser against the artifact. The parser is installed via `@ido4/spec-format` in the plugin data directory.

```bash
node "${CLAUDE_PLUGIN_DATA}/node_modules/@ido4/spec-format/dist/cli.js" <path-to-spec.md>
```

The parser outputs JSON to stdout with:
- `valid` — boolean, true if no structural errors
- `errors` — structural problems that WILL prevent downstream consumption (broken dependency refs, missing format marker, circular deps, duplicate capability IDs)
- `warnings` — structural issues that weaken the spec (invalid priority/risk values, empty groups, unknown metadata keys)
- `metrics` — group count, capability count, dependency depth, etc.
- `project`, `groups`, `dependencyGraph` — the full parsed structure

If the CLI is not available (npm install failed), skip this pass and note it in the report. Do NOT attempt to replicate the parser's structural checks manually — the whole point is deterministic validation.

Interpret the parser output to provide actionable guidance:
- For each error: identify the exact location, explain what's wrong, suggest the specific fix
- For dependency errors: cross-reference with the dependency graph to suggest valid alternatives
- For duplicate refs: suggest which one to rename and to what
- For metric anomalies: flag if groups are unbalanced (one group with 10 capabilities, another with 1)

### Pass 2 — Content Quality (LLM judgment)

Read the spec file and assess content quality. These checks require judgment that only an LLM can provide:

- Capability descriptions at least 200 characters with multi-stakeholder context
- Descriptions carry the WHY, not just the WHAT — stakeholder perspectives, not implementation approach
- Success conditions present, specific, independently verifiable, product-level
- Cross-cutting concerns have specific targets, not template filler
- Stakeholders section lists real contributors with real perspectives
- Constraints have rationale
- Priority calibration plausible (not everything is must-have)
- Strategic risk reflects actual unknowns, not guessed code complexity
- No implementation-level metadata (effort, type, ai, size) — if these appear, flag as error

If the canvas exists, cross-reference: flag if stakeholders, cross-cutting concerns, or constraints captured in the canvas didn't make it to the spec.

## Combined Report

Produce a unified report that merges both passes:

**Summary:** counts from parser metrics (groups, capabilities, dependencies, cross-cutting concerns)

**Structural Validation:** parser verdict (valid/invalid), errors with fixes, warnings

**Content Quality:** LLM findings, organized as errors (must fix), warnings (should fix), suggestions (could improve)

**Dependency Graph:** from parser output, annotated with critical path

**Verdict:** PASS / PASS WITH WARNINGS / FAIL

A single structural error from the parser means FAIL — the downstream consumer will reject it. Content warnings alone mean PASS WITH WARNINGS.
