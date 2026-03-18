# Strategic Spec Format — Quick Reference

The canonical format specification lives at `skills/artifact-format/references/format-spec.md`. This file provides a quick reference for the essential patterns.

## Hierarchy

```
# Project Name                    → project (with format: strategic-spec | version: 1.0)
## Cross-Cutting Concerns         → NFRs, security, performance (prose sections)
## Group: Capability Cluster      → logical grouping
### PREFIX-NN: Capability Title   → individual capability
```

## Metadata (in `>` blockquotes immediately after headings)

**Project:** `> format: strategic-spec | version: 1.0`

**Group:** `> priority: must-have|should-have|nice-to-have`

**Capability:**
```
> priority: must-have|should-have|nice-to-have | risk: low|medium|high
> depends_on: PREFIX-NN, PREFIX-NN | -
```

Key names must be **lowercase**. Values are case-insensitive.

## Quality Gates

- Capability body >= 200 characters with multi-stakeholder context
- Success conditions under `**Success conditions:**` as bullets
- All `depends_on` references must exist
- No circular dependencies
- Capability prefix must match group prefix
- `depends_on: -` = explicitly no dependencies
- Stakeholders section present
- Cross-cutting concerns not empty filler

## Not in Strategic Specs

effort, type, ai, size — these require codebase knowledge. Determined by ido4 MCP during technical decomposition.

## Full Specification

See `skills/artifact-format/references/format-spec.md` for the complete reference.
