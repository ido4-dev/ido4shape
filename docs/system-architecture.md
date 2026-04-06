# ido4shape — System Architecture

**Status:** living | **Last updated:** 2026-04-06 | **Audience:** public

Version 0.4.9 | Platform: Claude Code, Cowork | License: MIT

---

## Overview

ido4shape is a Claude Code / Cowork plugin that guides product managers, founders, and tech leads through interactive discovery to crystallize understanding of what needs to be built. It produces **strategic specifications** — structured markdown artifacts capturing multi-stakeholder understanding of problems, solutions, dependencies, and success conditions.

The plugin has zero external runtime dependencies. Every deliverable is a markdown file. The intelligence lives in prompt design, not infrastructure. The one exception is `dist/spec-validator.js` — a bundled copy of the @ido4/spec-format parser CLI (~8KB, zero npm deps) for deterministic structural validation.

---

## Plugin Configuration

### Manifest

**Location:** `.claude-plugin/plugin.json`

The plugin declares itself to the Claude Code / Cowork ecosystem:
- **name:** `ido4shape`
- **version:** `0.4.2`
- **category:** `productivity`
- **repository:** `https://github.com/ido4-dev/ido4shape`
- **author:** Bogdan Coman

### Permissions

**Location:** `settings.json`

```json
{
  "permissions": {
    "allow": ["Read", "Write", "Edit", "Glob", "Grep", "Bash", "Agent"]
  }
}
```

- **Read/Write/Edit:** Workspace file management (`.ido4shape/` canvas, decisions, tensions, stakeholders, sessions)
- **Glob/Grep:** File discovery and source material analysis
- **Bash:** Hook execution and script-based validation
- **Agent:** Sub-agent spawning for parallel review and synthesis

---

## Hooks

**Location:** `hooks/hooks.json`

Five lifecycle hooks enforce phase gates and manage workspace continuity:

| Hook | Event | What It Does |
|------|-------|-------------|
| **SessionStart** | Plugin initializes | Creates `.ido4shape/` workspace if missing; copies spec-validator.js to plugin data directory |
| **PreToolUse** (Write) | Before Write tool | Checks canvas Understanding Assessment; blocks `*-spec.md` writes if understanding is insufficient |
| **UserPromptSubmit** | Every user message | Injects canvas Understanding Assessment into context for persistent awareness |
| **PreCompact** | Context about to compact | Prompts agent to save insights to canvas before tokens are trimmed |
| **Stop** | Session ending | Prompts agent to update canvas and write a session summary |

The **phase gate** (`phase-gate.sh`) parses the canvas for "not started" or "thin" signals in the Understanding Assessment. If found, it blocks spec artifact writing and explains which dimensions need more work.

No hook accesses the network, modifies files outside `.ido4shape/`, or runs destructive operations.

---

## Skills (10 Total)

### User-Invocable Skills (6)

These are explicitly called via `/ido4shape:<skill-name>`.

#### create-spec

The core experience. Guides a non-linear discovery conversation across six knowledge dimensions:

1. **Problem Depth** — who suffers, how acutely, workarounds, cost of inaction
2. **Solution Shape** — conceptual topology, capability clusters
3. **Boundary Clarity** — scope, constraints, non-goals
4. **Risk Landscape** — unknowns, external dependencies, unvalidated assumptions
5. **Dependency Logic** — what must exist before what
6. **Quality Bar** — definition of done, success conditions

The skill reads all available project materials (docs, code, data, meeting notes) before asking its first question. For returning sessions, it reads the existing canvas and opens with observations, not questions.

Conversation discipline: one focused question per turn, lead with question then context, propose when user signals uncertainty. After 8-10 substantive exchanges, assesses convergence and proposes review or synthesis.

**References:** `soul.md` (character), `canvas-format.md` (canvas structure), `stakeholder-profiles.md` (role adaptation), `conversation-starters.md`, `conversation-patterns.md`

#### synthesize-spec

Crystallizes the knowledge canvas into a formal strategic spec artifact. Pre-flight checks verify understanding depth, stakeholder coverage, settled decisions, and resolved tensions. For larger specs (4+ groups or 10+ capabilities), recommends running review-spec first.

Delegates composition to the **canvas-synthesizer** sub-agent (Opus) which reads the full workspace and produces the artifact. Post-composition verification checks format metadata, stakeholder attribution, and cross-cutting concern substance. Automatically runs validate-spec afterward.

