# ido4-simulate — Synthetic Testing & Evaluation Framework

## 1. Purpose

A scenario-driven framework that runs synthetic multi-stakeholder specification conversations through ido4shape and produces structured quality assessments. It answers the question: **does ido4shape produce good specs from realistic conversations, consistently, across diverse project types?**

Four capabilities:
- **Simulate** — run automated spec conversations with synthetic personas
- **Evaluate** — assess both the conversation process and the spec output against rubrics
- **Compare** — track quality across ido4shape versions, detect regressions, find systematic patterns
- **Produce research-grade data** — every simulation run captures full provenance, supports ablation analysis, and builds toward publishable quantitative findings on AI-assisted specification

### Long-Term Research Vision

This framework is designed from day one to produce data suitable for academic publication. The immediate goal is testing ido4shape. The long-term goal is contributing to the scientific understanding of AI-assisted specification and requirements engineering — a space where quantitative data on what actually happens in AI-human specification conversations barely exists.

Potential research directions (not commitments, but options the data design keeps open):
- **Information fidelity in AI-assisted specification** — quantifying what gets discussed vs. what survives into the spec artifact, with traceability matrices across hundreds of conversations (ICSE, RE venues)
- **Multi-stakeholder knowledge preservation** — does an AI partner flatten or preserve diverse perspectives when crystallizing multi-stakeholder input? (CHI, CSCW venues)
- **Methodology contribution** — the evaluation framework itself as a novel approach for assessing conversational AI agents in creative knowledge work (AAAI/NeurIPS workshop venues)
- **Synthetic persona validity** — empirical study on when simulated users produce meaningful vs. misleading test results (CHI, meta-research)

This means every design decision in the framework should ask: "does this produce data we can analyze later, or does it discard information we'll wish we had?"

### What This Is Not

- Not a replacement for manual testing — manual testing calibrates what "good" looks like; synthetic testing scales that calibration
- Not a real-time supervisor — all evaluation is post-hoc, analyzing transcripts and artifacts after simulation completes
- Not Cowork testing — this tests ido4shape's methodology and plugin machinery via the Agent SDK, not the Cowork-specific runtime (injection defense, VM sandbox, UI flow). Cowork-specific testing remains manual.

---

## 2. Architecture

Three layers with strict separation of concerns:

```
┌──────────────────────────────────────────────────────────────┐
│  Layer 1: SCENARIO DESIGN                                     │
│  Scenario definitions with personas, behavioral triggers,     │
│  hidden constraints, expected coverage, evaluation weights     │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  Layer 2: SIMULATION ENGINE                                   │
│  Agent SDK orchestrates persona LLMs ↔ ido4shape              │
│  Captures: transcript, canvas snapshots per turn,             │
│  workspace evolution, tool calls, skill activations            │
└──────────────────────────┬───────────────────────────────────┘
                           │
                           ▼
┌──────────────────────────────────────────────────────────────┐
│  Layer 3: EVALUATION & REPORTING                              │
│  Code-based checks + LLM-as-judge assessments + synthesis     │
│  Per-scenario reports, cross-scenario pattern detection,       │
│  version-to-version regression analysis                       │
└──────────────────────────────────────────────────────────────┘
```

### Relationship to Existing Frameworks

The evaluation layer should leverage existing open-source tooling where possible rather than building everything from scratch:

- **DeepEval** (open-source, Python) — has built-in multi-turn metrics: conversation completeness, knowledge retention, role adherence, turn relevancy. Could serve as the evaluation backbone for standard metrics.
- **Promptfoo** (open-source, now part of OpenAI) — has simulated user providers and multi-turn conversation testing with assertions. Could inform scenario execution patterns.
- **Maxim** (commercial) — reference for CI/CD integration patterns and production-grade evaluation pipelines.

The implementation should evaluate whether DeepEval's `ConversationalTestCase` and built-in metrics can handle our evaluation needs before building custom evaluators. Our domain-specific evaluations (methodology compliance, information traceability) will likely need custom rubrics regardless, but standard metrics (knowledge retention, role adherence, conversation completeness) may be handled by existing frameworks.

---

## 3. Layer 1: Scenario Design

A scenario is a complete test case — not just a persona with a prompt, but a definition of inputs, behavioral dynamics, expected outcomes, and evaluation criteria.

### 3.1 Scenario Structure

Each scenario defines:

**Project Context** — what kind of project is being specified (domain, team size, existing codebase, complexity level)

**Personas** (ordered sequence) — each with:
- **Role and traits** — personality, communication style, domain expertise
- **Opening message** — how they introduce themselves and their needs
- **Hidden constraints** — facts the persona knows but won't volunteer unless specifically probed. This is critical: it tests ido4shape's ability to ask the right questions, not just process answers.
- **Behavioral triggers** — conditional behaviors that fire based on turn count, topic detection, or ido4shape actions. Examples: introducing a new constraint mid-conversation, getting defensive when asked about timeline, contradicting something said earlier.
- **Exit condition** — when this persona's part of the conversation ends
- **Joins after** — for multi-stakeholder scenarios, which persona precedes them on the same workspace

**Expected Coverage** — the ground truth for evaluation:
- `must_appear` — items that should appear in the final spec (traced from conversation)
- `must_not_appear` — items that should be explicitly excluded (scope discipline)
- `should_have_tensions` — contradictions that should be detected and surfaced
- `stakeholder_attribution` — whose perspective should be visible in the spec

**Evaluation Weights** — per-scenario weights for the four evaluation dimensions, allowing different scenarios to emphasize different quality aspects

### 3.2 Persona Trait Library

Reusable personality components that can be composed into scenario-specific personas:

| Trait | What it tests |
|---|---|
| **Vague stakeholder** | Probing depth — gives qualitative descriptions, needs pressing for specifics |
| **Scope creeper** | Boundary enforcement — keeps expanding scope, responds to pushback |
| **Contradiction-prone** | Tension detection — states conflicting things without realizing it |
| **Defensive about decisions** | Diplomatic probing — pushes back on questions about prior choices |
| **Information withholder** | Elicitation skill — holds back key context until directly asked |
| **Over-sharer** | Focus management — provides too much detail, tests whether ido4shape can prioritize |
| **Domain-naive** | Translation ability — doesn't speak technical language, needs concepts explained |
| **Technically dominant** | Balance — tries to steer into implementation details prematurely |

### 3.3 Scenario Categories

| Category | What it tests | Key evaluation focus |
|---|---|---|
| **Baseline: single stakeholder, clear project** | Core methodology flow end-to-end | Spec quality, canvas evolution |
| **Multi-stakeholder, sequential** | Handoff, context preservation, stakeholder briefing | Stakeholder awareness, information traceability |
| **Vague founder** | Probing depth, extracting hidden requirements | Hidden constraint probing rate |
| **Scope creep pressure** | Boundary enforcement, non-goal identification | Scope discipline in spec |
| **Mid-conversation disruption** | Adaptation to new information | Canvas responsiveness, spec incorporation |
| **Contradictory stakeholders** | Tension detection and management | Tension management score |
| **Minimal viable project** | Knows when to stop, doesn't over-engineer | Scope appropriateness |
| **Highly complex project** | Handles scale, doesn't collapse under complexity | Dimension coverage, spec completeness |
| **Returning session** | Session continuity, canvas persistence | Knowledge retention across sessions |
| **Recovery from error** | ido4shape makes wrong assumption — can it recover when corrected? | Adaptability, canvas correction |
| **Adversarial/uncooperative** | Handles reluctant or dismissive stakeholders | Character resilience, productive friction |
| **Domain-specific** | Healthcare, fintech, etc. where domain knowledge matters | Domain-appropriate probing |

### 3.4 Scenario Design Principles

Informed by research on synthetic persona validity (PersonaCite, SimAB) and Anthropic's evaluation guidance:

1. **Start from real failures.** The first scenarios should be based on actual problems observed during manual testing — not hypothetical edge cases. Anthropic recommends 20-50 simple tasks drawn from real failures as a starting point.

2. **Balance positive and negative cases.** Include scenarios where ido4shape should succeed easily (baseline validation) alongside scenarios designed to expose weaknesses. One-sided test suites produce one-sided optimization.

3. **Define ground truth before running.** The `expected_coverage` must be written before the simulation runs, not retrofitted to match results. Otherwise evaluation is circular.

4. **Include meta-assessment.** Every scenario includes evaluation of the test itself (persona realism) — bad tests are worse than no tests.

---

## 4. Layer 2: Simulation Engine

### 4.1 Runtime Architecture

The simulation engine uses the **Claude Agent SDK (Python)** to run ido4shape programmatically:

- **ido4shape** loads as a local plugin via `plugins: [{"type": "local", "path": "..."}]`
- All plugin machinery runs natively: hooks (SessionStart, UserPromptSubmit, PreToolUse, Stop, PreCompact), skills (auto-triggered and user-invocable via description matching), agents (canvas-synthesizer, reviewers)
- **Multi-turn sessions** via `ClaudeSDKClient` which handles session state automatically
- **Multi-persona continuity** via `continue_conversation=True` — second persona resumes the same workspace and session

