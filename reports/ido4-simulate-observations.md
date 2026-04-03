# ido4shape Manual Testing — Observation Log

**Project under test:** ido4-simulate (specifying the synthetic testing framework using ido4shape in Cowork)
**Tester:** Bogdan
**Started:** 2026-03-23

---

## Observations

### OBS-01: Workspace files not updated incrementally during conversation
- **Type:** Bug — agent behavior
- **When:** Agent made decisions, identified stakeholder perspectives, and potentially surfaced tensions throughout the conversation, but only wrote to workspace files (`decisions.md`, `tensions.md`, `stakeholders.md`) at session wrap-up.
- **Expected:** All workspace files updated at the moment the relevant event happens — a decision is made, a tension surfaces, a stakeholder perspective is captured. The create-spec skill says: "update the canvas after every significant insight, not just at session end." The same principle applies to all workspace files.
- **Actual:** During the conversation, only the canvas was updated. `decisions.md` remained at initial template state until session wrap-up, when the agent batch-wrote all 5 decisions. Unclear whether `tensions.md` and `stakeholders.md` were also deferred or neglected entirely.
- **Impact:** If the session had crashed or been interrupted before wrap-up, workspace files would be empty or stale. The Stop hook masks this by prompting a sync pass at session end — so the final state may be correct, but durability during the session is weak. Also, if the canvas gets compacted (PreCompact), decisions/tensions not yet written to their files could be lost permanently.
- **Root cause hypothesis:** Agent treats canvas as the single working document during conversation, then does a batch "sync pass" to workspace files at wrap-up. This is a natural LLM behavior (minimize tool calls) but violates the design intent of real-time workspace updates.
- **ido4shape fix candidate:** Strengthen create-spec skill with explicit guidance: "When a decision is made, write it to decisions.md immediately. When a tension surfaces, write it to tensions.md immediately. When a new stakeholder perspective is captured, update stakeholders.md immediately. Don't defer workspace file writes to session end — sessions can crash, context can compact." Consider a periodic hook or reminder that checks if workspace files are stale relative to canvas content.
- **Synthetic test signal:** Track workspace file write timestamps across the conversation. If decisions.md/tensions.md/stakeholders.md are only written at session end (last turn), flag as deferred-write pattern. These files should have writes distributed across the conversation, correlated with the turns where relevant content emerged.
- **Addendum (from v2 spec review):** A specific sub-pattern: the agent doesn't detect when conversation shifts a fundamental assumption from source materials. In this case, the plan specified an Agent SDK approach; the conversation shifted to a Cowork plugin approach. This was never tracked as a decision in decisions.md or as a resolved tension in tensions.md. The agent should recognize when "what we're discussing now" contradicts "what the source material says" and explicitly flag it: "This changes a key assumption from your plan — let me log it as a decision." Without this, the spec and the plan silently contradict each other and an implementation agent wouldn't know which to follow.

### OBS-02: Canvas overstuffed with plan content
- **Type:** User error / design misunderstanding
- **When:** Bogdan asked the agent to translate the plan document into the canvas
- **Expected (by design):** Plan stays as source material in working folder. Canvas builds up through conversation, tracking what's discovered beyond the source materials.
- **Actual:** Agent copied ~1,200 lines of plan content into canvas, making it a reorganized duplicate rather than a conversation-driven discovery document.
- **Impact:** Canvas lost its purpose as "what we learned by talking" layer. Agent spent time organizing rather than probing.
- **Root cause hypothesis:** User pushed the agent to do this. But agent could have pushed back — the create-spec skill says "scan the project folder for existing materials, read everything available before your first question." It doesn't say "copy them into the canvas."
- **ido4shape fix candidate:** Add guidance to create-spec skill: "When substantial source materials exist, reference them from the canvas but don't duplicate them. The canvas tracks what conversation adds, not what was already written."
- **Synthetic test signal:** Canvas size relative to source material size. If canvas is larger than source docs, something may be wrong.

