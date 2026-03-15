---
name: artifact-format
description: >
  This skill provides spec artifact format knowledge. It activates automatically whenever
  working with *-spec.md files, .ido4shape/ workspace files, or when the conversation involves
  writing task definitions, group definitions, metadata fields (effort, risk, type, ai,
  depends_on, size), dependency references, success conditions, or structured markdown
  specifications. Also triggers when the user mentions "artifact format", "spec format",
  "heading pattern", "metadata", "prefix", "depends_on", "success conditions", "group prefix",
  "## Group:", "### PREFIX-", or discusses how to format specification output.
user-invocable: false
---

## Format Rules

When producing or reviewing spec artifacts, these patterns must be followed:

**Project heading:** `# Project Name` — exactly one `#`, followed by `>` blockquote description.

**Group heading:** `## Group: Group Name` — must include `Group:` prefix. Followed by `>` metadata line with `size` and `risk`.

**Task heading:** `### PREFIX-NN: Task Title` — prefix is 2-5 uppercase letters, dash, 2-3 digit number. Must match parent group prefix. Followed by `>` metadata lines.

**Metadata blockquotes** appear immediately after headings. Key names are lowercase: `effort`, `risk`, `type`, `ai`, `depends_on`, `size`. Pipe-separated on one or two `>` lines.

**Allowed values:**
- effort: S, M, L, XL (case-insensitive)
- risk: low, medium, high, critical
- type: feature, bug, research, infrastructure
- ai: full, assisted, pair, human
- size: S, M, L, XL
- depends_on: comma-separated PREFIX-NN references, or `-` for no dependencies

**Task body** should be at least 200 characters with substantive content including approach hints, technical context, and integration points.

**Success conditions** appear as a bulleted list under `**Success conditions:**`. Each condition should be specific and independently verifiable.

**Prefix derivation:** Group name initials or meaningful abbreviation. "Notification Core" becomes NCO, "Email Channel" becomes EML. All tasks in a group share the prefix.

**Dependencies:** `depends_on: -` means explicitly none. Omitting `depends_on` means unspecified. All referenced IDs must exist in the document. No circular dependency chains.

For the complete format specification with parser regex patterns, see `${CLAUDE_SKILL_DIR}/references/format-spec.md`.
