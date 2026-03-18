# Methodology Mapping Reference

ido4shape produces methodology-agnostic strategic specs. Methodology mapping happens downstream — ido4 MCP applies methodology-specific interpretation when producing technical specs and during ingestion through its built-in profiles (Hydro, Scrum, Shape Up).

## What This Means for ido4shape

Strategic specs contain no methodology-specific fields or language. The mapping between strategic concepts and methodology-specific concepts is ido4 MCP's responsibility:

| Strategic Spec Concept | What ido4 MCP Maps It To |
|----------------------|--------------------------|
| Group | Epic (Hydro), Feature group (Scrum), Bet (Shape Up) |
| Capability | Task/Issue (Hydro), Story/Spike (Scrum), Scope (Shape Up) |
| Priority (must-have/should-have/nice-to-have) | Drives decomposition ordering and resource allocation |
| Strategic risk (low/medium/high) | Informs technical risk assessment, not replaces it |
| Functional dependencies | Preserved + augmented with code-level dependencies |
| Success conditions | Become acceptance criteria, definition of done, or "done means" per methodology |

## What ido4shape Must NOT Do

- Never ask "are you using Scrum or Shape Up?"
- Never use methodology-specific language (no "sprint," "wave," "bet," "epic," "story points," "appetite")
- Never adjust metadata values based on assumed methodology
- Never reference containers, cycles, or methodology-specific concepts
- The strategic spec is a universal contract — methodology is applied downstream by ido4 MCP

## Fields That Moved Downstream

These fields used to be in the spec artifact but are now determined by ido4 MCP from codebase analysis:

- **effort (S/M/L/XL):** Requires knowing code complexity. ido4 MCP maps to methodology-specific sizing.
- **type (feature/bug/research/infrastructure):** One capability may decompose into multiple types.
- **ai (full/assisted/pair/human):** Requires knowing code patterns and test coverage.
- **size (S/M/L/XL on groups):** Implementation scope, unknowable from conversation.

Strategic specs capture priority and strategic risk instead — things stakeholder conversations CAN meaningfully determine.
