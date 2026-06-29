# LightSuite ERP — Technology Stack

## Status of this stack

This document describes the proposed technology direction for LightSuite ERP.

At the current stage, LightSuite ERP is a system-design and portfolio case study. The technologies below should be read as a planned MVP stack, not as a claim that the whole system has already been implemented.

The goal is to choose technologies that support a lightweight, maintainable and understandable manufacturing ERP system.

## Technology selection principles

The stack should be:

- practical for local development,
- understandable for a small team,
- friendly to documentation,
- suitable for REST APIs,
- good for relational manufacturing data,
- easy to run with Docker,
- testable over time,
- not unnecessarily complex.

## Proposed MVP stack

| Layer | Proposed technology | Why it fits |
|---|---|---|
| Frontend | React + TypeScript | Good for modular UI, dashboards, forms and role-based screens. |
| UI styling | Tailwind CSS | Fast, consistent interface building without heavy design overhead. |
| Backend | Node.js + TypeScript | Good fit for REST APIs, validation and modular business logic. |
| API framework | Express or Fastify | Lightweight backend foundation for REST endpoints. |
| Database | PostgreSQL | Strong relational database for production, warehouse, quality and traceability data. |
| ORM / query layer | Prisma or Drizzle | Structured database access, migrations and clearer data models. |
| Validation | Zod | Runtime validation for API input and safer request handling. |
| API documentation | OpenAPI / Swagger | Makes endpoints understandable and easier to test or integrate. |
| Authentication | JWT or session-based auth | Supports user login and protected API routes. |
| Authorization | Role-Based Access Control | Matches the roles and permissions matrix. |
| Local environment | Docker Compose | Makes the system easier to run locally with database and services. |
| Testing | Vitest / Jest + API tests | Allows validation of business rules and endpoints. |
| Documentation | Markdown + Mermaid | Keeps architecture, workflows and diagrams close to the repository. |
| Version control | Git + GitHub | Tracks project evolution and supports portfolio visibility. |

## Why PostgreSQL

LightSuite ERP is naturally relational.

A production order connects to materials, operations, operators, quality records, documents, tools and reports. These relationships are easier to represent and protect in a relational database.

PostgreSQL is a good fit because it supports:

- strong relational modeling,
- transactions,
- constraints,
- indexes,
- views,
- reporting queries,
- future analytics integration.

## Why TypeScript

TypeScript is useful because LightSuite ERP will contain many structured objects: users, roles, orders, operations, documents, tools, quality records and calibration events.

Static typing can help reduce mistakes in a system where data relationships matter.

## Why REST API first

REST API design forces the system to define clear boundaries.

This matters because LightSuite ERP should later support:

- dashboards,
- external reporting tools,
- barcode / QR workflows,
- integrations,
- mobile or tablet interfaces,
- automation scripts.

## Barcode, EAN and QR support

EAN and QR support should be treated as part of the warehouse and tooling workflows.

Possible uses:

- scan material labels,
- identify warehouse locations,
- open tool records,
- issue measurement tools to production,
- open controlled documents,
- connect production orders with physical labels.

This can be implemented later using browser-based scanning or external scanner input. The first step is to design the data model so scanned identifiers have a clear place in the system.

## Analytics direction

The first analytics layer should stay simple:

- production progress,
- delayed orders,
- repeated quality issues,
- tools close to calibration due date,
- warehouse movement history,
- inspection status,
- basic KPIs.

Later, data could be exported to Power BI or other reporting tools.

## Security and reliability basics

Even as a portfolio project, LightSuite ERP should show security awareness:

- password hashing,
- role-based access,
- input validation,
- audit log for sensitive changes,
- protected document revisions,
- controlled access to quality records,
- environment variables for secrets,
- clear separation between demo data and real data.

## What is already used now

At the documentation stage, the project currently uses:

- Markdown for case study documentation,
- Mermaid for diagrams,
- GitHub for version control and public portfolio visibility.

## What comes next

The next technical step is to define the data model v0.1.

That should include first entities such as:

- User,
- Role,
- ProductionOrder,
- Operation,
- Material,
- WarehouseLocation,
- QualityRecord,
- MeasurementTool,
- CalibrationEvent,
- Document,
- DocumentRevision,
- AuditLog.
