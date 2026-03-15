---
name: review-spec
description: >
  This skill launches parallel independent reviewers to assess the canvas or spec artifact
  before composition. Use this skill when the user says "review the spec", "run reviewers",
  "check before we compose", "is this ready?", "launch review", or when the create-spec
  session determines that knowledge gathering is complete and wants independent validation
  before synthesis.
allowed-tools: Read, Glob, Grep, Agent
---

<review-protocol>

This skill launches three independent review sub-agents in parallel. Each reviews from a different lens and produces a focused report. The reviews are independent — no reviewer sees another's output.

## Pre-Flight

Read `.ido4shape/canvas.md` to verify the Understanding Assessment shows sufficient depth. If any dimension is "thin" or "not started", warn the user that review may be premature.

If a spec artifact exists (`*-spec.md`), reviewers assess the artifact. If only the canvas exists, reviewers assess canvas readiness for composition.

## Launch Three Reviewers

Launch all three in parallel using the Agent tool:

**1. Technical Feasibility Reviewer** (`agents/technical-reviewer.md`)
- Does the architecture cohere?
- Are effort/risk estimates honest given the technical approach?
- Are there hidden technical dependencies not captured?
- Do throughput/scale claims match the proposed architecture?
- Are technology choices appropriate for the constraints?

**2. Scope Alignment Reviewer** (`agents/scope-reviewer.md`)
- Does every group/task trace to the project's north star?
- Are constraints and non-goals respected throughout?
- Is there scope creep — tasks that don't belong?
- Are there gaps — work needed that no task covers?
- Does the scope match the implied timeline/effort?

**3. Dependency Auditor** (`agents/dependency-auditor.md`)
- Is the dependency graph acyclic?
- Does the critical path make sense?
- Are cross-group dependencies minimized?
- Are there hidden dependencies not captured in `depends_on`?
- Could any group be delivered independently?

## Synthesis

After all three reviewers report back, synthesize their findings:

```markdown
# Review Summary

## Verdict: [READY | READY WITH NOTES | NOT READY]

## Critical Issues (must address before composition)
[Issues from any reviewer that would produce a bad spec]

## Recommendations (should address)
[Improvements that would strengthen the spec]

## Observations (worth noting)
[Patterns, risks, or insights the reviewers noticed]

## Reviewer Reports
[Include each reviewer's full report below]
```

If the verdict is READY or READY WITH NOTES, suggest proceeding to `/ido4shape:synthesize-spec`. If NOT READY, identify what needs to happen — more conversation, a missing stakeholder perspective, or tension resolution.

</review-protocol>