### OBS-03: Agent slow to transition from organizer to thinking partner
- **Type:** Behavioral observation
- **When:** After ingesting the plan, agent spent multiple turns on completeness-checking and structure compliance assessment before starting to probe thin dimensions.
- **Expected:** Agent reads source materials, identifies thin dimensions, starts probing within 1-2 turns.
- **Actual:** Several turns spent on inventory and self-assessment before the first real probe.
- **Impact:** Slower time-to-value in the conversation. User had to wait through organizational turns before the creative work started.
- **Root cause hypothesis:** The volume of content in the canvas (from OBS-02) made the agent cautious about missing something. Also, the user asked for the assessment explicitly.
- **ido4shape fix candidate:** Consider adding guidance: "After reading source materials, identify the 2-3 thinnest dimensions and start probing immediately. Don't inventory what you already have — probe what's missing."
- **Synthetic test signal:** Number of turns before first substantive probe. Should be ≤ 3 for projects with existing source materials.

### OBS-04: No product context mechanism for new features on existing products
- **Type:** Design gap — ecosystem level
- **When:** Starting an ido4shape session in Cowork to spec a new feature for an existing product. The working folder is empty — ido4shape has no knowledge of the product it's building for.
- **Expected:** ido4shape should have access to product context (architecture, existing capabilities, tech stack, constraints) so it can ask informed questions from turn 1 instead of spending 10 turns learning what the product is.
- **Actual:** The create-spec skill says "scan the project folder for existing materials" but there's no mechanism to populate that context automatically. The user must manually write or gather product docs.
- **Impact:** First 5-10 turns of a feature spec conversation wasted on "tell me about your product" instead of "tell me about this feature." Questions are generic instead of product-aware. The agent can't say "I see you already have a message queue — should the notification system use it?"
- **Two solution approaches discussed:**
  1. **Static document:** ido4dev (running in Claude Code inside the project) generates a `product-context.md` by analyzing the codebase — a strategic summary (architecture, modules, tech stack, integrations, existing capabilities). This file gets placed in the Cowork working folder before starting ido4shape. Simple, works today, but stale after generation.
  2. **Live MCP connection (preferred):** ido4shape in Cowork connects to ido4 MCP as an MCP server. During conversation, ido4shape can query the codebase on demand — "is there existing code related to notifications?", "what message queue does this project use?", "describe the current auth architecture." Always current, dynamic, the agent can drill into specific areas as the conversation demands. The plumbing is natural: ido4 MCP is already an MCP server, Cowork supports MCP connections.
- **Context query tools ido4 MCP would expose to ido4shape (not decomposition — context only):**
  - "Describe the product architecture at a strategic level"
  - "List existing feature areas / modules"
  - "What tech stack and key dependencies?"
  - "Is there existing code related to [topic]?"
  - "What external services does this product integrate with?"
- **Scope:** This is an ecosystem-level design decision touching ido4shape, ido4 MCP, and their connection. Beyond the simulation plan — needs its own design document or addition to the ecosystem vision.
- **ido4shape fix candidate (near-term):** Add a product context template to the project templates in `references/project-templates/`. Document the workflow: "For new features on existing products, generate or write a product-context.md and place it in the working folder before starting ido4shape."
- **ido4shape fix candidate (long-term):** ido4shape connects to ido4 MCP via MCP, queries codebase context on demand during conversation. No static file needed.

### OBS-05: Agent is too chatty, unfocused, and doesn't help close questions
- **Type:** Behavioral — conversation quality
- **When:** Throughout the conversation. The agent provides excessive context, presents multiple options, asks several questions at once, and doesn't help the user reach decisions when they signal uncertainty.
- **Observed behaviors:**
  1. **Over-explains:** Provides paragraphs of context before getting to the question. The user has to wade through analysis to find what they're being asked.
  2. **Multiple questions at once:** Asks 3-4 questions in a single turn instead of one focused question. The user answers the easiest one and the others get lost.
  3. **Doesn't propose when user is stuck:** When the user gives a vague or uncertain answer (signaling they don't know), the agent asks more questions instead of shifting to "here's what I'd recommend based on similar projects."
  4. **Too eager to explore everything:** Tries to cover all dimensions rather than surgically targeting the thinnest ones.
