---
name: validate-spec
description: >
  This skill validates a spec artifact for format compliance and content quality. Use this
  skill when the user says "validate the spec", "check the spec", "review the artifact",
  "is this spec valid?", "will this pass ido4?", or wants to verify a spec file before
  ingestion. Pass the file path as argument: /ido4shape:validate-spec path/to/spec.md
allowed-tools: Read, Glob, Grep
---

<validation-protocol>

Read the spec artifact file passed as `$ARGUMENTS`. If no argument, look for `*-spec.md` files in the current directory.

## Format Validation (Pass 1)

Check each structural element against ido4's parser expectations:

**Project header:**
- [ ] Exactly one `#` heading (project name)
- [ ] `>` blockquote description immediately after
- [ ] `**Constraints:**` section with bullet items
- [ ] `**Non-goals:**` section with bullet items
- [ ] `**Open questions:**` section (optional but recommended)

**Groups:**
- [ ] Each group uses `## Group: Name` format (not `## Name`)
- [ ] `>` metadata line with `size` and `risk` immediately after heading
- [ ] Size value is S, M, L, or XL
- [ ] Risk value is low, medium, high, or critical
- [ ] Group has a description body

**Tasks:**
- [ ] Each task uses `### PREFIX-NN: Title` format
- [ ] PREFIX is 2-5 uppercase letters: `/[A-Z]{2,5}/`
- [ ] NN is 2-3 digits: `/\d{2,3}/`
- [ ] PREFIX matches parent group's derived prefix
- [ ] `>` metadata lines immediately after heading
- [ ] Metadata keys are exactly: effort, risk, type, ai, depends_on
- [ ] effort value: S, M, L, or XL
- [ ] risk value: low, medium, high, or critical
- [ ] type value: feature, bug, research, or infrastructure
- [ ] ai value: full, assisted, pair, or human
- [ ] depends_on: valid comma-separated PREFIX-NN references, or `-`

**Dependencies:**
- [ ] All depends_on references point to task IDs that exist in the document
- [ ] No circular dependency chains
- [ ] `depends_on: -` used (not omitted) when task has no dependencies

## Content Quality (Pass 2)

**Task descriptions:**
- [ ] Each task body >= 200 characters
- [ ] Description includes substantive content (not just restating the title)
- [ ] Approach hints or technical context present
- [ ] Integration points referenced where relevant

**Success conditions:**
- [ ] `**Success conditions:**` section present for every task
- [ ] Each condition is a bullet item
- [ ] Each condition is specific and independently verifiable
- [ ] No vague conditions ("works correctly", "performs well")

**Effort/Risk calibration:**
- [ ] No task with external integration marked as low risk
- [ ] No XL-effort task marked as low risk (large scope usually means unknowns)
- [ ] Research-type tasks have appropriate risk (usually medium+)

**Group coherence:**
- [ ] Each group has 3-8 tasks (1-2 is suspicious, 10+ should probably be split)
- [ ] Tasks within a group are related to the group's purpose
- [ ] Group description explains why tasks belong together

## Report Format

```
## Validation Report: [filename]

### Format Compliance
- Errors: [count] (must fix before ingestion)
- Warnings: [count] (should fix)

[List each error/warning with line reference and explanation]

### Content Quality
- Task description quality: [assessment]
- Success condition quality: [assessment]
- Effort/risk calibration: [assessment]
- Group coherence: [assessment]

[Specific issues with suggestions]

### Dependency Graph
- Total tasks: [N]
- Root tasks (no dependencies): [N]
- Critical path: [task chain]
- Cross-group dependencies: [count]
- Circular dependencies: [none | list]

### Verdict
[PASS — ready for ido4 ingestion | PASS WITH WARNINGS | FAIL — issues listed above]
```

If ido4 MCP is available, suggest running `ingest_spec` with `dryRun=true` for full governance validation.

</validation-protocol>
