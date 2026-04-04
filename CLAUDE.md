# ido4shape — Development Context

## What This Is

ido4shape is a **Claude Code / Cowork plugin** — a thinking partner that helps people crystallize what needs to be built. It guides PMs, founders, and tech leads through non-linear conversation until understanding is deep enough to produce a structured specification artifact.

**Two-artifact pipeline:**
```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  ido4 ingestion  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

ido4shape produces strategic specs — multi-stakeholder understanding crystallized into structured prose. ido4 MCP reads the strategic spec, explores the actual codebase, and produces a technical spec with implementation-ready tasks. The existing ingestion pipeline turns the technical spec into governed GitHub issues.

**V1 has zero external dependencies.** Every deliverable is a markdown file — soul.md, SKILL.md files, agent definitions, references. The intelligence lives in prompt design, not infrastructure. The one exception is `dist/spec-validator.js` — a bundled copy of the @ido4/spec-format parser CLI (~8KB, zero npm deps) for deterministic structural validation.

## Development Conventions

- **All authored files are markdown** — no build tools, no npm, no TypeScript, no compilation
- **One bundled artifact:** `dist/spec-validator.js` is built upstream in ido4-MCP, committed to git, and shipped with the plugin
- **Plugin follows the Agent Skills standard** (agentskills.io) — SKILL.md with YAML frontmatter
- **SKILL.md bodies target 1,500-2,000 words** — heavy content goes in `references/` subdirectories within each skill
- **Skill descriptions should be "a little bit pushy"** — Claude tends to undertrigger; descriptions should clearly state activation conditions
- **No XML tags in skill bodies** — triggers Cowork injection defense. Use markdown headers instead
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
│   ├── review-spec/                   # User-invocable
│   │   └── SKILL.md
│   ├── stakeholder-brief/             # User-invocable
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
│   ├── spec-reviewer.md               # Sonnet — format + quality review (4th reviewer in review-spec)
│   ├── canvas-synthesizer.md          # Opus — reasoning-intensive composition
│   ├── technical-reviewer.md          # Sonnet — architecture feasibility review
│   ├── scope-reviewer.md              # Sonnet — scope alignment review
│   └── dependency-auditor.md          # Sonnet — dependency graph audit
├── references/
│   ├── soul.md                        # Agent character (SoulSpec-aligned)
│   ├── strategic-spec-format.md       # Full strategic spec format specification
│   ├── artifact-format-spec.md        # Quick reference
│   ├── example-strategic-notification-system.md  # Strategic spec example
│   ├── example-notification-system.md # Technical spec example (reference)
│   ├── methodology-mapping.md
│   ├── strategic-spec-adaptation-plan.md  # Work plan for this adaptation
│   └── project-templates/
├── dist/
│   ├── spec-validator.js              # Bundled validator (~8KB, zero deps)
│   ├── .spec-format-version           # Bundle version marker
│   └── .spec-format-checksum          # SHA-256 checksum
├── docs/
│   ├── CLAUDE.md                      # Documentation directory instructions
│   ├── README.md                      # Documentation index
│   ├── developer-guide.md             # Spec format, workspace structure, pipeline
│   ├── vision.md                      # Product vision & strategy
│   └── system-architecture.md         # Technical architecture reference
├── private/                           # Internal planning docs (gitignored)
│   ├── enterprise-cloud-vision.md     # Enterprise cloud platform brief
│   └── simulate-plan.md               # Synthetic testing framework plan
├── settings.json
├── CLAUDE.md                          # This file
├── CONTRIBUTING.md                    # How to contribute
├── SECURITY.md                        # Data handling, hooks, privacy
├── CHANGELOG.md                       # Version history (auto-generated on release)
├── LICENSE
└── README.md
```

## Build History

