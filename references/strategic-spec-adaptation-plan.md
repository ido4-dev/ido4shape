# ido4shape — Strategic Spec Adaptation Plan

Adapting ido4shape from producing implementation-ready artifacts to producing strategic specs.

**This is the ido4shape side of a two-project change.** For the ido4 side (decomposition agent, strategic spec reader, technical spec producer), see `/Users/bogdanionutcoman/dev-projects/ido4/strategic-spec-mcp-plan.md`.

## Context

The two-artifact architecture (decided 2026-03-18) splits specification into:
- **Strategic spec** (ido4shape) — multi-stakeholder understanding, prose-rich, minimal metadata
- **Technical spec** (ido4 MCP) — codebase-grounded implementation tasks, full metadata

Format designed: `references/strategic-spec-format.md`
Example: `references/example-strategic-notification-system.md`

## Pre-Work: Transfer Implementation-Level Assets to ido4

Before rewriting ido4shape skills, transfer content that ido4 MCP will need for its side of the pipeline. These assets currently live in ido4shape but belong on the governance/implementation side.

**What to transfer:**
- `skills/quality-guidance/SKILL.md` — effort/risk/AI suitability definitions and calibration logic
- `skills/validate-spec/SKILL.md` — format validation protocol for implementation-ready specs
- `agents/spec-reviewer.md` — two-stage review protocol (format compliance + quality assessment)

**How:** Adapt framing from "discovery/conversation" to "governance/execution." Create as new skills in ido4's plugin. Don't copy-paste — rewrite for the MCP audience.

**When:** Before rewriting these skills in ido4shape. The current content is the source material.

---

## Phase 1: Format Foundation

### 1.1 Update artifact-format skill
**File:** `skills/artifact-format/SKILL.md`
**Current:** Teaches implementation-ready format (effort, risk, type, ai metadata, parser regex)
**New:** Teaches strategic spec format — heading patterns (unchanged), strategic metadata (priority, risk-redefined, depends_on), prose-rich content sections, cross-cutting concerns
**Also update:** `skills/artifact-format/references/format-spec.md` — replace with strategic spec rules

### 1.2 Update artifact-format-spec reference
**File:** `references/artifact-format-spec.md`
**Current:** Quick reference for implementation-ready format
**New:** Quick reference for strategic spec format. Point to `strategic-spec-format.md` as the comprehensive spec.

### 1.3 Update example artifact
**File:** `references/example-notification-system.md`
**Current:** Implementation-ready notification system with effort/risk/type/ai
**New:** Replace with strategic version (`example-strategic-notification-system.md` already written)

### 1.4 Update or remove methodology-mapping reference
**File:** `references/methodology-mapping.md`
**Current:** Maps artifact values to Hydro/Scrum/Shape Up methodology concepts
**Decision needed:** Strategic specs are methodology-agnostic by design. The methodology mapping is now ido4 MCP's concern (it already has this in `spec-artifact-format.md`). This reference may no longer be needed in ido4shape, or could be reduced to a brief note that strategic specs are methodology-agnostic and ido4 MCP handles methodology mapping.

---

## Phase 2: Composition Pipeline

### 2.1 Update canvas-synthesizer agent
**File:** `agents/canvas-synthesizer.md`
**Current:** Produces implementation-ready artifact with effort/risk/type/ai judgments
**New:** Produces strategic spec. Key changes:
- Output `format: strategic-spec | version: 1.0` in project header
- Use `priority` and strategic `risk` instead of effort/type/ai
- Include Stakeholders section from canvas stakeholder data
- Include Cross-Cutting Concerns section from canvas (NFRs, security, performance, etc.)
- Write richer prose descriptions with stakeholder attribution
- Don't make implementation-level judgment calls (no effort estimation, no AI suitability classification)

### 2.2 Update synthesize-spec skill
**File:** `skills/synthesize-spec/SKILL.md`
**Current:** Pre-flight checks include understanding depth for implementation-level detail
**New:** Pre-flight checks focus on multi-stakeholder coverage, cross-cutting concern capture, constraint clarity. The threshold for "ready to synthesize" shifts — you don't need to know enough to estimate effort, but you DO need rich stakeholder perspectives and clear success conditions.

### 2.3 Update spec-reviewer agent
**File:** `agents/spec-reviewer.md`
**Current:** Reviews against implementation-ready format rules
**New:** Reviews against strategic spec format rules. Format checks change (priority instead of effort, no type/ai fields). Quality checks shift to: stakeholder coverage, cross-cutting concern richness, success condition specificity, prose quality.

### 2.4 Update review-spec skill and sub-agents
**File:** `skills/review-spec/SKILL.md` + `agents/technical-reviewer.md`, `agents/scope-reviewer.md`, `agents/dependency-auditor.md`
**Current:** Technical reviewer checks effort/risk honesty, AI suitability, implementation feasibility
**New:** Technical reviewer checks strategic risk honesty, constraint realism, NFR completeness. Scope reviewer stays mostly the same (north star alignment, non-goal respect). Dependency auditor stays the same (graph integrity, critical path — functional dependencies are still valid).

---

## Phase 3: Quality & Validation

