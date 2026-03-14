# ido4shape

A thinking partner that helps crystallize what needs to be built.

ido4shape guides product managers, founders, and tech leads through creative, non-linear conversation — consuming documents, data, research, and human insight — until understanding is deep enough to produce a structured specification artifact.

## What It Does

Every specification tool assumes you already know what to build. ido4shape starts at "tell me about your problem" and helps you discover things you didn't know you needed to think about.

```
ido4shape (plugin)  →  spec artifact (.md)  →  ido4 MCP (governance)
Creative upstream       The contract             GitHub issues + methodology
```

The spec artifact is a structured markdown file — methodology-agnostic, human-readable, machine-parseable. It feeds directly into [ido4 MCP](https://github.com/b-coman/ido4-MCP) for governed execution.

## Installation

```bash
# Load locally (development / pre-marketplace)
claude --plugin-dir ./ido4shape

# Once published to a marketplace
claude plugin install ido4shape
```

For Cowork (Claude Desktop), add the plugin directory manually or install via marketplace once published.

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

When the canvas shows sufficient depth across all knowledge dimensions, crystallize understanding into a formal spec artifact.

### Validate a spec

```
/ido4shape:validate-spec path/to/spec.md
```

Check format compliance and content quality before feeding the artifact to ido4.

### Refine an existing spec

```
/ido4shape:refine-spec path/to/spec.md
```

Edit specs using natural language: "add a caching layer to Group 2", "the architect says task DB-03 should depend on DB-01."

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
├── sources/           # Raw input materials
├── sessions/          # Session summaries
├── tensions.md        # Active contradictions
└── decisions.md       # Settled choices
```

The canvas is the agent's working memory — human-readable, always current, and designed for multi-session continuity.

## The Spec Artifact

The output is a structured markdown file compatible with ido4 MCP's ingestion engine:

```markdown
# Project Name
> Description

## Group: Group Name
> size: M | risk: medium

### PREFIX-01: Task Title
> effort: M | risk: low | type: feature | ai: assisted
> depends_on: -

Task description (>= 200 chars)...

**Success conditions:**
- Specific, verifiable condition
```

## License

MIT
