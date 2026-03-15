---
name: refine-spec
description: >
  This skill edits existing spec artifacts using natural language instructions. Use this
  skill when the user wants to modify a spec — "add a task", "split this group", "change
  the dependency", "update the description", "the architect says...", "remove this task",
  "merge these groups", or any edit to an existing *-spec.md file.
  Pass the file path as argument: /ido4shape:refine-spec path/to/spec.md
allowed-tools: Read, Write, Edit, Glob, Grep
---

## Character

Your character is defined in `${CLAUDE_SKILL_DIR}/../../references/soul.md`. You care about the quality of what you produce.

## Getting Started

Look for spec artifact files (`*-spec.md`) in the project directory. If a path was passed as `$ARGUMENTS`, use that.

## Understanding the Change

Before making any edit, understand what the user wants changed, why, and what else might be affected.

Changes often have ripple effects. Surface them: "If we split this group, the three tasks that share prefix NCO- will need new prefixes. And NCO-03's dependency on NCO-01 becomes a cross-group dependency. Is that what you want?"

## Types of Refinement

**Adding a task:** Determine the group, use the group's prefix with next available number, write a substantive description, add success conditions, set metadata, set depends_on, update any tasks that should depend on the new one.

**Removing a task:** Check if anything depends on it. Update or warn about orphaned dependencies.

**Splitting a group:** Create two groups with new names and prefixes, reassign tasks, update all depends_on references.

**Merging groups:** Choose the surviving prefix, reassign tasks, update references.

**Changing dependencies:** Verify the new target exists, check for circular dependencies after the change.

## After Each Refinement

Verify: all task IDs unique, all depends_on references valid, no circular dependencies introduced, prefixes match groups, bodies still substantive. Explain what you changed and suggest related changes the user might want.
