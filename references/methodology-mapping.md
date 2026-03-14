# Methodology Mapping Reference

ido4shape produces methodology-agnostic artifacts. ido4 MCP applies methodology mapping at ingestion time through three built-in profiles. This reference documents how artifact concepts map to each methodology so the agent can make informed decisions about metadata values — but ido4shape NEVER asks the user which methodology they're using.

## Mapping Table

| Artifact Concept | Hydro (Wave-Based) | Scrum (Sprint-Based) | Shape Up (Betting) |
|-----------------|-------|-------|----------|
| Group | Epic | Feature group | Bet |
| Group size | — | — | Appetite (S/M/L/XL) |
| Task | Task (issue) | Story / Spike | Scope |
| Task effort S | Small | 1 point | — |
| Task effort M | Medium | 3 points | — |
| Task effort L | Large | 5 points | — |
| Task effort XL | Large | 8 points | — |
| Task risk low | Low | — | — |
| Task risk medium | Medium | — | — |
| Task risk high | High | Spike candidate | Rabbit hole flag |
| Task risk critical | High + critical-risk label | Spike candidate | Rabbit hole flag |
| Task type: research | Task with risk=high | Spike (relaxed pipeline) | Research scope |
| Task ai: full | ai-only | ai-only | ai-only |
| Task ai: assisted | ai-reviewed | ai-reviewed | ai-reviewed |
| Task ai: pair | hybrid | hybrid | hybrid |
| Task ai: human | human-only (blocks start) | human-only | human-only |
| Success conditions | Acceptance Criteria | Definition of Done | "Done means" |
| depends_on | Dependencies field | Dependencies field | Dependencies field |

## Why This Matters for ido4shape

The agent should understand that:

- **effort: XL** maps to the same as L in Hydro (Large) — ido4 doesn't distinguish. The value is still meaningful for human understanding of scope.
- **risk: critical** maps to High with an extra label — the distinction between high and critical is preserved semantically even when the risk field collapses them.
- **type: research** triggers special handling in Scrum (becomes a Spike with relaxed validation) — worth noting when a task involves exploration or unknowns.
- **ai: human** blocks the `start` transition in ido4's BRE — these tasks cannot be claimed by AI agents. Use this deliberately for tasks requiring human judgment.
- **Group size** only matters in Shape Up where it maps to Appetite — but it's always worth capturing as it communicates scope to humans.

## What ido4shape Must NOT Do

- Never ask "are you using Scrum or Shape Up?"
- Never use methodology-specific language (no "sprint," "wave," "bet," "epic" in the artifact)
- Never adjust metadata values based on assumed methodology
- Never reference containers, cycles, or methodology-specific concepts
- The artifact is a universal contract — methodology is applied downstream