### 3.1 Update quality-guidance skill
**File:** `skills/quality-guidance/SKILL.md`
**Current:** Coaches on effort calibration, risk assessment, AI suitability, task description quality
**New:** Coaches on strategic-level quality:
- Priority calibration (when is something truly must-have vs should-have?)
- Strategic risk assessment (unknowns, external dependencies, stakeholder disagreement)
- Capability description quality (multi-stakeholder perspective, user-facing value, enough context for technical decomposition)
- Success condition quality (unchanged — still needs to be specific and independently verifiable)
- Cross-cutting concern quality (are NFRs specific enough? Are security requirements actionable?)
- Stakeholder coverage (are all relevant perspectives represented?)

### 3.2 Update validate-spec skill
**File:** `skills/validate-spec/SKILL.md`
**Current:** Validates against parser expectations (metadata values, prefix matching, 200-char bodies)
**New:** Validates against strategic spec format:
- Format: `format: strategic-spec` present, headings correct, prefixes consistent
- Metadata: `priority` on all groups and capabilities, `risk` on capabilities, `depends_on` valid
- Content: descriptions ≥200 chars, success conditions present and specific, stakeholders section exists, cross-cutting concerns not empty template filler
- Dependencies: all references exist, no circular chains
- Does NOT check: effort, type, ai (these don't exist in strategic specs)

---

## Phase 4: Conversation Flow

### 4.1 Update create-spec skill
**File:** `skills/create-spec/SKILL.md`
**Current:** Guides toward implementation-level detail (effort estimation discussions, AI suitability assessment)
**New:** Guides toward strategic-level completeness. The conversation naturally focuses on what it already does best: problem understanding, stakeholder alignment, capability definition, success conditions. Remove any prompts that push toward implementation detail. Add prompts for:
- Cross-cutting concerns discovery ("what about performance? security? accessibility?")
- Stakeholder perspective gaps ("who else should weigh in on this?")
- Strategic risk identification ("what are we most uncertain about?")

### 4.2 Update creative-decomposition skill
**File:** `skills/creative-decomposition/SKILL.md`
**Current:** Question patterns include some implementation-focused probes
**New:** Question patterns stay at the strategic level. The conversation methodology is already mostly right — it's about understanding depth, not implementation detail. Minor adjustments to ensure it doesn't prompt for effort estimates or technical approach decisions.

### 4.3 Update dependency-analysis skill
**File:** `skills/dependency-analysis/SKILL.md`
**Current:** Covers both functional and implementation dependencies
**New:** Focus on functional dependencies only. "You need notification delivery before notification preferences" is strategic. "The database migration must run before the API endpoint" is technical — that's ido4 MCP's concern.

---

## Phase 5: Infrastructure & Documentation

### 5.1 Update CLAUDE.md downstream contract
**File:** `CLAUDE.md`
**Current:** Documents parser regex, metadata values, quality gates for implementation-ready format
**New:** Documents the strategic spec format as the output contract. Reference `references/strategic-spec-format.md` for the full spec. Update the "Downstream Contract" section to explain that ido4shape produces strategic specs consumed by ido4 MCP's decomposition agent, not by the ingestion parser directly.

### 5.2 Update project templates
**Files:** `references/project-templates/*.md`
**Current:** Templates encode implementation-level patterns (groups with size/risk, task-level effort/type/ai)
**New:** Templates encode strategic-level patterns. Same domain structures (API Service, Mobile App, Platform Feature, Data Pipeline) but with priority, strategic risk, and prose-rich descriptions instead of implementation metadata. Add cross-cutting concerns sections relevant to each domain.

### 5.3 Update hooks (if needed)
**Files:** `hooks/hooks.json`, hook scripts
**Current:** phase-gate.sh validates against implementation-ready format
**New:** phase-gate.sh validates against strategic spec format (or may not need changes if it only checks structural completeness, not metadata values)

### 5.4 Update tests
**File:** `tests/validate-plugin.sh`
**Current:** Validates V1 plugin structure and passes 99 tests
**New:** Update test expectations for changed skill content, metadata references, example artifacts. The test structure stays the same — the assertions change.

---

## Work Order

The phases are roughly sequential but some items within phases are independent:

1. **Pre-work** — Transfer assets to ido4 (do this first, before rewriting)
2. **Phase 1** — Format foundation (all items can be done in parallel)
3. **Phase 2** — Composition pipeline (2.1 and 2.2 are coupled; 2.3 and 2.4 are coupled)
4. **Phase 3** — Quality & validation (3.1 and 3.2 are independent)
5. **Phase 4** — Conversation flow (4.1, 4.2, 4.3 are independent)
6. **Phase 5** — Infrastructure & documentation (all items can be done in parallel)

Phases 2-4 are the core work. Phase 1 sets the foundation. Phase 5 is cleanup.

---

## What This Plan Does NOT Cover

- **ido4 MCP side:** Building the decomposition agent, strategic spec reader, technical spec producer. See `/Users/bogdanionutcoman/dev-projects/ido4/strategic-spec-mcp-plan.md`.
- **V2 (GitHub backend):** The GitHub-as-canvas architecture. Independent of this format change.
- **Canvas redesign:** The single-document canvas architecture. Can proceed in parallel.
