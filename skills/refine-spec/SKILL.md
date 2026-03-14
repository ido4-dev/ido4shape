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

<refinement-protocol>

Read the spec artifact file passed as `$ARGUMENTS`. If no argument, look for `*-spec.md` files in the current directory.

Read `${CLAUDE_SKILL_DIR}/../../references/soul.md` — maintain character. You care about the quality of what you produce.

## Understanding the Change

Before making any edit, understand:
1. What the user wants changed (the request)
2. Why they want it changed (the motivation — if not stated, ask)
3. What else might be affected (ripple effects)

Changes often have implications the user hasn't considered. Surface them: "If we split this group, the three tasks that currently share prefix NCO- will need new prefixes. And NCO-03's dependency on NCO-01 becomes a cross-group dependency. Is that what you want?"

## Types of Refinement

**Adding a task:**
- Determine which group it belongs to
- Use the group's prefix with the next available number
- Write a substantive description (>= 200 chars)
- Add success conditions
- Set metadata (effort, risk, type, ai)
- Set depends_on (check what it needs, and what might need it)
- Update any existing tasks that should depend on the new one

**Removing a task:**
- Check if any other tasks depend on it (depends_on references)
- If so, either update those tasks' dependencies or warn the user
- Remove the task cleanly

**Splitting a group:**
- Create two new groups with appropriate names and prefixes
- Reassign tasks to the correct group, updating prefixes
- Update all depends_on references to use new task IDs
- Update any cross-references in task descriptions

**Merging groups:**
- Choose the surviving group name and prefix
- Reassign tasks, updating prefixes
- Update all depends_on references
- Merge group descriptions

**Changing dependencies:**
- Verify the new dependency target exists
- Check for circular dependencies after the change
- Update task descriptions if they reference upstream tasks by ID

**Updating metadata:**
- Verify new values are from allowed sets
- Consider whether the change affects related assessments (e.g., increasing risk might affect dependent tasks)

## Delta Tracking

After each refinement, mentally verify:
- All task IDs are still unique
- All depends_on references still point to existing tasks
- No circular dependencies were introduced
- Prefixes still match their groups
- Task bodies are still >= 200 characters
- The change is consistent with the project's constraints and non-goals

## Conversation Style

Refinement is collaborative. Don't just execute the edit silently — explain what you changed and why, flag any ripple effects, and suggest related changes the user might want to make: "I've added the caching task. Since the routing engine (NCO-03) currently calls preferences directly, you might want to update NCO-03's description to mention the cache layer. Want me to do that?"

</refinement-protocol>
