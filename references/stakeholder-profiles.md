# Stakeholder Profiles Reference

How the agent adapts its conversation, questions, and canvas contributions based on who it's talking to.

## Detecting the Stakeholder

On first encounter with a new person in a workspace, ask naturally — not as a form field:

"Before we dive in — what's your role on this project? I want to make sure I'm asking the right questions."

Store the answer in `.ido4shape/stakeholders.md`. On subsequent sessions, recognize them from context (session history, or ask if unclear).

If the user passes `$ARGUMENTS` with a role hint (e.g., `/ido4shape:create-spec --as architect`), use that directly.

## Profile: Product Manager

**What they bring:** Problem understanding, user empathy, business context, priority judgments, scope decisions.

**How to adapt:**
- Lead with problem depth and user impact
- Explore business context and competitive pressure
- Challenge scope — PMs tend to over-include
- Probe for non-goals explicitly — "what are we NOT doing?"
- Ask for specific user stories and scenarios
- Push for clear success criteria from the user's perspective

**Canvas dimensions they typically own:**
- Problem Depth (primary)
- Boundary Clarity (primary)
- Quality Bar (co-own with UX)
- Solution Shape (initiator — architect refines)

**Questions to ask:**
- "Who suffers most from this problem? Walk me through their day."
- "What's the cost of NOT solving this?"
- "If we could only ship one piece, what would it be?"
- "What have you explicitly decided NOT to build?"

## Profile: Technical Architect

**What they bring:** Feasibility assessment, infrastructure reality, risk identification, dependency knowledge, performance constraints.

**How to adapt:**
- Be more direct, less exploratory — architects value efficiency
- Ask specific technical questions, not open-ended ones
- Probe infrastructure constraints and integration points
- Challenge optimistic effort estimates with technical reality
- Explore what the team has and hasn't built before
- Ask about failure modes, not just happy paths

**Canvas dimensions they typically own:**
- Risk Landscape (primary)
- Dependency Logic (primary)
- Solution Shape (refiner — validates/reshapes PM's initial concepts)

**Questions to ask:**
- "Is 10k events/minute achievable with your current infrastructure?"
- "What's the scariest part of this technically?"
- "What has this team never built before?"
- "What external dependency could block everything?"
- "Where would you put the architectural boundaries?"

## Profile: UX Designer

**What they bring:** User perspective, interaction patterns, edge cases humans hit, accessibility constraints, information architecture.

**How to adapt:**
- Focus on user flows and interaction patterns
- Ask about edge cases in the UI — what happens when things go wrong
- Probe for accessibility and inclusive design considerations
- Challenge engineer-logical designs with user-logical alternatives
- Ask to see or describe wireframes, mockups, existing UI

**Canvas dimensions they typically own:**
- Quality Bar (co-own with PM — from user experience perspective)
- Solution Shape (UI/UX dimension that engineers often miss)

**Questions to ask:**
- "Walk me through what a user actually sees and does."
- "What happens when this fails? What does the user experience?"
- "Is there an existing pattern in the product we should follow?"
- "What's the most confusing part of this for a new user?"
- "How would this work on mobile vs desktop?"

## Profile: Business Stakeholder

**What they bring:** Budget constraints, timeline pressure, strategic alignment, market context, organizational politics.

**How to adapt:**
- Frame everything in business impact, not technical detail
- Focus on ROI, timeline, and risk to the business
- Be direct about trade-offs: "we can have X or Y, not both in this timeline"
- Surface organizational dependencies (other teams, approvals, compliance)
- Keep technical jargon minimal

**Canvas dimensions they typically own:**
- Boundary Clarity (business constraints, budget, timeline)
- Problem Depth (market and business perspective)

**Questions to ask:**
- "What's the business case for doing this now vs next quarter?"
- "Who else in the organization needs to sign off?"
- "What's the competitive pressure — are we racing someone?"
- "What's the budget constraint — does this affect scope?"

## Profile: QA / Test Engineer

**What they bring:** Edge case thinking, quality requirements, testability concerns, regression awareness, environment needs.

**How to adapt:**
- Welcome their skepticism — it improves the spec
- Focus on success conditions and how to verify them
- Ask about test environments and test data needs
- Probe for non-functional requirements (load, security, accessibility)

**Canvas dimensions they typically own:**
- Quality Bar (primary — from verification perspective)
- Risk Landscape (testing gaps and regression risks)

## The Missing Voice Detector

After each session, assess which perspectives are represented:

```
Perspectives captured:
  PM: sessions 1, 2, 4 — Problem Depth, Boundary Clarity, Quality Bar
  Architect: session 3 — Risk Landscape, Dependency Logic, Solution Shape
  UX: not yet consulted
  Business: not yet consulted
```

Flag when a critical perspective is missing for a dimension that needs it:
- Solution Shape without architect input → "The architecture is based on PM assumptions. I'd feel more confident with technical validation."
- Quality Bar without UX input → "Success conditions are engineer-defined. A UX perspective might change what 'done' looks like for users."
- Boundary Clarity without business input → "Timeline and budget constraints are assumed, not confirmed."

Don't flag exhaustively — flag the gaps that would actually change the spec.
