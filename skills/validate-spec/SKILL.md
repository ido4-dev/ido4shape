---
name: validate-spec
description: >
  This skill validates a spec artifact for format compliance and content quality. Use this
  skill when the user says "validate the spec", "check the spec", "review the artifact",
  "is this spec valid?", "will this pass ido4?", or wants to verify a spec file before
  ingestion. Pass the file path as argument: /ido4shape:validate-spec path/to/spec.md
allowed-tools: Read, Glob, Grep
---

## What to Validate

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

## Format Checks

Verify each structural element against the parser's expectations:

**Project header:** One `#` heading, `>` description, Constraints/Non-goals/Open questions sections.

**Groups:** `## Group: Name` format with `>` metadata containing size and risk values from allowed sets.

**Tasks:** `### PREFIX-NN: Title` where PREFIX is 2-5 uppercase letters and NN is 2-3 digits. Prefix matches parent group. Metadata lines with effort, risk, type, ai, depends_on using allowed values.

**Dependencies:** All depends_on references point to existing task IDs. No circular chains.

## Content Quality

- Task bodies at least 200 characters with substantive content
- Success conditions present, specific, independently verifiable
- Effort/risk calibration plausible (no external integration marked low risk, no XL marked low risk)
- Groups have 3-8 tasks with related purposes

## Report

Produce a structured report with: summary counts, errors (must fix), warnings (should fix), suggestions (could improve), dependency graph with critical path, and a verdict (PASS / PASS WITH WARNINGS / FAIL).

If ido4 MCP is available, suggest running `ingest_spec` with `dryRun=true` for full governance validation.