- **Expected (from soul.md):**
  - "You don't overwhelm. When someone's energy drops, you notice."
  - "Conversational. Substantive. Warm but focused."
  - "You match the energy of the conversation."
  - "You have opinions. Strong ones. You share these opinions openly and directly."
  - The agent should be direct, one question per turn, and shift from asking to proposing when the user can't answer.
- **Impact:** Conversations take longer than necessary. The user does more cognitive work than they should — a thinking partner should make thinking easier, not harder. Important questions get buried in verbose turns.
- **Root cause hypothesis:** Three factors:
  1. Default LLM verbosity — Claude tends toward thoroughness and explanation. The soul.md says "don't overwhelm" but doesn't give specific enough guidance on turn length and question count.
  2. Missing "propose mode" — the create-spec skill doesn't explicitly guide the agent to shift from asking to proposing when the user signals uncertainty. "I'm not sure" from the user should trigger "Here's what I'd suggest and why" from the agent.
  3. No question discipline — nothing in the skills says "one focused question per turn." The agent's instinct is to be comprehensive.
- **ido4shape fix candidates:**
  1. **soul.md addition:** Add explicit guidance on turn discipline — "One question per turn. Be direct. If the user's answer signals uncertainty, shift from asking to proposing: 'Based on what you've described, I'd recommend X because Y. Does that feel right?'"
  2. **create-spec skill:** Add a "Conversation Discipline" section: "Keep your turns short and focused. Lead with the question or the proposal, not with analysis. Save context for when the user asks for it."
  3. **Propose mode guidance:** "When the user says 'I'm not sure', 'I don't know', 'what do you think?', or gives a vague answer — stop asking and start proposing. Use your understanding of the problem to offer a concrete recommendation with rationale. Let the user react to a proposal instead of generating answers from scratch."
- **Synthetic test signal:**
  - Average agent turn length in tokens (should decrease over the conversation as understanding deepens)
  - Questions per turn count (should be ≤ 2, ideally 1)
  - Detection of user uncertainty signals ("I don't know", "not sure", "what do you think?") followed by agent asking more questions instead of proposing (failure pattern)
  - Ratio of agent proposals to agent questions in later turns (should increase as conversation matures)

### OBS-06: Canvas-synthesizer produces format-non-compliant output
- **Type:** Bug — agent behavior (canvas-synthesizer sub-agent)
- **When:** Synthesis step. The canvas-synthesizer (Opus sub-agent) produced the spec artifact.
- **Expected:** The synthesizer's instructions in `canvas-synthesizer.md` specify the exact format: `## Group:` headings, blockquote metadata (`> priority: ...`), capability pattern `### PREFIX-NN:`. The output should be format-compliant on first pass.
- **Actual:** Multiple format violations across synthesis and subsequent passes:
  - v1: `### Group SIM:` instead of `## Group:`, inline bold metadata instead of blockquotes
  - v2: Extra H2 sections that aren't `## Group:` or `## Cross-Cutting Concerns` (see OBS-09)
  - After refine-spec: Capability IDs use single digits (`SIM-1`) instead of zero-padded 2-digit format (`SIM-01`). The format spec requires `\d{2,3}`. validate-spec caught this; neither the synthesizer nor refine-spec produced compliant IDs.
