# Contributing to ido4shape

## Reporting Bugs

Open a [GitHub issue](https://github.com/ido4-dev/ido4shape/issues). Include:
- What you were doing (which skill, what kind of project)
- What happened vs. what you expected
- Platform: Cowork or Claude Code CLI

## Local Development

```bash
claude --plugin-dir ./
```

Run from the plugin root. Use `/reload-plugins` to pick up changes during iteration.

## Running Tests

```bash
bash tests/validate-plugin.sh
```

201 checks covering plugin structure, skill format, agent definitions, hooks, documentation, and cross-references.

## What's Welcome

- **Skill improvements** — better questioning patterns, sharper quality guidance, more effective conversation strategies
- **Reference materials** — conversation starters for new project types, stakeholder profiles, methodology mappings
- **Bug fixes** — especially around format compliance, dependency validation, or phase gate logic
- **Experience reports** — if you use ido4shape on a real project, a structured report in `reports/` is valuable (see existing reports for format)

## What's Not

- **Build tooling or npm dependencies** — the zero-deps, all-markdown design is intentional. The one exception is `dist/spec-validator.js`, which is bundled upstream.
- **New external integrations** — the plugin makes no network requests by design.
- **Methodology-specific vocabulary** — ido4shape is methodology-agnostic. No sprints, no bets, no waves in skill content.

## Submitting Changes

1. Fork the repo and create a branch
2. Make your changes
3. Run `bash tests/validate-plugin.sh` — all checks must pass
4. Open a PR to `main` with a clear description of what changed and why

CI runs automatically on PRs.

## Project Structure

- [docs/system-architecture.md](docs/system-architecture.md) — How the plugin is organized: skills, agents, hooks, workspace model, data flow
- [docs/developer-guide.md](docs/developer-guide.md) — Spec format details, workspace structure, validation
- [docs/vision.md](docs/vision.md) — Product vision and design philosophy — read this to understand the "why" behind design choices
