# LightSuite ERP — Architecture Outline

## Architecture goal

LightSuite ERP should be modular, understandable and easy to extend.

The architecture should support small and medium manufacturing workflows without becoming unnecessarily complex.

## High-level layers

```text
User interface
    ↓
Application modules
    ↓
REST API
    ↓
Business logic
    ↓
Relational database
    ↓
Audit, reporting and integration layer
```

## Core modules

### Production module

Handles production orders, operations, workstations, operator assignments and production reports.

### Warehouse module

Handles material receipts, internal issues, stock locations, EAN / QR support and movement history.

### Quality module

Handles inspection records, measurement requirements, quality notes, MSA-related data and Cg / Cgk calculations.

### Documentation module

Handles work instructions, technical drawings, revisions and controlled documents.

### Tooling and calibration module

Handles measurement tools, tool locations, issue history, assigned operators and calibration due dates.

### Analytics module

Handles dashboards, reports, KPIs and operational visibility.

### Administration module

Handles users, roles, permissions, system configuration and licensing.

## Shared concepts

- Users
- Roles
- Permissions
- Audit log
- Document revisions
- Attachments
- Notifications
- API tokens
- License validation

## Suggested technical direction

This is an early architecture direction, not a final stack decision.

Possible direction:

- backend API,
- SQL database,
- modular frontend,
- Docker-based local development,
- REST API documentation,
- role-based access control,
- structured migrations,
- API validation,
- automated tests over time.

## Architecture principle

The architecture should stay close to the real workflow.

If a module exists only because it sounds good, it should be questioned. If it helps a real manufacturing user avoid confusion, improve traceability or reduce manual work, it belongs in the system.