- **Impact:** Required multiple editing rounds across synthesis, refine-spec, and validation. Each step caught different format violations but none produced fully compliant output. The format has at least four distinct compliance dimensions (heading level, heading syntax, metadata format, ID numbering) and the synthesizer fails on different ones each time.
- **Root cause hypothesis:** The synthesizer agent focuses its reasoning budget on the hard parts (group boundaries, capability granularity, success conditions, dependency logic) and gets sloppy on mechanical format. The format has many specific rules and the synthesizer doesn't internalize all of them. The instructions in canvas-synthesizer.md describe the format but don't provide a concrete template that shows every rule simultaneously. Refine-spec has the same gap — it edits content and structure but doesn't verify format compliance of the changes it makes.
- **ido4shape fix candidates:**
  1. Add a concrete format template directly in `canvas-synthesizer.md` — a literal 10-line example showing exact heading syntax, metadata blockquotes, AND zero-padded IDs together. Not description — example.
  2. Add a pre-write checklist in the synthesizer: "Before writing each group/capability, verify: heading uses `## Group:` prefix, metadata uses `> ` blockquote, capability ID uses zero-padded 2-digit numbering (PREFIX-01 not PREFIX-1), no H2 sections except Group and Cross-Cutting Concerns"
  3. Add the same ID format rule to refine-spec: "When creating or editing capability IDs, use zero-padded 2-digit numbers: PREFIX-01, PREFIX-02, ... PREFIX-10"
  4. Consider a post-synthesis auto-format pass (code-based, not LLM) that fixes common structural issues — heading levels, metadata format, ID zero-padding — without changing content
- **Synthetic test signal:** Run validate-spec on every synthesized artifact. Track first-pass compliance rate across runs. Track which specific format rules fail most often. Target: >90% first-pass pass rate. Currently: 0% (every pass has had at least one format violation).

### OBS-07: Validate-fix loop is effective but expensive
- **Type:** Behavioral observation — process efficiency
- **When:** After validate-spec reported format failures, the agent spent 6+ tool calls fixing structural issues one at a time.
- **Expected:** Quick, systematic fix — either rewrite the non-compliant sections or use refine-spec skill effectively.
- **Actual:** Agent searched for issues, fixed them one capability at a time, introduced redundant metadata, had to clean up the redundancy, then verified again. Messy, iterative, token-expensive process.
- **Impact:** Significant token cost on mechanical fixes. Risk of content alteration during structural edits (capability count changed from 15 to 17 during the process).
- **Root cause hypothesis:** The agent doesn't have a systematic fix strategy. It tackles each issue individually rather than understanding the pattern and fixing all instances at once. The refine-spec skill was invoked but didn't prevent the manual surgery.
- **ido4shape fix candidate:** Add guidance to refine-spec skill for systematic format fixes: "When fixing format compliance issues, identify the pattern (e.g., all group headings wrong), fix ALL instances in one pass, then verify. Don't fix one at a time."
- **Synthetic test signal:** Count tool calls between validate-spec failure and subsequent validate-spec pass. High counts indicate inefficient fix process. Also compare spec content (capability count, descriptions) before and after fix to detect unintended content changes.

### OBS-08: Synthesizer loses source material content not captured in canvas
- **Type:** Design gap — synthesis workflow
- **When:** Synthesis step. The canvas-synthesizer produced a spec that was missing ~30% of the plan's substantive content — hidden constraints, behavioral triggers, persona trait library, three-layer data format, six-level cost control, traceability evaluator, non-determinism metrics.
- **Expected:** The spec should incorporate all valid, uncontradicted content from source materials — not just what was explicitly discussed in conversation.
- **Actual:** The synthesizer worked primarily from the canvas and workspace files. Source materials (the plan document) were in the working folder but not in the synthesizer's prescribed reading list. Content that was in the plan but never surfaced into the canvas through conversation was lost or under-weighted.
- **Three causes identified (by the agent itself, validated):**
  1. **Synthesizer reading list doesn't include source materials.** `canvas-synthesizer.md` prescribes: read canvas, decisions, tensions, stakeholders, session summaries. The plan document sitting in the working folder isn't on the list.
  2. **Conversation naturally abstracts.** Discussions operate at higher level than design documents. "Three evaluators with failure modes" was discussed conceptually; the plan had specific traceability matrices, pass@k formulas, JSONL schemas. The synthesizer crystallized from conversation-level abstraction.
  3. **Fresh context window.** The synthesizer is a sub-agent with its own clean context. It doesn't have two sessions of conversation history. What was implicitly endorsed by not being challenged is invisible to it.
