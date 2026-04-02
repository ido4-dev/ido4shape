# E2E Test #2: OpenClaw Outreach Strategy

**Date:** 2026-04-02
**Tester:** Bogdan Coman
**Project under test:** OpenClaw outreach strategy for ido4
**Environment:** Cowork (Anthropic desktop agent runtime)
**ido4shape version:** 0.3.3
**Source material:** `openclaw-outreach.md` (~240 lines, comprehensive strategy doc)

---

## Context

This test validated the 5 high-severity observation fixes (OBS-01, 05, 06, 08, 11) from the first real-world test. The project was a real outreach strategy — not a toy example. The source document had specific details (4 named agents, metric targets, scoring thresholds, phased rollout, critical rules) that made it a strong test for content preservation during synthesis.

A structured test plan (`tests/e2e-test-plan-openclaw.md`) was prepared in advance with 7 probe points, each tied to a specific observation fix.

---

## What Happened

### Discovery Conversation (~15 turns)

**Skill used:** `/ido4shape:create-spec`

The agent read the source document and engaged well from the first turn. Key decisions made during conversation:

1. Spec scope: OpenClaw outreach implementation
2. Substack replaces Medium (existing audience)
3. Personal LinkedIn for thought leadership (not brand page)
4. Three-tier autonomy model: auto-execute (Radar), auto-post after calibration (Lighthouse on brand accounts), always-review (personal LinkedIn, Bridge)
5. Daily batch review workflow (once/day, 2-3 hours)
6. Validation spike needed before committing to full architecture
7. All 4 agents built to full quality (no shortcuts)
8. Echo and Lighthouse can auto-post after calibration for time-sensitive content
9. Bluesky deferred to Phase 2

The agent made several strong proposals: validation spike, risk tiers for autonomy, personal LinkedIn vs brand accounts. These were genuine thinking contributions, not just parroting the source doc.

### Review

**Skill used:** `/ido4shape:review-spec` (on canvas, pre-synthesis)

Three parallel reviewers ran:
- **Scope reviewer:** North star alignment strong. Flagged: validation spike lacks success criteria, ido4 landing destination not hard-gated, content quality bar not operationalized.
- **Technical reviewer:** Architecture coherent but "CONCERNS" — unvalidated skill ecosystem, undefined Telegram bot architecture, no LLM cost model, no error handling spec, credential management unaddressed.
- **Dependency auditor:** Clean graph, no cycles. Found optimization: decouple LinkedIn warm-up from Bridge email/DM outreach. Flagged ido4 readiness as hidden cross-project dependency.

All three reviewers produced actionable findings. The dependency auditor's optimization (decoupling LinkedIn warm-up from all Bridge outreach) made it into the final spec.

### Synthesis

**Skill used:** `/ido4shape:synthesize-spec`

Pre-synthesis reconciliation identified specific source doc items not fully captured in canvas (metric targets, critical rules, secondary ICP). Agent noted these and ensured the synthesizer carried them forward.

Synthesizer (Opus sub-agent) produced: 5 groups, 27 capabilities, ~594 lines. Groups: Infrastructure & Validation (7), Lighthouse (5), Radar (5), Bridge (6), Echo (4). Plus cross-cutting sections on Performance, Security, Observability, Operational Cadence, and ido4 Product Lifecycle.

### Validation

**Skill used:** `/ido4shape:validate-spec`

First pass: 1 issue — `BRIDGE` prefix is 6 characters, exceeding 2-5 limit. Agent caught it, renamed to `BRDG`, reran validation.

Second pass: **PASS** — 0 errors, 0 warnings. 5 groups, 27 capabilities, 40 dependency edges, max depth 10, no cycles.

---

## The Full Pipeline Sequence

```
1. create-spec              → Discovery conversation (~15 turns, 9 decisions)
2. review-spec              → 3 parallel reviewers, actionable findings
3. synthesize-spec           → Source reconciliation + Opus synthesis
4. validate-spec             → 1 format issue (prefix length), fixed, PASS on second run
```

**Total Cowork sessions:** 1
**Skills exercised:** 4 of 6 user-invocable (create-spec, review-spec, synthesize-spec, validate-spec)
**Final artifact:** 5 groups, 27 capabilities, format-compliant strategic spec

---

## Observation Fix Results

