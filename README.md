# ido4shape

A thinking partner that helps crystallize what needs to be built.

ido4shape guides product managers, founders, and tech leads through creative, non-linear conversation — consuming documents, data, research, and human insight — until understanding is deep enough to produce a structured strategic specification.

## What It Does

Every specification tool assumes you already know what to build. ido4shape starts at "tell me about your problem" and helps you discover things you didn't know you needed to think about.

```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

The strategic spec captures multi-stakeholder understanding — what to build, who needs it, why, constraints, NFRs, success conditions. [ido4 MCP](https://github.com/ido4-dev/ido4) then decomposes it against the actual codebase to produce implementation-ready tasks.

## Installation

```bash
# Via marketplace
claude plugin marketplace add ido4-dev/ido4-plugins
claude plugin install ido4shape@ido4-plugins

# Load locally (development)
claude --plugin-dir ./ido4shape
```

For Cowork (Claude Desktop): sync `ido4-plugins` marketplace and install the plugin.

## Usage

### Start a specification session

```
/ido4shape:create-spec my-project
```

The agent reads any existing materials in your project folder, then guides you through non-linear knowledge gathering. It maintains a knowledge canvas in `.ido4shape/canvas.md` that evolves as understanding deepens.

### Compose the spec artifact

```
/ido4shape:synthesize-spec
```

When the canvas shows sufficient depth across all knowledge dimensions, crystallize understanding into a strategic spec artifact.

### Validate a spec

```
/ido4shape:validate-spec path/to/spec.md
```

Check format compliance and content quality before handoff to ido4 MCP.

### Refine an existing spec

```
/ido4shape:refine-spec path/to/spec.md
```

Edit specs using natural language: "add a capability to Group 2", "the architect says we need GDPR compliance."

## How It Works

ido4shape pursues understanding across six dimensions:

1. **Problem Depth** — who suffers, how acutely, what workarounds exist
2. **Solution Shape** — what capabilities need to exist, how they relate
3. **Boundary Clarity** — constraints, non-goals, open questions
4. **Risk Landscape** — unknowns, external dependencies, untested assumptions
5. **Dependency Logic** — what must exist before what
6. **Quality Bar** — what "done" means, verifiable success conditions

Understanding develops non-linearly. The agent adapts to project complexity, communication style, and energy. It connects dots across sessions and stakeholders, surfaces tensions, and knows when to push deeper vs when to step back.

## The Knowledge Canvas

During specification, ido4shape maintains a workspace at `.ido4shape/`:

```
.ido4shape/
├── canvas.md          # Current understanding (continuously updated)
├── stakeholders.md    # Contributors and their perspectives
├── sources/           # Raw input materials
├── sessions/          # Session summaries
├── tensions.md        # Active contradictions
└── decisions.md       # Settled choices
```

The canvas is the agent's working memory — human-readable, always current, and designed for multi-session continuity.

## The Strategic Spec

The output is a structured markdown document:

```markdown
# Project Name
> format: strategic-spec | version: 1.0

[Problem description, stakeholders, constraints, non-goals]

## Cross-Cutting Concerns
### Performance / Security / Accessibility
[NFRs and cross-cutting requirements as prose]

## Group: Capability Cluster
> priority: must-have

### PREFIX-01: Capability Title
> priority: must-have | risk: low
> depends_on: -

[Rich description with stakeholder context (>= 200 chars)]

**Success conditions:**
- Specific, verifiable condition
```

<!-- BEGIN SKILL INVENTORY -->
## Skills

| Skill | Type | Description |
|-------|------|-------------|
| `artifact-format` | auto-triggered | Provides strategic spec artifact format knowledge. |
| `create-spec` | user-invocable | Guides users through creative specification development. |
| `creative-decomposition` | auto-triggered | Provides conversation methodology for creative specification work. |
| `dependency-analysis` | auto-triggered | Provides dependency graph knowledge. |
| `quality-guidance` | auto-triggered | Provides strategic spec quality standards. |
| `refine-spec` | user-invocable | Edits existing spec artifacts using natural language instructions. |
| `review-spec` | user-invocable | Launches parallel independent reviewers to assess the canvas or spec artifact before composition. |
| `stakeholder-brief` | user-invocable | Generates a stakeholder-specific briefing from the current canvas. |
| `synthesize-spec` | user-invocable | Crystallizes a knowledge canvas into a strategic spec artifact. |
| `validate-spec` | user-invocable | Validates a strategic spec artifact for format compliance and content quality. |
<!-- END SKILL INVENTORY -->

## License

MIT