- **Fourth cause (not identified by agent):** The strategic spec format naturally compresses toward strategic-level content. Some lost elements (data format, cost hierarchy) may be implementation detail that correctly belongs downstream. But others (hidden constraints, behavioral triggers, persona traits) are core WHAT, not HOW — losing those was genuinely wrong.
- **What was lost that matters most:**
  - Hidden constraints in personas (core testing mechanism — tests probing ability)
  - Behavioral triggers (tests mid-conversation disruption handling)
  - Persona trait library (composable, reusable test design)
  - Information traceability evaluator (systematic discussed-vs-in-spec analysis)
  - Canvas diff tracking (enables canvas responsiveness metric)
  - Multi-level cost control architecture (critical for unattended execution)
- **ido4shape fix candidates:**
  1. **Add source material reconciliation to synthesize-spec pre-flight.** Before invoking the synthesizer: "Scan source materials in the working folder. Compare against the canvas. Flag any substantive content that wasn't contradicted by the conversation but also wasn't captured in the canvas. Present the list to the user: 'These items from your source materials weren't discussed — should they be included, excluded, or discussed before synthesis?'"
  2. **Add source materials to the synthesizer's reading list.** Update `canvas-synthesizer.md` process step: "6. Read source materials in the working folder as supplementary context. Content from source materials that aligns with the canvas understanding should be incorporated. Content that contradicts the canvas should be noted as an open question."
  3. **Both approaches are complementary** — reconciliation in pre-flight catches the gap early; source material reading in the synthesizer catches anything that slips through.
- **Synthetic test signal:** Compare plan/source material content coverage against spec content. Compute a "source material coverage rate" — what percentage of substantive source material items appear (in some form) in the final spec. Items explicitly marked as out-of-scope don't count against coverage. Target: >85% coverage of in-scope source material.

### OBS-09: Format non-compliance deeper than heading syntax — structural violations
- **Type:** Bug — canvas-synthesizer understanding of format
- **When:** v2 spec synthesis. The v1 format issues (wrong heading syntax, inline metadata) were fixed. But v2 introduced a different class of format violation.
- **Expected:** The strategic spec format allows only specific H2 sections: `## Group:` and `## Cross-Cutting Concerns`. Everything else (problem statement, stakeholders, constraints, non-goals, open questions) lives inline under the H1 project header as bold-label sections (`**Stakeholders:**`, `**Constraints:**`, etc.).
- **Actual:** v2 spec has 10 extra H2 sections that aren't in the format: `## Problem & Context`, `## Strategic Constraints`, `## Non-Goals`, `## Stakeholders`, `## Groups & Capabilities`, `## Phasing & Dependency Chain`, `## Open Questions & Known Unknowns`, `## Success Criteria Summary`, `## Constraints & Trade-Offs`, `## Summary`. A parser using `^## Group:\s*(.+)$` would skip these, but they violate the structural contract.
- **Impact:** ido4dev's parser would need to handle or ignore non-standard H2 sections. validate-spec would flag these. The content is correct — it's the structural packaging that's wrong.
- **Root cause hypothesis:** The synthesizer understands some format rules (group heading prefix, capability prefix pattern, blockquote metadata) but doesn't understand the full structural contract — specifically, what's allowed at each heading level. It treats the format as "capabilities need PREFIX-NN" rather than "the entire document has a prescribed section hierarchy."
- **ido4shape fix candidate:** Add a structural outline to `canvas-synthesizer.md`: "The spec document has exactly this structure at H2 level: Cross-Cutting Concerns, then Group sections. Problem statement, stakeholders, constraints, non-goals, and open questions are part of the project header (under H1), not separate H2 sections. Do not add H2 sections that aren't `## Group:` or `## Cross-Cutting Concerns`." A concrete example showing the full document skeleton would help.
- **Synthetic test signal:** Count H2 headings that don't match `## Group:` or `## Cross-Cutting Concerns`. Target: 0.