| OBS | Fix Description | Result | Notes |
|-----|----------------|--------|-------|
| **01** | Immediate workspace file writes | **PASS** | decisions.md, tensions.md had real content mid-conversation |
| **05** | Turn discipline + propose mode | **MOSTLY PASS** | One question/turn consistent. Proposes with conviction. Presented menu (not recommendation) when genuinely unsure. |
| **06** | Format compliance on first synthesis | **MOSTLY PASS** | Near-clean first pass. Only prefix length issue (BRIDGE→BRDG). All other format rules correct. |
| **08** | Source material reconciliation | **PASS** | Reconciliation happened. 10/10 content coverage items survived synthesis. |
| **11** | Review-spec gate before synthesis | **PASS** | Explicitly offered review, explained why it matters. |

---

## New Observations

### NEW-01: Agent doesn't self-terminate discovery
- **Type:** Behavioral — conversation pacing
- **When:** After ~15 turns, the agent kept finding new areas to probe. Bogdan had to say "I think we covered enough."
- **Expected:** Agent should assess convergence proactively and propose moving to composition when understanding is sufficient.
- **Impact:** User does unnecessary cognitive work deciding when to stop. Sessions run longer than needed.
- **Fix applied (v0.3.4):** Added "Convergence check" to create-spec — assess readiness after 8-10 exchanges, propose transition proactively.

### NEW-02: Propose mode leads with menu, not recommendation
- **Type:** Behavioral — conversation quality (refinement of OBS-05)
- **When:** When asked about landing page strategy (user said "I'm not sure"), the agent presented three options without picking one, then deferred: "I don't want to solve that yet."
- **Expected:** Agent should lead with one recommendation, even tentative, and let user push back.
- **Fix applied (v0.3.4):** Strengthened language in create-spec and soul.md — "always lead with one recommendation, even tentative."

### NEW-03: Prefix length not enforced by synthesizer
- **Type:** Bug — synthesizer format knowledge gap
- **When:** Synthesis produced `BRIDGE-01` (6-char prefix). Format spec requires 2-5 characters.
- **Fix applied (v0.3.4):** Added explicit 2-5 char prefix constraint to canvas-synthesizer format template with `BRIDGE→BRDG` example.

### NEW-04: Agent stalls mid-conversation
- **Type:** Behavioral / infrastructure — unclear
- **When:** Agent appeared to freeze after file operations. Bogdan had to prompt "is it blocked?" twice and "why you stopped?" once.
- **Impact:** Breaks conversation flow. User unsure if agent is still working.
- **Root cause:** Unclear — may be Cowork infrastructure (VM latency) or agent confusion about turn completion after tool use.
- **Fix:** None applied. Monitor in future tests.

---

## What Worked

1. **Workspace discipline is solid.** Decisions and tensions written in real time. Files had meaningful content mid-session, not just templates. This was the most improved behavior.

2. **Turn discipline held consistently.** One focused question per turn throughout the conversation. No question dumps. Significant improvement from first test.

3. **The agent made genuine thinking contributions.** Validation spike proposal, three-tier autonomy model, personal LinkedIn vs brand page analysis, decoupling LinkedIn warm-up from Bridge outreach. These weren't in the source doc.

4. **Review-spec produced actionable findings.** Three reviewers caught issues that would have survived into the spec: credential management gap, Telegram architecture gap, dependency optimization.

5. **Format compliance dramatically improved.** From 0% first-pass compliance (first test) to near-clean with one minor issue (prefix length). The format skeleton worked.

6. **Source material content survived synthesis.** 10/10 specific details from the source doc present in the final spec. Reconciliation step worked.

---

## What Didn't Work

1. **Agent doesn't know when to stop probing.** Kept going until told to stop. Needs a self-assessment mechanism for convergence.

2. **Propose mode is inconsistent.** Strong proposals when the agent has conviction, but defaults to option menus when uncertain. Should always lead with a recommendation.

3. **Agent stalls during conversation.** Root cause unclear. Low-severity but noticeable UX issue.

4. **Source reconciliation didn't ask for confirmation.** The fix intended the agent to present unreconciled items and ask the user "include, exclude, or discuss?" The agent just said "I'll carry them through." Acceptable but not the full intended behavior.

---

## Comparison with First Test

| Dimension | First Test (v0.2.1) | This Test (v0.3.3) |
|-----------|---------------------|---------------------|
| Workspace files mid-session | Empty templates | Real content |
| Questions per turn | 3-4 | 1 (consistent) |
| Format compliance first pass | 0% (multiple violations) | ~95% (one prefix issue) |
| Content coverage | ~70% (30% lost) | 100% (10/10 items) |
| Review-spec offered | Skipped silently | Explicitly offered |
| Sessions to valid spec | 3 | 1 |
| Fix rounds after synthesis | 6+ tool calls | 1 (prefix rename) |

All five high-severity observations show clear improvement. The remaining issues are refinements, not regressions.
