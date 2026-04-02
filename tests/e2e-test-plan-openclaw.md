# E2E Test Plan: OpenClaw Outreach Strategy

**Purpose:** Validate the 5 high-severity observation fixes (OBS-01, 05, 06, 08, 11) against a real project with rich source material.

**Project:** OpenClaw outreach strategy for ido4
**Source material:** `ido4-MCP/strategy/openclaw-outreach.md` (~240 lines)
**Environment:** Cowork with ido4shape plugin, working folder mounted

---

## Setup

1. Create a fresh working folder for the Cowork session
2. Copy `openclaw-outreach.md` into it as source material
3. Start Cowork session with ido4shape installed, working folder selected
4. Run `/ido4shape:create-spec`

---

## Probe Points

### Probe 1: First response quality (OBS-05 — chattiness)
**When:** After the agent reads the source material and responds
**Check:**
- Does the agent lead with a focused question or observation?
- Or does it dump 3+ paragraphs of summary before getting to the point?
- Is it asking ONE question, or 3-4 at once?

**Share back:** Copy the agent's first substantive response (after reading the doc)

---

### Probe 2: Mid-conversation workspace writes (OBS-01 — immediate writes)
**When:** After 3-4 turns where at least one decision or tension has been discussed
**Action:** Ask the agent: "What's in the decisions file right now?" or check `.ido4shape/decisions.md` yourself
**Check:**
- Are decisions written already, or is the file still at template state?
- If a tension surfaced (e.g., automation vs authenticity), is it in tensions.md?

**Share back:** Contents of decisions.md and tensions.md at this point

---

### Probe 3: Propose mode (OBS-05 — propose when stuck)
**When:** Around turn 5-7, when the agent asks you something
**Action:** Give a deliberately uncertain answer. Try one of:
- "I'm not sure about that, what do you think?"
- "Could go either way honestly"
- "I haven't thought about that much"
**Check:**
- Does the agent propose a concrete recommendation with rationale?
- Or does it ask another question / present options without a recommendation?

**Share back:** Your uncertain answer + the agent's response

---

### Probe 4: Review-spec gate (OBS-11 — review before synthesis)
**When:** When the agent suggests moving to composition/synthesis
**Check:**
- Does the agent mention `/ido4shape:review-spec` before synthesis?
- If it skips review, does it explain why?
- Or does it go straight to synthesize-spec silently?

**Share back:** The agent's transition message (when it suggests moving to composition)

---

### Probe 5: Source material reconciliation (OBS-08 — content preservation)
**When:** During the synthesis process (after running synthesize-spec)
**Check:**
- Does the agent mention comparing source materials against the canvas?
- Does it present a list of items from the doc that weren't discussed?
- Or does it just invoke the synthesizer without reconciliation?

**Share back:** Whatever the agent says/does between "let's synthesize" and the actual spec output

---

### Probe 6: Format compliance (OBS-06 — first-pass synthesis quality)
**When:** After the spec is produced
**Action:** Run `/ido4shape:validate-spec` on the output
**Check:**
- Does it pass on first try?
- If not, what failed? (H2 headings, ID format, metadata syntax?)

**Share back:** The validate-spec output

---

### Probe 7: Content coverage (OBS-08 — what survived)
**When:** After the spec is finalized
**Check these specific details from the source doc — are they in the spec?**

| Detail | In spec? |
|--------|----------|
| 4 named agents (Lighthouse, Radar, Bridge, Echo) | |
| 80+ scoring threshold for prospect handoff | |
| "Never auto-send" critical rule | |
| Phased rollout (4 phases with week ranges) | |
| ICP: Series A-C, 50-500 person companies | |
| Metric targets (25% reply rate, 3-4 posts/week, etc.) | |
| Human-in-the-loop for Bridge and Echo | |
| VPS infrastructure spec (4 CPU, 4GB RAM) | |
| Content themes (4 categories) | |
| LinkedIn warm-up period requirement | |

**Share back:** The final spec + this checklist filled in

---

## What to Share Back (Summary)

After the session, share with me:
1. Agent's first substantive response (Probe 1)
2. Mid-session decisions.md and tensions.md contents (Probe 2)
3. Your uncertain answer + agent's response (Probe 3)
4. Agent's composition transition message (Probe 4)
5. Pre-synthesis reconciliation activity (Probe 5)
6. validate-spec output (Probe 6)
7. Final spec + content coverage checklist (Probe 7)

I'll compare each probe against the detection criteria in memory and tell you what landed, what partially worked, and what's new.

---

## Pass Criteria

All 5 fixes are considered "landed" if:
- **OBS-01:** decisions.md has content mid-session (not just at wrap-up)
- **OBS-05:** Agent asks ≤2 questions per turn AND proposes when you give an uncertain answer
- **OBS-06:** validate-spec passes on first try (or fails on content only, not format)
- **OBS-08:** Agent does reconciliation before synthesis AND ≥7/10 content coverage items present
- **OBS-11:** Agent explicitly mentions review-spec before synthesis
