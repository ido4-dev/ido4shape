---
name: quality-guidance
description: >
  This skill provides strategic spec quality standards. It activates automatically whenever
  Claude is writing or reviewing capability descriptions, success conditions, priority assessments,
  strategic risk assessments, or evaluating spec quality. Also triggers when writing to canvas
  emerging structure sections, when the user mentions "quality", "acceptance criteria",
  "definition of done", "is this good enough", "priority", "risk", "spec completeness",
  or when a /ido4shape:synthesize-spec or /ido4shape:validate-spec session is active.
user-invocable: false
---

## Capability Description Quality

A capability description must be rich enough for a technical decomposition agent to understand the intent without accessing the original conversations. At least 200 characters, but substance matters more than length.

A good description includes: what the capability provides and who needs it, stakeholder perspectives that shaped it ("Per Marcus: needs idempotency"), relevant constraints, what success looks like from the user's perspective, and integration points with other capabilities.

A weak description just restates the title in longer form or says "build X" without context. A description that prescribes implementation approach ("use a discriminated union pattern") is overstepping — that's the technical spec's job.

## Success Conditions

Each condition should be independently verifiable — someone could check it without checking any other condition.

Good: "Quiet hours spanning midnight work correctly (e.g., 22:00-08:00)"
Weak: "System handles edge cases correctly"

Test: could two people independently agree whether this condition is met?

Success conditions in strategic specs are product-level: "user can set quiet hours", "notifications during quiet hours are deferred not dropped." Code-level conditions ("migration runs successfully", "test coverage above 80%") belong in the technical spec.

## Priority Assessment

Priority is about strategic importance — what matters most for the project to succeed.

- **must-have:** Without this, the project fails to deliver its core value. Non-negotiable.
- **should-have:** Important for a complete solution. Would ship without it but it would hurt.
- **nice-to-have:** Adds polish or handles edge cases. Defer without guilt if needed.

Common mistakes: marking everything must-have (if everything is critical, nothing is). A good spec has a clear pyramid: few must-haves, more should-haves, some nice-to-haves.

Priority should be assessed from the stakeholder conversations — what did the PM say was non-negotiable? What did the business say about minimum viable scope?

## Strategic Risk Assessment

Risk in strategic specs is about unknowns and external factors, not code complexity.

- **low:** Well-understood by stakeholders. Requirements clear and stable. Team has confidence. No external blockers.
- **medium:** Some unknowns but bounded. Partial stakeholder alignment. Manageable external dependencies. Might need further conversation.
- **high:** Significant unknowns. Depends on factors outside team control (third-party APIs, legal sign-off, market validation). Stakeholder disagreement unresolved.

This is NOT code risk. A capability can be strategically low-risk ("everyone agrees we need it, requirements are clear") but technically high-risk ("the codebase is a mess here"). Code risk is determined by ido4 MCP during technical decomposition.

## Cross-Cutting Concern Quality

Cross-cutting concerns (NFRs, security, performance, accessibility) should have specific targets or requirements, not vague aspirations.

Good: "10K events/minute throughput at peak, per architect's analysis of 5x growth headroom"
Weak: "System should be performant"

Each concern should carry attribution when relevant — who defined the target and why.

## Stakeholder Coverage

A strategic spec shaped by a single stakeholder perspective is weaker than one shaped by multiple perspectives. The Understanding Assessment should track which stakeholders contributed to which dimensions.

Missing perspectives to flag:
- No architect input on feasibility or risk → strategic risk assessments may be unrealistic
- No UX input on user interaction → success conditions may miss user experience
- No business input on priority → priority assessments may not reflect strategic reality

## Group Quality

Groups should be coherent (all capabilities serve the same functional cluster), self-contained (delivering the group provides standalone value), and right-sized (3-8 capabilities typically).

Groups in strategic specs represent functional clusters, not code modules. "Notification Preferences" is a functional group even if the code spans multiple services. Code-level grouping (by module or service boundary) happens in the technical spec.
