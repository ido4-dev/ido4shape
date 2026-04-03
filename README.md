# ido4shape

A thinking partner that helps crystallize what needs to be built.

ido4shape guides product managers, founders, and tech leads through creative, non-linear conversation — consuming documents, data, research, and human insight — until understanding is deep enough to produce a structured strategic specification.

## What It Does

Every specification tool assumes you already know what to build. ido4shape starts at "tell me about your problem" and helps you discover things you didn't know you needed to think about.

The output is a strategic specification — multi-stakeholder understanding crystallized into structured markdown: what to build, who needs it, why, constraints, NFRs, and verifiable success conditions. Hand it to your team, feed it to any AI coding tool, or use it as a project brief. No downstream tooling required.

## Installation

```bash
# Via marketplace
claude plugin marketplace add ido4-dev/ido4-plugins
claude plugin install ido4shape@ido4-plugins

# Load locally (development)
claude --plugin-dir ./ido4shape
```

For Cowork (Claude Desktop): sync `ido4-plugins` marketplace and install the plugin.

## Quick Start

1. **Navigate to your project folder** (or create a new one)
2. **Run** `/ido4shape:create-spec my-project`
3. **Have a conversation** — the agent reads your documents, asks questions, and builds understanding. Expect 3-5 sessions for a thorough spec.
4. **When understanding is deep enough**, run `/ido4shape:review-spec` for independent review by parallel agents
5. **Run** `/ido4shape:synthesize-spec` to produce the formal spec artifact
6. **Run** `/ido4shape:validate-spec` to check format and quality before sharing

The agent creates a `.ido4shape/` workspace in your project folder to track understanding across sessions. You can stop and resume at any time — the workspace is your continuity.

### Before you start

Optionally gather any materials you have — PRDs, architecture docs, meeting notes, analytics, research, design references. Put them in your project folder. The agent reads everything available before asking its first question.

You can also start with nothing. The agent guides discovery from scratch.

## Usage

### Start a specification session

```
/ido4shape:create-spec my-project
```

The agent reads any existing materials in your project folder, then guides you through non-linear knowledge gathering. It maintains a knowledge canvas in `.ido4shape/canvas.md` that evolves as understanding deepens.

### Review before synthesis

```
/ido4shape:review-spec
```

Launches parallel independent reviewers (technical feasibility, scope alignment, dependency audit, format/quality) to catch issues before or after composition.

### Compose the spec artifact

```
/ido4shape:synthesize-spec
```

When the canvas shows sufficient depth across all knowledge dimensions, crystallize understanding into a strategic spec artifact.

### Validate a spec

```
/ido4shape:validate-spec path/to/spec.md
```

Check format compliance and content quality before sharing with your team.

### Refine an existing spec

```
/ido4shape:refine-spec path/to/spec.md
```

Edit specs using natural language: "add a capability to Group 2", "the architect says we need GDPR compliance."

### Generate a stakeholder briefing

```
/ido4shape:stakeholder-brief --as architect
```

Produce a role-specific summary from the current canvas — what an architect, PM, or designer needs to know.

## How It Works

The agent explores six dimensions of understanding. These emerge naturally from conversation — you won't answer them in sequence; the agent follows what matters for your specific project.

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

The canvas is the agent's working memory — human-readable, always current, and designed for multi-session continuity. If a session crashes after turn 15, the workspace reflects everything through turn 15.

Add `.ido4shape/` to your `.gitignore` — it's working state, not a project artifact. The spec output (`*-spec.md`) is the artifact you share and commit.

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

## Going Further: The ido4 Pipeline

ido4shape produces strategic specs — the WHAT. If you want automated technical decomposition, [ido4 MCP](https://github.com/ido4-dev/ido4) reads the strategic spec, explores your actual codebase, and produces implementation-ready tasks with effort estimates, risk assessments, and methodology-specific governance.

```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

This is optional. The strategic spec is a complete, standalone artifact.

<!-- BEGIN SKILL INVENTORY -->
## Skills

### Commands

| Skill | Description |
|-------|-------------|
| `/ido4shape:create-spec` | Start a specification session — guided discovery conversation |
| `/ido4shape:synthesize-spec` | Crystallize the knowledge canvas into a formal strategic spec |
| `/ido4shape:validate-spec` | Check a spec for format compliance and content quality |
| `/ido4shape:refine-spec` | Edit an existing spec using natural language instructions |
| `/ido4shape:review-spec` | Launch parallel independent reviewers on the canvas or spec |
| `/ido4shape:stakeholder-brief` | Generate a role-specific briefing from the current canvas |

### Supporting skills (auto-triggered)

These activate automatically during conversation when relevant — you don't invoke them directly.

| Skill | Description |
|-------|-------------|
| `artifact-format` | Provides strategic spec format knowledge when working with specs |
| `creative-decomposition` | Guides conversation methodology during discovery |
| `dependency-analysis` | Activates when discussing task ordering and dependencies |
| `quality-guidance` | Applies quality standards when writing descriptions and conditions |
<!-- END SKILL INVENTORY -->

## Glossary

- **Canvas** — The agent's working memory during specification. Lives in `.ido4shape/canvas.md`. Evolves throughout conversations.
- **Crystallization** — Moving from fuzzy conversation to structured, formal specification.
- **Knowledge dimensions** — Six areas of understanding the agent explores: Problem Depth, Solution Shape, Boundary Clarity, Risk Landscape, Dependency Logic, Quality Bar.
- **Groups** — Clusters of related capabilities in a spec (e.g., "Notification Core", "Email Channel").
- **Capabilities** — Individual units of functionality within a group, each with a description and success conditions.
- **Strategic spec** — The output: a structured document capturing WHAT to build, for whom, and why. Does not include implementation details like effort estimates or code-level decisions.
- **Cross-cutting concerns** — Non-functional requirements (performance, security, accessibility) that apply across the entire project.
- **Success conditions** — Specific, verifiable statements of what "done" means for each capability.

## Security & Data Handling

See [SECURITY.md](SECURITY.md) for details on data handling, hooks, and privacy.

## License

MIT