### OBS-10: Dependency logic errors survive validation
- **Type:** Design gap — validate-spec scope
- **When:** Both v1 and v2 specs. validate-spec passed on dependency validation, but logically incorrect dependencies exist.
- **Expected:** Dependencies should be logically correct — a capability should only depend on capabilities whose output it actually needs.
- **Actual:** EVL-4 (Code Graders) depends on EVL-1, EVL-2, EVL-3 — wrong, because code graders analyze transcripts/specs directly and don't need LLM evaluator output. RUN-1 (Orchestration) depends on EVL-4 — too strict, because EVL-4 is "should-have" and explicitly described as added incrementally. These passed validate-spec because the references exist and there are no cycles.
- **Impact:** An implementation agent following these dependencies would sequence work incorrectly — building code graders after LLM evaluators, and blocking orchestration on optional code graders. Incorrect dependencies create false critical paths.
- **Root cause hypothesis:** validate-spec checks structural validity (references exist, no cycles) but not logical validity (does this dependency make functional sense?). Logical dependency validation requires understanding what each capability does — that's a judgment call the synthesizer should make during composition, not something a format checker can catch.
- **ido4shape fix candidate:** Two options:
  1. Add guidance to `canvas-synthesizer.md`: "For each depends_on, verify the dependency is functional — capability A needs capability B's output to work. Don't add dependencies just because capabilities are in the same domain or mentioned together."
  2. Add a dependency review step to the review-spec skill: "For each dependency chain, does the critical path make sense? Would removing a dependency break functionality or just change sequencing?"
- **Synthetic test signal:** Hard to automate — logical dependency correctness is a judgment call. Could flag capabilities where depends_on includes items from unrelated groups as candidates for human review.

### OBS-11: Agent skipped review-spec before synthesis
- **Type:** Bug — agent behavior (skill sequencing)
- **When:** Transition from conversation to synthesis. The agent went directly from canvas update to synthesize-spec without offering or running review-spec.
- **Expected:** The create-spec skill (lines 97-98) prescribes: "Suggest `/ido4shape:review-spec` for independent review by three parallel agents" before invoking synthesize-spec. The designed sequence is: create-spec → review-spec → synthesize-spec → validate-spec → refine-spec.
- **Actual:** Agent went create-spec → synthesize-spec → validate-spec → manual fixes. The review-spec step was skipped entirely. No evidence in workspace files (no review reports, no mention in session-002 summary). The agent mentioned "five review gaps" but this was its own self-assessment of the canvas, not the three-reviewer skill.
- **Impact:** The review-spec skill launches three parallel sub-agents: technical reviewer, scope reviewer, and **dependency auditor**. The dependency auditor is specifically designed to check graph integrity, critical path analysis, and cross-group dependency health. It would likely have caught the EVL-4 and RUN-1 dependency logic errors (OBS-10) before they made it into the spec. Skipping review-spec meant these errors survived into the final artifact.
- **Root cause hypothesis:** The agent was focused on moving toward synthesis after extensive conversation. The instruction to "suggest review-spec" is guidance, not a hard gate — the agent can skip it if it judges the canvas is ready. But it didn't explicitly decide to skip it or explain why. It simply didn't surface the option. The create-spec skill says "suggest" not "require" — which gives the agent discretion but also lets it silently skip a valuable step.
- **ido4shape fix candidates:**
  1. Strengthen the language in create-spec: "Before invoking synthesize-spec, offer `/ido4shape:review-spec`. If you judge the review is unnecessary, explain why to the user: 'I'm skipping the independent review because [reason]. If you'd like it, say /ido4shape:review-spec.'"
  2. Add review-spec as a soft gate in synthesize-spec pre-flight: "Check if review-spec was run in this session. If not, note it: 'Independent review hasn't been run. Consider running /ido4shape:review-spec first — the dependency auditor catches issues the synthesizer often misses.'"
  3. Consider making review-spec a required step for specs with 4+ groups or 10+ capabilities (the synthesize-spec skill already mentions this threshold for "complex specs").
