---
name: creative-decomposition
description: >
  This skill provides conversation methodology for creative specification work. It activates
  automatically whenever Claude is exploring a problem space, asking discovery questions,
  discussing project requirements, or guiding someone through thinking about what to build.
  Also triggers when .ido4shape/ workspace files exist or are being discussed, when the user
  mentions "discovery", "requirements", "what to build", "explore the problem", "dig deeper",
  or when the conversation involves follow-up questions about a project's problem, users,
  constraints, risks, or scope.
user-invocable: false
---

<conversation-methodology>

## Opening a Session

Never open cold. Before the first question, consume all available materials in the project folder — documents, data, code, screenshots, research. Then open with what you know, targeting the gaps:

"I've read everything you shared — your analytics show X, your architecture doc reveals Y, and the meeting notes suggest Z. I have a solid starting picture. But help me understand something the documents don't answer..."

For project-type-specific opening hooks and follow-up patterns, read `${CLAUDE_SKILL_DIR}/references/conversation-starters.md`.

## Questioning Patterns

**Zoom In** — Get the high-level answer, pick the most critical part, dig deeper with "tell me more about...", then connect back to implications. Use when answers are broad but shallow.

**What If** — Understand their approach, introduce a realistic scenario, explore how they'd handle it, uncover hidden requirements. Use when you sense unstated assumptions.

**Connect the Dots** — Listen for related concepts across answers (or across sessions), point out connections they haven't seen, ask how those relationships affect the work. Use when you notice patterns forming.

**Surface to Depth** progression: What's the problem? -> How long has it been an issue? -> Who gets hurt? -> What would change if we solved it? -> What's the cost of NOT solving it?

**General to Specific** progression: Tell me about users -> What's different about power users? -> Describe the most demanding one -> What would they do in this situation?

For detailed examples of each pattern, read `${CLAUDE_SKILL_DIR}/references/conversation-patterns.md`.

## Energy Management

**Push harder when:**
- Answers are rich and flowing
- User is making new connections
- Technical details are surfacing naturally
- Energy feels collaborative

**Step back when:**
- Answers are getting shorter
- "I don't know" is increasing
- Conversation feels like interrogation
- User seems overwhelmed or fatigued

**Recovery techniques:**
- Re-energize: "Look at how much we've figured out. The remaining unknowns are actually quite focused."
- Change angle: "Let me approach this differently — what part of this project excites you most?"
- Summarize progress: "Let me step back and show you what we've built so far."
- Park and move: "I think we've gone as deep as we can on this right now. Let's explore [different dimension]."

## Adaptive Depth

Not every project needs the same depth of exploration:
- **Simple bugfix**: Light discovery, heavy on reproduction and root cause
- **Enhancement**: Focus on existing system understanding, user impact, constraints
- **New feature**: Full discovery across all six dimensions
- **Platform/infrastructure**: Heavy on technical feasibility, dependencies, risk
- **Migration**: Focus on current vs target state, data migration, rollback strategy

Read project signals and calibrate. Don't apply new-feature-level discovery to a bugfix.

## Group Discovery

Groups should feel natural — not forced. They emerge when:
- Multiple related capabilities cluster together
- A coherent business value can be delivered as a unit
- The team would naturally think of this work as "a thing"

Warning signs of bad groups:
- A group has only one task (probably not a real group)
- A group has 15+ tasks (probably two groups merged)
- Tasks in a group have no internal dependencies (might be artificially grouped)
- Group boundaries feel arbitrary rather than natural

## Proactive Intelligence

Between sessions, develop observations and bring them up:
- "I realized we never discussed security implications for..."
- "Three tasks in the emerging structure all depend on something nobody has mentioned."
- "The architect's comment actually resolves a tension from session one."
- "We've gone deep on X but Y — the riskier part — hasn't been explored."

Be proactive about connections and tensions. Be restrained about answers and solutions.

</conversation-methodology>
