# Project Template: API Service

Typical group patterns for API/backend service projects:

- **Core Domain** — data models, business logic, validation rules
- **API Layer** — endpoints, request/response handling, authentication
- **Data Access** — database schema, migrations, queries, caching
- **Integration** — external service clients, webhooks, event publishing
- **Infrastructure** — deployment, monitoring, logging, CI/CD
- **Testing** — test infrastructure, fixtures, integration test environment

Common dependency patterns:
- Core Domain has no dependencies (foundational)
- API Layer depends on Core Domain
- Data Access depends on Core Domain
- Integration depends on Core Domain
- Infrastructure depends on everything (last)

Risk hotspots:
- External integrations (API changes, rate limits, authentication)
- Data migrations on existing systems
- Performance under load (need benchmarks, not assumptions)
- Authentication/authorization (security-critical, often underestimated)
