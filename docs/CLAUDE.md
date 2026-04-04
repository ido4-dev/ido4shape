# docs/ — Documentation Directory

This directory contains project documentation, vision documents, and reference material. These files are **not consumed by the plugin at runtime** — they exist for humans and for Claude to understand context.

## What belongs here

- **Product vision and strategy** — long-term direction, competitive analysis, market positioning
- **Developer guides** — contributor setup, conventions, pipeline details
- **Architecture documents** — system design, component descriptions, data flow

Everything in `docs/` is **public** — it's committed to the repo and visible to anyone.

## What does NOT belong here

- **Internal planning** — business strategy, initiative briefs, pricing models, competitive teardowns go in `private/` (gitignored, never pushed to the public repo)
- **Operational references** — files consumed by skills/agents at runtime go in `references/`
- **Skill or agent definitions** — go in `skills/` and `agents/`
- **Test reports** — go in `reports/`
- **Generated artifacts** — spec files go in the project root or user's working directory

## Naming

- `README.md` and `CLAUDE.md` stay ALL CAPS (platform convention)
- All other files use **kebab-case**: `system-architecture.md`, `developer-guide.md`, `vision.md`
- Names should be descriptive: `system-architecture.md` not `arch.md`

## Document Header

Every document (except README.md and CLAUDE.md) must start with a standard header:

```markdown
# Document Title

**Status:** draft | living | stable | archived
**Last updated:** YYYY-MM-DD
**Audience:** contributors | public
```

- **draft** — work in progress, may change substantially
- **living** — actively maintained, updated as the project evolves
- **stable** — mature content, changes are infrequent and incremental
- **archived** — kept for historical reference, no longer maintained

## Other conventions

- All files are markdown
- Keep `docs/README.md` updated when adding or removing documents
- Documents here may be referenced from root `README.md` and `CLAUDE.md` — update links when renaming or moving files
- The `docs/` directory is excluded from marketplace sync — these files are not shipped with the plugin

## About `private/`

Internal planning documents (business strategy, initiative briefs, pricing models, roadmap details) go in `private/` at the repo root. That directory is gitignored — never pushed to the public repo. No formal conventions enforced there, but the same document header is recommended for consistency.
