# Project Template: Platform Feature

Typical group patterns for features added to existing platforms:

- **Core Capability** — the new functionality itself, business logic
- **UI/UX** — user-facing interface, components, interactions
- **Integration Points** — how the feature connects to existing platform systems
- **Data Model** — schema changes, migrations, backward compatibility
- **Access Control** — permissions, feature flags, role-based access
- **Observability** — metrics, logging, alerts specific to the feature

Common dependency patterns:
- Data Model is foundational (schema must exist first)
- Core Capability depends on Data Model
- Integration Points depend on Core Capability
- UI/UX depends on Core Capability and Integration Points
- Access Control can be parallel with UI/UX
- Observability depends on Core Capability being functional

Risk hotspots:
- Backward compatibility with existing data
- Performance impact on existing features
- Feature flag rollout strategy
- Interaction with other in-progress features
- Migration of existing data to new schema
