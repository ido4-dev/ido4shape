# Conversation Patterns & Question Strategies

Detailed reference for the creative-decomposition skill. These patterns are drawn from the specs-wizard heritage and refined through real specification sessions.

## The Zoom In Pattern

**When to use:** Answers are broad but shallow. User describes a problem at surface level.

**How it works:**
1. Get the high-level answer
2. Pick the most interesting or critical part
3. Dig deeper: "Tell me more about..."
4. Connect back to implications for the project

**Example:**
```
User: "We need a better dashboard."
Agent: "What specifically about the current dashboard isn't working?"
User: "It's too slow and hard to find things."
Agent: "Let's zoom in on 'hard to find things' — can you walk me through
        the last time you needed to find something specific? What happened?"
User: "I was looking for monthly revenue for a client call, and I had to
        click through three different views..."
Agent: "So navigation is the real friction — not just speed. That changes
        what we'd prioritize. How often does this happen to other people
        on the team?"
```

## The What If Pattern

**When to use:** You suspect there are unstated assumptions or edge cases.

**How it works:**
1. Understand their current approach
2. Introduce a realistic scenario they haven't considered
3. Explore how they'd handle it
4. Uncover hidden requirements or risks

**Example:**
```
Agent: "What happens if a user has 50 devices registered? Your current
        design assumes a small number per user — but power users or
        shared accounts might break that assumption."
User: "Hmm, I hadn't thought about that. We should probably cap it."
Agent: "What's the right cap? And what happens when they hit it — reject
        the new device, or drop the oldest one?"
```

## The Connect the Dots Pattern

**When to use:** You notice related concepts across different parts of the conversation (or across sessions) that the user hasn't connected.

**How it works:**
1. Listen for related concepts
2. Surface the connection
3. Ask how the relationship affects the project

**Example:**
```
Agent: "Something interesting — in session one you mentioned that the
        routing engine needs to handle 10k events/minute, and today the
        architect said the preference lookup hits the database on every
        call. Those two things are in tension. At 10k/min, that's 10k
        database reads/min just for preferences. Should we cache?"
```

## Question Progression: Surface to Depth

Use this progression to move from superficial understanding to genuine insight:

1. **Surface:** "What's the problem?"
2. **Context:** "How long has this been an issue?"
3. **Impact:** "Who gets hurt when this happens?"
4. **Emotion:** "What does that feel like for them?"
5. **Insight:** "What would change if we solved this?"
6. **Cost:** "What's the cost of NOT solving it?"

## Question Progression: General to Specific

Use this to move from broad categories to concrete, testable scenarios:

1. **General:** "Tell me about your users"
2. **Segment:** "What's different about your power users?"
3. **Specific:** "Describe your most demanding power user"
4. **Behavioral:** "What would they do in this situation?"
5. **Emotional:** "How would they feel if we changed this?"

## Follow-Up Quality Guidelines

**Good follow-ups build on the answer:**
- "That's interesting — what led you to that conclusion?"
- "Help me understand the 'why' behind that choice..."
- "I'm curious about [specific detail] — can you elaborate?"
- "What would happen if [scenario]?"
- "How do you see that playing out in practice?"

**Avoid:**
- Repeating questions already asked
- Yes/no questions without context
- Questions that don't build on their answer
- Academic questions that don't serve the project
- "Great question!" or any performative acknowledgment

## Transition Phrases

**Building momentum:**
- "Building on what you just said..."
- "That reminds me of something important..."
- "I'm starting to see a pattern here..."
- "This connects to something you mentioned earlier..."

**Shifting direction:**
- "Let me approach this from a different angle..."
- "I want to explore something tangential but important..."
- "Stepping back from the details for a moment..."
- "This is a different dimension, but..."

**Flagging insight:**
- "That's actually a crucial piece — here's why..."
- "I think you just identified something we hadn't seen..."
- "This changes the picture..."
