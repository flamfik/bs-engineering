# LightSuite ERP

LightSuite ERP is the flagship BS Engineering manufacturing systems case study.

It explores how a lightweight ERP system could connect production, warehouse, quality, documentation, tooling, calibration, analytics and REST APIs in one practical manufacturing workflow.

## Files

- [Case study](./case-study.md)
- [Architecture outline](./architecture.md)
- [Technology stack](./technology-stack.md)
- [Module map](./module-map.md)
- [Roles and permissions matrix](./roles-permissions.md)
- [Data model v0.1](./data-model-v0.1.md)
- [SQL schema v0.1](./schema-v0.1.sql)
- [REST API endpoints v0.1](./api-endpoints-v0.1.md)
- [Roadmap](./roadmap.md)

## Why this project exists

This project connects the strongest parts of the BS Engineering profile:

- manufacturing experience,
- quality and metrology thinking,
- technical documentation,
- process improvement,
- data structure,
- software architecture,
- practical systems thinking.

## What this case study shows

LightSuite ERP is not only an idea for software. It is a structured way to show how manufacturing information could flow between people, roles, modules and data.

The most important questions behind the project are:

- How does an order move through production?
- Where does material information come from?
- How are quality records connected to production context?
- Which documents are current and controlled?
- Which measurement tools are valid for use?
- Who should be allowed to change sensitive data?
- How can analytics support decisions without creating reporting chaos?

## Proposed technology direction

The planned MVP stack is based on practical and understandable technologies:

- React + TypeScript for the frontend,
- Node.js + TypeScript for the backend,
- PostgreSQL for relational manufacturing data,
- REST API with OpenAPI documentation,
- Zod validation,
- role-based access control,
- Docker Compose for local development,
- Markdown and Mermaid for documentation.

This is currently a proposed stack for the case study and future MVP, not a claim that the full system has already been implemented.

## Current status

Case study in progress.

The project is currently a concept and documentation portfolio piece. Implementation can be developed later after the system design is clear.
