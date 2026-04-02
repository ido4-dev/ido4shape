---
name: refine-spec
description: >
  This skill edits existing spec artifacts using natural language instructions. Use this
  skill when the user wants to modify a spec — "add a capability", "split this group", "change
  the dependency", "update the description", "the architect says...", "remove this capability",
  "merge these groups", or any edit to an existing *-spec.md file.
  Pass the file path as argument: /ido4shape:refine-spec path/to/spec.md
allowed-tools: Read, Write, Edit, Glob, Grep
---

## Character

Your character is defined in `${CLAUDE_SKILL_DIR}/../../references/soul.md`. You care about the quality of what you produce.

## Getting Started

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

Determine whether this is a strategic spec (`format: strategic-spec` in project metadata) or a technical spec (has effort/type/ai fields). Apply the appropriate format rules.

## Understanding the Change

Before making any edit, understand what the user wants changed, why, and what else might be affected.

Changes often have ripple effects. Surface them: "If we split this group, the three capabilities that share prefix NCO- will need new prefixes. And NCO-03's dependency on NCO-01 becomes a cross-group dependency. Is that what you want?"

## Types of Refinement

**Adding a capability:** Determine the group, use the group's prefix with next available number, write a substantive description (≥200 chars with stakeholder context), add success conditions, set priority and strategic risk, set depends_on, update any capabilities that should depend on the new one.

**Removing a capability:** Check if anything depends on it. Update or warn about orphaned dependencies.

**Splitting a group:** Create two groups with new names and prefixes, reassign capabilities, update all depends_on references. Each new group needs a priority.

**Merging groups:** Choose the surviving prefix, reassign capabilities, update references.

**Changing dependencies:** Verify the new target exists, check for circular dependencies after the change.

**Adding stakeholder context:** When the user says "the architect says..." or brings new stakeholder input, integrate it into relevant capability descriptions, cross-cutting concerns, or constraints. Attribute naturally: "Per the architect: ..."

**Adding cross-cutting concerns:** New NFRs, security requirements, or performance targets go in the Cross-Cutting Concerns section, not on individual capabilities (unless specific to one capability).

## After Each Refinement

Verify: all capability IDs unique, all depends_on references valid, no circular dependencies introduced, prefixes match groups, bodies still substantive, stakeholder attribution preserved.

**Format checks:** Capability IDs must use zero-padded 2-digit numbers (`PREFIX-01`, not `PREFIX-1`). Group headings must use `## Group: ` prefix. All metadata must use blockquote syntax (`> priority: ...`). Only `## Group:` and `## Cross-Cutting Concerns` are allowed as H2 sections.

When fixing format compliance issues, identify the pattern (e.g., all IDs missing zero-padding) and fix ALL instances in one pass. Don't fix one at a time — that's expensive and risks content drift.

Explain what you changed and suggest related changes the user might want.
