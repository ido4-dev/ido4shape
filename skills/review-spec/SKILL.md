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

## Review Process

This skill launches three independent review sub-agents in parallel. Each reviews from a different lens and produces a focused report.

Check the canvas in the project's `.ido4shape/` directory to verify the Understanding Assessment shows sufficient depth. If any dimension is thin, warn that review may be premature.

If a spec artifact exists (`*-spec.md`), reviewers assess the artifact. If only the canvas exists, they assess canvas readiness for composition.

## Three Reviewers

Launch all three in parallel using the Agent tool:

1. **Technical Feasibility** (`agents/technical-reviewer.md`) — Architecture coherence, strategic risk honesty, cross-cutting concern completeness, hidden dependencies, constraint realism.

2. **Scope Alignment** (`agents/scope-reviewer.md`) — North star alignment, constraint compliance, non-goal violations, coverage gaps, priority coherence.

3. **Dependency Audit** (`agents/dependency-auditor.md`) — Graph integrity, critical path analysis, cross-group dependency health, parallelization opportunities, hidden dependencies.

## Synthesis

After all three report back, synthesize findings into a summary with: verdict (READY / READY WITH NOTES / NOT READY), critical issues, recommendations, and observations.

If READY, suggest proceeding to `/ido4shape:synthesize-spec`. If NOT READY, identify what needs to happen.
