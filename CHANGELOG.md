# Changelog

## [0.4.13] — 2026-04-11

Add local/remote sync pre-flight check with detailed remediation messages

### Added
- Pre-flight validation for sync configuration with detailed remediation guidance
- Automated changelog generation from commits with Claude API and deterministic fallback
- System architecture documentation and contributor guidelines

### Changed
- Validation test suite expanded from 130 to 199 checks with improved diagnostics
- Documentation reorganized into public (docs/) and internal (private/) structures
- Spec-validator bundle updated to v0.7.1 with enhanced validation messages

### Fixed
- Release workflow now validates Claude CLI authentication before marketplace operations
- Marketplace manifest syncing corrected for description and category fields

## [0.4.12] — 2026-04-11

Strengthen release gates: pre-flight validation, CI-gated marketplace sync, shell script quality checks

### Added
- Automated changelog generation from commit history during releases
- Pre-flight validation gates (203 checks) prevent broken specs from reaching marketplace
- CONTRIBUTING.md with developer setup guidance and workflow documentation

### Changed
- Updated spec-validator to v0.7.1 with stricter description and format validation
- Reorganized documentation into public docs/ and internal planning/ sections
- Release process now gates marketplace sync behind validation checks and CI workflows
- CLAUDE.md refactored to 95 lines following Anthropic best practices

### Fixed
- Marketplace metadata automatically synced with plugin manifest on each release
- Release script now verifies Claude CLI authentication before proceeding
- CI workflow permissions fixed for validator updates and cross-repo synchronization
- Validation checks clarified (description presence, numbered lists, field requirements)

## [0.4.11] — 2026-04-11

Fix Stop hook loop in empty-folder exploration sessions

### Added
- Automatic CHANGELOG generation from git commits on release
- Expanded validation test suite (130 → 199 checks)

### Changed
- Updated spec-validator to v0.7.1 with improved description formatting
- Documentation reorganized: public content in docs/, internal planning in private/
- Developer guide simplified (CLAUDE.md: 291 → 95 lines)

### Fixed
- Stop hook loop in empty-folder exploration sessions
- Validation checks for description and openQuestions field presence
- Cowork installation instructions updated to match current UI
- Release script verifies Claude CLI authentication before running
- Marketplace manifest syncs properly on release

## [0.4.10] — 2026-04-09

fix: close NEW-06 and NEW-14 — role-transition onboarding and stakeholder-brief next steps

### Fixed
- Role-transition onboarding (NEW-06) and stakeholder-brief next steps (NEW-14).
- Spec validation: description presence checks corrected and openQuestions validation added.
- Release automation: OAuth-compatible authentication for changelog generation.

### Changed
- Developer documentation: CLAUDE.md streamlined to 95 lines following Anthropic best practices.
- Validation suite: expanded from 130 to 199 checks for stricter quality gates.
- Marketplace integration: plugin description and category now auto-synced to manifest on release.

### Added
- Automated CHANGELOG generation from commits during release with LLM support.
- Cross-repo sync pipeline and system architecture documentation.
- E2E test #3 report: enterprise cloud platform spec validation.
- CONTRIBUTING.md guide.

## [0.4.9] — 2026-04-06

Phase 3: parser trust boundary fix — description check restored to FAIL

### Added
- Automatic CHANGELOG generation from git commits on release

### Changed
- Validation test suite expanded from 130 to 199 checks
- Bundled spec validator updated with support for plain-text descriptions and numbered lists
- Documentation reorganized with public docs/ directory and contributor guide
- Release automation now includes LLM-powered changelog generation with OAuth-compatible authentication

### Fixed
- Description presence check now enforces as hard FAIL—parser trust boundary restored (Phase 3)
- Description and openQuestions validation severity levels restored
- Cowork installation instructions corrected to match actual UI flow
- Marketplace manifest now auto-syncs with plugin version, description, and category on release

## [0.4.8] — 2026-04-06

Format/content split: auto-fix format silently, present only content findings to user

### Added
- LLM-powered changelog generation with deterministic fallback, synced to marketplace on release
- CONTRIBUTING.md guide and expanded public documentation directory
- Enterprise cloud platform end-to-end test report with 9 observations and fixes
- System architecture reference documentation

### Changed
- **Validation now auto-fixes format issues silently** — structural problems are corrected in the background, only content findings are presented to the user
- Expanded validation suite from 130 to 199 checks covering format completeness and content quality
- Marketplace sync now includes description and category updates, not just version
- Documentation reorganized with `/docs` for public-facing guides and `/private` for internal planning
- Release process now auto-generates CHANGELOG entries from commits instead of manual creation

### Fixed
- Downgrade description presence check from FAIL to WARNING to reduce false positives
- Clarified description and openQuestions presence checks in synthesizer template
- Cowork installation instructions to match actual UI flow
- OAuth-compatible authentication for LLM changelog generation
- Release script now warns if claude CLI is not authenticated

## [0.4.7] — 2026-04-06

Capability-level completeness check + user-facing report restructure

