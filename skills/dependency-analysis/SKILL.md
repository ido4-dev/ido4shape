---
name: dependency-analysis
description: >
  This skill provides dependency graph knowledge. It activates automatically when the
  conversation involves task dependencies, ordering of work, critical paths, "what depends on
  what", "what needs to be built first", circular dependencies, infrastructure-before-features
  patterns, cross-group dependency implications, or the depends_on field in spec artifacts.
  Also triggers when the user asks about sequencing, parallelization, blocking relationships,
  "what can we parallelize", "what's the critical path", or when .ido4shape/canvas.md is being
  updated with dependency information.
user-invocable: false
---

<dependency-knowledge>

## Core Principles

Dependencies are discovered through understanding how capabilities relate — not assigned in a dedicated phase. They fall naturally out of exploring the solution shape.

**Infrastructure before features** — Foundational abstractions (data models, interfaces, core services) must exist before features that consume them. This is almost always the first dependency layer.

**Interfaces before implementations** — Define the contract before implementing against it. A `DeliveryChannel` interface should exist before email or push implementations.

**Data before logic** — Schema and data models before business logic that operates on them. Migrations before features that depend on new fields.

**Core before periphery** — The central capability of each group before edge cases, optimizations, and polish.

## Dependency Patterns

**Linear chain:** A -> B -> C -> D. Common in setup/initialization sequences. Critical path concern — no parallelization possible.

**Fan-out:** A -> B, A -> C, A -> D. Common when a foundational piece enables multiple parallel streams. B, C, D can be worked simultaneously.

**Fan-in:** B -> D, C -> D. Common for integration points where multiple components must exist before assembly. D blocks on the slowest of B, C.

**Cross-group:** A group's task depends on another group's task. These are the highest-risk dependencies — they create coordination requirements between potentially different teams or work streams.

## Quality Checks

When reviewing a dependency graph:

- **No orphans:** Every task should be reachable from at least one root (no-dependency) task, or BE a root task.
- **No cycles:** A -> B -> C -> A is invalid. Kahn's algorithm will reject it. If you spot a cycle, the tasks need restructuring.
- **Sensible critical path:** The longest dependency chain should represent the logical progression of the project. If the critical path doesn't make intuitive sense, dependencies may be wrong.
- **Minimal cross-group deps:** Heavy cross-group dependencies suggest the groups are poorly bounded. Consider restructuring.
- **Explicit independence:** Use `depends_on: -` when a task genuinely has no dependencies. This signals intentional assessment, not oversight.

## Common Mistakes

- **Over-specifying dependencies:** Not everything that "relates to" something else depends on it. Only specify dependencies where one task's output is required input for another.
- **Implicit dependencies:** "Obviously the database needs to exist first" — make it explicit with `depends_on`.
- **Confusing sequence with dependency:** "We'll do A before B" (planning choice) is different from "B requires A's output" (real dependency).
- **Missing transitive awareness:** If A -> B -> C, C transitively depends on A. But only B should be in C's `depends_on` — don't list transitive deps explicitly.

## Critical Path Analysis

The critical path is the longest chain of dependent tasks through the graph. It determines:
- **Minimum project duration** — no amount of parallelization shortens the critical path
- **Risk concentration** — delays on the critical path delay everything
- **Where to focus risk mitigation** — high-risk tasks on the critical path need the most attention

When presenting the dependency structure, identify the critical path explicitly and discuss whether the risk distribution along it is acceptable.

</dependency-knowledge>
