---
name: dependency-analysis
description: >
  This skill provides dependency graph knowledge. It activates automatically when the
  conversation involves capability dependencies, ordering of work, critical paths, "what depends
  on what", "what needs to be built first", circular dependencies, foundational-before-dependent
  patterns, cross-group dependency implications, or the depends_on field in spec artifacts.
  Also triggers when the user asks about sequencing, parallelization, blocking relationships,
  "what can we parallelize", "what's the critical path", or when the canvas is being
  updated with dependency information.
user-invocable: false
---

## Core Principles

Dependencies are discovered through understanding how capabilities relate — not assigned in a dedicated phase.

**Infrastructure before features** — Foundational abstractions (data models, interfaces, core services) must exist before features that consume them.

**Interfaces before implementations** — Define the contract before implementing against it.

**Data before logic** — The underlying data concepts before the business logic that operates on them.

**Core before periphery** — The central capability of each group before edge cases, optimizations, and polish.

Note: These are functional dependency patterns — how capabilities relate conceptually. Code-level dependencies (specific migrations, module coupling) are discovered by ido4 MCP during technical decomposition.

## Dependency Patterns

**Linear chain:** A then B then C then D. Critical path concern — no parallelization possible.

**Fan-out:** A enables B, C, D in parallel. Common when a foundational piece enables multiple streams.

**Fan-in:** B and C must both complete before D. Common for integration points.

**Cross-group:** A capability in one group depends on a capability in another group. These are highest-risk — they create coordination requirements.

## Quality Checks

When reviewing a dependency graph:

- Every task should be reachable from at least one root task, or be a root task
- No cycles — if you spot A depending on B depending on A, the tasks need restructuring
- The critical path (longest dependency chain) should represent the logical progression
- Heavy cross-group dependencies suggest poorly bounded groups
- Use `depends_on: -` when a task genuinely has no dependencies — this signals intentional assessment

## Common Mistakes

- Over-specifying: not everything related is dependent. Only specify where one task's output is required input for another
- Implicit dependencies: "obviously the database needs to exist first" — make it explicit
- Confusing planning sequence with real dependency: "we'll do A before B" is different from "B requires A's output"

## Critical Path

The critical path determines minimum project duration and concentrates risk. Identify it explicitly, discuss whether high-risk tasks on the critical path need mitigation, and note what can be parallelized.
