# Project Template: API Service

Typical group patterns for API/backend service projects:

- **Core Domain** — data models, business logic, validation rules
- **API Layer** — endpoints, request/response handling, authentication
- **Data Access** — database schema, queries, caching
- **Integration** — external service clients, webhooks, event publishing
- **Infrastructure** — deployment, monitoring, logging, CI/CD
- **Testing** — test infrastructure, fixtures, integration test environment

Common dependency patterns:
- Core Domain has no dependencies (foundational)
- API Layer depends on Core Domain
- Data Access depends on Core Domain
- Integration depends on Core Domain
- Infrastructure depends on everything (last)

Priority patterns:
- Core Domain and API Layer are typically must-have
- Integration depends on which external systems are critical vs nice-to-have
- Infrastructure and Testing are must-have for production but may be should-have for MVP

Typical cross-cutting concerns:
- **Performance:** API response time targets, throughput requirements, concurrent user expectations
- **Security:** Authentication model, authorization/RBAC, input validation, rate limiting, data sensitivity
- **Observability:** Structured logging, health endpoints, metrics, alerting thresholds, SLA targets
- **Compliance:** Data retention, GDPR/privacy requirements, audit trail needs

Risk hotspots:
- External integrations (API changes, rate limits, authentication) — often marked low risk but frequently surprises
- Data migrations on existing systems — stakeholders underestimate complexity
- Performance under load — need specific targets from stakeholders, not assumptions
- Authentication/authorization — security-critical, compliance implications
