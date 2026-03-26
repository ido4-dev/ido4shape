# First Real-World Test: ido4shape Full Pipeline

**Date:** 2026-03-23 to 2026-03-24
**Tester:** Bogdan Coman (creator of ido4shape)
**Project under test:** ido4-simulate — a synthetic testing framework for ido4shape
**Environment:** Cowork (Anthropic's desktop agent runtime)
**ido4shape version:** 0.2.1

---

## Context

ido4shape had been built over several weeks — 30+ files, 10 skills, 5 sub-agents, hooks, references, 125 validation tests, all passing. The strategic spec format had been designed and adapted. But nobody had ever used it on a real project in a real Cowork session.

The project chosen for the first test was ido4-simulate — a synthetic testing framework for ido4shape itself. This was deliberate: Bogdan had deep knowledge of the problem space (having spent hours discussing the architecture and design), and the project was genuinely needed. It wasn't a toy example.

A detailed plan document (1,200+ lines, 14 sections) existed before the ido4shape session began, covering architecture, cost modeling, research design, ablation studies, infrastructure, and phasing. This made the test both easier (rich source material) and harder (the agent had to add value beyond what was already written).

---

## What Happened

### Pre-Session: Plan Development (Claude Code, not Cowork)

Before using ido4shape, Bogdan worked with Claude Code to develop the ido4-simulate plan through extended conversation. This covered:
- Research into OpenClaw, Claude Code Channels, and the Claude Agent SDK as simulation approaches
- Architecture design (three layers: scenario design, simulation execution, evaluation)
- Persona design with hidden constraints and behavioral triggers
- Four evaluation dimensions (methodology compliance, information traceability, spec quality, persona realism)
- Cost modeling with actual Anthropic API pricing
- Six-level cost control hierarchy
- Research data design for potential academic publication
- Ablation and baseline support with model-as-variable testing

The plan was comprehensive — arguably over-specified for a strategic spec conversation. This created an unusual test condition: ido4shape received more detailed source material than a typical session would.

### Session 1: Discovery Conversation

**Skill used:** `/ido4shape:create-spec`

Bogdan started the Cowork session and asked ido4shape to create a specification for the ido4-simulate project, providing the plan document as source material.

**What went right:**
- The agent read the plan and engaged with the content
- It began probing the thin dimensions (quality bar, risk landscape)
- It made good decisions: testing-over-research priority, downstream-agent-usability as the quality frame, automation-first feedback loop
- 5 decisions were captured by session end

**What went wrong:**
- Bogdan asked the agent to translate the plan into the canvas. This was a user error, but the agent complied without pushing back. The canvas became a 1,200-line reorganization of the plan rather than a conversation-driven discovery document (OBS-02).
- The agent was slow to transition from organizing to probing — several turns spent on completeness-checking before the first real question (OBS-03).
- Decisions were not written to `decisions.md` during the conversation, only at session wrap-up (OBS-01).
- The agent was too chatty — multiple questions per turn, excessive context before getting to the point, didn't propose solutions when Bogdan signaled uncertainty (OBS-05).

**Session wrap-up:** The agent wrote a session summary, updated the canvas, and batch-wrote 5 decisions to `decisions.md`. The wrap-up itself was well-structured — clear status (5 decisions, 5 open questions, thinnest dimensions identified).

### Session 2: Deepening + Synthesis

**Skills used:** `/ido4shape:create-spec` (continued), then `/ido4shape:synthesize-spec`

The conversation deepened into evaluation design. The agent made genuinely valuable contributions:
- Reframing spec quality as failure modes (what goes wrong when ido4dev consumes the spec) rather than quality categories
- Identifying that methodology evaluation catches process failures that good specs can mask
- Folding phase-gate resistance into character integrity, tested via pressure personas
- Proposing the dependency chain: simulate → evaluate → trust → regress → research

When the canvas was mature enough, the agent moved to synthesis.

**Synthesis — what happened:**

1. The agent read the canvas and added "five review gaps" (its own self-assessment, not the review-spec skill)
2. It updated cross-cutting concerns in the canvas
3. It launched the canvas-synthesizer sub-agent (Opus)
4. The synthesizer produced a spec: 4 groups + 1 validation group, 15 capabilities
5. The agent ran validate-spec — **FAIL on format**

**Format failures (OBS-06):**
- Group headings used `### Group SIM:` instead of `## Group:`
- Metadata was inline bold text instead of blockquotes
- The agent spent 6+ editing rounds fixing these issues (OBS-07)
- During the fix process, the capability count changed from 15 to 17

**Content loss (OBS-08):**
When Bogdan compared the spec against the plan, ~30% of substantive content was missing:
- Hidden constraints and behavioral triggers in persona design
- Composable trait library (8 types)
- Three-layer data architecture (JSONL, derived, SQLite)
- Six-level cost control hierarchy
- Information traceability evaluator
- Canvas diff tracking
- Batch API optimization
- Non-determinism strategy (pass@k, pass^k)

The agent diagnosed the loss honestly — three causes:
1. The synthesizer worked from the canvas, not the plan (source materials aren't in the synthesizer's prescribed reading list)
2. Conversation operated at higher abstraction than the plan's specific mechanisms
3. The synthesizer has a fresh context window and doesn't know what was implicitly endorsed

A fourth cause (identified externally): some lost elements were arguably implementation detail, not strategic spec content. But others (hidden constraints, trait library, traceability) were core design concepts that were genuinely lost.

**Reconciliation pass:** When prompted, the agent went back to the plan and recovered all lost content in a v2 spec. The reconciliation worked — but it required Bogdan to notice the loss and ask for it.

**Skipped review (OBS-11):** The create-spec skill prescribes suggesting `/ido4shape:review-spec` before synthesis. The agent skipped it entirely — went straight from conversation to synthesis. The dependency auditor (one of the three review sub-agents) would likely have caught the dependency logic errors that made it into the spec.

### Post-Synthesis: Validate → Refine → Review → Validate

**Skill sequence:** `/ido4shape:refine-spec` → `/ido4shape:review-spec` → `/ido4shape:validate-spec`

After the v2 spec was produced, Bogdan ran the remaining ido4shape skills in a new Cowork session.

**Refine-spec** handled four targeted fixes:
- Restructured H2 sections for format compliance
- Fixed EVL-04 dependency (code graders don't depend on LLM evaluators)
- Fixed RUN-01 dependency (orchestration doesn't need code graders)
- Added Decision #6: Agent SDK approach (resolving silent architectural shift from plan)

The skill worked well — it made all changes, tracked ripple effects across the document (updating Phase 0 description, success criteria, open questions when the Agent SDK decision affected them), and verified dependencies after fixing.

**Review-spec** launched three parallel sub-agents:
- Technical Feasibility: 1 critical, 2 important, 4 observations
- Scope Alignment: 1 critical, 4 important, 5 observations
- Dependency Audit: CLEAN (confirmed the refine fixes worked)

Overall verdict: READY WITH NOTES. Three genuinely new findings:
1. Phase 0 "transcript consistency" is undefined — needs quantitative criteria
2. EVL-04 scope mismatch (written like must-have, prioritized as should-have)
3. ido4dev version coupling acknowledged but not tracked

The reviewers found issues that neither Bogdan nor Claude Code had caught. This validated the skill's value.

One issue: the review sub-agents couldn't load their definition files due to a path resolution error (OBS-12). They ran with correct definitions through the plugin's agent registration system, so the impact was minimal — but the path bug is real.

**Validate-spec** ran a thorough check:
- Found one format error: capability IDs used single digits (`SIM-1`) instead of zero-padded (`SIM-01`)
- Everything else passed: structure, metadata, content quality, dependencies, priority calibration
- Produced a dependency graph visualization and critical path analysis

The zero-padding was fixed via another refine-spec pass. Final validation: PASS.

---

## The Full Pipeline Sequence (As Executed)

```
1. create-spec (Session 1)     → Discovery conversation, 5 decisions
2. create-spec (Session 2)     → Deeper probing, evaluation design
3. synthesize-spec              → First spec (v1) — format failures, content losses
4. validate-spec                → Caught format issues
5. [manual fixes]               → 6+ editing rounds (should have been refine-spec)
6. [reconciliation pass]        → v2 spec, recovered lost content
7. refine-spec (new session)    → 4 targeted fixes + ripple tracking
8. review-spec                  → 3 parallel reviewers, found 3 new issues
9. validate-spec                → Caught zero-padding error
10. refine-spec                 → Fixed zero-padding + EVL-04 scope
11. validate-spec               → PASS
```

**Total Cowork sessions:** 3 (Session 1: discovery, Session 2: synthesis, Session 3: refine/review/validate)
**Total skills exercised:** 5 of 6 user-invocable (create-spec, synthesize-spec, validate-spec, refine-spec, review-spec — only stakeholder-brief not used)
**Final artifact:** 5 groups, 17 capabilities, format-compliant, dependency-clean strategic spec

---

## What Worked

1. **The methodology produced genuine insights.** The conversation added value beyond the plan: failure-mode evaluation framing, downstream-agent-usability quality frame, Phase A/B model, conversation quality metrics from real observation. These weren't in the plan and wouldn't have emerged without the ido4shape conversation.

2. **The skill sequence is sound.** create-spec → review-spec → synthesize-spec → validate-spec → refine-spec is a logical pipeline. Each step catches different things. The dependency auditor catches what the synthesizer misses. validate-spec catches what refine-spec misses.

3. **Session continuity works.** The agent picked up context between sessions via the canvas and session summaries.

4. **The agent's self-diagnosis was honest and accurate.** When asked why it lost content, the agent identified three real causes and proposed the right fix (pre-synthesis reconciliation).

5. **refine-spec with ripple tracking is valuable.** When the Agent SDK decision changed SIM-01, refine-spec updated all downstream references — phasing, success criteria, open questions, constraints. This is hard to do manually without missing something.

6. **review-spec found genuinely new issues.** Three findings that neither Bogdan nor the external reviewer (Claude Code) had caught. Independent reviewers add real value.

---

## What Didn't Work

1. **The synthesizer doesn't produce format-compliant output.** Three rounds of format violations (heading syntax, structural sections, ID numbering). Every synthesis required validation + fix cycles. The synthesizer focuses reasoning on content and gets sloppy on mechanical format rules.

2. **Content loss during synthesis.** ~30% of plan substance lost in v1 because: the synthesizer's reading list doesn't include source materials, conversation abstracts away from specifics, and the synthesizer's fresh context window loses implicit endorsements. Recovered in v2, but only because the loss was noticed.

3. **Workspace files not maintained during conversation.** decisions.md, tensions.md, stakeholders.md only updated at session wrap-up, not when events happened. If a session crashes, mid-conversation decisions are lost.

4. **review-spec was skipped before synthesis.** The create-spec skill says to suggest it; the agent didn't. The dependency auditor would have caught errors that made it into the spec.

5. **The agent is too chatty.** Multiple questions per turn, excessive context, doesn't propose when users signal uncertainty. This is a soul.md / create-spec skill issue, not a one-off behavior.

6. **Architectural decisions can shift silently.** The plan said Agent SDK; the spec said Cowork plugin. The shift happened in conversation but wasn't tracked as a decision or tension. Nobody would have noticed if the spec and plan weren't compared externally.

---

## Observations Summary

12 observations logged in `ido4-simulate-observations.md`:

| # | Title | Type | Severity |
|---|---|---|---|
| OBS-01 | Workspace files not updated incrementally | Bug — agent behavior | High |
| OBS-02 | Canvas overstuffed with plan content | User error / design gap | Medium |
| OBS-03 | Agent slow to transition to thinking partner | Behavioral | Low |
| OBS-04 | No product context for existing products | Design gap — ecosystem | Medium |
| OBS-05 | Agent too chatty, doesn't propose | Behavioral — conversation quality | High |
| OBS-06 | Synthesizer produces non-compliant format | Bug — synthesizer | High |
| OBS-07 | Validate-fix loop expensive | Behavioral — process efficiency | Medium |
| OBS-08 | Synthesizer loses source material content | Design gap — synthesis workflow | High |
| OBS-09 | Structural format violations (H2 sections) | Bug — synthesizer | Medium |
| OBS-10 | Dependency logic errors survive validation | Design gap — validate-spec | Medium |
| OBS-11 | Agent skipped review-spec before synthesis | Bug — skill sequencing | High |
| OBS-12 | Review sub-agent files not found in Cowork | Bug — path resolution | Low |

**High severity (fix first):** OBS-01, OBS-05, OBS-06, OBS-08, OBS-11
**Medium severity (fix next):** OBS-02, OBS-04, OBS-07, OBS-09, OBS-10
**Low severity (fix when convenient):** OBS-03, OBS-12

---

## What This Means for ido4shape

**The plugin works.** It produces a usable strategic spec from a real conversation. The methodology adds genuine value — the conversation produced insights the plan didn't have. The skill pipeline (create → review → synthesize → validate → refine) is sound.

**But it needs polish.** Format compliance, workspace discipline, conversation quality, source material reconciliation, and skill sequencing all need improvement. These are specific, fixable issues — not architectural problems.

**The observations are the calibration baseline for ido4-simulate.** Every manual finding maps to a synthetic test signal. When ido4-simulate is built, it should detect these same issues automatically. If a synthetic test doesn't catch OBS-05 (chattiness) or OBS-08 (content loss), the testing framework has a gap.

---

## What This Means for ido4-simulate

The strategic spec is ready for ido4dev decomposition. It was produced by the thing it's designed to test — which means the spec itself is evidence of both ido4shape's capability and its current limitations.

The plan document (`ido4-simulate-plan.md`) remains the richer reference for implementation details that are out of scope for the strategic spec: research data design, ablation variants, cost model with token estimates, funding strategy. The implementation agent should read both.