#### validate-spec

Two-pass validation:

- **Pass 1 — Structural (deterministic):** Runs `node spec-validator.js <file>` for parser-based validation. Interprets every error with root-cause diagnosis.
- **Pass 2 — Quality (LLM judgment):** Checks description richness, success condition specificity, cross-cutting concern substance, stakeholder attribution, priority calibration.

If the `.ido4shape/` workspace exists, cross-references against canvas to catch dropped stakeholders, lost constraints, or missing cross-cutting concerns.

Combined verdict: **PASS** | **PASS WITH WARNINGS** | **FAIL**

#### refine-spec

Edits existing spec artifacts using natural language instructions. Handles: add/remove capabilities, split/merge groups, change dependencies, add stakeholder context, add cross-cutting concerns. Surfaces ripple effects before making changes and re-validates format and dependencies after each refinement.

#### review-spec

Launches parallel independent reviewers to assess the canvas or spec artifact:

1. **Technical Feasibility Reviewer** (Sonnet) → SOUND | CONCERNS | SIGNIFICANT ISSUES
2. **Scope Alignment Reviewer** (Sonnet) → ALIGNED | MINOR DRIFT | SCOPE ISSUES
3. **Dependency Auditor** (Sonnet) → CLEAN | MINOR ISSUES | STRUCTURAL PROBLEMS
4. **Format & Quality Reviewer** (Sonnet) → PASS | PASS WITH WARNINGS | FAIL *(only for existing artifacts)*

Synthesizes findings into: **READY** | **READY WITH NOTES** | **NOT READY**

#### stakeholder-brief

Generates a role-tailored 3-minute briefing from the current canvas. Covers: the problem from that role's perspective, key decisions they shouldn't relitigate, where their expertise is needed, active tensions relevant to them, and what to look at.

### Auto-Triggered Skills (4)

These activate automatically when their criteria are met. `user-invocable: false` in frontmatter.

#### quality-guidance

Activates when writing or reviewing capability descriptions, success conditions, priority/risk assessments, or evaluating spec quality. Provides standards for description richness (>=200 chars, multi-stakeholder), success condition specificity (independently verifiable, product-level), priority calibration, risk assessment (strategic, not code complexity), and group coherence.

#### dependency-analysis

Activates when conversation involves dependencies, ordering, critical paths, or `depends_on` fields. Provides principles (infrastructure before features, interfaces before implementations), pattern recognition (linear chains, fan-out, fan-in, cross-group), and quality checks (reachability, acyclicity, critical path analysis).

#### creative-decomposition

Activates during problem exploration and discovery conversations. Provides questioning patterns (Zoom In, What If, Connect the Dots, Surface to Depth, General to Specific), energy management (push harder when energy is high, step back on fatigue), and adaptive depth guidance.

**References:** `conversation-starters.md`, `conversation-patterns.md`

#### artifact-format

Activates when working with `*-spec.md` files or `.ido4shape/` workspace files. Provides format rules: heading patterns, metadata syntax, prefix derivation, dependency rules, quality gates.

**References:** `format-spec.md`

---

## Agents (5 Total)

All agents are spawned via the Agent tool. They read source materials and produce focused reports.

| Agent | Model | Purpose | Tools |
|-------|-------|---------|-------|
| **canvas-synthesizer** | Opus | Reasoning-intensive crystallization from canvas to spec artifact | Read, Write, Glob |
| **technical-reviewer** | Sonnet | Architecture coherence, risk honesty, constraint realism | Read, Glob, Grep |
| **scope-reviewer** | Sonnet | North star alignment, constraint compliance, coverage gaps | Read, Glob, Grep |
| **dependency-auditor** | Sonnet | Graph integrity, critical path, cross-group dependency health | Read, Glob, Grep |
| **spec-reviewer** | Sonnet | Format compliance + content quality on existing artifacts | Read, Glob, Grep |

No agent has Bash access or can execute arbitrary commands. The canvas-synthesizer is the only agent that writes files.

---

## Workspace Model (.ido4shape/)

Created automatically by the SessionStart hook. Persists across sessions.