Each simulation run operates in an **isolated working directory** (one per scenario run) to prevent workspace state contamination across runs.

### 4.2 Persona Engine

The persona engine wraps the Anthropic API (using a cheap model like Haiku) with behavioral logic:

- **System prompt** built from traits, role, and hidden constraint instructions
- **Hidden constraint tracking** — monitors which constraints were revealed vs. withheld, and whether revelation was probed (by ido4shape asking) or leaked (by persona volunteering)
- **Behavioral trigger evaluation** — checks conditions each turn and injects contextual instructions into the persona's next response when triggered
- **Conversation history management** — maintains the persona's view of the conversation for context continuity

Key design requirement: the persona must behave like a **real human**, not a helpful AI. This means:
- Short, conversational responses (2-5 sentences typical)
- Realistic uncertainty and hedging
- Occasional tangents and self-corrections
- Defensiveness, vagueness, or scope creep as defined by traits
- Hidden constraints genuinely withheld, not leaked

### 4.3 Data Capture — What, When, How

#### What Gets Captured

| Data | Purpose |
|---|---|
| **Conversation transcript** — every message from both sides, with speaker ID and turn number | Traceability analysis, methodology assessment |
| **Canvas snapshots** — `.ido4shape/canvas.md` read after every turn | Canvas responsiveness, dimension coverage tracking |
| **Canvas diffs** — computed change between consecutive snapshots | Temporal analysis: what changed when |
| **Workspace file evolution** — `decisions.md`, `tensions.md`, `stakeholders.md` snapshots | Tension management, stakeholder tracking |
| **Raw SDK messages** — full message objects including tool use, tool results, system messages | Phase gate verification, skill activation tracking, research provenance |
| **Raw API responses** — full request/response payloads from persona LLM calls | Persona behavior analysis, reproducibility |
| **Hidden constraint state** — which constraints revealed, when, whether probed or leaked | Hidden constraint analysis |
| **Behavioral trigger log** — which triggers evaluated, which fired, with what context | Persona realism evaluation |
| **Session metadata** — session ID, turn count, duration, token usage, cost, compaction events | Operational metrics, cost tracking |
| **Final spec artifact** — `*-spec.md` file (or absence of one) | Spec quality evaluation |

#### When Data Is Written (Capture Timing)

Data must be **streamed to disk as it happens**, not batched at the end. A simulation run takes 30+ minutes. A crash at turn 22 must not lose turns 1-21.

**Event-driven capture model:**

| Event | What gets written | Format |
|---|---|---|
| **Run starts** | Provenance (ido4shape version, framework version, variant config, model, scenario definition frozen copy) | `provenance.json` — written once at start |
| **Session starts** | SessionStart hook output, initial workspace state | Appended to `events.jsonl` |
| **Persona message sent** | Turn number, speaker, message content, trigger state, hidden constraint state | Appended to `events.jsonl` |
| **ido4shape responds** | Full SDK message stream (assistant text, tool calls, tool results) | Raw messages appended to `events.jsonl`; individual tool calls also logged |
| **After each turn** | Canvas snapshot, canvas diff from previous, workspace file snapshots | Canvas snapshot written to `canvas/turn-{NNN}.md`; diff appended to `events.jsonl` |
| **Persona exits** | Exit reason, turn count, revealed constraints summary | Appended to `events.jsonl` |
| **Spec produced** | Copy of spec artifact | Copied to run output directory |
| **Run completes** | Summary: total turns, total duration, total tokens, total cost, compaction events | `summary.json` — written once at end |
| **Evaluation completes** | Evaluator inputs hash, evaluator raw outputs, parsed scores, evidence | `evaluation.json` — written after evaluation |
| **Report generated** | Human-readable synthesis | `report.md` — written last |

#### Data Format — Three Layers

**Layer 1: Raw Event Stream (append-only, never modified)**

`events.jsonl` — JSON Lines format, one event per line. Same format Claude Code uses for session transcripts. Each line:

```json
{"type": "turn", "turn": 5, "role": "user", "speaker": "sarah-pm", "content": "...", "timestamp": "2026-03-24T14:32:05Z", "trigger_state": {...}, "hidden_constraints_revealed": [...]}
```

This is the source of truth. It's append-only — events are never modified or deleted. If the process crashes, everything up to the last flushed line is preserved.

Raw SDK messages go into a separate `raw-sdk-messages.jsonl` to avoid bloating the primary event stream (tool call payloads can be large).

**Layer 2: Per-Run Derived Data (computed after run completes)**

- `summary.json` — run-level metrics (turns, cost, duration, models used, compaction events)
- `canvas-evolution.json` — all canvas snapshots with diffs, dimension progression extracted
- `metrics.json` — computed metrics: canvas update frequency, dimension progression curve, anti-pattern counts, skill activation counts, hidden constraint probe rate
- `evaluation.json` — all four evaluator outputs with parsed scores and evidence
- `report.md` — human-readable report

These are derived from Layer 1 data. If the computation is wrong, they can be regenerated from the raw events without re-running the simulation.

**Layer 3: Cross-Run Analysis Store (aggregated across all runs)**

A **SQLite database** (`ido4-simulate.db`) that aggregates key metrics across all runs. Updated after each run completes. Contains:

- `runs` table — one row per run: scenario_id, variant, model, persona_model, repetition, ido4shape_version, timestamp, total_turns, total_cost, spec_produced
- `scores` table — one row per (run, evaluator, dimension): score, evidence_summary
- `metrics` table — one row per (run, metric): value (canvas_update_freq, hidden_constraint_probe_rate, anti_pattern_count, etc.)
- `canvas_progression` table — one row per (run, turn, dimension): level (not_started, thin, forming, deep)

This is what Jupyter notebooks and analysis scripts query. It supports SQL queries like:
- "Average spec quality score by variant across all scenarios"
- "Phase gate ablation effect size per scenario category"
- "Canvas update frequency on Sonnet vs. Opus"

SQLite is a single file, requires no server, works with pandas (`pd.read_sql`), R (`DBI`), and standard SQL tools. It can be committed to the data repo or shared as a research artifact.

**Export formats for analysis:** The SQLite database can be exported to CSV or Parquet for tools that prefer flat files. The framework should include a `export-for-analysis` script that produces these.

#### Storage Estimates

Per simulation run (25 turns, 2 personas):
- `events.jsonl`: ~200-500 KB (conversation content + metadata)
- `raw-sdk-messages.jsonl`: ~2-5 MB (full API payloads)
- `canvas/` snapshots: ~100-300 KB (25 markdown files)
- Derived data (summary, metrics, evaluation): ~50-100 KB
- Spec artifact: ~10-30 KB
- **Total per run: ~3-6 MB**

For Phase 3 (700 runs): ~2-4 GB
For research-grade (3,700 runs): ~11-22 GB
For full research with raw data: ~20-40 GB

These are manageable volumes. No need for cloud storage or distributed systems — a local drive or a simple cloud storage bucket (S3, GCS) is sufficient.

### 4.4 Infrastructure

#### Where the Simulation Engine Runs

The simulation engine is **API-bound, not CPU-bound.** The bottleneck is API response time and rate limits, not compute. A minimal machine can run it — all it does is send API requests, wait for responses, and write JSON to disk.

