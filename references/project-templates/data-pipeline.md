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

Risk hotspots:
- Data volume at scale (what works for 1GB fails at 1TB)
- Schema evolution (source systems change without notice)
- Late-arriving data (time-based partitioning assumptions)
- Exactly-once processing guarantees
- Backfill strategy for historical data
- Source system rate limits and availability
