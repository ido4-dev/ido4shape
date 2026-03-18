# Strategic Spec Format — v1.0

## Purpose

The strategic spec is the contract between ido4shape (creative upstream) and ido4 MCP (technical downstream). It captures everything knowable from multi-stakeholder conversation — problem understanding, functional capabilities, dependencies, constraints, NFRs, success conditions — without claiming knowledge that requires codebase access.

ido4 MCP consumes this artifact, decomposes each capability against the actual codebase, and produces a technical spec with implementation-ready tasks. Only the technical spec becomes GitHub issues.

## Format Identifier

The project-level metadata includes a format field that distinguishes this from a technical spec:

```
> format: strategic-spec | version: 1.0
```

This tells any parser which validation rules and metadata schema to apply.

---

## Document Structure

### Level 1: Project Header

```markdown
# Project Name
> format: strategic-spec | version: 1.0

[Problem statement — who suffers, how, why solving it now matters. Rich narrative from stakeholder conversations. Not a summary — the actual understanding.]

**Stakeholders:**
- [Name/Role]: [Key perspective they brought, dimensions they shaped]
- [Name/Role]: [Key perspective they brought, dimensions they shaped]

**Constraints:**
- [Hard constraint with rationale — why this boundary exists]
- [Hard constraint with rationale]

**Non-goals:**
- [What we're explicitly NOT building and why — prevents scope creep at technical decomposition]
- [What we're explicitly NOT building and why]

**Open questions:**
- [Genuine unknowns that might affect scope or direction — honest gaps, not hidden decisions]
- [Genuine unknowns]
```

**Stakeholders section** is new. It tells ido4 MCP who shaped the understanding — if questions arise during technical decomposition, the system knows which perspective to consult. Lists contributors by role with their primary contribution.

**Constraints, Non-goals, Open questions** carry forward from the current format. They're product-level and don't require codebase knowledge.

---

### Level 1.5: Cross-Cutting Concerns (new section)

```markdown
## Cross-Cutting Concerns

### Performance
[Specific targets, load expectations, response time requirements, scalability needs. Attribution to the stakeholder who defined them when relevant.]

### Security
[Auth requirements, data sensitivity classification, compliance requirements (GDPR, HIPAA, SOC2), threat model considerations, encryption expectations.]

### Accessibility
[Standards to meet (WCAG level), device/browser support matrix, assistive technology requirements, internationalization needs.]

### Observability
[Logging requirements, monitoring expectations, alerting needs, SLA targets, incident response implications.]

### [Domain-Specific Concern]
[Any other cross-cutting requirement that emerged from stakeholder conversations — regulatory, legal, operational, organizational.]
```

**Why this section exists:** NFRs, security, performance targets, accessibility standards — these emerge from architect, security, UX, and business conversations. They don't belong to any single capability. They inform every technical task ido4 MCP will create. Without them, the technical decomposition misses constraints that were explicitly discussed.

**What goes here vs. in capability descriptions:** If it applies to the whole project or multiple groups, it goes here. If it's specific to one capability ("this endpoint must respond in <100ms"), it goes in that capability's description.

**Subsection headings are flexible.** Not every project has security concerns. Some have regulatory requirements that deserve their own section. The subsections reflect what the conversation actually covered.

---

### Level 2: Groups (Capability Clusters)

```markdown
## Group: [Capability Cluster Name]
> priority: must-have|should-have|nice-to-have

[What this group delivers as a coherent unit. Why these capabilities belong together. What value it provides standalone — what becomes possible when this group is complete. Stakeholder perspectives that shaped the boundary.]
```

**Group metadata:**

| Field | Values | Meaning |
|-------|--------|---------|
| `priority` | `must-have`, `should-have`, `nice-to-have` | Strategic importance — drives decomposition ordering |

**Removed from groups:** `size` and `risk`. Size (S/M/L/XL) was a proxy for implementation scope — unknowable without code. Risk at the group level was a rollup of task-level code risk — also unknowable.

**Why only priority:** It's the one thing stakeholders can meaningfully assess at the group level. "This entire cluster is must-have for launch" or "this is nice-to-have, we could ship without it." This directly drives ido4 MCP's decomposition strategy — must-have groups get decomposed first and most thoroughly.

---

### Level 3: Capabilities (Functional Requirements)

```markdown
### PREFIX-NN: Capability Name
> priority: must-have|should-have|nice-to-have | risk: low|medium|high
> depends_on: PREFIX-NN, PREFIX-NN | -

[Rich description of what this capability provides. Who needs it and why. User-facing value. Context from stakeholder conversations — what the PM said about user need, what the architect flagged about feasibility, what UX observed about interaction patterns. Integration points with external systems if known from conversation. NOT implementation approach — that's for the technical spec.]

**Success conditions:**
- [Specific, independently verifiable condition — same standard as current format]
- [Specific, independently verifiable condition]
- [Specific, independently verifiable condition]
```

**Capability metadata:**

| Field | Values | Meaning |
|-------|--------|---------|
| `priority` | `must-have`, `should-have`, `nice-to-have` | Strategic importance within its group |
| `risk` | `low`, `medium`, `high` | **Strategic risk** — unknowns, external dependencies, stakeholder disagreement, regulatory uncertainty. NOT code complexity. |
| `depends_on` | Comma-separated refs or `-` | Functional dependencies — capability A needs capability B to exist. NOT code module dependencies. |

