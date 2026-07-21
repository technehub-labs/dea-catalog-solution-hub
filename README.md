# Solution Hub

> Solution archetypes, delivery templates, and implementation accelerators for recurring enterprise technology challenges — bridging pattern selection to production deployment.

[![Layer: L1](https://img.shields.io/badge/Layer-L1%20—%20Reference%20Catalogs-8b5cf6?style=flat-square)](https://github.com/technehub-labs/dea-metamodel)
[![Status: Alpha](https://img.shields.io/badge/Status-Alpha-FF6B35?style=flat-square)](./)
[![License: MIT](https://img.shields.io/badge/License-MIT-44CC11?style=flat-square)](LICENSE)

---

## Overview

Solution Hub is the L1 reference catalog that bridges the gap between architecture patterns and production-ready solution implementations. Where `dea-catalog-patterns` defines *what* patterns exist, Solution Hub defines *how to deliver them* as a working solution in an enterprise context.

It provides:
- **Solution archetypes** — canonical structures for recurring enterprise challenges: Customer Data Platform, API Gateway, Event Streaming Hub, Identity Provider, Workflow Engine, Analytics Pipeline
- **Delivery templates** — sprint-by-sprint delivery plans for each archetype: activities, milestones, exit criteria
- **Implementation accelerators** — starter code, infrastructure-as-code templates, and configuration profiles that jump-start delivery
- **Integration guides** — how to connect each archetype to the existing enterprise ecosystem (ERP, CRM, data warehouse, etc.)

---

## Framework Position

```
L0 — Metamodel (dea-metamodel)
  └─ defines: SolutionComponent, Technology, BusinessService, Relationship
L1 — Solution Hub (this repo)
  └─ seeds solution archetypes and delivery templates
  └─ references: dea-catalog-patterns (pattern selection), dea-catalog-digital-business-service-factory (services)
L2 — Tooling (dea-cli, dea-code-gen, dea-scripts)
  └─ generate implementation scaffolding, validate archetype compliance, produce delivery plans
L3 — Governance
  └─ Solution Hub delivery templates enforce governance checkpoints and compliance gates
```

---

## Structure

```
dea-catalog-solution-hub/
├── README.md
├── CATALOG/
│   ├── v1-alpha/
│   │   ├── index.yaml
│   │   ├── archetypes/              ← one YAML per solution archetype
│   │   │   ├── customer-data-platform.yaml
│   │   │   ├── api-gateway-archetype.yaml
│   │   │   ├── event-streaming-hub.yaml
│   │   │   ├── identity-provider.yaml
│   │   │   ├── workflow-engine.yaml
│   │   │   └── analytics-pipeline.yaml
│   │   └── delivery-templates/      ← sprint-by-sprint delivery plans
│   │       ├── customer-data-platform-delivery.yaml
│   │       └── api-gateway-delivery.yaml
│   └── index.yaml
├── accelerators/
│   ├── customer-data-platform/
│   │   ├── docker-compose.yaml
│   │   ├── infrastructure.tf
│   │   └── config-schema.yaml
│   └── api-gateway/
│       ├── kong-config.yaml
│       └── service-routing.yaml
├── integration-guides/
│   ├── erp-integration.yaml
│   ├── crm-integration.yaml
│   └── data-warehouse-integration.yaml
├── viewpoints/
│   └── stakeholder-views.yaml
└── LICENSE
```

---

## Solution Archetype Entity

Each archetype is a `SolutionComponent` entity:

```yaml
id: dea:archetype-customer-data-platform
type: SolutionComponent
name: Customer Data Platform Archetype
abbreviation: CDP Archetype
version: "1.0.0"
status: active
description: >
  Canonical delivery archetype for implementing a Customer Data Platform (CDP).
  Covers data ingestion from multiple sources, identity resolution, unified customer
  profile creation, activation to downstream systems, and governance controls.
archetype_class: data-platform
complexity: high
delivery_sprints: 12
team_size: 6-8

patterns_applied:
  - dea:pattern-cqrs
  - dea:pattern-event-sourcing
  - dea:pattern-api-gateway

services_realised:
  - dea:service-customer-360

capabilities_enabled:
  - dea:capability-customer-data-management
  - dea:capability-customer-identity-resolution

infrastructure_requirements:
  - Cloud: AWS / Azure / GCP
  - Ingestion: Kafka / Kinesis
  - Storage: Snowflake / BigQuery / Redshift
  - Identity: LiveRamp / Amperity / custom
  - Activation: Reverse ETL (Census / Hightouch)

delivery_phases:
  - phase: Discovery
    sprints: 1-2
    focus: Source audit, requirements, architecture design
  - phase: Foundation
    sprints: 3-4
    focus: Identity resolution engine, base data model
  - phase: Build
    sprints: 5-9
    focus: Ingestion pipelines, profile unification, activation endpoints
  - phase: Harden
    sprints: 10-11
    focus: Performance, security review, compliance validation
  - phase: Launch
    sprint: 12
    focus: UAT, training, cutover, hypercare

exit_criteria:
  - Identity resolution accuracy > 95%
  - P99 ingestion latency < 30s
  - GDPR deletion pipeline operational
  - SOC 2 Type II audit complete

governance_checkpoints:
  - Architecture review gate (end of Discovery)
  - Security review gate (end of Foundation)
  - Compliance gate (before Launch)
  - UAT sign-off gate (before hypercare)

relationships:
  - source_id: dea:archetype-customer-data-platform
    target_id: dea:pattern-cqrs
    relationship_type: applies_pattern
  - source_id: dea:archetype-customer-data-platform
    target_id: dea:service-customer-360
    relationship_type: implements_service
  - source_id: dea:archetype-customer-data-platform
    target_id: dea:standard-rest
    relationship_type: conforms_to

tags:
  - solution-archetype
  - data-platform
  - cdp
  - customer
```

---

## Delivery Template

Each archetype has a `delivery-templates/*.yaml` file defining sprint activities:

```yaml
delivery_template:
  archetype_id: dea:archetype-customer-data-platform
  sprint_duration: 2 weeks
  total_sprints: 12

  sprint_plan:
    - sprint: 1
      phase: Discovery
      activities:
        - Conduct source system audit (CRM, POS, Web, Mobile, Call Center)
        - Document customer identity requirements and resolution strategy
        - Produce high-level architecture design (HLD)
        - Identify integration points with existing data warehouse
      exit_criteria:
        - Source audit report complete
        - HLD reviewed and approved
        - Identity resolution approach agreed
        - Sprint 2 kickoff prep done

    - sprint: 2
      phase: Discovery
      activities:
        - Detailed requirements for each source system ingestion
        - Choose identity resolution approach (probabilistic vs deterministic)
        - Evaluate and select CDP platform / build approach
        - Sprint 1 review and sprint 2 review

    - sprint: 3
      phase: Foundation
      activities:
        - Stand up CDP environment (cloud infrastructure)
        - Configure identity resolution engine base
        - Define unified customer profile data model
        - CI/CD pipeline for data pipelines
      exit_criteria:
        - Environment provisioned and accessible
        - Base identity resolution running on synthetic data
        - Profile schema reviewed
```

And continues through sprints 4-12 with realistic activities for each phase.

---

## How to Use

**Browse solution archetypes:**
```bash
dea query --type SolutionComponent --tag solution-archetype
```

**Generate a delivery plan viewpoint:**
```bash
dea viewpoint --stakeholder SolutionsArchitect --tag delivery-template
```

**Generate implementation scaffolding:**
```bash
dea generate --template implementation-scaffold --id dea:archetype-customer-data-platform
```

---

## Contributing

1. Propose a new archetype or update via issue
2. Align with the `SolutionComponent` metamodel entity
3. Include: delivery template, infrastructure requirements, governance checkpoints
4. Declare all pattern and service relationships
5. Submit PR — CI validates against metamodel schema

---

## License

MIT License — see [LICENSE](./LICENSE)
