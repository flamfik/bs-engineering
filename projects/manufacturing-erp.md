# LightSuite ERP

## Case study status

Personal architecture and portfolio case study. Early concept, designed to document systems thinking, manufacturing workflows and the connection between quality, production, warehouse, calibration, data and software.

LightSuite ERP is the new name for the Manufacturing ERP Platform concept.

## Why this project matters

This project started from a simple observation: in manufacturing, information often lives in too many separate places.

Production has one workflow. Warehouse has another. Quality documentation is somewhere else. Calibration reminders are handled separately. Reports are often built manually. When those pieces do not talk to each other, people lose time, traceability becomes weaker and decisions become harder.

LightSuite ERP is my attempt to think through that problem as a system.

The goal is not to pretend that this is a finished enterprise product. The goal is to show how I understand manufacturing environments and how I would structure a lightweight system around real operational needs.

## Case study summary

LightSuite ERP is a modular ERP concept for small and medium manufacturing environments. It focuses on the flow of information between production, warehouse, quality, documentation, calibration and analytics.

The system is designed around one central idea:

> a manufacturing system becomes easier to manage when work, materials, quality checks, documents, tools and data are connected in one clear workflow.

## Problem

Many manufacturing teams work with separated tools:

- spreadsheets for reporting,
- local folders for documentation,
- separate warehouse records,
- manual quality logs,
- disconnected calibration reminders,
- informal task tracking,
- limited visibility between departments.

The result is not only administrative friction. It also affects quality, traceability and decision-making.

The core problem is flow: how information moves from one part of the organization to another.

## Target users

LightSuite ERP is designed around practical manufacturing roles:

| Role | Main need |
|---|---|
| Operator | Clear tasks, simple reporting and access to current instructions. |
| Leader / Supervisor | Visibility into production status, assignments, issues and performance. |
| Quality user | Inspection records, traceability, measurement data and documentation control. |
| Warehouse user | Material receipts, issues, locations and stock movement. |
| Tooling / Calibration owner | Measurement tool locations, issue history and calibration due dates. |
| Administrator | Users, roles, modules, licensing and system configuration. |

## Proposed modules

### 1. Production

Manages orders, operations, workstations, operator assignments and production reports.

The production module should answer:

- What needs to be produced?
- Who is working on it?
- Which operation is active?
- What was completed?
- Were there problems or deviations?

### 2. Warehouse

Manages material receipts, internal issues, stock movements, locations, EAN / QR support and links between material and production orders.

The warehouse module should reduce uncertainty around material flow.

### 3. Quality

Stores inspection records, nonconformity notes, measurement requirements, MSA-related data and Cg / Cgk calculations.

The quality module should connect inspection data with production context, not keep it isolated.

### 4. Documentation

Controls work instructions, technical drawings, revisions and controlled documents.

This module matters because outdated documentation can create real production and quality risks.

### 5. Tooling and calibration

Tracks measurement tools, locations, issue to production, assigned operators and calibration due dates.

This module connects metrology with daily production reality.

### 6. Analytics

Collects operational and quality data into dashboards and reports.

The goal is not only charts. The goal is better questions: where are delays, where are recurring issues, where is performance changing and what needs attention?

### 7. REST API

Provides integration points for future modules, reporting tools, external systems and automation.

### 8. Licensing and administration

Supports user roles, permissions, subscription logic and external license validation.

This is part of the concept because system access and role control are important in real business software.

## High-level workflow

```text
Customer order
    ↓
Production order
    ↓
Material requirement
    ↓
Warehouse receipt / stock check
    ↓
Material issue to production
    ↓
Operation assignment
    ↓
Production reporting
    ↓
Quality inspection
    ↓
Documentation / traceability record
    ↓
Analytics and performance review
```

## Architecture thinking

LightSuite ERP should be modular rather than monolithic in design.

The early architecture direction:

- clear module boundaries,
- shared user and permission model,
- SQL-based relational data,
- REST API for integration,
- audit-friendly records,
- document revision control,
- simple UI focused on real tasks,
- Docker-ready local development,
- future support for dashboards and external analytics.

## Data areas

Key data areas include:

- users and roles,
- customers and suppliers,
- products and materials,
- orders and operations,
- warehouse locations,
- quality records,
- measurement tools,
- calibration events,
- documents and revisions,
- reports and KPIs,
- license data.

## What this project should demonstrate

This case study is meant to show:

- understanding of manufacturing workflows,
- quality and traceability thinking,
- ability to structure complex systems,
- awareness of user roles and permissions,
- data model thinking,
- documentation discipline,
- bridge between shop-floor reality and software architecture.

## Current limitations

This is currently a concept and architecture case study, not a finished production system.

Current limitations:

- no complete implementation yet,
- no validated production deployment,
- no real customer data,
- architecture still needs diagrams,
- data model needs refinement,
- UI concepts need to be designed and tested.

These limitations are intentional to state clearly. A case study is stronger when it explains what exists and what does not exist yet.

## Next steps

1. Create a module map.
2. Draft the first database model.
3. Define user roles and permissions.
4. Document the production-to-quality workflow.
5. Create a first UI wireframe.
6. Add REST API endpoint examples.
7. Prepare a roadmap toward a lightweight MVP.

## Career value

LightSuite ERP is the strongest BS Engineering portfolio project because it connects the most important parts of my profile:

- manufacturing,
- quality,
- metrology,
- documentation,
- process improvement,
- data,
- software architecture,
- systems thinking.

It turns my professional story into something visible: not only a list of skills, but a structured example of how I approach real manufacturing problems.