**What each risk level means (strategic, not technical):**

- **low** — Well-understood by stakeholders. Team has confidence. Requirements are clear and stable. No external blockers.
- **medium** — Some unknowns but bounded. Partial stakeholder alignment. Might need further conversation. Manageable external dependencies.
- **high** — Significant unknowns. Depends on factors outside team's control (third-party APIs, legal sign-off, market validation). Stakeholder disagreement unresolved. Requirements may shift.

**What was removed and why:**

| Removed Field | Why | Where It Goes |
|---------------|-----|---------------|
| `effort: S\|M\|L\|XL` | Requires knowing code complexity, module coupling, migration needs | Technical spec (ido4 MCP determines from codebase) |
| `type: feature\|bug\|research\|infrastructure` | Implementation classification — a single capability might decompose into feature + infrastructure + research tasks | Technical spec (ido4 MCP classifies each implementation task) |
| `ai: full\|assisted\|pair\|human` | Requires knowing code patterns, test coverage, API complexity | Technical spec (ido4 MCP assesses from actual code) |

**Success conditions:** Unchanged from current format. These are product-level — "user can set quiet hours" is verifiable without code knowledge. The 200-character minimum on descriptions carries forward too — ido4 MCP needs rich descriptions to produce good technical decompositions.

---

## Prefix Rules

Same as current format:

- **Pattern:** `[A-Z]{2,5}-\d{2,3}`
- **Derivation:** From group name (initials or abbreviation)
  - "Notification Core" → `NCO`
  - "Email Channel" → `EML`
  - "User Preferences" → `UPR`
- **Constraint:** All capabilities in a group share the group's prefix
- **Numbering:** Sequential, zero-padded (`01`, `02`, ... `10`, `11`)

---

## Dependency Rules

Same validation as current format, same semantics:

- All `depends_on` references must point to existing capability IDs in the document
- No circular dependencies (would be detected by Kahn's algorithm if validated)
- `depends_on: -` means explicitly no dependencies
- Omitting `depends_on` means unspecified

**The difference:** These are functional dependencies, not code dependencies. "You need notification delivery before notification preferences" — this is product logic. The technical spec may discover additional code-level dependencies (e.g., "the database migration must run before the API endpoint can be built") that weren't visible at the strategic level.

---

## Quality Gates

### Format compliance (machine-checkable)
- Exactly one `# ` project heading with `format: strategic-spec` in metadata
- Groups use `## Group: ` prefix
- Capabilities use `### PREFIX-NN: ` pattern
- Prefix matches parent group
- All `depends_on` references exist
- No circular dependencies
- Metadata values from allowed sets
- `priority` present on every group and capability

### Content quality (requires judgment)
- Problem statement is multi-perspective, not single-stakeholder
- Capability descriptions ≥200 characters with substantive content
- Success conditions are specific and independently verifiable
- Cross-cutting concerns reflect actual stakeholder conversations (not template filler)
- Stakeholders section lists real contributors with real perspectives
- Constraints have rationale (not just "must use PostgreSQL" but "must use PostgreSQL — existing team expertise and ops tooling")
- Non-goals are genuine boundaries, not obvious statements
- Open questions are honest unknowns, not disguised decisions
- Risk assessments reflect strategic uncertainty, not guessed code complexity

---

## What This Format Enables Downstream

When ido4 MCP receives a strategic spec:

1. **Parse** — Extract project context, cross-cutting concerns, groups, capabilities, dependencies
2. **Prioritize** — Must-have groups with high-risk capabilities get decomposed first
3. **Decompose** — For each capability: read description + success conditions + cross-cutting concerns, explore the codebase, produce implementation tasks with real effort/risk/type/AI suitability
4. **Connect** — Strategic spec capability becomes parent; implementation tasks become children. Functional dependencies from strategic spec are preserved; code-level dependencies are added.
5. **Output** — Technical spec in the current artifact format (effort, risk, type, ai, depends_on) that the ingestion engine already knows how to consume

The strategic spec is the "PM brief." The technical spec is the "architect's breakdown." GitHub issues are the "team's tickets."

---

## Comparison: Strategic Spec vs Technical Spec

| Aspect | Strategic Spec (ido4shape) | Technical Spec (ido4 MCP) |
|--------|---------------------------|---------------------------|
| **Produced by** | Multi-stakeholder conversation | Codebase-aware decomposition |
| **Leaf unit** | Capability (functional requirement) | Task (implementation work unit) |
| **Effort** | Not included — unknowable | S/M/L/XL from code analysis |
| **Risk** | Strategic (unknowns, dependencies) | Technical (complexity, coupling) |
| **Type** | Not included — a capability may decompose into multiple types | feature/bug/research/infrastructure |
| **AI suitability** | Not included — requires code | full/assisted/pair/human |
| **Priority** | must-have/should-have/nice-to-have | Inherited from strategic spec |
| **Dependencies** | Functional (capability ordering) | Code-level (module ordering) + inherited functional |
| **Success conditions** | Product-level (user-verifiable) | Implementation-level (code-verifiable) + inherited product |
| **Cross-cutting concerns** | Explicit section | Encoded into individual task constraints |
| **Stakeholder attribution** | Explicit | Traced back to strategic spec |
| **Consumed by** | ido4 MCP decomposition agent | ido4 ingestion engine → GitHub issues |