### Added
- Capability-level completeness validation with 199 structured checks
- LLM-powered CHANGELOG generation with deterministic fallback for offline release workflows
- End-to-end test report documenting enterprise cloud platform specification

### Changed
- Documentation restructured into public (`docs/`) and internal (`private/`) sections
- README refocused on value proposition and intermediate artifacts
- Description validation downgraded to WARNING (reduces false positives)

### Fixed
- Completeness checks for capability descriptions and open questions in specs
- Marketplace sync now updates both description and category
- Cowork installation instructions and getting-started guide
- Canvas synthesizer template for clearer capability structure
- Release script now warns if Claude CLI authentication is missing

## [0.4.6] — 2026-04-06

Assertion-based Pass 2 — authoritative content quality gate

### Added
- Automated CHANGELOG generation from git commits on release (LLM-powered with deterministic fallback)

### Changed
- Reorganized documentation: public docs in `docs/`, internal planning in `private/`
- Expanded validation suite from 130 to 199 structural checks
- README restructured to address both product builders and developers

### Fixed
- Downgraded description and openQuestions checks from FAIL to WARNING to reduce false positives
- Corrected Cowork installation and getting started steps in documentation
- Fixed marketplace metadata syncing (description and category) on release
- Fixed OAuth compatibility in LLM changelog generation
- Release script now warns if Claude CLI isn't logged in

## [0.4.5] — 2026-04-05

Downgrade description check to WARNING — remove false positive on parser/docs mismatch

### Added
- CONTRIBUTING.md with contribution guidelines
- System architecture documentation
- LLM-powered changelog generation with deterministic fallback
- E2E test #3 report for enterprise cloud platform use case

### Changed
- Description validation check downgraded from FAIL to WARNING to eliminate false positives
- Documentation reorganized into public `docs/` and internal `private/` directories
- README refocused on value delivered to both PMs and tech leads
- Marketplace auto-sync now updates description and category alongside version
- Test suite expanded from 130 to 199 validation checks

### Fixed
- Clarity on description and openQuestions presence checks
- Validate-spec completeness checking logic
- Cowork installation and getting started instructions
- Format documentation accuracy and naming consistency

## [0.4.4] — 2026-04-05

Presence checks for description and open questions, template placeholder fix

### Added
- Contribution guidelines (CONTRIBUTING.md) with development workflow and testing expectations
- E2E test #3 report documenting enterprise cloud platform specification validation
- New documentation structure (docs/ for public docs, private/ for internal planning)
- System architecture documentation with technical design details
- Auto-generated changelog entries from commit messages with LLM assistance and deterministic fallback

### Changed
- Synthesizer template now clarifies placeholder usage in canvas context
- README reorganized to address both PM/founder and engineer audiences with intermediate artifacts as value
- Documentation site structure unified with example specification linked in "What You Get" section
- CLAUDE.md expanded with complete file inventory, skill definitions, and marketplace submission guidance

### Fixed
- Presence validation checks for description and openQuestions fields in strategic specs
- Completeness checks in validate-spec skill with improved format documentation
- Cowork installation and getting started instructions to match current UI
- Release script OAuth authentication for LLM changelog generation
- Release script now warns if claude CLI is not authenticated before running
- Marketplace manifest now syncs description and category on release
- Validation test suite expanded from 130 to 199 checks covering edge cases and format compliance

## [0.4.3] — 2026-04-05

Validation completeness checks and format documentation fixes

### Added
- Full system architecture documentation covering plugin structure, skill design, and validator bundling
- E2E test #3 report documenting enterprise cloud platform specification and validation results
- Automated CHANGELOG generation from commit history with LLM-powered summarization and deterministic fallback
- CONTRIBUTING.md guide for contributors and developers
- 69 new validation completeness checks (test suite expanded from 130 to 199 checks)
- Marketplace manifest auto-sync for plugin description and category on release

### Changed
- Reorganized documentation: public docs in docs/ directory, internal planning in private/ (gitignored)
- README rewritten to serve two audiences (PMs/founders vs. tech leads) and highlight intermediate artifacts as value
- Updated Cowork getting started instructions to match actual UI flow
- Enhanced release script with OAuth-compatible auth and CLI login verification warnings
- Improved LLM changelog generation with graceful fallback to conventional commit parsing

### Fixed
- Validation completeness checks in validate-spec skill for stricter artifact validation
- Format documentation corrections in artifact-format references
- Cowork installation alignment with actual marketplace UI behavior
- Code fence stripping in auto-generated changelog entries

## [0.4.2] — 2026-04-03

Infrastructure: test suite expansion, automated changelog, marketplace sync

### Added
- Auto-generate CHANGELOG entries from commits on release

### Changed
- Expanded validation test suite from 130 to 199 checks
- Release script now syncs plugin metadata to marketplace

### Fixed
- OAuth-compatible auth for LLM changelog generation and code fence cleanup
- Warn when Claude CLI is not logged in at release start
- Deterministic fallback when LLM is unavailable

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