1. ~~V1 plugin~~ — complete (30 files, 99 tests, all skills/agents/hooks)
2. ~~Strategic spec format~~ — designed and documented
3. ~~Skill adaptation~~ — all skills, agents, references updated for strategic spec output
4. ~~First real-world test~~ — complete (2026-03-24). Full pipeline: create-spec → synthesize-spec → validate-spec → refine-spec → review-spec → validate-spec. 12 observations logged. See `reports/first-real-world-test.md`
5. ~~High-severity obs fixes~~ — OBS-01, 05, 06, 08, 11 addressed (v0.3.3, 2026-04-02). Workspace discipline, turn discipline, format skeleton, source reconciliation, review gate.
6. ~~Bundled validator~~ — replaced npm install approach with bundled .js file (2026-03-29). See `architecture/bundled-validator-architecture.md` in ido4-MCP.
7. ~~E2E test #2~~ — OpenClaw outreach project (v0.3.3, 2026-04-02). 4/5 fixes pass, 1 mostly pass. 3 follow-up fixes applied (v0.3.4): convergence check, stronger propose mode, prefix length rule. See `reports/e2e-test-002-openclaw-outreach.md`
8. ~~Marketplace submission prep~~ — (v0.4.0-v0.4.2, 2026-04-03). Standalone positioning, README rewrite with example workflows, SECURITY.md, developer-guide.md, CHANGELOG.md, SEO optimization, spec-reviewer integrated into review-spec, test suite expanded to 199 checks, LLM-powered changelog generation, marketplace sync for description/category.
9. Next: Submit to official Anthropic plugin marketplace

## Bundled Validator

ido4shape ships a bundled copy of the @ido4/spec-format parser CLI at `dist/spec-validator.js`.
This is a single self-contained JS file (~8KB) with zero npm dependencies.

**How it works:**
- SessionStart hook copies the bundle to `${CLAUDE_PLUGIN_DATA}/spec-validator.js`
- The validate-spec skill runs it via `node` to get deterministic structural validation
- If the bundle is unavailable, validation falls back to LLM-only (graceful degradation)

**How it's updated:**
- ido4-MCP publishes @ido4/spec-format → CI dispatches to ido4shape
- `update-validator.yml` creates a PR with the new bundle
- Patch/minor updates auto-merge after CI passes
- Major version updates require review (output format may have changed)

**Manual update (if needed):**
```bash
scripts/update-validator.sh 0.7.0                  # from npm
scripts/update-validator.sh ~/dev-projects/ido4-MCP # from local build
```

**Release checks:**
- `release.sh` hard-fails if bundle is missing
- `release.sh` warns if bundle version differs from latest npm version
- CI validates bundle presence, version header, and execution

## Testing & Experience Reports

After every end-to-end test of ido4shape (manual or synthetic), produce a structured experience report in `reports/`. Each report documents: what was tested, pipeline steps, what worked, what didn't, observations, and implications.

- `reports/first-real-world-test.md` — First e2e test (ido4-simulate project, 2026-03-24). **This is the calibration baseline for the ido4-simulate synthetic testing framework.** The 12 observations map to synthetic test signals — the framework should detect these same issues automatically.
- `reports/ido4-simulate-observations.md` — Structured observation log from the first test (12 observations with type, root cause, fix candidates, synthetic test signals)
- `private/simulate-plan.md` — Detailed plan for the synthetic testing framework (1,200+ lines, architecture, cost model, research design). Gitignored — not in public repo.
- `reports/e2e-test-002-openclaw-outreach.md` — Second e2e test (OpenClaw outreach, 2026-04-02). Validated obs fixes, found 3 follow-ups.

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

### CI & Automation

**CI** runs on every push to main and on PRs — validates plugin structure (199 tests, ~4s).

**Marketplace auto-sync** triggers when `plugin.json` version changes on main — syncs full plugin directory + updates description, category, and version in `ido4-dev/ido4-plugins` marketplace manifest. No manual marketplace bumps needed.

### Releasing

```bash
bash scripts/release.sh [patch|minor|major] "Release message"
```

This bumps the version in `plugin.json`, auto-generates a CHANGELOG entry (LLM-powered via Haiku with deterministic fallback), commits, and pushes. The marketplace sync CI handles the rest automatically.

**LLM changelog:** Requires `claude` CLI to be logged in (`claude /login`). The script warns at startup if auth is missing. Falls back to deterministic conventional-commit parsing if unavailable.

### Deploying to Cowork / CLI

After a release is pushed:

**For Cowork:**
1. In Cowork UI: click `...` next to `ido4-plugins` → Sync
2. Reinstall the plugin in Cowork

**For Claude Code CLI:**
1. `claude plugin marketplace update ido4-plugins`
2. `claude plugin uninstall ido4shape@ido4-plugins && claude plugin install ido4shape@ido4-plugins`

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
