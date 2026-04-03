# Developer Guide

Technical details for contributors and advanced users.

## Local Development

```bash
claude --plugin-dir ./
```

Run from the plugin root directory.

Use `/reload-plugins` to pick up changes during iteration.

## The Strategic Spec Format

The output is a structured markdown document following the `strategic-spec` format:

```markdown
# Project Name
> format: strategic-spec | version: 1.0

[Problem description, stakeholders, constraints, non-goals]

## Cross-Cutting Concerns
### Performance / Security / Accessibility
[Non-functional requirements as prose]

## Group: Capability Cluster
> priority: must-have

### PREFIX-01: Capability Title
> priority: must-have | risk: low
> depends_on: -

[Rich description with stakeholder context (>= 200 chars)]

**Success conditions:**
- Specific, verifiable condition
```

Full format specification: `references/strategic-spec-format.md`
Example artifact: `references/example-strategic-notification-system.md`

## The .ido4shape/ Workspace

During specification, the plugin creates a workspace in your project folder:

```
.ido4shape/
├── canvas.md          # Current understanding (continuously updated)
├── stakeholders.md    # Contributors and their perspectives
├── sources/           # Raw input materials
├── sessions/          # Session summaries
├── tensions.md        # Active contradictions
└── decisions.md       # Settled choices
```

Add `.ido4shape/` to your `.gitignore` — it's working state, not a project artifact. The spec output (`*-spec.md`) is the artifact you share and commit.

## The ido4 Pipeline

ido4shape produces strategic specs — the WHAT. For automated technical decomposition, [ido4 MCP](https://github.com/ido4-dev/ido4) reads the strategic spec, explores your codebase, and produces implementation-ready tasks.

```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

This is optional. The strategic spec is a complete, standalone artifact.

## Validation

The plugin includes a bundled spec format validator (`dist/spec-validator.js`) for deterministic structural validation. Source: [@ido4/spec-format](https://github.com/ido4-dev/ido4/tree/main/packages/spec-format). SHA-256 checksum in `dist/.spec-format-checksum`.

## CI & Releases

See `CLAUDE.md` for CI workflows, release process, and marketplace sync details.