```
.ido4shape/
├── canvas.md          # Living knowledge document (continuously updated)
├── stakeholders.md    # Contributors and their perspectives
├── decisions.md       # Settled choices with reasoning
├── tensions.md        # Active contradictions between stakeholders/requirements
├── sessions/          # Session summaries (one per session)
│   ├── session-001-pm.md
│   └── session-002-architect.md
└── sources/           # Raw input materials
```

### Canvas (canvas.md)

The central knowledge document. Represents current understanding, not a transcript.

**Understanding Assessment** — six dimensions, each with a signal level:
- **not started** — dimension unexplored
- **thin** — some exploration, significant gaps
- **forming** — conceptual structure emerging
- **solid** — well-understood, multi-perspective, stable
- **deep** — multi-stakeholder, validated, comprehensive

Sections: Problem Understanding, Solution Concepts, Stakeholders, Cross-Cutting Concerns, Constraints & Non-Goals, Dependencies, Risk Assessment, Open Questions, Key Insights.

**Update discipline:** Update in place immediately after significant exchanges. Canvas represents CURRENT understanding, not history.

### Decisions (decisions.md)

Tracks architectural decisions, scope choices, constraint acceptances. Each entry captures: context, choice, rationale, alternatives considered, and which stakeholders decided.

### Tensions (tensions.md)

Holds contradictions between stakeholder perspectives or requirements. Logged immediately when they surface. Held until enough context exists for good resolution — not forced to premature closure.

### Sessions (sessions/)

One summary per session. Curated memory, not transcripts. Captures: key insights, decisions made, tensions surfaced, perspective shifts, notable statements, and next session focus.

---

## Bundled Validator

**Location:** `dist/spec-validator.js` (~8KB, zero npm dependencies)

**Source:** @ido4/spec-format package from ido4-MCP repository

Deterministic structural validation of strategic specs. Invoked via `node spec-validator.js <path>`, outputs JSON with:
- Validity status
- Metrics (group count, capability count, dependency edges, max depth)
- Parsed structure (project, groups, capabilities, dependency graph)
- Errors and warnings

**Error types:** circular dependencies, broken references, duplicate IDs, missing format marker, invalid metadata values, empty groups.

**Installation:** SessionStart hook copies the bundle to `${CLAUDE_PLUGIN_DATA}/spec-validator.js`. If unavailable, validation falls back to LLM-only.

**Update mechanism:** ido4-MCP publishes @ido4/spec-format → CI dispatches to ido4shape via `update-validator.yml`. Patch/minor auto-merge; major requires review.

---

## Data Flow

```
USER PROJECT MATERIALS (docs, code, notes, data)
    │
    ├── SessionStart Hook
    │   ├── Create .ido4shape/ workspace
    │   └── Copy spec-validator.js to plugin data
    │
    ├── /ido4shape:create-spec ──────────────────────────────────────────
    │   │
    │   │  DISCOVERY PHASE
    │   │  ├── Read all available materials
    │   │  ├── Explore six knowledge dimensions non-linearly
    │   │  ├── canvas.md: update in real-time after significant exchanges
    │   │  ├── tensions.md: log contradictions immediately
    │   │  ├── decisions.md: log choices when made
    │   │  ├── stakeholders.md: track who contributed what
    │   │  │
    │   │  │  [UserPromptSubmit hook injects canvas state on every turn]
    │   │  │  [PreCompact hook saves canvas before context trim]
    │   │  │  [Stop hook ensures canvas + session summary updated]
    │   │  │
    │   │  └── After convergence: propose review or synthesis
    │   │
    ├── /ido4shape:review-spec (optional) ───────────────────────────────
    │   │  ├── Technical Reviewer (Sonnet)  ─┐
    │   │  ├── Scope Reviewer (Sonnet)       ├── parallel
    │   │  ├── Dependency Auditor (Sonnet)   ─┘
    │   │  └── Synthesis: READY | READY WITH NOTES | NOT READY
    │   │
    ├── /ido4shape:synthesize-spec ──────────────────────────────────────
    │   │  ├── Pre-flight: understanding depth, stakeholder coverage,
    │   │  │   settled decisions, resolved tensions
    │   │  ├── Source material reconciliation (scan for unincorporated docs)
    │   │  ├── Canvas Synthesizer (Opus) reads full workspace
    │   │  ├── Writes [project-name]-spec.md
    │   │  └── Post-composition: format check, attribution check
    │   │
    ├── /ido4shape:validate-spec (optional) ─────────────────────────────
    │   │  ├── Pass 1: structural (parser) → errors with root-cause diagnosis
    │   │  ├── Pass 2: quality (LLM) → description, success conditions, NFRs
    │   │  └── Verdict: PASS | PASS WITH WARNINGS | FAIL
    │   │
    ├── /ido4shape:refine-spec (optional) ───────────────────────────────
    │   │  ├── Natural language edits
    │   │  ├── Ripple effect analysis
    │   │  └── Re-validate format and dependencies
    │   │
    └── STRATEGIC SPEC ARTIFACT ─────────────────────────────────────────
        │
        ├── To human teams: project brief
        ├── To investors/executives: strategy document
        ├── To AI coding agents: structured input
        └── To ido4 MCP: automated technical decomposition
```

