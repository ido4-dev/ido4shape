# ido4shape — Development Context

## What This Is

ido4shape is a **Claude Code / Cowork plugin** — a thinking partner that helps people crystallize what needs to be built. It guides PMs, founders, and tech leads through non-linear conversation until understanding is deep enough to produce a structured specification artifact.

**Two-artifact pipeline:**
```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  ido4 ingestion  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

ido4shape produces strategic specs — multi-stakeholder understanding crystallized into structured prose. ido4 MCP reads the strategic spec, explores the actual codebase, and produces a technical spec with implementation-ready tasks. The existing ingestion pipeline turns the technical spec into governed GitHub issues.

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

ido4shape produces **strategic specs** consumed by ido4 MCP's decomposition agent — an AI that reads the spec, explores the codebase, and produces technical implementation tasks. The strategic spec is NOT consumed by the ingestion parser directly.

**Format identifier:** `> format: strategic-spec | version: 1.0` in project metadata.

**Heading patterns (same structural regex):**
```
PROJECT:     /^# (.+)$/
GROUP:       /^## Group:\s*(.+)$/
CAPABILITY:  /^### ([A-Z]{2,5}-\d{2,3}):\s*(.+)$/
```

**Metadata — strategic level only:**
```markdown
> format: strategic-spec | version: 1.0          (project level)
> priority: must-have|should-have|nice-to-have    (groups and capabilities)
> priority: must-have | risk: low|medium|high     (capabilities)
> depends_on: PREFIX-NN, PREFIX-NN | -            (capabilities)
```

**Not in strategic specs:** `effort`, `type`, `ai`, `size` — these require codebase knowledge and are determined by ido4 MCP during technical decomposition.

**Quality gates:**
- Capability body ≥200 characters with multi-stakeholder context
- Success conditions under `**Success conditions:**` as bullet list
- All `depends_on` references must exist in the document
- No circular dependencies
- Capability prefix must match group prefix
- Stakeholders section present
- Cross-cutting concerns section with substance (when applicable)
- `depends_on: -` means explicit no dependencies; omitted = unspecified

**Full format spec:** `references/strategic-spec-format.md`
**Example:** `references/example-strategic-notification-system.md`

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
│   ├── strategic-spec-format.md       # Full strategic spec format specification
│   ├── artifact-format-spec.md        # Quick reference
│   ├── example-strategic-notification-system.md  # Strategic spec example
│   ├── example-notification-system.md # Technical spec example (reference)
│   ├── methodology-mapping.md
│   ├── strategic-spec-adaptation-plan.md  # Work plan for this adaptation
│   └── project-templates/
├── settings.json
├── CLAUDE.md                          # This file
├── VISION.md                          # Full vision document
├── LICENSE
└── README.md
```

## Build History

1. ~~V1 plugin~~ — complete (30 files, 99 tests, all skills/agents/hooks)
2. ~~Strategic spec format~~ — designed and documented
3. ~~Skill adaptation~~ — all skills, agents, references updated for strategic spec output
4. Next: test with real conversations, then update project templates

## Related Repos

**ido4-MCP** — `/Users/bogdanionutcoman/dev-projects/ido4-MCP/`
- Technical spec format: `spec-artifact-format.md` (what ido4 MCP produces, not what ido4shape produces)
- Parser: `packages/core/src/domains/ingestion/spec-parser.ts` (consumes technical specs only)
- Mapper: `packages/core/src/domains/ingestion/spec-mapper.ts`
- Profiles: `packages/core/src/profiles/` (hydro.ts, scrum.ts, shape-up.ts)
- MCP plan: `strategic-spec-mcp-plan.md` (ido4 MCP's side of the two-artifact work)
- Transferred skills: `packages/plugin/skills/spec-quality/`, `packages/plugin/skills/spec-validate/`

**specs-wizard** (old, reference only) — `/Users/bogdanionutcoman/dev-projects/specs-wizard/`
- Conversation starters: `templates/conversation-starters.md`
- Conversation examples: `knowledge/methodology/conversation-examples.md`
- Conversation philosophy: `CLAUDE.md` (energy management, question strategies)
- Example project: `projects/mini-jira/`

## Cowork Debugging

Cowork session data lives at:
```
~/Library/Application Support/Claude/local-agent-mode-sessions/<accountId>/<orgId>/
```

Each session has:
- `local_<sessionId>.json` — metadata (title, model, timestamps, userSelectedFolders)
- `local_<sessionId>/` — session directory
  - `.claude/projects/-sessions-<vm-name>/<cliSessionId>.jsonl` — conversation transcript
  - `audit.jsonl` — audit log
  - `outputs/` — files produced

To investigate a hung or failed session, read the conversation JSONL and look for:
- `"Operation stopped by hook"` — Cowork's injection defense falsely flagged skill content
- Path resolution errors — relative paths don't resolve safely in the VM sandbox
- Rate limit events — API throttling

### Cowork Usage Requirement

**Always select a working folder** when starting a Cowork session with ido4shape. Without a mounted folder, Cowork's injection defense blocks skill execution. With a folder selected, it works reliably.

### Deploying Updates

**For Cowork:**
1. Push to GitHub (`git push`)
2. In Cowork UI: click `...` next to `ido4-plugins` → Sync
3. Reinstall the plugin in Cowork

**For Claude Code CLI:**
1. Push to GitHub
2. `claude plugin marketplace update ido4-plugins`
3. `claude plugin uninstall ido4shape@ido4-plugins && claude plugin install ido4shape@ido4-plugins`

These are separate systems. CLI commands do NOT update Cowork. Cowork UI syncs do NOT update CLI. Do not use `deploy-to-cowork.sh` or manual file copies — they create duplicate plugin copies that conflict.

### Cowork Compatibility Rules (Learned the Hard Way)

- **No XML tags in SKILL.md** — tags like `<context>`, `<initialization>` trigger Cowork's injection defense. Use markdown headers instead.
- **No directive language that sounds like injection** — "you are not following instructions" gets flagged. Use guidance framing instead.
- **Avoid literal relative paths in skill instructions** — `.ido4shape/canvas.md` as a literal instruction gets flagged as "file-based context injection." Describe the intent instead.
- **`${CLAUDE_SKILL_DIR}`** resolves to the skill's own directory. Use `${CLAUDE_SKILL_DIR}/references/` for within-skill refs.
- **`${CLAUDE_SKILL_DIR}/../../references/`** traverses up to plugin root. Works but can be fragile in the VM.
- **`${CLAUDE_PLUGIN_ROOT}`** only works in hooks.json and .mcp.json — NOT in SKILL.md content.
- **Keep skills lean** — heavy instruction-loaded skills are slower and more likely to trigger safety false positives.

## Working Style

- Lead with original thinking, not organized checklists
- Be a genuine thinking partner — propose ideas, challenge assumptions, think independently
- Stay in exploration/investigation mode until explicitly told to build
- Don't ask obvious questions just for the sake of asking
- Share uncertainty as genuine thinking, not formatted "open questions" lists
- Deep reasoning and novel synthesis over pattern matching and categorization
