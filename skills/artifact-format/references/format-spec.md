# Complete Format Specification

This is the detailed reference for the spec artifact format. The artifact-format skill provides the essential rules; this file contains the complete specification including parser regex patterns and edge cases.

## Parser Regex Patterns (from ido4's spec-parser.ts)

```
PROJECT_HEADING:  /^# (.+)$/
GROUP_HEADING:    /^## Group:\s*(.+)$/
TASK_HEADING:     /^### ([A-Z]{2,5}-\d{2,3}):\s*(.+)$/
BLOCKQUOTE:       /^>\s?(.*)$/
BULLET_ITEM:      /^- (.+)$/
SECTION_HEADER:   /^\*\*(.+?):\*\*\s*$/
SEPARATOR:        /^---\s*$/
```

## State Machine

The parser processes the markdown line-by-line through states: INIT -> PROJECT -> GROUP -> TASK.

- `#` heading transitions to PROJECT state
- `## Group:` transitions to GROUP state
- `### PREFIX-NN:` transitions to TASK state
- `>` lines after any heading are metadata
- Everything else between headings is body text
- `---` is an optional visual separator

## Metadata Parsing

Metadata lines use pipe-separated key-value pairs:
```
> effort: M | risk: low | type: feature | ai: full
> depends_on: NCO-01, NCO-02
```

Key names must be lowercase (effort, risk, type, ai, depends_on, size). The parser matches keys case-sensitively — `Effort` or `EFFORT` will generate an unknown-key warning. Values are matched case-insensitively (e.g., `effort: m` and `effort: M` both work). Unknown keys generate warnings but don't fail parsing.

Multiple `>` lines are concatenated. The depends_on field is typically on its own line for readability.

## Prefix Derivation

The parser derives expected prefixes from group names:
- Takes uppercase initials: "Notification Core" -> "NC"
- Or uses abbreviation: "Notification Core" -> "NCO"
- The prefix in task headings must match the group's expected prefix
- Prefix length: 2-5 characters (regex: `[A-Z]{2,5}`)
- Task number: 2-3 digits (regex: `\d{2,3}`), typically zero-padded

## Dependency Validation

During mapping (spec-mapper.ts):
1. All `depends_on` references are collected
2. Each reference is checked against existing task IDs
3. References to non-existent tasks generate errors
4. Topological sort via Kahn's algorithm detects circular dependencies
5. Tasks are ordered for creation: dependencies created before dependents

## Value Mapping (at ingestion time)

**Effort mapping:**
| Artifact | ido4 Internal |
|----------|--------------|
| S | Small |
| M | Medium |
| L | Large |
| XL | Large (no distinction from L) |

**Risk mapping:**
| Artifact | ido4 Internal |
|----------|--------------|
| low | Low |
| medium | Medium |
| high | High |
| critical | High (+ critical-risk label) |

**AI mapping:**
| Artifact | ido4 Internal |
|----------|--------------|
| full | AI_ONLY |
| assisted | AI_REVIEWED |
| pair | HYBRID |
| human | HUMAN_ONLY |

**Type mapping:**
| Artifact | ido4 Internal |
|----------|--------------|
| feature | FEATURE |
| bug | BUG |
| research | RESEARCH |
| infrastructure | INFRASTRUCTURE |

## Common Validation Failures

1. `## Name` without `Group:` prefix — not recognized as a group
2. `### name-01:` with lowercase prefix — doesn't match `[A-Z]{2,5}`
3. `> Effort: M` with capital E — unknown key warning (keys are matched case-sensitively in some paths)
4. Body under 200 characters — SpecCompletenessValidation fails
5. Missing `**Success conditions:**` — quality gate warning
6. `depends_on: TASK-99` referencing non-existent task — dependency resolution error
7. Circular dependency chain (A -> B -> C -> A) — Kahn's algorithm fails
