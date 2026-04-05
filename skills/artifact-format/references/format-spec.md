# Strategic Spec Format — Complete Reference

This is the detailed reference for the strategic spec artifact format. The artifact-format skill provides the essential rules; this file contains the complete specification.

## Document Structure

```
# Project Name                          → PROJECT level (one per document)
> format: strategic-spec | version: 1.0

[Problem description, stakeholders, constraints, non-goals, open questions]

## Cross-Cutting Concerns               → CONCERNS level (one section, multiple subsections)
### Performance / Security / etc.

## Group: Capability Cluster Name       → GROUP level (multiple)
> priority: must-have|should-have|nice-to-have

### PREFIX-NN: Capability Title         → CAPABILITY level (multiple per group)
> priority: must-have|should-have|nice-to-have | risk: low|medium|high
> depends_on: PREFIX-NN, PREFIX-NN | -
```

## Heading Patterns

The strategic spec uses the same heading regex as the technical spec for structural compatibility:

```
PROJECT:     /^# (.+)$/
GROUP:       /^## Group:\s*(.+)$/
CAPABILITY:  /^### ([A-Z]{2,5}-\d{2,3}):\s*(.+)$/
```

Additional recognized areas (beyond regex-parsed headings):
- `## Cross-Cutting Concerns` — H2 section, project-wide NFRs and constraints
- `**Stakeholders:**`, `**Constraints:**`, `**Non-goals:**`, `**Open questions:**` — bold labels in the project header area (between the project description and `## Cross-Cutting Concerns`), each followed by a bullet list. These are NOT H2 headings — writing `## Stakeholders` makes the parser treat it as unknown H2 and ignore the content.

## Metadata

Metadata appears in blockquotes immediately after headings. Key names are lowercase. Values are case-insensitive. Pipe-separated.

### Project Metadata
```
> format: strategic-spec | version: 1.0
```
Required. Identifies the document as a strategic spec.

### Group Metadata
```
> priority: must-have|should-have|nice-to-have
```
Required on every group.

### Capability Metadata
```
> priority: must-have|should-have|nice-to-have | risk: low|medium|high
> depends_on: PREFIX-NN, PREFIX-NN | -
```
`priority` required. `risk` recommended. `depends_on` recommended (explicit `-` for no dependencies; omitting means unspecified).

## Strategic Risk (Not Code Risk)

Risk in strategic specs means something different from risk in technical specs:

- **low:** Well-understood by stakeholders. Requirements clear and stable. No external blockers. Team has confidence.
- **medium:** Some unknowns but bounded. Partial stakeholder alignment. Manageable external dependencies. Might need further conversation.
- **high:** Significant unknowns. Depends on factors outside team control (third-party APIs, legal sign-off, market validation). Stakeholder disagreement unresolved. Requirements may shift.

This is NOT code complexity risk. That's determined by ido4 MCP from actual codebase analysis.

## Fields NOT Present in Strategic Specs

These fields exist in technical specs (produced by ido4 MCP) but not in strategic specs:

| Field | Why Not | Where It Lives |
|-------|---------|----------------|
| effort: S/M/L/XL | Requires knowing code complexity, coupling, migration needs | Technical spec |
| type: feature/bug/research/infrastructure | One capability may decompose into multiple types | Technical spec |
| ai: full/assisted/pair/human | Requires knowing code patterns, test coverage | Technical spec |
| size: S/M/L/XL (group) | Implementation scope, unknowable from conversation | Technical spec |

## Prefix Derivation

Same rules as technical specs:
- Takes uppercase initials or abbreviation from group name
- "Notification Core" → NCO, "Email Channel" → EML, "User Preferences" → UPR
- Prefix length: 2-5 characters (regex: `[A-Z]{2,5}`)
- Capability number: 2-3 digits (regex: `\d{2,3}`), typically zero-padded
- All capabilities in a group share the prefix

## Dependency Validation

- All `depends_on` references must point to existing capability IDs in the document
- No circular dependency chains
- These are functional dependencies: "notification delivery before notification preferences"
- Code-level dependencies ("migration before API endpoint") are added by ido4 MCP during technical decomposition

## Content Quality Gates

### Capability descriptions
- Minimum 200 characters with substantive content
- Must carry multi-stakeholder understanding: what, who needs it, why, stakeholder context
- Should NOT prescribe implementation approach — that's the technical spec's job
- Stakeholder attribution inline where relevant: "Per Marcus: needs idempotency key"

### Success conditions
- Present on every capability as `**Success conditions:**` bullet list
- Specific and independently verifiable
- Product-level: "user can set quiet hours" not "database migration runs successfully"
- Two independent people should agree whether the condition is met

### Cross-cutting concerns
- Not empty template filler — each concern should have specific targets or requirements
- Stakeholder attribution where relevant
- Rich enough for a technical decomposition agent to factor into implementation decisions

### Project sections
- Stakeholders section lists real contributors with real perspectives
- Constraints have rationale (not just "must use PostgreSQL" but why)
- Non-goals are genuine boundaries, not obvious statements
- Open questions are honest unknowns, not disguised decisions

## The Downstream Consumer

The strategic spec is consumed by ido4 MCP's decomposition agent — an AI that reads this document, explores the actual codebase, and produces a technical spec with implementation-ready tasks. The richer and more honest this document is, the better the technical decomposition will be.

The technical spec then feeds into ido4's existing ingestion pipeline (spec-parser.ts → spec-mapper.ts → GitHub issues). The strategic spec never touches that parser directly.
