# ido4shape

A specification discovery plugin primarily designed for [Cowork](https://claude.com/product/cowork), Anthropic's agentic desktop application — though it also works in Claude Code.

ido4shape is like having a principal consultant inside Claude — it reads your docs, probes your assumptions, tracks stakeholder tensions across sessions, and produces the kind of structured strategic specification that usually takes weeks of consulting.

**Building with AI coding agents?** Your agent is only as good as the spec you give it. ido4shape produces structured specs with dependencies, priorities, and success conditions — input that makes Cursor, Claude Code, or Copilot actually deliver.

**Need help thinking it through?** The agent probes your assumptions, extracts what your team knows but hasn't articulated, and turns it into something you can hand to your boss, your investors, or your dev team.

Either way — every specification tool assumes you already know what to build. ido4shape starts at "tell me about your problem."

## Installation

> ido4shape is also published in Anthropic's community plugin marketplace (`anthropics/claude-plugins-community`), but the listing there is pinned to an older release and there is no maintainer-side update path. For the most recent release, install from the `ido4-dev/ido4-plugins` marketplace below — it tracks `main` automatically and supports auto-sync.

### Cowork (Claude Desktop)

1. Click **Customize** in the left sidebar
2. Under **Personal plugins**, click the **+** button
3. Select **Create plugin** → **Add marketplace**
4. Enter `ido4-dev/ido4-plugins` and click **Sync**
5. Open the Directory, go to the **Personal** tab, and click **+** on ido4shape to install

> **Tip:** In the marketplace card menu (•••), enable **Sync automatically** to receive new releases without lifting a finger.

### Claude Code (CLI)

For developer audiences using Claude Code in the terminal:

```bash
claude plugin marketplace add ido4-dev/ido4-plugins
claude plugin install ido4shape@ido4-plugins
```

## Getting Started

1. **Prepare a project folder** with any materials you have — PRDs, meeting notes, architecture docs, research. You can also start with nothing.
2. **Start a session:**
   - **Cowork:** Click **"Work in a project"** at the bottom of the chat input and select your project folder. Then type `/create-spec my-project` or pick from the "Get to work with ido4shape" suggestions.
   - **Claude Code:** Navigate to your project folder, start Claude Code, then run `/ido4shape:create-spec my-project`
3. **Have a conversation** — the agent reads your materials, asks questions, and builds understanding. Stop and resume anytime; everything is saved.
4. **When ready**, run `/synthesize-spec` to produce the formal spec

> **Cowork users:** Always select a project folder via "Work in a project" before starting. Without a folder selected, the plugin won't work.

## Example Workflows

### Starting from scratch

You have an idea but no documents. You start a session and the agent guides discovery.

```
You: /ido4shape:create-spec my-saas-product

Agent: What's your role on this project? I want to make sure I'm asking the
       right questions.

You: I'm the founder. We're building a B2B analytics dashboard.

Agent: Before we go further — who's feeling the pain right now? Is this
       "customers are asking for it" or "we think the market needs it"?
       That changes how we think about the problem.

You: Our existing customers keep building their own dashboards in spreadsheets.
     We have the data, they just can't access it easily.

Agent: That's a strong signal — they're already solving the problem badly.
       What I want to understand is how acute this is. Are you losing
       customers over it, or is it more of a retention and expansion play?
```

The agent continues probing across problem depth, solution shape, risks, and dependencies. Understanding builds across one or several sessions depending on project complexity. Everything is saved to a knowledge canvas that persists between conversations.

### Starting from existing materials

You have documents — a PRD, meeting notes, architecture sketches. Drop them in your project folder before starting.

```
You: /ido4shape:create-spec notification-system

Agent: I've read the three documents in your folder. Your architecture doc
       describes a multi-channel notification system with email, push, and
       SMS. The meeting notes mention a 10,000 events/minute target from
       Marcus, and Sarah flagged that users currently miss critical alerts.

       Something jumped out at me: the architecture doc assumes synchronous
       delivery, but at 10K events/minute that's going to be a bottleneck.
       Has the team discussed async vs sync delivery?
```

The agent doesn't start from zero — it reads everything first, then targets the gaps. Conversations go deeper faster because you're not repeating what's already written down.

### Picking up where you left off

Sessions can be days or weeks apart. The agent reads the canvas and continues.

```
Agent: Welcome back. Last time we mapped out three capability groups and
       identified a dependency chain through the authentication layer.
       Since then, I've been thinking about something — the risk around
       the third-party API integration we discussed. We left it as an
       open question.

       The architect hasn't weighed in yet on feasibility. Should we
       bring them in, or do you want to make an assumption and flag it?
```

### Running the full pipeline

When understanding is deep enough, the agent proposes moving to synthesis.

```
Agent: I think we have enough to produce a solid spec. Here's the picture:
       4 capability groups, 15 capabilities, 3 cross-cutting concerns. The
       dependency graph is clean — no cycles, critical path through the
       data pipeline group.

       I'd recommend running the independent reviewers first — the
       dependency auditor catches things I consistently miss. Want me
       to launch /ido4shape:review-spec?

You: Yes, go ahead.

[Three parallel reviewers run: technical feasibility, scope alignment,
 dependency audit. Each produces an independent report.]

Agent: Reviews are in. Two findings worth addressing: the scope reviewer
       flagged that Group 3 has a capability that contradicts our non-goal
       of real-time streaming, and the dependency auditor found an
       optimization — decoupling the auth layer from the API gateway
       would let two groups start in parallel.

       Want me to adjust the canvas and then synthesize?

You: Fix those and synthesize.

[Agent updates canvas, runs /ido4shape:synthesize-spec, produces the
 strategic spec artifact, then runs /ido4shape:validate-spec]

Agent: Spec produced: 4 groups, 15 capabilities, valid format, no warnings.
       The file is at notification-system-spec.md. Ready to share with
       your team.
```

## How It Works

The agent explores six areas of understanding. These aren't stages you walk through in order — the agent follows what matters for your specific project, jumping between topics as the conversation evolves.

1. **Problem Depth** — who suffers, how acutely, what workarounds exist
2. **Solution Shape** — what capabilities need to exist, how they relate
3. **Boundary Clarity** — constraints, non-goals, open questions
4. **Risk Landscape** — unknowns, external dependencies, untested assumptions
5. **Dependency Logic** — what must exist before what
6. **Quality Bar** — what "done" means for each capability

The agent adapts to your communication style and energy. It connects dots across sessions and stakeholders, surfaces tensions between conflicting requirements, and knows when to push deeper vs when to step back. When you're stuck, it proposes — it doesn't just ask more questions.

## What You Get

Not just a spec — the thinking behind it.

The final output is a **strategic specification** — groups of capabilities with priorities, risk assessments, dependencies, and verifiable success conditions. Designed to be read by humans and consumed by AI tools alike. See a [complete example spec](references/example-strategic-notification-system.md).

But the real value is everything the agent captures along the way:

- **The knowledge canvas** — your evolving understanding, updated after every insight, readable at any time. Survives sessions, context compaction, and crashes.
- **Decisions & tensions** — every call made and why. Contradictions between stakeholders tracked until resolved. No more "why did we decide that?" six weeks later.
- **Stakeholder perspectives** — who said what, what each person cares about, which perspectives are missing. Both the PM's view and the architect's survive into the spec.
- **Independent review** — before the spec is finalized, parallel AI reviewers check technical feasibility, scope alignment, and dependency integrity.

The spec goes wherever you need it — your dev team (as a project brief), your boss or investors (as a strategy document), AI coding agents (as structured input), or spec-driven tools like [ido4 MCP](https://github.com/ido4-dev/ido4) for automated technical decomposition.

<!-- BEGIN SKILL INVENTORY -->
## Skills

### Commands

| Skill | Description |
|-------|-------------|
| `/ido4shape:create-spec` | Guides users through creative specification development. |
| `/ido4shape:refine-spec` | Edits existing spec artifacts using natural language instructions. |
| `/ido4shape:review-spec` | Launches parallel independent reviewers to assess the canvas or spec artifact before composition. |
| `/ido4shape:stakeholder-brief` | Generates a stakeholder-specific briefing from the current canvas. |
| `/ido4shape:synthesize-spec` | Crystallizes a knowledge canvas into a strategic spec artifact. |
| `/ido4shape:validate-spec` | Validates a strategic spec artifact for format compliance and content quality. |

### Supporting skills (auto-triggered)

These activate automatically during conversation when relevant — you don't invoke them directly.

| Skill | Description |
|-------|-------------|
| `artifact-format` | Provides strategic spec artifact format knowledge. |
| `creative-decomposition` | Provides conversation methodology for creative specification work. |
| `dependency-analysis` | Provides dependency graph knowledge. |
| `quality-guidance` | Provides strategic spec quality standards. |
<!-- END SKILL INVENTORY -->

## Glossary

- **Canvas** — The agent's working memory during specification. Evolves throughout conversations. Human-readable markdown.
- **Crystallization** — Moving from fuzzy conversation to structured, formal specification.
- **Knowledge dimensions** — Six areas the agent explores: Problem Depth, Solution Shape, Boundary Clarity, Risk Landscape, Dependency Logic, Quality Bar.
- **Groups** — Clusters of related capabilities in a spec (e.g., "Notification Core", "Email Channel").
- **Capabilities** — Individual units of functionality within a group, each with a description and success conditions.
- **Strategic spec** — The output: a structured document capturing WHAT to build, for whom, and why.
- **Cross-cutting concerns** — Non-functional requirements (performance, security, accessibility) that apply across the entire project.
- **Success conditions** — Specific, verifiable statements of what "done" means for each capability.
- **NFRs** — Non-functional requirements. Performance targets, security standards, accessibility requirements — things that aren't features but constrain how features are built.

## More Information

- [CONTRIBUTING.md](CONTRIBUTING.md) — How to report bugs, run tests, submit changes
- [SECURITY.md](SECURITY.md) — Data handling, hooks, privacy
- [Developer Guide](docs/developer-guide.md) — Spec format details, workspace structure, the ido4 pipeline
- [CHANGELOG.md](CHANGELOG.md) — Version history
- [Vision & Strategy](docs/vision.md) — Product vision, design philosophy, competitive analysis
- [Documentation Index](docs/README.md) — Full documentation directory

## License

MIT
