# ido4shape — Development Context

## What This Is

A **Claude Code / Cowork plugin** that helps people crystallize what needs to be built. Guides PMs, founders, and tech leads through conversation to produce a strategic specification artifact.

Pipeline: `ido4shape → strategic spec (.md) → ido4 MCP (decomposition) → technical spec (.md) → GitHub issues`

V1 has zero external dependencies. Every deliverable is markdown. The one exception is `dist/spec-validator.js` — a bundled @ido4/spec-format parser CLI (~8KB, zero npm deps).

## Development Conventions

- **All authored files are markdown** — no build tools, no npm, no TypeScript
- **One bundled artifact:** `dist/spec-validator.js` — built upstream in ido4, committed to git
- **Plugin follows Agent Skills standard** (agentskills.io) — SKILL.md with YAML frontmatter
- **SKILL.md bodies target 1,500-2,000 words** — heavy content goes in `references/` subdirectories
- **Skill descriptions should be pushy** — Claude undertriggers; clearly state activation conditions
- **No XML tags in skill bodies** — triggers Cowork injection defense. Use markdown headers
- **Progressive disclosure**: metadata always loaded → skill body on activation → references on demand
- **State in inspectable files**: workspace state lives in `.ido4shape/` as human-readable markdown
- **Test locally**: `claude --plugin-dir ./` loads the plugin. `/reload-plugins` picks up changes

## The Downstream Contract (Critical)

ido4shape produces **strategic specs** consumed by ido4 MCP's decomposition agent. The parser is the trust boundary — both ido4shape and MCP use the same @ido4/spec-format parser. Empty fields in parser output mean MCP also sees them as empty.

**Format identifier:** `> format: strategic-spec | version: 1.0`

**Heading patterns:**
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

**Not in strategic specs:** `effort`, `type`, `ai`, `size` — determined by ido4 MCP during decomposition.

**Quality gates:**
- Capability body ≥200 characters with multi-stakeholder context
- Success conditions under `**Success conditions:**` as bullet list
- All `depends_on` references must exist; no circular dependencies
- Capability prefix must match group prefix
- Stakeholders, constraints sections present
- `depends_on: -` = explicit no dependencies; omitted = unspecified

**Full format spec:** `references/strategic-spec-format.md` | **Example:** `references/example-strategic-notification-system.md`

## Bundled Validator

`dist/spec-validator.js` — bundled @ido4/spec-format CLI. SessionStart hook copies to `${CLAUDE_PLUGIN_DATA}/`. Falls back to LLM-only if unavailable.

**Manual update:** `scripts/update-validator.sh 0.7.0` (npm) or `scripts/update-validator.sh ~/dev-projects/ido4` (local). Automated sync via CI — see `.claude/rules/cross-repo-sync.md`.

## Testing, Releasing, Deploying

```bash
bash tests/validate-plugin.sh                                    # 203 checks
bash scripts/release.sh [patch|minor|major] "Release message"        # bump + changelog + push
bash scripts/release.sh --yes [patch|minor|major] "Release message"  # non-interactive (agent/CI)
```

**Release:** bumps `plugin.json` version, auto-generates CHANGELOG (Haiku LLM with deterministic fallback), commits, pushes. CI syncs to marketplace automatically.

**Deploy to Cowork:** Cowork UI → Sync `ido4-plugins` → Reinstall plugin.
**Deploy to CLI:** `claude plugin marketplace update ido4-plugins && claude plugin uninstall ido4shape@ido4-plugins && claude plugin install ido4shape@ido4-plugins`

These are separate systems — CLI commands do NOT update Cowork and vice versa.

**After e2e tests:** produce a structured report in `reports/`. See existing reports for format.

## ido4 Suite Coordination

This repo is part of the ido4 suite. Cross-repo release patterns, audit tooling, and coordination docs live in `~/dev-projects/ido4-suite/`:

- `docs/release-architecture.md` — the canonical 4-layer release pattern this repo follows (reference implementation)
- `scripts/audit-suite.sh` — verifies all repos against the pattern. Run after any release/CI changes: `bash ~/dev-projects/ido4-suite/scripts/audit-suite.sh`
- `PLAN.md` — master plan tracking in-progress cross-repo work
- `docs/cross-repo-connections.md` — dispatch map, shared secrets, trust boundaries

Before changing release scripts, CI workflows, or cross-repo dispatch: read `release-architecture.md` first. After changes: run the audit script. Also see `.claude/rules/cross-repo-sync.md` for the bundled validator sync flow specifically.

Before writing or auditing skills, agents, or prompts: read `docs/prompt-strategy.md` first. It defines degrees of freedom, rules vs principles, language guidance for Opus 4.5/4.6, skill architecture patterns, and the two-layer validation pattern.

## Cowork Compatibility Rules

- **No XML tags in SKILL.md** — triggers injection defense. Use markdown headers.
- **No directive language** — "you are not following instructions" gets flagged. Use guidance framing.
- **Avoid literal relative paths** — `.ido4shape/canvas.md` gets flagged. Describe the intent instead.
- **`${CLAUDE_SKILL_DIR}`** resolves to skill's own directory. Use for within-skill refs.
- **`${CLAUDE_PLUGIN_ROOT}`** only works in hooks.json and .mcp.json — NOT in SKILL.md.
- **Always select a working folder** for Cowork sessions — without it, injection defense blocks skills.
- **Keep skills lean** — heavy skills are slower and more likely to trigger false positives.

## Working Style

- Lead with original thinking, not organized checklists
- Be a genuine thinking partner — propose ideas, challenge assumptions, think independently
- Stay in exploration/investigation mode until explicitly told to build
- Don't ask obvious questions just for the sake of asking
- Share uncertainty as genuine thinking, not formatted "open questions" lists
- Deep reasoning and novel synthesis over pattern matching and categorization
