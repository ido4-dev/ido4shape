# Changelog

## [0.4.0] — 2026-04-03

Marketplace submission preparation. ido4shape is now positioned as an independent specification discovery tool, not just a pipeline component.

### Changed
- **Standalone positioning** — README, descriptions, and skill language now frame ido4shape as independently valuable. The ido4 MCP pipeline is presented as an optional next step, not the primary use case.
- **README rewritten for first-time users** — Quick Start guide, glossary, role-specific skill commands, material preparation guidance.
- **SEO optimization** — plugin description front-loads searchable terms (specification, PRD, product-requirements). Keywords updated. Category set to `productivity`.
- **spec-reviewer integrated into review-spec** — now runs as a 4th parallel reviewer (format + quality) when reviewing existing spec artifacts. Previously defined but not invoked by any workflow.
- **Skill inventory auto-generator** updated for two-table format (Commands + Supporting skills).

### Added
- `SECURITY.md` — data handling, hooks, privacy, sub-agent architecture, cleanup guidance.
- Validator checksum (`dist/.spec-format-checksum`) for bundle integrity verification.
- GitHub repository topics for discoverability.

### Fixed
- Repository URL corrected from `b-coman/ido4shape` to `ido4-dev/ido4shape`.
- Marketplace sync now excludes `tests/` and `ido4-simulate*` files.
- Workflow permissions for README skill inventory auto-update.

## [0.3.4] — 2026-04-02

Follow-up fixes from the second end-to-end test (OpenClaw outreach project).

### Fixed
- **Convergence check** — agent now assesses readiness after 8-10 substantive exchanges and proactively proposes transitioning to composition, instead of probing indefinitely.
- **Stronger propose mode** — when the user signals uncertainty, the agent leads with one recommendation instead of presenting a menu of options.
- **Prefix length rule** — canvas-synthesizer now enforces the 2-5 character prefix constraint with explicit examples (BRIDGE becomes BRDG).

## [0.3.3] — 2026-04-02

Five high-severity observation fixes from the first real-world test. These addressed the most impactful behavioral issues discovered during the ido4-simulate specification session.

### Fixed
- **OBS-01: Workspace discipline** — decisions and tensions are now written to workspace files immediately during conversation, not batched at session end. Session wrap-up reframed as verification, not the primary write pass.
- **OBS-05: Turn discipline and propose mode** — one focused question per turn, propose solutions when the user signals uncertainty. Eliminates multi-question dumps and excessive preamble.
- **OBS-06: Format compliance on first synthesis** — canvas-synthesizer now uses a format skeleton with pre-write checklist. Moved from 0% first-pass compliance to near-clean output.
- **OBS-08: Source material preservation** — synthesize-spec now performs source reconciliation before invoking the synthesizer. Items from source documents that weren't contradicted in conversation are flagged and carried forward.
- **OBS-11: Review gate before synthesis** — create-spec now actively recommends review-spec before composition for specs with 4+ groups. synthesize-spec checks whether review has been run.

## [0.3.2] — 2026-03-29

### Fixed
- Added Bash and Agent to allowed tool permissions for Cowork compatibility.

## [0.3.1] — 2026-03-29

### Changed
- **Bundled spec-format validator** — replaced npm install approach with a single self-contained JS file (~8KB, zero npm dependencies). SessionStart hook copies the bundle; validate-spec runs it via node.
- Automated marketplace sync: release script pushes to GitHub, CI syncs to ido4-plugins marketplace and creates a GitHub release.

## [0.3.0] — 2026-03-27

### Added
- **Deterministic spec validation** — integrated @ido4/spec-format parser for structural validation. validate-spec now runs a two-pass process: deterministic parser (format compliance) + LLM judgment (content quality).

## [0.2.1] — 2026-03-19

### Added
- CI workflow — runs 125+ structural validation tests on push and PR.
- Marketplace auto-sync workflow — version bump triggers automatic sync to ido4-plugins.
- Skill inventory auto-generation in README.
- GitHub Releases created automatically on version bump.

## [0.2.0] — 2026-03-19

The architectural pivot. ido4shape stops producing implementation-ready specs and starts producing strategic specs.

### Changed
- **Two-artifact architecture** — ido4shape now produces strategic specs (the WHAT from multi-stakeholder conversation). Implementation-level metadata (effort, type, AI suitability) removed — these require codebase knowledge and are determined by ido4 MCP during technical decomposition.
- **Strategic spec format** designed: `format: strategic-spec | version: 1.0`. Rich prose descriptions, stakeholder attribution, cross-cutting concerns as prose, functional dependencies. No methodology-specific fields.
- All skills, agents, and references adapted for strategic spec output.

## [0.1.1] — 2026-03-15

### Changed
- Restored canvas management depth with V4 multi-stakeholder features, merged with V1 instruction richness in markdown format (no XML tags).

## [0.1.0] — 2026-03-15

### Changed
- Reset to semver pre-release versioning. Added release script.

## [0.0.1] — 2026-03-14

Initial release. Complete plugin with 10 skills, 5 sub-agents, hooks, and references.

### The Cowork compatibility arc (0.0.1 → 0.1.0)
Multiple iterations to make the plugin work reliably in Cowork's sandbox environment:
- Replaced XML tags with markdown headers (Cowork injection defense flagged XML)
- Replaced directive language with guidance framing
- Replaced prompt hooks with deterministic command hooks
- Slimmed skill bodies to reduce injection defense surface area
- Added VM environment detection for workspace path resolution
- Documented working folder requirement (Cowork blocks execution without a mounted folder)
