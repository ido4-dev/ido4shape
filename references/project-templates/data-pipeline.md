# Project Template: Data Pipeline

Typical group patterns for data pipeline and processing projects:

- **Ingestion** — data sources, connectors, extraction, raw storage
- **Processing** — transformation, validation, enrichment, normalization
- **Storage** — data warehouse, indexes, partitioning, retention policies
- **Serving** — APIs, dashboards, exports, real-time queries
- **Orchestration** — scheduling, dependencies, retry logic, monitoring
- **Quality** — data validation, anomaly detection, reconciliation

Common dependency patterns:
- Ingestion is foundational (data must flow in first)
- Processing depends on Ingestion
- Storage depends on Processing (schema must match transformed data)
- Serving depends on Storage
- Orchestration depends on all pipeline stages existing
- Quality can be parallel but needs data flowing to test against

Priority patterns:
- Ingestion and Processing are must-have (no pipeline without them)
- Storage is must-have (data needs a destination)
- Serving is must-have if the pipeline has consumers, should-have if it's a backend process
- Orchestration is should-have for v1 (manual runs first), must-have for production
- Quality is should-have but becomes must-have for financial/compliance data

Typical cross-cutting concerns:
- **Performance:** Volume targets (records/hour), latency requirements (real-time vs batch), peak load expectations
- **Data quality:** Completeness thresholds, accuracy requirements, freshness SLAs, duplicate handling strategy
- **Security:** Data classification (PII, financial, health), encryption at rest and in transit, access control, audit logging
- **Compliance:** Data retention policies, right to deletion, geographic data residency, regulatory reporting requirements
- **Operational:** Backfill strategy, schema evolution approach, source system change management, alerting thresholds

Risk hotspots:
- Data volume at scale — what works for 1GB fails at 1TB
- Schema evolution — source systems change without notice (external dependency)
- Late-arriving data — time-based partitioning assumptions break
- Exactly-once processing guarantees — stakeholders assume this is easy
- Backfill strategy for historical data — often discovered late as a requirement
- Source system rate limits and availability — external dependency outside team control
