---
name: artifact-format
description: >
  This skill provides strategic spec artifact format knowledge. It activates automatically whenever
  working with *-spec.md files, .ido4shape/ workspace files, or when the conversation involves
  writing capability definitions, group definitions, metadata fields (priority, risk, depends_on),
  dependency references, success conditions, or structured markdown specifications. Also triggers
  when the user mentions "artifact format", "spec format", "strategic spec", "heading pattern",
  "metadata", "prefix", "depends_on", "success conditions", "group prefix", "## Group:",
  "### PREFIX-", or discusses how to format specification output.
user-invocable: false
---

## Strategic Spec Format

ido4shape produces strategic specs — the WHAT from multi-stakeholder conversation. The downstream consumer is an AI decomposition agent in ido4 MCP, not a line-by-line parser.

**Project heading:** `# Project Name` — exactly one `#`, followed by `> format: strategic-spec | version: 1.0` in a blockquote. Rich problem description follows — who suffers, how, why solving it now.

**Stakeholders section:** List contributors with role and key perspective. Tells the decomposition agent who shaped each part of the understanding.

**Cross-Cutting Concerns section:** `## Cross-Cutting Concerns` with subsections for Performance, Security, Accessibility, Observability, or whatever the conversations covered. These are prose — rich enough for a technical agent to factor into every implementation task.

**Group heading:** `## Group: Group Name` — must include `Group:` prefix. Followed by `>` metadata with `priority`.

**Capability heading:** `### PREFIX-NN: Capability Title` — prefix is 2-5 uppercase letters, dash, 2-3 digit number. Must match parent group prefix. Followed by `>` metadata lines.

**Metadata blockquotes** appear immediately after headings. Key names are lowercase. Pipe-separated.

**Allowed values:**
- priority: must-have, should-have, nice-to-have (on both groups and capabilities)
- risk: low, medium, high (strategic risk — unknowns, external dependencies, stakeholder disagreement. NOT code complexity.)
- depends_on: comma-separated PREFIX-NN references, or `-` for no dependencies

**Not in strategic specs:** effort, type, ai, size. These require codebase knowledge and are determined by ido4 MCP during technical decomposition.

**Capability body** should be at least 200 characters with substantive content including: what the capability provides, who needs it and why, stakeholder context ("Per Marcus: ..."), relevant constraints, and integration points with other capabilities.

**Success conditions** appear as a bulleted list under `**Success conditions:**`. Each condition should be specific and independently verifiable at the product level.

**Prefix derivation:** Group name initials or meaningful abbreviation. "Notification Core" becomes NCO, "Email Channel" becomes EML. All capabilities in a group share the prefix.

**Dependencies:** `depends_on: -` means explicitly none. Omitting means unspecified. All referenced IDs must exist in the document. No circular dependency chains. These are functional dependencies, not code-level.

For the complete format specification, see `${CLAUDE_SKILL_DIR}/references/format-spec.md`.
