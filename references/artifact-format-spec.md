# Spec Artifact Format — Quick Reference

The canonical format specification lives at `skills/artifact-format/references/format-spec.md`. This file provides a quick reference for the essential patterns.

## Hierarchy

```
# Project Name          → project
## Group: Group Name    → logical grouping
### PREFIX-NN: Title    → individual task
```

## Metadata (in `>` blockquotes immediately after headings)

**Group:** `> size: S|M|L|XL | risk: low|medium|high|critical`

**Task:**
```
> effort: S|M|L|XL | risk: low|medium|high|critical | type: feature|bug|research|infrastructure | ai: full|assisted|pair|human
> depends_on: PREFIX-NN, PREFIX-NN | -
```

Key names must be **lowercase**. Values are case-insensitive.

## Quality Gates

- Task body >= 200 characters
- Success conditions under `**Success conditions:**` as bullets
- All `depends_on` references must exist
- No circular dependencies
- Task prefix must match group prefix
- `depends_on: -` = explicitly no dependencies

## Full Specification

See `skills/artifact-format/references/format-spec.md` for parser regex patterns, state machine details, value mappings, and common errors.
