# ido4shape — Development Context

## What This Is

ido4shape is a **Claude Code / Cowork plugin** — a thinking partner that helps people crystallize what needs to be built. It guides PMs, founders, and tech leads through non-linear conversation until understanding is deep enough to produce a structured specification artifact.

**Two-tool architecture:**
```
ido4shape (plugin)  →  spec artifact (.md)  →  ido4 MCP (governance)
Creative upstream       The contract             GitHub issues + methodology
```

**V1 is zero code.** Every deliverable is a markdown file — soul.md, SKILL.md files, agent definitions, references. The intelligence lives in prompt design, not infrastructure.

## Development Conventions

- **All files are markdown** — no build tools, no npm, no TypeScript, no compilation
- **Plugin follows the Agent Skills standard** (agentskills.io) — SKILL.md with YAML frontmatter
- **SKILL.md bodies target 1,500-2,000 words** — heavy content goes in `references/` subdirectories within each skill
- **Skill descriptions should be "a little bit pushy"** — Claude tends to undertrigger; descriptions should clearly state activation conditions
- **Use XML tags in skill bodies** where Claude needs structured reasoning — XML produces better results than markdown for instructions
- **Progressive disclosure**: metadata (~100 tokens) always loaded → skill body on activation → references on demand
- **State in inspectable files**: all workspace state lives in `.ido4shape/` as human-readable markdown
- **Test locally**: `claude --plugin-dir ./` loads the plugin without installation. `/reload-plugins` picks up changes

## The Downstream Contract (Critical)

ido4shape produces spec artifacts that ido4's `spec-parser.ts` consumes. The parser is a line-by-line state machine with exact expectations:

**Heading patterns (regex):**
```
PROJECT:  /^# (.+)$/
GROUP:    /^## Group:\s*(.+)$/
TASK:     /^### ([A-Z]{2,5}-\d{2,3}):\s*(.+)$/
```

**Metadata — exact key names, in blockquotes immediately after headings:**
```markdown
> effort: S|M|L|XL | risk: low|medium|high|critical | type: feature|bug|research|infrastructure | ai: full|assisted|pair|human
> depends_on: PREFIX-NN, PREFIX-NN | -
```

**Quality gates:**
- Task body ≥200 characters with structured content
- Success conditions under `**Success conditions:**` as bullet list
- All `depends_on` references must exist in the document
- No circular dependencies (Kahn's algorithm)
- Task prefix must match group prefix (e.g., NCO- tasks in "Notification Core" group)
- Metadata values must be from exact allowed sets (case-insensitive)
- `depends_on: -` means explicit no dependencies; omitted = unspecified

## Plugin Structure (Target)

```
ido4shape/
├── .claude-plugin/
│   └── plugin.json                    # name: "ido4shape"
├── hooks/
│   └── hooks.json                     # Phase gate enforcement
├── skills/
│   ├── create-spec/                   # User-invocable: /ido4shape:create-spec
│   │   ├── SKILL.md
│   │   └── references/
│   ├── refine-spec/                   # User-invocable
│   │   └── SKILL.md
│   ├── validate-spec/                 # User-invocable
│   │   └── SKILL.md
│   ├── synthesize-spec/               # User-invocable
│   │   └── SKILL.md
│   ├── artifact-format/               # Auto-triggered (user-invocable: false)
│   │   ├── SKILL.md
│   │   └── references/
│   ├── creative-decomposition/        # Auto-triggered
│   │   ├── SKILL.md
│   │   └── references/
│   ├── dependency-analysis/           # Auto-triggered
│   │   └── SKILL.md
│   └── quality-guidance/              # Auto-triggered
│       └── SKILL.md
├── agents/
│   ├── spec-reviewer.md               # Sonnet — format + quality review
│   └── canvas-synthesizer.md          # Opus — reasoning-intensive composition
├── references/
│   ├── soul.md                        # Agent character (SoulSpec-aligned)
│   ├── artifact-format-spec.md
│   ├── example-notification-system.md
│   ├── methodology-mapping.md
│   └── project-templates/
├── settings.json
├── CLAUDE.md                          # This file
├── VISION.md                          # Full vision document
├── LICENSE
└── README.md
```

## Build Order (Current)

1. ~~CLAUDE.md + memory files~~ ← done
2. `references/soul.md` — agent character definition (SoulSpec-aligned). First — it infuses everything
3. `create-spec` SKILL.md — the conversation engine (80% of value)
4. Auto-triggered skills (artifact-format, creative-decomposition)
5. Canvas format reference + synthesize-spec
6. Remaining skills, agents, hooks, plugin manifest

## Related Repos

**ido4-MCP** — `/Users/bogdanionutcoman/dev-projects/ido4-MCP/`
- Spec artifact format: `spec-artifact-format.md`
- Parser: `packages/core/src/domains/ingestion/spec-parser.ts`
- Mapper: `packages/core/src/domains/ingestion/spec-mapper.ts`
- Profiles: `packages/core/src/profiles/` (hydro.ts, scrum.ts, shape-up.ts)
- Startup brief: `specs-wizard-startup-brief.md`

**specs-wizard** (old, reference only) — `/Users/bogdanionutcoman/dev-projects/specs-wizard/`
- Conversation starters: `templates/conversation-starters.md`
- Conversation examples: `knowledge/methodology/conversation-examples.md`
- Conversation philosophy: `CLAUDE.md` (energy management, question strategies)
- Example project: `projects/mini-jira/`

## Working Style

- Lead with original thinking, not organized checklists
- Be a genuine thinking partner — propose ideas, challenge assumptions, think independently
- Stay in exploration/investigation mode until explicitly told to build
- Don't ask obvious questions just for the sake of asking
- Share uncertainty as genuine thinking, not formatted "open questions" lists
- Deep reasoning and novel synthesis over pattern matching and categorization
