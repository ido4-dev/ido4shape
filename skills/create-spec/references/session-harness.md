# Session Continuity Protocol

How the agent resumes after time away from a specification project.

## Resume Sequence

When `.ido4shape/` exists (returning to an active project):

1. **Read the canvas** — this is the complete current state of understanding
2. **Read the Understanding Assessment** — know immediately where understanding is thin
3. **Read the latest session summary** — know what happened last and what was flagged for next
4. **Read tensions.md** — know what contradictions are active
5. **Read decisions.md** — know what's been settled (don't relitigate)
6. **Check for new source materials** — anything added to `sources/` since last session
7. **Process new materials** if found — develop observations before the conversation starts

## Opening a Return Session

Never open with "Where were we?" or "Let's continue." Open with substance:

**If new materials were added:**
"I read the [document/data] you added — [specific observation]. This connects to [something from a previous session]."

**If tensions are active:**
"Something's been on my mind since last time. [Tension description]. I think we might be ready to address it now because [reason]."

**If a specific dimension is thin:**
"Looking at where we are, I feel solid about [strong areas] but I'm still uncertain about [thin area]. I think that's where we should focus."

**If the last session flagged something:**
"Last time we said we'd explore [topic]. I've been thinking about it, and here's what I want to understand: [specific question]."

## Multi-Stakeholder Sessions

When a different stakeholder opens the workspace (e.g., architect after PM sessions):

1. Read all existing context (canvas, all session summaries)
2. Adapt to the stakeholder's perspective — ask architecture-focused questions if they're the architect
3. Open by acknowledging what's been established: "I've been working with [PM name] on this. Here's what we've figured out so far: [key points]. But I have questions that I think only you can answer."
4. When new input from this stakeholder reshapes understanding, update the canvas and flag what changed

## Context Anxiety Management

During long sessions, the agent's context window fills. To prevent degradation:

- Keep the canvas updated — it re-enters context on re-read, refreshing the global picture
- Don't try to hold everything in conversation context — write important things to canvas or session notes
- If the conversation has been going for a long time, explicitly re-read the canvas to refresh
- Trust the canvas as ground truth, not conversation memory
