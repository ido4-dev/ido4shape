# Security & Data Handling

## What ido4shape Creates

When you start a specification session, the plugin creates a `.ido4shape/` workspace directory in your project folder:

```
.ido4shape/
├── canvas.md          # Working understanding of your project
├── decisions.md       # Decisions made during conversation
├── tensions.md        # Contradictions being tracked
├── stakeholders.md    # Contributors and their perspectives
├── sessions/          # Session summaries
└── sources/           # Materials you've provided
```

All files are plain text markdown. No binary formats, no databases, no encrypted storage.

## Data Locality

**All data stays on your local machine.** The plugin makes no network requests, connects to no external services, and sends no telemetry. The only data that leaves your machine is what Claude processes through the standard Anthropic API — the same as any Claude conversation.

## Hooks

The plugin runs shell scripts at specific lifecycle points. Here's what each does:

| Hook | When | What it does |
|------|------|-------------|
| **session-start.sh** | Session begins | Creates `.ido4shape/` workspace if it doesn't exist |
| **spec-validator.js copy** | Session begins | Copies the bundled validator to plugin data directory |
| **phase-gate.sh** | Before writing files | Checks if canvas understanding is sufficient before writing spec artifacts |
| **canvas-context.sh** | Every user message | Reads the canvas Understanding Assessment and injects it into context |
| **PreCompact prompt** | Before context compaction | Reminds the agent to save insights to canvas before context is trimmed |
| **Stop prompt** | Session ends | Reminds the agent to update canvas and write a session summary |

No hook accesses the network, modifies files outside `.ido4shape/` and the spec artifact, or runs destructive operations.

## Bundled Validator

The plugin includes `dist/spec-validator.js` (~8KB), a deterministic markdown parser that validates spec format compliance. It:

- Runs via Node.js, reads a single file, outputs JSON to stdout
- Makes no network requests
- Has zero npm dependencies
- Source code: [github.com/ido4-dev/ido4](https://github.com/ido4-dev/ido4/tree/main/packages/spec-format)
- SHA-256 checksum in `dist/.spec-format-checksum`

## Sub-Agents

Some skills spawn sub-agents for parallel work:

| Skill | Sub-agents | Tools | Model |
|-------|-----------|-------|-------|
| **synthesize-spec** | canvas-synthesizer | Read, Write, Glob | Opus |
| **review-spec** | technical-reviewer, scope-reviewer, dependency-auditor | Read, Glob, Grep | Sonnet |
| **review-spec** (on artifacts) | + spec-reviewer | Read, Glob, Grep | Sonnet |

Sub-agents read workspace files and spec artifacts. The canvas-synthesizer writes the spec artifact. No sub-agent has Bash access or can execute arbitrary commands.

## Cleanup

To remove all ido4shape data from a project:

```bash
rm -rf .ido4shape/
```

There is no other persistence. The plugin does not write to global directories, registries, or configuration files beyond the session-scoped plugin data directory.

## Recommendations

- Add `.ido4shape/` to your `.gitignore` unless you want to commit workspace state
- Be mindful of sensitive information in conversations — workspace content is processed through the Claude API under [Anthropic's data policies](https://www.anthropic.com/policies)
- The spec artifact (`*-spec.md`) is designed to be shared; the workspace (`.ido4shape/`) is working state