**Phase 0-1: Local machine (Bogdan's laptop)**

Sufficient for validation and calibration. One scenario at a time, interactive debugging.

Pros: zero setup, direct file inspection, easy debugging
Cons: ties up the machine, can't run unattended for long, laptop must stay awake

**Phase 2+: Dedicated environment for batch runs**

Options, from simplest to most robust:

| Option | Setup effort | Cost | Unattended overnight | Parallelism |
|---|---|---|---|---|
| **Local machine + `tmux`/`screen`** | None | Free | Yes (if machine stays on) | Limited by API rate limits |
| **Cloud VM (small)** | Low | ~$5-20/month (e2-small or t3.micro) | Yes | Same as local |
| **Docker container (local or cloud)** | Medium | Container hosting cost | Yes | Can run multiple containers |
| **GitHub Actions (self-hosted runner)** | Medium | Free (self-hosted) or runner minutes | Yes | Workflow parallelism |

**Recommended path:**

- **Phase 0-2:** Run locally. Use `tmux` or `nohup` for batch runs that take hours. Simple, no infrastructure to manage.
- **Phase 3:** Move to a small cloud VM (or a dedicated home machine like a Mac Mini). The simulation suite takes hours to days at this scale — it needs to run unattended. The VM cost (~$10-20/month) is negligible compared to API costs ($1,000+).
- **Phase 4 (CI):** GitHub Actions workflow for regression tests on each ido4shape release. A self-hosted runner avoids paying for GitHub runner minutes on long runs.

**Parallelism and rate limits:**

Individual simulation runs are sequential (each turn depends on the previous). But independent runs (different scenarios, different variants, different repetitions) can run in parallel — limited by Anthropic API rate limits.

The framework should support:
- Sequential execution (default, simplest)
- Parallel execution with configurable concurrency (e.g., 3 runs at once)
- Rate limit awareness (back off when hitting API limits, resume automatically)
- Run queue management (submit 100 runs, framework distributes them over time)

**Environment requirements:**
- Python 3.11+
- `claude-agent-sdk` package
- `anthropic` package
- `ANTHROPIC_API_KEY` environment variable
- Network access to Anthropic API
- ~50 GB disk space (for research-grade data accumulation)
- No GPU, no special hardware, no database server

#### Data Storage Location

**Code repo** (`ido4-simulate/`): scenario definitions, evaluator rubrics, variant configs, framework source code, analysis notebooks. Committed to git. Public or private.

**Data repo or storage** (separate from code): all simulation outputs (`events.jsonl`, raw messages, evaluations, reports), the SQLite analysis database, exported datasets. This should be **separate from the code repo** because:
- Data volumes are large (20-40 GB for research-grade)
- Data contains full conversation transcripts (potentially sensitive)
- Data changes independently of code (new runs don't change code)

Options:
- **Separate git repo** (e.g., `ido4-simulate-data/`) — works for early phases, gets unwieldy at scale. Use git-lfs for large files.
- **Cloud storage bucket** (S3, GCS, or similar) — better for research-grade volumes. Cheap (~$0.50/month for 40 GB). Shareable via presigned URLs for publication.
- **Local directory** (gitignored in code repo) with periodic backup — simplest for Phase 0-2.

**Recommended path:**
- Phase 0-2: local `outputs/` directory (gitignored), manual backups
- Phase 3+: cloud storage bucket with automated upload after each run completes. SQLite database synced to the bucket.
- For publication: export anonymized dataset subset to a public bucket or Zenodo/HuggingFace Datasets for reproducibility.

### 4.5 Context Window Management

A 25-30 turn conversation with canvas injection each turn will approach context limits. The framework must handle this:

- ido4shape's **PreCompact hook** already instructs it to save insights to canvas before context compression — this should work in SDK mode
- The simulation engine should monitor context usage via SDK metadata and log when compaction occurs
- Evaluation should account for post-compaction quality — does ido4shape maintain coherence after context compression?
- If context limits cause degradation, this is a valid finding about ido4shape, not a framework bug

### 4.6 Non-Determinism Strategy

LLM outputs vary between runs. The framework addresses this at multiple levels:

**Measurement:** Each scenario should be run **at minimum 3 times** to measure variance. Report scores as mean ± standard deviation across runs.

**Metrics (from Anthropic's guidance):**
- **pass@k** — probability of at least one success across k runs. Appropriate for: "can ido4shape produce a good spec for this scenario?"
- **pass^k** — probability of all k runs succeeding. Appropriate for: "does ido4shape reliably produce good specs for this scenario?"

**Persona seed control:** While LLM temperature can't be fully controlled, behavioral triggers provide deterministic checkpoints in the conversation that reduce divergence.

**Variance as signal:** High variance on a specific scenario category is itself a finding — it means ido4shape's quality is inconsistent in that area.

### 4.7 Cost Control and Guard Rails

An LLM-to-LLM conversation running unattended is a runaway cost risk. A stuck loop, an unexpectedly verbose model, or a persona that never triggers its exit condition can burn through budget silently. Guard rails operate at six levels, from innermost (single API call) to outermost (overnight batch).

#### Level 1: Per-Query Guards (SDK built-in)

The Agent SDK provides two hard limits per `query()` call (one turn of ido4shape responding):

- **`max_turns`** — caps the number of tool-use iterations ido4shape can do in a single response. A normal response might involve 3-5 tool calls (read canvas, update canvas, read a file, respond). Set to ~20 to allow complex responses but prevent infinite tool loops.
- **`max_budget_usd`** — hard dollar cap per query. If ido4shape's response exceeds this, the SDK stops and returns a result with `error_max_budget_usd`. Set to ~$0.50 for Sonnet, ~$2.00 for Opus per single query.

These are the innermost safety net. They prevent any single ido4shape response from running away.

#### Level 2: Per-Persona Guards (framework-managed)

The persona engine tracks cumulative cost across all turns for one persona's session:

- **Turn limit** — already in the scenario definition (`max_turns` per persona, typically 12-15). Hard stop.
- **Cumulative cost limit** — after each turn, the framework reads `total_cost_usd` from the SDK result and adds it to a running total. If the persona's cumulative cost exceeds a threshold (derived from the scenario's expected cost × 2), the persona exits early with reason `cost_limit`.
- **Stall detection** — if ido4shape's response for 3 consecutive turns is very short (< 100 characters) or very similar to previous responses (indicating a loop), force the persona to exit. A stuck conversation wastes both money and produces useless data.

#### Level 3: Per-Run Guards (framework-managed)

A run includes all personas for one scenario execution:

- **Run budget** — pre-computed from scenario definition: `sum(persona.max_turns × estimated_cost_per_turn) × 2.0 safety margin`. If the run's cumulative cost hits this, skip remaining personas, go directly to evaluation.
- **Run duration limit** — if a run exceeds a maximum wall-clock time (e.g., 60 minutes), kill it. Something is wrong — normal runs should complete in 15-30 minutes.
- **No-spec timeout** — if all personas have completed and no spec was produced, this is a valid outcome (ido4shape correctly determined understanding wasn't deep enough, or something went wrong). Don't retry — evaluate what happened.

#### Level 4: Per-Batch Guards (queue-managed)

A batch is a set of runs (e.g., "run all Tier 1 ablation for 4 scenarios × 3 reps = 72 runs"):

- **Batch budget** — hard dollar limit for the entire batch. The queue manager tracks cumulative spend across all runs. When the batch budget is 80% consumed, log a warning. At 100%, pause remaining runs.
- **Circuit breaker** — if 3 consecutive runs exceed their per-run budget (indicating a systematic problem, not a one-off), pause the entire batch. Something is wrong — a model update, an API issue, or a scenario bug. Don't keep spending money on broken runs.
- **Cost anomaly detection** — if a run's actual cost exceeds 3× its expected cost, flag it in the results and log a warning. Don't necessarily stop the batch (it could be a legitimately complex conversation), but make it visible.

#### Level 5: Session-Level / Daily Guards

For overnight or multi-day execution:

- **Daily spend limit** — configurable cap on total API spend per 24-hour period across all batches. When reached, all execution pauses until the next day or until manually resumed.
- **Notification on thresholds** — when daily spend hits 50%, 80%, and 100% of limit, write to a log file and optionally send a notification (email, Slack, or a simple file-based flag that a monitoring script can check).

#### Level 6: Pre-Execution Validation

Before spending any money:

- **Dry run mode** — execute the full batch plan without making API calls. Compute expected cost per run (turns × model pricing × estimated tokens), sum across the batch, and report: "This batch will run 72 simulations with an estimated cost of $133 ± $30. Proceed? [y/N]". This catches configuration errors (accidentally running everything on Opus instead of Sonnet, or a scenario with max_turns=100).
- **Tiered execution** — run the cheapest configuration first (Haiku) as a smoke test. If the scenario flow works (conversation progresses, spec is produced), then run the more expensive variants (Sonnet, Opus). This catches scenario design bugs before they're expensive.
- **Budget reservation** — before starting a batch, verify that the estimated cost fits within the daily spend limit. Don't start a $500 batch with a $200 daily limit — it'll get paused halfway and waste partial runs.

#### Graceful Degradation vs. Hard Kill

When a cost limit is hit, the framework should **degrade gracefully** rather than hard-kill:

1. **Turn budget exceeded:** Inject a "wrap up" instruction to the persona on the next turn: "We're running short on time. Let's synthesize what we have." This produces a natural ending and a partial (but evaluable) spec.
2. **Run budget exceeded with personas remaining:** Skip remaining personas, but still run evaluation on what was produced. A partial run still generates useful data about the turns that did complete.
3. **Batch budget exceeded:** Pause remaining runs, evaluate completed runs, produce a partial report. Never discard completed work.

Only hard-kill on truly stuck situations: infinite loops (stall detection), API errors that won't resolve, or process-level hangs (duration timeout).

#### Configuration

Cost control parameters should be configurable at multiple levels with inheritance (batch → run → persona → query), with more specific levels overriding more general ones:

```yaml
# Default cost control config
cost_control:
  daily_limit_usd: 100.00
  batch:
    budget_multiplier: 1.5      # 1.5x estimated cost
    circuit_breaker_threshold: 3 # consecutive over-budget runs
  run:
    budget_multiplier: 2.0      # 2x estimated cost per run
    max_duration_minutes: 60
  persona:
    budget_multiplier: 2.0      # 2x estimated cost per persona
    stall_detection_turns: 3    # consecutive similar responses
  query:
    max_turns: 20               # tool-use iterations per response
    max_budget_usd:             # per model
      opus-4-6: 2.00
      sonnet-4-6: 0.50
      haiku-4-5: 0.10
```

Scenario definitions can override these defaults for specific scenarios that are expected to be more expensive (e.g., complex multi-stakeholder scenarios with 3 personas and 40+ total turns).

---

## 5. Layer 3: Evaluation & Reporting

### 5.1 Three Types of Graders

Following Anthropic's evaluation guidance, use three complementary grader types:

**Code-based graders** (fast, objective, deterministic):
- Run `validate-spec` structural checks (heading patterns, metadata, dependency validation)
- Check canvas dimension progression (did dimensions advance from "not started"?)
- Count canvas updates per turn (responsiveness metric)
- Verify phase gate fired when expected
- Check for anti-pattern strings ("great question!", "let me help you")

**Model-based graders** (flexible, nuanced, for open-ended assessment):
- Four LLM-as-judge evaluators (see 5.2)
- Run on strong model (Opus) for reasoning quality
- Structured JSON output for aggregation

**Human graders** (gold standard, for calibration):
- Manual review of a sample of simulation transcripts + evaluator scores
- Used to calibrate model-based graders — are the scores meaningful?
- Applied during Phase 1 calibration, then periodically to prevent drift
- Not required for every run — sample-based

### 5.2 Four Evaluation Dimensions

Each dimension has a rubric with specific criteria scored 1-5. Evaluators run independently and in parallel. All four receive the conversation transcript; each receives additional context specific to its assessment.

#### Dimension A: Methodology Compliance

*Assesses: did ido4shape follow its own methodology?*

Input: transcript, canvas evolution (snapshots per turn), ido4shape's methodology rules

Criteria:
- **Canvas Responsiveness** — Did the canvas update within 1-2 turns of significant insights? (Compare canvas snapshots against conversation content)
- **Knowledge Dimension Coverage** — Were all six dimensions (Problem Depth, Solution Shape, Boundary Clarity, Risk Landscape, Dependency Logic, Quality Bar) meaningfully explored?
- **Phase Gate Respect** — Did ido4shape avoid premature synthesis? Did the phase gate block appropriately?
- **Character Compliance** — Did it follow soul.md character? (No anti-patterns, genuine opinions, intellectual curiosity, honest about uncertainty)
- **Stakeholder Awareness** — Did it brief new stakeholders appropriately? Flag missing perspectives? Attribute insights correctly?
- **Tension Management** — Did it detect tensions, surface them, hold them rather than prematurely resolving, offer resolution paths?

Evidence: evaluator must cite specific turn numbers for each score.

#### Dimension B: Information Traceability

*Assesses: is there fidelity between what was discussed and what ended up in the spec?*

Input: transcript, final spec, scenario's expected coverage, persona definitions (including hidden constraints)

Outputs:
- **Traceability matrix** — for each `must_appear` item: was it discussed? Is it in the spec? (TRACED / DISCUSSED_NOT_IN_SPEC / IN_SPEC_NOT_DISCUSSED / MISSING)
- **Scope violation check** — do any `must_not_appear` items appear in the spec?
- **Hidden constraint analysis** — for each hidden constraint: was it surfaced through probing? (PROBED_AND_FOUND / NOT_PROBED / PROBED_BUT_MISSED)
- **Hallucination check** — things in the spec that were never discussed (severity: MINOR inference / MAJOR invention)
- **Information loss check** — things discussed but missing from spec (severity: MINOR tangential / MAJOR core requirement)
- **Tension preservation** — were detected tensions reflected in the spec as open questions, decisions, or constraints?

#### Dimension C: Spec Quality

*Assesses: is the output spec artifact good?*

Input: final spec, strategic spec format rules, scenario context, validate-spec structural results (pre-computed)

Criteria:
- **Structural compliance** — from automated validate-spec (pass/fail + details)
- **Problem statement depth** — rich narrative from conversation vs. thin generic summary
- **Success condition specificity** — testable by two independent people? Specific to this project?
- **Dependency logic** — acyclic? Foundational before dependent? Cross-group identified?
- **Multi-stakeholder preservation** — can you tell who contributed what? Attribution present and accurate?
- **Cross-cutting concerns** — NFRs specific with rationale and numbers, not boilerplate?
- **Priority calibration** — must-have/should-have/nice-to-have defensible and aligned with stakeholder emphasis?
- **Scope discipline** — non-goals explicit? Constraints with rationale? Bounded appropriately?

#### Dimension D: Persona Realism (Meta-Assessment)

*Assesses: was the test itself valid?*

Input: persona definitions, transcript, hidden constraint state log, behavioral trigger log

Criteria:
- **Trait adherence** — did each persona behave according to defined traits? Or did the LLM default to being helpful and compliant?
- **Hidden constraint discipline** — did constraints stay hidden until probed? If leaked, the simulation's probing metric is invalid.
- **Behavioral trigger execution** — did triggers fire at the right moments and feel natural?
- **Conversational realism** — appropriate response lengths, natural tangents, realistic uncertainty?
- **Friction quality** — did the persona make ido4shape work for information? Were there genuine moments of disagreement or confusion?

**Critical rule:** If persona realism scores below 3.0, the entire simulation run should be flagged as potentially invalid. Evaluation findings from low-realism runs should not be used for ido4shape improvement decisions without manual review.

### 5.3 Standard Multi-Turn Metrics

In addition to the four custom evaluators, apply established multi-turn conversation metrics (potentially via DeepEval integration):

- **Conversation Completeness** — did ido4shape satisfy all user intentions across the conversation?
- **Knowledge Retention** — did ido4shape remember facts stated earlier? (Never re-ask something already provided)
- **Role Adherence** — did ido4shape maintain its specification partner role throughout?
- **Turn Relevancy** — was each response relevant to the conversation context?

These provide standardized benchmarks comparable across projects and frameworks.

### 5.4 Reporting

**Per-Scenario Report** includes:
- Summary: scenario name, personas used, turn counts, spec produced yes/no
- Scores per evaluation dimension with sub-dimension breakdown
- Weighted composite score
- Top issues with specific evidence (turn numbers, spec sections)
- Recommendations for ido4shape improvement
- Persona realism assessment with validity flag
- Operational metrics: duration, token usage, cost, context compaction events

**Cross-Scenario Aggregate Report** detects systematic patterns:
- Dimension scores averaged across all scenarios (e.g., "Risk Landscape consistently underexplored")
- Hidden constraint probing rates by constraint type (technical vs. compliance vs. budget)
- Character compliance trends across conversation length (does quality degrade in later turns?)
- Failure mode frequency (which types of failures occur most often?)
- Persona realism trends (which persona traits produce the most/least realistic behavior?)

**Version Comparison Report** (regression analysis):
- Side-by-side scores for two ido4shape versions on the same scenario suite
- Statistically significant improvements/regressions flagged (accounting for non-determinism)
- Specific capabilities that improved or degraded

---

## 6. Feedback Loop

Evaluation findings are useless unless they drive improvement. The feedback loop works at two levels:

### 6.1 Direct Improvement

Each simulation run produces specific, actionable findings:
- "soul.md anti-patterns appeared at turns 4 and 9" → strengthen anti-pattern guidance in create-spec skill
- "compliance constraints never probed" → add compliance probing guidance to creative-decomposition skill
- "information lost during synthesis" → investigate canvas-synthesizer agent instructions
- "canvas not updated for 5 turns" → strengthen canvas update frequency guidance

These map directly to changes in ido4shape's skills, agents, soul.md, or hooks.

### 6.2 Regression Protection

Once an issue is fixed, the scenario that exposed it becomes a **regression test**. The fix should improve the score on that specific dimension. If a future ido4shape change degrades the score, the regression is caught before release.

### 6.3 Scenario Evolution

As ido4shape improves, scenarios that consistently score 5/5 become less useful. The framework should:
- Graduate saturated scenarios to a lightweight regression suite (run less often, just verify no regression)
- Replace them with harder scenarios that target remaining weaknesses
- Track scenario difficulty ratings over time

---

## 7. E2E Pipeline Testing (Future)

The current framework tests ido4shape in isolation. The full pipeline is:

```
ido4shape → strategic spec → ido4 MCP decomposition → technical spec → ingestion → GitHub issues
```

E2E testing extends the framework by:
1. Taking the strategic spec produced by a simulation run
2. Feeding it to ido4 MCP's decomposition agent (also via Agent SDK or CLI)
3. Evaluating the technical spec output
4. Optionally running ingestion and validating the GitHub issues

This requires ido4 MCP to be testable via the Agent SDK. The feasibility depends on ido4 MCP's architecture — it needs codebase access, which means pointing it at a representative test codebase.

E2E evaluation adds a fifth dimension: **Pipeline Coherence** — does the strategic spec produce good technical tasks? Does context survive the handoff? This is deferred to Phase 4+.

---

## 8. Research Data Design

This section specifies what the framework must capture and support to keep the research option viable. These are design constraints, not optional features — they should be built into the framework from Phase 0, not retrofitted.

### 8.1 Data Provenance Requirements

Every simulation run must capture full provenance. Data that isn't recorded during simulation can never be recovered.

**Per API call (ido4shape, persona, evaluator):**
- Exact model identifier and version (e.g., `claude-opus-4-6-20250514`, not just "Opus")
- Temperature and any sampling parameters
- Full request payload (system prompt + messages sent)
- Full response object (not just extracted text — includes usage metadata, stop reason, latency)
- Timestamps (request sent, response received)
- Token counts (input tokens, output tokens, cache hits if applicable)

**Per turn:**
- Turn number, speaker ID, role
- Message content (both sides)
- Canvas diff (not just snapshot — what specifically changed between turn N and N+1)
- Which skills activated (if detectable from tool calls)
- Which hooks fired and their output
- Persona behavioral trigger state (which triggers evaluated, which fired)
- Hidden constraint state (revealed set, still-hidden set)

**Per simulation run:**
- Scenario definition (frozen copy, not reference — scenarios may evolve)
- ido4shape version (git commit hash)
- Framework version (git commit hash)
- Configuration variant ID (full, no-plugin, no-phase-gate, etc.)
- Working directory contents at start and end
- Total duration, total cost, context compaction events

**Storage format:** All raw data in structured JSON with a documented schema. Human-readable reports are derived views, not the primary data store. The raw data must support re-analysis without re-running simulations.

### 8.2 Ablation, Baseline, and Model Variant Support

The simulation engine must support **configuration variants** across three independent dimensions, allowing controlled experiments that isolate specific contributions.

#### Dimension 1: ido4shape Configuration (Ablation)

Each variant disables one ido4shape component to measure its contribution:

| Variant ID | Description | What it isolates |
|---|---|---|
| `full` | ido4shape with all features enabled | Production configuration (the thing we're actually testing) |
| `no-plugin` | Vanilla Claude, no ido4shape plugin loaded. Same persona, same working directory. | ido4shape's total contribution — "Claude" vs. "Claude with ido4shape" |
| `no-phase-gate` | ido4shape loaded but PreToolUse hook disabled | Phase gate's contribution to preventing premature synthesis |
| `no-canvas-injection` | ido4shape loaded but UserPromptSubmit hook disabled | Canvas context injection's contribution to conversation coherence and information retention |
| `no-soul` | ido4shape loaded but soul.md reference removed from create-spec skill | Character design's contribution to conversation quality |
| `no-hooks` | ido4shape loaded but all hooks disabled | Combined hook system contribution |

#### Dimension 2: Model (Capability Level)

The same scenario and configuration can be run on different Claude models to measure how model capability interacts with methodology:

| Model ID | Approximate cost (ido4shape side) | Role |
|---|---|---|
| `opus-4-6` | ~$3.00/run | Gold standard. Key comparison runs, reference scores. |
| `sonnet-4-6` | ~$0.60/run | Workhorse. Bulk ablation and testing. 5x cheaper than Opus. |
| `haiku-4-5` | ~$0.06/run | Stress test. Does the methodology rescue a weaker model? 50x cheaper than Opus. |

The Agent SDK supports model selection. All Claude models support the same plugin machinery (hooks, skills, agents), so ablation variants work identically across models.

**Key research questions from the model dimension:**
- Does ido4shape's methodology help more with weaker models? (Larger effect size on Haiku than Opus would mean methodology compensates for model capability.)
- Can ido4shape + Sonnet match or beat vanilla Opus? (If yes: structured methodology is more valuable than raw model intelligence for spec work. Strong publishable finding.)
- Does the phase gate matter more on weaker models? (Model × ablation interaction effects.)
- At what model capability level does ido4shape stop adding value? (Ceiling effect analysis.)

#### Dimension 3: Persona Model (Meta-Validation)

The persona LLM model affects simulation validity, not ido4shape quality. This dimension validates the testing methodology itself:

| Persona model | Cost | Role |
|---|---|---|
| `haiku-4-5` (default) | ~$0.05/scenario | Standard for all testing |
| `sonnet-4-6` | ~$0.50/scenario | Validation: does persona quality affect results? |

If ido4shape scores differ significantly between Haiku and Sonnet personas, the persona model is a confound and must be controlled for. If scores are stable, Haiku is sufficient.

#### Non-Claude Models (Future, Track 2)

The Agent SDK only supports Claude models. Testing with non-Claude models (Llama, Mistral, GPT, Gemini) requires **extracting ido4shape's methodology from the plugin format into model-agnostic prompts:**
- soul.md character → system prompt
- Creative decomposition methodology → system prompt instructions
- Canvas management → function-calling-based file operations
- Phase gate → prompt instruction ("do not synthesize until all dimensions are explored")

This tests **methodology portability** but not the plugin machinery. It's a separate engineering effort — a simpler, prompt-based simulation path alongside the SDK-based path. Defer to Phase 4+ unless there's a specific reason to prioritize earlier.

Candidate non-Claude models: Llama 3 (via Ollama, free), Mistral Large (API), GPT-4o (OpenAI API), Gemini 2.0 (Google API). Running locally via Ollama is essentially free for high-repetition experiments.

#### Smart Execution Matrix

Running the full cross-product of all dimensions (6 configs × 3 models × 2 persona models = 36 cells) per scenario is unnecessary. Use a **smart matrix** that answers the most important questions with the fewest runs:

**Tier 1 — Full ablation on Sonnet (answers: which components matter?)**
All 6 config variants × Sonnet × Haiku persona × N reps

**Tier 2 — Cross-model baseline (answers: does model capability interact with methodology?)**
`full` + `no-plugin` × all 3 models × Haiku persona × N reps

**Tier 3 — Persona validation (answers: is the testing methodology sound?)**
`full` × Sonnet × Haiku persona + Sonnet persona × small N

**Tier 4 (future) — Targeted deep dives**
Specific ablation × model combinations suggested by Tier 1-2 findings

This gives you:
- Tier 1: 6 cells (component contribution on Sonnet)
- Tier 2: 6 cells (model × methodology interaction)
- Tier 3: 2 cells (persona validation)
- Total: 14 cells per scenario (vs. 36 for full cross-product)

The implementation must make it straightforward to define custom variants by specifying which hooks to disable, which skill references to remove, which model to use, or whether to load the plugin at all. Each variant produces the same data structure, enabling direct comparison.

**Batch execution support:**

```
scenario: notification-system
tier: 1  # full ablation on Sonnet
model: sonnet-4-6
variants: [full, no-plugin, no-phase-gate, no-canvas-injection, no-soul, no-hooks]
persona_model: haiku-4-5
repetitions: 5
→ 30 total simulation runs
→ all results tagged with (scenario, variant, model, persona_model, repetition)
```

### 8.3 Statistical Analysis Requirements

The framework should produce data that supports standard statistical analysis:

**Per-condition aggregation:**
- Mean, standard deviation, confidence intervals for each evaluation dimension
- Effect sizes (Cohen's d or similar) when comparing variants
- Statistical significance testing (paired tests when comparing variants on the same scenario)

**Cross-condition analysis:**
- Scenario × config variant interaction effects (does the phase gate matter more for some project types?)
- Model × config variant interaction effects (does the phase gate matter more on weaker models?)
- Model × methodology effect sizes (does ido4shape's contribution grow as model capability decreases?)
- Dimension correlation (do methodology compliance and spec quality co-vary?)
- Temporal analysis within conversations (does quality degrade in later turns? At what turn count? Does this differ by model?)

The framework doesn't need to perform all statistical analysis itself — exporting clean, structured data that loads into standard tools (pandas, R, Jupyter) is sufficient. But the data schema must support these analyses without transformation.

### 8.4 Human Evaluation Protocol

LLM-as-judge scores require human validation for research credibility.

**Calibration study (one-time, during Phase 1-2):**
- Select a sample of 10-15 simulation transcripts + their automated evaluator scores
- Recruit 3-5 human raters (PMs, engineers, or requirements engineering practitioners)
- Each rater independently scores the same transcripts using the same rubric dimensions
- Compute inter-rater reliability (Fleiss' kappa for multiple raters)
- Compute LLM-human agreement (Cohen's kappa between each evaluator and human consensus)
- Document the calibration results — this becomes part of any paper's methodology section

**Ongoing validation (periodic):**
- After rubric changes or ido4shape major versions, re-validate a sample
- Track calibration drift over time

**Rater recruitment:** The initial calibration can use Bogdan + 2-3 colleagues or collaborators. For publication, you may need a broader panel and formal IRB approval depending on the venue.

### 8.5 Research Data Management

**Versioning:** All raw simulation data, scenario definitions, rubrics, and evaluation results should be version-controlled. Outputs should be in a separate, possibly private, data repository (not in the ido4-simulate code repo — data volumes will be large).

**Retention:** No simulation data should be deleted. Even failed or low-quality runs contain useful information (failure mode analysis, persona validity assessment). Mark runs as invalid rather than deleting them.

**Schema evolution:** If the data schema changes, maintain backward compatibility or provide migration scripts. Analysis across time periods requires consistent data structure.

**Data sharing:** If publishing, the dataset (scenario definitions, anonymized transcripts, evaluation scores) should be shareable as a research artifact. Design the data format with this in mind — no hardcoded local paths, no sensitive API keys in captured payloads.

---

## 9. Technical Feasibility

### 9.1 Confirmed

| Component | Evidence |
|---|---|
| Plugin loading in Agent SDK | `plugins: [{"type": "local", "path": "..."}]` — documented with Python examples |
| Multi-turn sessions | `ClaudeSDKClient` handles session state across `query()` calls |
| Session continuation for multi-persona | `continue_conversation=True` resumes most recent session |
| Transcript capture | `get_session_messages()` reads full conversation from JSONL |
| Hook execution in SDK | SessionStart, UserPromptSubmit, PreToolUse, Stop all supported |
| Canvas in working directory | `find-workspace.sh` falls through to `pwd` in CLI mode |
| Phase gate on Write | `phase-gate.sh` reads canvas, no Cowork dependency |
| Skill auto-triggering | Description-based matching works without slash commands |
| Agent definitions from plugin | Plugin `agents/` directory loaded with plugin |

### 9.2 Needs Validation (Phase 0 Spike)

| Question | How to validate |
|---|---|
| Does `${CLAUDE_PLUGIN_ROOT}` resolve in SDK hooks? | Load ido4shape, check if SessionStart hook fires and creates workspace |
| Does `${CLAUDE_SKILL_DIR}` resolve in skill bodies? | Trigger create-spec via description matching, check if soul.md is read |
| Does `continue_conversation` work across separate `ClaudeSDKClient` instances? | Two sequential persona clients in same directory |
| Does UserPromptSubmit hook fire for each `query()` in the SDK? | Send two messages, check canvas state injection in second |
| Does agent model routing work? | Trigger synthesis, check if canvas-synthesizer uses Opus |
| What's the context budget for a 25-30 turn conversation with canvas injection? | Run a full-length scenario and monitor context usage |

### 9.3 Known Gaps (Not Addressable)

| Gap | Impact | Mitigation |
|---|---|---|
| Cowork-specific testing (injection defense, VM sandbox) | Cowork-specific bugs won't be caught | Manual Cowork testing remains necessary |
| Slash command invocation | Can't invoke `/ido4shape:create-spec` directly | Skills trigger on description matching — persona phrases intent naturally |
| Cowork UI experience | Plugin installation, working folder selection untested | Manual testing only |

---

## 10. Implementation Plan

### Phase 0: Validation Spike
**Goal:** Confirm the Agent SDK can run ido4shape end-to-end. Establish data schema. Verify model selection works.
- Install `claude-agent-sdk`, write minimal script
- Validate all items in section 9.2
- Verify full data provenance capture works (model IDs, token counts, timestamps from response metadata)
- Test on **Sonnet** (the workhorse model) — confirm ido4shape plugin loads and hooks fire
- Test the `no-plugin` variant on Sonnet — confirms baseline capability works
- Verify model selection parameter works (run one message on Opus and one on Haiku to confirm switching)
- **Output:** Go/no-go decision for the full framework. Established data capture schema. Confirmed model switching.
- **Decision point:** If `${CLAUDE_PLUGIN_ROOT}` or hooks don't work in SDK, the entire plugin-based approach fails. Fallback: extract ido4shape's methodology into system prompts (tests methodology but not plugin machinery — which becomes the Track 2 approach by default).
- **Research note:** Establish the data schema from day one. Every spike run should produce the same structured JSON output as a production run — no "we'll add provenance later."

### Phase 1: Minimal Simulation + Calibration
**Goal:** One scenario, one persona, end-to-end on Sonnet. Calibrate evaluation against manual testing. First baseline comparison.
**Prerequisite:** At least one manual ido4shape test completed (provides calibration baseline).
- Single-persona simulation with basic trait injection (no behavioral triggers yet)
- Full data capture: transcript, canvas snapshots, canvas diffs, tool calls, provenance metadata
- Code-based graders (validate-spec, anti-pattern scan, canvas update frequency)
- One model-based evaluator (Spec Quality — most concrete)
- Run **Tier 1** (all 6 config variants on Sonnet) for one scenario — first ablation data
- Run **Tier 2** (`full` + `no-plugin` on Opus + Haiku) for same scenario — first cross-model data
- **Human calibration:** Bogdan manually reviews transcript + evaluator scores. Are scores meaningful? What did the evaluator miss? Document calibration notes formally in `calibration/` directory.
- Tune rubrics based on calibration
- **Output:** First calibrated simulation. Rubric v1. First ablation comparison. First cross-model comparison. Early signal on whether model matters.

### Phase 2: Full Evaluation + Multi-Persona
**Goal:** All four evaluators, multi-stakeholder scenarios, behavioral triggers. Broader model comparison.
- Multi-persona support (sequential on same workspace)
- Behavioral triggers and hidden constraint tracking
- All four LLM-as-judge evaluators
- Standard multi-turn metrics (evaluate DeepEval integration)
- Per-scenario reporting
- 3-4 scenarios across different categories
- **Tier 1** (full ablation on Sonnet) × 3 reps per scenario
- **Tier 2** (cross-model baseline: `full` + `no-plugin` × Opus/Sonnet/Haiku) × 3 reps per scenario
- **Tier 3** (persona validation: Haiku vs. Sonnet persona) on 1 scenario × 3 reps
- **Human calibration round 2:** Recruit 2-3 additional raters. Compute inter-rater reliability (Cohen's/Fleiss' kappa). Document formally.
- **Output:** Multi-scenario test suite. First inter-rater reliability numbers. Ablation data across scenarios. Cross-model findings: preliminary answer to "can ido4shape + Sonnet match vanilla Opus?"

### Phase 3: Scale + Patterns + Regression
**Goal:** Systematic quality assessment, pattern detection, version comparison, research data accumulation.
- 8-10 scenarios across all categories
- **Tier 1** (full ablation on Sonnet) × 5 reps per scenario
- **Tier 2** (cross-model baseline) × 5 reps per scenario
- Cross-scenario aggregate reporting with pattern detection
- Model × methodology interaction analysis (does ido4shape help more on weaker models?)
- Version comparison capability (run same suite against two ido4shape versions)
- Persona trait library with composable traits
- Scenario variations (same project, different persona combinations)
- Statistical analysis: effect sizes (Cohen's d), significance tests, confidence intervals, interaction effects
- Export data in analysis-ready format (CSV/parquet for pandas/R/Jupyter)
- **Output:** Regression test suite. Research-grade dataset. Findings on: methodology contribution (full vs. no-plugin), component contribution (ablation), model × methodology interaction.

### Phase 4: CI + E2E + Research Readiness (Future)
**Goal:** Automated quality gates, pipeline testing, publication readiness, non-Claude model exploration.
- Select 3-4 representative scenarios as CI regression tests (Sonnet, `full` + `no-plugin`, 3 reps)
- Integrate into GitHub Actions (separate workflow, longer timeout)
- Fail the build if weighted score drops below threshold on regression scenarios
- Begin E2E pipeline testing (ido4shape → ido4 MCP) if ido4 MCP supports SDK execution
- **Track 2 exploration:** Extract methodology into model-agnostic prompts. Test with Llama (Ollama, free), GPT, Gemini. Compare methodology portability across model families.
- Increase repetitions to 30 for key conditions (research-grade statistical power)
- Finalize human evaluation panel for publication (broader rater recruitment, formal IRB protocol if required by venue)
- Prepare shareable dataset artifact (anonymized, documented schema, no local paths or API keys in captured payloads)
- **Output:** Automated quality gates. E2E pipeline coverage. Cross-model-family data (Track 2). Dataset and analysis ready for paper drafting.

---

## 11. Cost Model

### 11.1 Anthropic API Pricing (as of March 2026)

Source: [platform.claude.com/docs/en/about-claude/pricing](https://platform.claude.com/docs/en/about-claude/pricing)

**Standard API pricing (per million tokens):**

| Model | Input | Output | Cache Read (hit) | Cache Write (5m) |
|---|---|---|---|---|
| **Opus 4.6** | $5.00 | $25.00 | $0.50 | $6.25 |
| **Sonnet 4.6** | $3.00 | $15.00 | $0.30 | $3.75 |
| **Haiku 4.5** | $1.00 | $5.00 | $0.10 | $1.25 |

**Batch API pricing (50% discount, asynchronous processing):**

| Model | Input | Output |
|---|---|---|
| **Opus 4.6** | $2.50 | $12.50 |
| **Sonnet 4.6** | $1.50 | $7.50 |
| **Haiku 4.5** | $0.50 | $2.50 |

**Key pricing facts that affect our cost model:**
- Output tokens are **5× more expensive** than input tokens across all models
- Cache hits are **10× cheaper** than fresh input (0.1× base price)
- The Agent SDK uses **automatic prompt caching** — system prompts, plugin context, and conversation history get cached without manual configuration
- The **Batch API** gives 50% discount for asynchronous processing — usable for evaluators (post-hoc, non-interactive) but NOT for simulation turns (interactive, sequential)
- Tool use adds overhead: ~346 tokens system prompt + tool definitions per request
- No surcharge for the Agent SDK itself — it's billed as standard API usage

### 11.2 Token Usage Estimates Per Simulation Turn

A single turn in the simulation involves multiple components:

**ido4shape side (via Agent SDK):**

One "turn" from the user's perspective (persona sends message, ido4shape responds) may involve 3-5 internal API iterations in the agent loop:
1. Receive message + canvas injection → decide what to do
2. Read canvas file (tool call) → process content
3. Formulate response + update canvas (tool call)
4. Return response to user

Each internal iteration sends the full conversation context. However, the Agent SDK's automatic caching means most of this context is served from cache after the first iteration.

Estimated tokens per turn (averaged across a 25-turn conversation):

| Component | Input tokens | Output tokens | Notes |
|---|---|---|---|
| System prompt + plugin context | ~8,000 (first turn only) | — | Cached after first turn |
| Conversation history | ~500 (turn 1) to ~15,000 (turn 25) | — | Grows linearly, mostly cached |
| Canvas injection (hook) | ~200-500 | — | Grows as canvas fills |
| User message | ~100-300 | — | |
| ido4shape response | — | ~500-2,000 | The expensive part (5× input rate) |
| Tool calls (read/write canvas, files) | ~1,000-3,000 combined | ~500-1,000 combined | Per internal agent loop iteration |

**Estimated totals for a full 25-turn conversation (ido4shape side):**

| Metric | Without caching (worst case) | With caching (realistic) |
|---|---|---|
| Total input tokens | ~500K | ~50K fresh + ~75K cache write + ~375K cache read |
| Total output tokens | ~30K | ~30K (output is never cached) |

**Persona side (Haiku 4.5):**

The persona LLM is a simple API call (no agent loop, no tools):
- Input per turn: system prompt (~500 tokens) + conversation history (~200-600 tokens growing) + instruction (~50 tokens)
- Output per turn: ~100-300 tokens
- Total over 25 turns: ~75K input tokens, ~5K output tokens

**Evaluator side (Opus 4.6, can use Batch API):**

Each evaluator is a single API call with:
- Rubric: ~1,000 tokens
- Transcript: ~15,000 tokens
- Additional context (canvas evolution, spec, scenario): ~5,000-15,000 tokens
- Total input per evaluator: ~20,000-30,000 tokens
- Output per evaluator: ~2,000-3,000 tokens

4 evaluators total: ~100K input tokens, ~10K output tokens.

### 11.3 Cost Per Run (Realistic Estimates)

**Simulation (ido4shape) — with automatic caching:**

| Model | Fresh input cost | Cache write cost | Cache read cost | Output cost | **Total** |
|---|---|---|---|---|---|
| Opus 4.6 | 50K × $5/M = $0.25 | 75K × $6.25/M = $0.47 | 375K × $0.50/M = $0.19 | 30K × $25/M = $0.75 | **~$1.66** |
| Sonnet 4.6 | 50K × $3/M = $0.15 | 75K × $3.75/M = $0.28 | 375K × $0.30/M = $0.11 | 30K × $15/M = $0.45 | **~$0.99** |
| Haiku 4.5 | 50K × $1/M = $0.05 | 75K × $1.25/M = $0.09 | 375K × $0.10/M = $0.04 | 30K × $5/M = $0.15 | **~$0.33** |

**Persona (Haiku 4.5):**
75K × $1/M + 5K × $5/M = $0.075 + $0.025 = **~$0.10**

**Evaluation (Opus 4.6 — Standard API vs. Batch API):**

| API mode | Input cost | Output cost | **Total (4 evaluators)** |
|---|---|---|---|
| Standard | 100K × $5/M = $0.50 | 10K × $25/M = $0.25 | **~$0.75** |
| **Batch (recommended)** | 100K × $2.50/M = $0.25 | 10K × $12.50/M = $0.125 | **~$0.38** |

Evaluators don't need real-time results — using the Batch API halves evaluation cost with no functional impact.

**Total per run (25 turns, 2 personas, with caching, evaluators on Batch):**

| Simulation model | ido4shape | Persona | Evaluation | **Total** |
|---|---|---|---|---|
| **Opus 4.6** | $1.66 | $0.10 | $0.38 | **~$2.14** |
| **Sonnet 4.6** | $0.99 | $0.10 | $0.38 | **~$1.47** |
| **Haiku 4.5** | $0.33 | $0.10 | $0.38 | **~$0.81** |

**Important caveats:**
- Cache effectiveness varies. The 80% cache hit rate assumed above is optimistic for early turns and realistic for later turns. Actual costs may be 20-40% higher if caching is less effective.
- Tool-heavy turns (ido4shape reads many files, updates multiple workspace files) increase token counts beyond these estimates.
- Context compaction (PreCompact hook) changes the token pattern — after compaction, subsequent turns lose cache benefits on the compacted content.
- The Agent SDK may add overhead not captured here (internal system prompts, tool definitions).

**Conservative estimate (1.4× realistic):**

| Simulation model | Conservative total per run |
|---|---|
| Opus 4.6 | **~$3.00** |
| Sonnet 4.6 | **~$2.06** |
| Haiku 4.5 | **~$1.13** |

Use the conservative estimates for budget planning. Use the realistic estimates for cost-benefit analysis.

### 11.4 Cost Optimization Strategies

1. **Sonnet as workhorse** — run bulk ablation on Sonnet (Tier 1), reserve Opus for cross-model comparison only (Tier 2). Saves 40% vs. all-Opus execution.
2. **Batch API for evaluators** — evaluators are non-interactive post-hoc analysis. Batch API saves 50% on evaluation with no functional impact. The 4 evaluators per run become $0.38 instead of $0.75.
3. **Haiku smoke tests** — before running expensive Sonnet/Opus ablation, run the scenario once on Haiku to verify the conversation flow works. Catches scenario design bugs for $0.81 instead of $2.06.
4. **Cache warming** — the Agent SDK caches automatically, but the first turn of each run pays full input price for the system prompt and plugin context. Running multiple repetitions of the same scenario benefits from cross-run cache hits if runs happen within the 5-minute cache window.
5. **Shorter scenarios for development** — while debugging the framework, use 10-turn scenarios instead of 25-turn. Reduces cost proportionally.
6. **Selective evaluation** — for quick iteration during development, run only Evaluator C (spec quality) instead of all four. Run all four for formal assessments only.

### 11.5 Scaling by Phase (Conservative Estimates)

| Phase | What's running | Runs | Est. cost |
|---|---|---|---|
| Phase 0 (spike) | 1 scenario: `full` + `no-plugin` on Sonnet, 1 rep each | 2 | **~$4** |
| Phase 1 (calibration) | 1 scenario: Tier 1 (6 × Sonnet) + Tier 2 (2 × Opus + 2 × Haiku), 1 rep | 10 | **~$19** |
| Phase 2 (full eval) | 4 scenarios × 14 cells × 3 reps | 168 | **~$290** |
| Phase 3 (full suite) | 10 scenarios × 14 cells × 5 reps | 700 | **~$1,070** |
| Weekly regression | 4 scenarios × 2 variants × Sonnet × 3 reps | 24 | **~$50/week (~$200/month)** |

**Research-grade run** (Phase 3+, for paper, conservative):
- Tier 1 (full ablation on Sonnet): 10 × 6 × 30 = 1,800 runs @ ~$2.06 = **~$3,708**
- Tier 2 (cross-model baseline): 10 × 2 × 3 models × 30 reps = 1,800 runs @ mixed = **~$2,340**
- Tier 3 (persona validation): 10 × 2 × 5 = 100 runs @ ~$2.06 = **~$206**
- **Total research-grade: ~$6,254**

### 11.6 Funding and Credit Opportunities

The research-grade run (~$6K) can potentially be offset through Anthropic's programs or direct outreach:

**Formal programs (partial fit):**
- [AI for Science Program](https://www.anthropic.com/news/ai-for-science-program) — up to $20K in API credits for academic/nonprofit researchers. Targets life sciences primarily, but software engineering research is not excluded. Application-based.
- [External Researcher Access Program](https://support.claude.com/en/articles/9125743-what-is-the-external-researcher-access-program) — free API credits for AI safety/alignment research. Agent evaluation and reliability is adjacent to this.
- [Claude for Open Source](https://claude.com/contact-sales/claude-for-oss) — free Max plan for major OSS maintainers (5K+ stars threshold). ido4shape doesn't qualify yet but may as the ecosystem grows.

**Direct outreach (strongest angle):**

This work has clear value to Anthropic's ecosystem:
- ido4shape is an open-source Claude Code/Cowork plugin — it makes the platform more valuable to users
- The research produces quantitative data about Claude's specification capabilities across model tiers — data Anthropic's product and marketing teams can reference
- The simulation framework is an advanced Agent SDK reference implementation (plugins, hooks, multi-turn, multi-model)
- Ablation findings validate (or challenge) Anthropic's design decisions around caching, tool use, and agent architecture

A direct, well-documented request to Anthropic's developer relations or plugin team — with the research plan attached — is more likely to succeed than fitting into a formal program designed for a different purpose. The ask is modest ($5-6K) relative to the data and ecosystem value produced.

**Action item:** Draft outreach after Phase 0 validates the technical approach. A working spike demo + the research plan is more compelling than the plan alone.

### 11.7 Notes

- All estimates use March 2026 pricing. Recompute before committing to research-grade runs.
- Failed/stuck runs add to cost. The cost control guard rails (section 4.7) limit this but don't eliminate it.
- Human calibration time is not monetized here but is significant (Bogdan's time + rater recruitment for publication).
- Non-Claude model testing (Track 2) is separate: free for Ollama/local, varies for hosted APIs.

---

## 12. Repository Structure

```
ido4-simulate/
├── README.md
├── pyproject.toml
├── scenarios/                    # Scenario definitions (YAML)
│   ├── baseline-notification.yaml
│   ├── multi-stakeholder-notification.yaml
│   ├── vague-founder-marketplace.yaml
│   └── ...
├── personas/
│   └── traits/                   # Reusable persona trait definitions
├── evaluators/
│   ├── rubrics/                  # Evaluation rubrics (markdown, not code)
│   │   ├── methodology.md
│   │   ├── traceability.md
│   │   ├── spec-quality.md
│   │   └── persona-realism.md
│   └── ...                       # Evaluator implementations
├── variants/
│   ├── configs/                  # ido4shape configuration variants
│   │   ├── full.yaml             # Default: all features enabled
│   │   ├── no-plugin.yaml        # Baseline: vanilla Claude
│   │   ├── no-phase-gate.yaml    # Ablation: phase gate disabled
│   │   ├── no-canvas-injection.yaml  # Ablation: UserPromptSubmit hook disabled
│   │   ├── no-soul.yaml          # Ablation: soul.md reference removed
│   │   └── no-hooks.yaml         # Ablation: all hooks disabled
│   ├── models/                   # Model variant definitions
│   │   ├── opus-4-6.yaml
│   │   ├── sonnet-4-6.yaml
│   │   └── haiku-4-5.yaml
│   └── tiers/                    # Pre-defined execution matrices
│       ├── tier-1-ablation.yaml  # Full ablation on Sonnet
│       ├── tier-2-crossmodel.yaml  # full + no-plugin × all models
│       └── tier-3-persona.yaml   # Persona model validation
├── src/                          # Simulation engine, persona engine, capture, reporting
├── schemas/                      # JSON schemas for data output format (versioned)
│   └── run-output-v1.json
├── outputs/                      # Simulation results (gitignored, or separate data repo)
│   └── {scenario-id}/
│       └── {variant}-{rep}-{timestamp}/
│           ├── .ido4shape/       # Workspace state
│           ├── .simulation/      # Captured data (transcript, canvas snapshots, diffs, triggers)
│           ├── provenance.json   # Full provenance: model IDs, versions, hashes, config
│           ├── raw-messages/     # Full API request/response objects per turn
│           ├── *-spec.md         # Produced spec (if any)
│           ├── evaluation.json   # Evaluator results (structured, machine-readable)
│           └── report.md         # Human-readable report
├── calibration/                  # Human calibration notes, inter-rater data, rubric tuning history
├── baselines/                    # Saved baseline results for regression comparison
├── analysis/                     # Jupyter notebooks / R scripts for research analysis
│   ├── ablation-analysis.ipynb
│   ├── traceability-study.ipynb
│   └── cross-scenario-patterns.ipynb
└── scripts/                      # CLI entry points (run-scenario, run-suite, run-ablation-matrix)
```

---

## 13. Open Questions

### Design Decisions

1. **DeepEval integration vs. custom evaluators:** Should we use DeepEval's built-in multi-turn metrics (conversation completeness, knowledge retention, role adherence) as the standard evaluation backbone, and only build custom evaluators for domain-specific dimensions (methodology compliance, traceability)? Or build everything custom for full control?

2. **Persona model choice:** Haiku is cheapest but may not produce realistic enough personas. Should some persona types (technically dominant architect, adversarial stakeholder) use Sonnet for more convincing behavior? This doubles the persona cost but may be necessary for high-friction scenarios.

3. **Evaluation consistency:** LLM-as-judge scores vary between runs. Options: (a) run each evaluator 3× and average (triples evaluation cost), (b) use temperature 0 for evaluators (reduces but doesn't eliminate variance), (c) accept variance and report confidence intervals.

4. **Session handoff for multi-persona:** When the second persona starts, ido4shape should recognize it's a different stakeholder. Should the persona explicitly introduce themselves? Or should the scenario simulate a "moderator" message like "Marcus the architect is joining the conversation"?

### Technical Unknowns

5. **Phase 0 blockers:** If `${CLAUDE_PLUGIN_ROOT}` doesn't resolve in SDK mode, the entire plugin-based approach fails. Fallback: extract ido4shape's methodology into system prompts and test that (tests methodology but not plugin machinery).

6. **Context window limits:** A 30-turn conversation may trigger context compaction. Does ido4shape's PreCompact hook behave correctly? Does the persona engine need to handle a mid-conversation "summary" from ido4shape?

### Process Questions

7. **Calibration cadence:** How often should human calibration be performed? After every rubric change? After every ido4shape release? Quarterly?

8. **Scenario retirement:** When does a scenario stop being useful? When it consistently scores 5/5 across multiple ido4shape versions? What replaces it?

9. **Failure investigation workflow:** When a simulation produces a low score, what's the process? Read the transcript manually? File an ido4shape issue? Both?

### Research Questions

10. **Publication timeline:** When is there "enough" data? Minimum viable paper likely needs: 5+ scenarios × 3+ variants × 30 reps = 450+ runs, plus human calibration study. This is achievable in Phase 3 but requires planning.

11. **IRB requirements:** If recruiting external raters (beyond Bogdan and close collaborators), some venues require Institutional Review Board approval for human subjects research. Investigate early if targeting CHI or CSCW.

12. **Baseline fairness:** The `no-plugin` baseline gives vanilla Claude the same persona messages but no methodology guidance. Is this a fair comparison? Should there be an intermediate baseline where Claude gets a simple "help me create a spec" system prompt without the full ido4shape plugin? This affects the strength of claims about ido4shape's contribution.

13. **Synthetic persona validity claims:** Any paper must address the limitation that synthetic personas are not real stakeholders. How strongly can we generalize from synthetic conversations to real human conversations? The PersonaCite and SimAB literature provides framing, but this remains a limitation to discuss honestly.

---

## 14. Success Criteria

### Framework Success (Testing)

How do we know ido4-simulate works as a testing tool?

1. **Phase 0 success:** Agent SDK loads ido4shape, hooks fire, canvas is created, multi-turn conversation completes. Data capture schema produces complete provenance. `no-plugin` baseline runs successfully.
2. **Phase 1 success:** Simulation run produces scores that correlate with Bogdan's manual assessment of the same scenario. If the evaluators score something 4/5 that Bogdan would score 2/5 (or vice versa), the rubrics need tuning.
3. **Phase 2 success:** Framework finds at least one genuine issue in ido4shape that wasn't previously known. (Not a false positive, not a persona artifact — a real methodology or quality issue.) Inter-rater reliability between LLM evaluators and human raters achieves Cohen's kappa ≥ 0.6 (moderate agreement).
4. **Phase 3 success:** A change to ido4shape that improves one scenario's score doesn't degrade other scenarios' scores (regression detection works). Cross-scenario patterns produce actionable improvement themes.

### Research Success (Publication Readiness)

How do we know the data supports a publishable paper?

5. **Ablation significance:** At least two ablation variants show statistically significant differences from the `full` configuration (p < 0.05 with appropriate correction for multiple comparisons). This proves ido4shape's design decisions have measurable impact.
6. **Baseline separation:** The `full` configuration consistently outperforms the `no-plugin` baseline with meaningful effect size (Cohen's d ≥ 0.5) across multiple scenario categories. This is the core claim: ido4shape's methodology produces better specs than unguided Claude.
7. **Human validation:** Inter-rater reliability among human evaluators achieves Fleiss' kappa ≥ 0.6. LLM-human agreement achieves Cohen's kappa ≥ 0.6. This validates the evaluation methodology.
8. **Reproducibility:** Same scenario, same variant, different runs produce scores within ±0.5 standard deviations of the mean. High variance scenarios are identified and explained.
9. **Dataset completeness:** All runs have full provenance, all raw data is recoverable, data schema is documented, and the dataset can be shared without exposing API keys or local paths.

---

## References

- [Claude Agent SDK — Plugins](https://platform.claude.com/docs/en/agent-sdk/plugins) — plugin loading in SDK
- [Claude Agent SDK — Sessions](https://platform.claude.com/docs/en/agent-sdk/sessions) — multi-turn session management
- [Anthropic: Demystifying Evals for AI Agents](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents) — evaluation methodology guidance
- [DeepEval](https://github.com/confident-ai/deepeval) — open-source multi-turn evaluation framework
- [Promptfoo — Simulated User](https://www.promptfoo.dev/docs/providers/simulated-user/) — synthetic user testing patterns
- [Confident AI: Multi-Turn LLM Evaluation in 2026](https://www.confident-ai.com/blog/multi-turn-llm-evaluation-in-2026) — standard multi-turn metrics
- [PersonaCite](https://arxiv.org/html/2601.22288v1) — grounded synthetic personas with source attribution
- [IntellAgent](https://arxiv.org/html/2501.11067v1) — multi-agent evaluation framework
- [Maxim AI — Agent Simulation](https://www.getmaxim.ai/products/agent-simulation-evaluation) — commercial reference for CI/CD integration
