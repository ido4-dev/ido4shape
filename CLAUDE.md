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
