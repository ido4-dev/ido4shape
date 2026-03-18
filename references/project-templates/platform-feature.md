# Project Template: Platform Feature

Typical group patterns for features added to existing platforms:

- **Core Capability** — the new functionality itself, business logic
- **UI/UX** — user-facing interface, components, interactions
- **Integration Points** — how the feature connects to existing platform systems
- **Data Model** — schema changes, backward compatibility
- **Access Control** — permissions, feature flags, role-based access
- **Observability** — metrics, logging, alerts specific to the feature

Common dependency patterns:
- Data Model is foundational (schema must exist first)
- Core Capability depends on Data Model
- Integration Points depend on Core Capability
- UI/UX depends on Core Capability and Integration Points
- Access Control can be parallel with UI/UX
- Observability depends on Core Capability being functional

Priority patterns:
- Core Capability and Data Model are must-have
- UI/UX is must-have (users need to access the feature)
- Integration Points depend on which platform connections are critical
- Access Control is must-have if multi-tenant or role-based, should-have otherwise
- Observability is should-have but becomes must-have for high-stakes features

Typical cross-cutting concerns:
- **Backward compatibility:** Existing data must continue working, existing API consumers must not break
- **Performance:** Impact on existing platform response times, database query performance with new schema
- **Feature rollout:** Feature flag strategy, percentage rollout, rollback plan
- **Security:** Permission model, data access boundaries, audit trail for sensitive operations

Risk hotspots:
- Backward compatibility with existing data — stakeholders often assume it's simple
- Performance impact on existing features — new queries/indexes can degrade unrelated flows
- Feature flag rollout strategy — partial rollout introduces state complexity
- Interaction with other in-progress features — concurrent development on same codebase
