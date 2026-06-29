# LightSuite ERP — Roles and Permissions Matrix

## Purpose

This document defines the first role model for LightSuite ERP.

The goal is not to create a complicated permission system too early. The goal is to show that the system understands real manufacturing responsibility: different users need different levels of access, and some actions must be protected.

## Role model principle

Permissions should follow responsibility.

An operator needs a simple workflow and should not be distracted by administration. A leader needs visibility and coordination tools. Quality users need controlled access to inspection and documentation. Administrators need configuration rights, but their actions should still be traceable.

## Core roles

| Role | Description |
|---|---|
| Operator | Performs assigned production tasks and reports progress or issues. |
| Leader / Supervisor | Coordinates work, assigns tasks and monitors performance. |
| Warehouse User | Handles material receipts, stock movements, locations and issues to production. |
| Quality User | Creates and reviews inspection records, quality notes and measurement-related data. |
| Tooling / Calibration Owner | Manages measurement tools, issue history, locations and calibration due dates. |
| Document Controller | Manages controlled documents, drawings, work instructions and revisions. |
| Analyst | Reviews dashboards, reports and KPIs without changing operational data. |
| Administrator | Manages users, roles, modules, system configuration and licensing. |

## Permission matrix

| Area / Action | Operator | Leader | Warehouse | Quality | Tooling | Document Controller | Analyst | Administrator |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| View assigned tasks | Yes | Yes | No | No | No | No | No | Yes |
| Report production progress | Yes | Yes | No | No | No | No | No | Yes |
| Report production issue | Yes | Yes | No | Yes | No | No | No | Yes |
| Assign operators | No | Yes | No | No | No | No | No | Yes |
| Create production order | No | Yes | No | No | No | No | No | Yes |
| View warehouse stock | Limited | Yes | Yes | No | No | No | Yes | Yes |
| Receive material | No | No | Yes | No | No | No | No | Yes |
| Issue material to production | No | Yes | Yes | No | No | No | No | Yes |
| Manage locations | No | No | Yes | No | No | No | No | Yes |
| View quality records | Limited | Yes | No | Yes | Yes | No | Yes | Yes |
| Create inspection record | No | No | No | Yes | No | No | No | Yes |
| Approve inspection record | No | No | No | Yes | No | No | No | Yes |
| Add nonconformity note | Yes | Yes | No | Yes | No | No | No | Yes |
| View controlled documents | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| Upload new document | No | No | No | No | No | Yes | No | Yes |
| Approve document revision | No | No | No | Yes | No | Yes | No | Yes |
| View measurement tools | Limited | Yes | No | Yes | Yes | No | Yes | Yes |
| Issue tool to operator | No | Yes | No | No | Yes | No | No | Yes |
| Update calibration date | No | No | No | No | Yes | No | No | Yes |
| View analytics dashboard | No | Yes | Limited | Yes | Yes | No | Yes | Yes |
| Export reports | No | Yes | No | Yes | No | No | Yes | Yes |
| Manage users | No | No | No | No | No | No | No | Yes |
| Manage roles | No | No | No | No | No | No | No | Yes |
| Manage license | No | No | No | No | No | No | No | Yes |

## Permission levels

| Level | Meaning |
|---|---|
| No | User should not see or perform this action. |
| Limited | User can see only data related to their work or assigned area. |
| Yes | User can perform the action within their responsibility area. |

## Important access-control rules

### 1. Operators should have a focused interface

Operators should not see unnecessary administration, configuration or analytics. Their interface should focus on assigned work, current instructions, reporting and issue notes.

### 2. Quality records should be protected

Inspection records and approvals should require appropriate quality permissions. This protects traceability and reduces accidental changes.

### 3. Document revisions need control

Work instructions and drawings should have revision history. Uploading and approving documents should be limited to responsible users.

### 4. Calibration data should be owned

Calibration dates and measurement tool status should be managed by a tooling or calibration owner. Production can use this information, but should not freely modify it.

### 5. Administration should be traceable

Administrator actions should be logged. A user with high permissions should not mean invisible changes.

## Future refinement

The role model can later be extended with:

- custom roles,
- department-based permissions,
- workstation-based access,
- approval workflows,
- audit logs,
- temporary permissions,
- API token scopes.

The current version is intentionally simple enough to understand and strong enough to show real system-design thinking.