---

## The Downstream Contract

ido4shape produces strategic specs. The downstream consumer is ido4 MCP's decomposition agent — an AI that reads the strategic spec, explores the actual codebase, and produces implementation-ready technical tasks.

```
ido4shape (plugin)  →  strategic spec (.md)  →  ido4 MCP (decomposition)  →  technical spec (.md)  →  GitHub issues
Creative upstream       The WHAT                  Codebase-aware                The HOW                  Governance
```

### Strategic Spec Format

**Format identifier:** `> format: strategic-spec | version: 1.0`

**Heading patterns:**
```
PROJECT:     /^# (.+)$/
GROUP:       /^## Group:\s*(.+)$/
CAPABILITY:  /^### ([A-Z]{2,5}-\d{2,3}):\s*(.+)$/
```

**Metadata (strategic level only):**
```markdown
> priority: must-have | should-have | nice-to-have
> priority: must-have | risk: low | medium | high
> depends_on: PREFIX-NN, PREFIX-NN | -
```

**Not in strategic specs:** `effort`, `type`, `ai`, `size` — these require codebase knowledge and are determined by ido4 MCP during technical decomposition.

### What ido4 MCP Adds

From the strategic spec, ido4 MCP reads the problem context, stakeholders, cross-cutting concerns, capability groups, success conditions, priority, strategic risk, and dependencies. It then adds: effort estimates (S/M/L/XL from code analysis), type classification, AI suitability, code-level dependencies, and technical risk.

---

## Testing & CI

### Validation Suite

**Location:** `tests/validate-plugin.sh`

Tests plugin structure, format compliance, content quality, and internal consistency:

1. Plugin manifest (plugin.json valid, required fields present)
2. Directory structure (skills, agents, hooks, references, dist, .claude-plugin)
3. Documentation files (README, SECURITY, CHANGELOG, LICENSE, docs/)
4. SKILL.md files (all 10 present, YAML frontmatter, word count)
5. Skill references (all referenced files exist)
6. Auto-triggered vs user-invocable classification
7. Agent files (5 agents, frontmatter, valid models)
8. Hooks configuration (hooks.json valid, all events defined)
9. Validator bundle (exists, executable, produces valid JSON)
10. Documentation cross-references (README claims backed by files)

### CI

Runs on every push to main and on PRs. Validates full plugin structure.

### Additional Workflows

- **sync-marketplace.yml** — syncs to marketplace when plugin.json version changes
- **update-validator.yml** — pulls latest spec-validator.js from ido4-MCP

---

## Security & Data Handling

- **All data stays local.** No network requests, no telemetry, no external services.
- **Workspace files are plain text markdown.** Not encrypted, not binary.
- **Recommended:** add `.ido4shape/` to `.gitignore` — it's working state, not a project artifact.
- **The spec artifact** (`*-spec.md`) is the only output designed to be shared.
- **Sub-agents** have no Bash access — they read workspace files and produce reports.

---

## Technology Stack

| Component | Technology | Notes |
|-----------|-----------|-------|
| Plugin format | Agent Skills standard (agentskills.io) | SKILL.md with YAML frontmatter |
| All authored files | Markdown | No build tools, no compilation |
| Hooks | Bash scripts + inline prompts | Lifecycle enforcement |
| Validator | Bundled JavaScript (~8KB) | Zero npm deps, runs via Node.js |
| Sub-agents | Claude models (Opus, Sonnet) | Spawned via Agent tool |
| CI | GitHub Actions | Structure validation |
| Marketplace | ido4-dev/ido4-plugins | Auto-synced on release |