- **Synthetic test signal:** Check whether review-spec sub-agents (technical-reviewer, scope-reviewer, dependency-auditor) were invoked before synthesize-spec in each simulation run. Track correlation between review-spec usage and post-synthesis validation pass rate.

### OBS-12: Review-spec sub-agent files not found in Cowork
- **Type:** Bug — path resolution in Cowork
- **When:** Running `/ido4shape:review-spec`. The skill attempted to read three agent definition files and all three were not found.
- **Expected:** The review-spec skill references agents at `agents/technical-reviewer.md`, `agents/scope-reviewer.md`, `agents/dependency-auditor.md`. These files exist in the ido4shape plugin directory. The skill should load them to configure the three parallel reviewer sub-agents with their specialized prompts.
- **Actual:** "Attempted to read three agent specification files, all not found." The reviews still ran (likely with generic/inline prompts), and the output was useful, but the reviewers didn't have their dedicated agent definitions — meaning the specialized review lenses (architecture coherence, scope alignment, graph integrity) were approximated, not precise.
- **Impact:** Reviews were good but could be sharper. The technical reviewer, scope reviewer, and dependency auditor each have specific instructions about what to look for and how to report. Without those definitions, the reviewers are generic Claude instances doing their best guess at the review task. The quality difference may be subtle or significant — hard to know without a comparison run where the agents load correctly.
- **Root cause (confirmed by investigation):** The review-spec SKILL.md references agents as `agents/technical-reviewer.md` (relative path). The agent appended `agents/` directly to the skill's own directory (`skills/review-spec/agents/`) instead of resolving `../../agents/` from the skill directory to reach the plugin root. The files DO exist at the plugin root's `agents/` directory — the path was simply resolved incorrectly by the agent.
- **Actual impact (lower than initially assessed):** The agent definitions in `agents/` are registered by the plugin system when the plugin loads. The named subagent types (`ido4shape:technical-reviewer`, etc.) were already available through plugin registration. The skill reading the .md files would have been redundant — the agents ran with their correct definitions through the plugin's agent system, not through the SKILL.md reading them manually. The reviews were run with correct agent definitions.
- **Remaining issue:** The path reference in review-spec SKILL.md is still incorrect and the agent wasted tool calls trying to read files at wrong paths. If the plugin's agent registration ever fails or changes, the skill has no fallback.
- **ido4shape fix candidate:** Update review-spec SKILL.md to use `${CLAUDE_SKILL_DIR}/../../agents/technical-reviewer.md` for agent references (consistent with how other skills reference soul.md). Even though the plugin system registers agents automatically, explicit paths serve as documentation and fallback.
- **Synthetic test signal:** Check for "file not found" errors during review-spec execution. Track whether review output matches the structured format prescribed in the agent definitions (would differ if agents ran without their definitions).

---

## Template for New Observations

```
### OBS-NN: [Short title]
- **Type:** Bug / Behavioral observation / Design gap / User error
- **When:** [What was happening in the conversation]
- **Expected:** [What should have happened per ido4shape design]
- **Actual:** [What actually happened]
- **Impact:** [How this affects the conversation or spec quality]
- **Root cause hypothesis:** [Why this might have happened]
- **ido4shape fix candidate:** [What could be changed in skills/hooks/agents to prevent this]
- **Synthetic test signal:** [How the synthetic testing framework could detect this]
```
