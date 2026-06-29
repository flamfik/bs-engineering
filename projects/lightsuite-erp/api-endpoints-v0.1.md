# LightSuite ERP — REST API Endpoints v0.1

## Status

Initial REST API endpoint draft for the LightSuite ERP case study.

This document is not a final OpenAPI specification yet. It is a first structured API design draft showing how the system could expose manufacturing, warehouse, quality, documentation, tooling, calibration and administration workflows.

## API design goal

The API should make the system workflow visible.

LightSuite ERP is not only a database. It is a set of connected manufacturing actions:

```text
create order → plan production → issue material → run operation → report progress → inspect quality → record traceability → review analytics
```

The endpoint design should follow that flow.

## Base path

```text
/api/v1
```

## API principles

### 1. Workflow-first endpoints

Endpoints should represent real user actions, not only database tables.

For example, issuing material to production is more meaningful than only inserting a stock movement row.

### 2. Role-aware access

Every endpoint should eventually map to a permission code from the roles and permissions matrix.

### 3. Validation at the boundary

Incoming data should be validated before it reaches business logic. The proposed validation layer is Zod.

### 4. Audit-sensitive actions

Approvals, document revision changes, calibration updates, permission changes and exports should create audit log entries.

### 5. Simple first, extensible later

The first API should be clear enough to build an MVP, while leaving space for future modules and integrations.

## Authentication and session endpoints

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| POST | `/auth/login` | Authenticate user and start session / return token. | Public |
| POST | `/auth/logout` | End current session. | Authenticated |
| GET | `/auth/me` | Return current user profile and roles. | Authenticated |

### Example login request

```json
{
  "email": "operator@example.com",
  "password": "example-password"
}
```

### Example login response

```json
{
  "user": {
    "id": "uuid",
    "name": "Operator One",
    "email": "operator@example.com",
    "roles": ["Operator"]
  },
  "accessToken": "jwt-or-session-token"
}
```

## Users, roles and permissions

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/users` | List users. | `admin.user.manage` |
| POST | `/users` | Create user. | `admin.user.manage` |
| GET | `/users/{id}` | View user details. | `admin.user.manage` |
| PATCH | `/users/{id}` | Update user status or profile. | `admin.user.manage` |
| GET | `/roles` | List roles. | `admin.role.manage` |
| POST | `/roles` | Create custom role. | `admin.role.manage` |
| PATCH | `/roles/{id}` | Update role. | `admin.role.manage` |
| POST | `/users/{id}/roles` | Assign role to user. | `admin.role.manage` |

## Products and materials

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/products` | List products. | Authenticated |
| POST | `/products` | Create product. | Leader / Admin |
| GET | `/products/{id}` | View product details. | Authenticated |
| PATCH | `/products/{id}` | Update product data. | Leader / Admin |
| GET | `/materials` | List materials. | Authenticated |
| POST | `/materials` | Create material. | Warehouse / Admin |
| GET | `/materials/{id}` | View material details. | Authenticated |
| PATCH | `/materials/{id}` | Update material data. | Warehouse / Admin |
| GET | `/materials/scan/{code}` | Find material by EAN or QR code. | Authenticated |

## Production orders

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/production-orders` | List production orders. | Leader / Quality / Analyst / Admin |
| POST | `/production-orders` | Create production order. | `production.order.create` |
| GET | `/production-orders/{id}` | View production order details. | Authenticated |
| PATCH | `/production-orders/{id}` | Update status, priority or dates. | Leader / Admin |
| POST | `/production-orders/{id}/release` | Release order to production. | Leader / Admin |
| POST | `/production-orders/{id}/hold` | Put order on hold. | Leader / Quality / Admin |
| GET | `/production-orders/{id}/traceability` | View connected materials, operations, quality records, documents and tools. | Leader / Quality / Admin |

### Example production order create request

```json
{
  "productId": "uuid",
  "customerOrderId": "uuid",
  "orderNumber": "PO-2026-0001",
  "quantityPlanned": 100,
  "priority": 2,
  "plannedStartDate": "2026-07-01",
  "plannedEndDate": "2026-07-05"
}
```

## Operations and production reporting

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/operations` | List operations. | Leader / Operator / Admin |
| GET | `/operations/{id}` | View operation details. | Authenticated |
| POST | `/production-orders/{id}/operations` | Add operation to production order. | Leader / Admin |
| PATCH | `/operations/{id}` | Update operation status or workstation. | Leader / Admin |
| POST | `/operations/{id}/assignments` | Assign operator to operation. | Leader / Admin |
| GET | `/operators/me/tasks` | View current assigned tasks. | `production.task.view` |
| POST | `/operations/{id}/reports` | Report production progress. | `production.report.create` |
| POST | `/operations/{id}/issues` | Report production issue. | `production.issue.report` |

### Example production report request

```json
{
  "quantityOk": 24,
  "quantityNok": 1,
  "notes": "One part rejected during visual check."
}
```

## Warehouse and stock movement

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/warehouse/locations` | List warehouse locations. | `warehouse.stock.view` |
| POST | `/warehouse/locations` | Create location. | Warehouse / Admin |
| GET | `/warehouse/stock` | View stock items. | `warehouse.stock.view` |
| GET | `/warehouse/stock/{id}` | View stock item details. | `warehouse.stock.view` |
| POST | `/warehouse/receipts` | Receive material into stock. | `warehouse.material.receive` |
| POST | `/warehouse/issues` | Issue material to production. | `warehouse.material.issue` |
| POST | `/warehouse/transfers` | Transfer stock between locations. | Warehouse / Admin |
| GET | `/warehouse/scan/{code}` | Find stock item or location by QR / EAN code. | Warehouse / Leader / Admin |

### Example material issue request

```json
{
  "stockItemId": "uuid",
  "productionOrderId": "uuid",
  "quantity": 10,
  "fromLocationId": "uuid"
}
```

## Quality and inspection

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/quality/records` | List quality records. | Quality / Leader / Analyst / Admin |
| POST | `/quality/records` | Create quality record. | `quality.record.create` |
| GET | `/quality/records/{id}` | View quality record. | Quality / Leader / Admin |
| PATCH | `/quality/records/{id}` | Update draft quality record. | Quality / Admin |
| POST | `/quality/records/{id}/characteristics` | Add inspection characteristic. | Quality / Admin |
| POST | `/quality/characteristics/{id}/measurements` | Add measurement result. | Quality / Admin |
| POST | `/quality/records/{id}/approve` | Approve quality record. | `quality.record.approve` |
| POST | `/quality/records/{id}/nonconformities` | Add nonconformity note. | Quality / Leader / Operator / Admin |

### Example measurement result request

```json
{
  "measurementToolId": "uuid",
  "measuredValue": 12.48,
  "resultStatus": "ok",
  "measuredAt": "2026-07-01T10:15:00Z"
}
```

## Documentation and revisions

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/documents` | List controlled documents. | `document.view` |
| POST | `/documents` | Create document record. | Document Controller / Admin |
| GET | `/documents/{id}` | View document metadata. | `document.view` |
| POST | `/documents/{id}/revisions` | Add document revision. | `document.revision.create` |
| POST | `/document-revisions/{id}/approve` | Approve document revision. | `document.revision.approve` |
| POST | `/document-revisions/{id}/links` | Link revision to product, production order or quality record. | Document Controller / Quality / Admin |
| GET | `/production-orders/{id}/documents` | View documents linked to production order. | Authenticated |

## Measurement tools and calibration

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/tools` | List measurement tools. | `tooling.tool.view` |
| POST | `/tools` | Create measurement tool. | Tooling / Admin |
| GET | `/tools/{id}` | View tool details. | `tooling.tool.view` |
| PATCH | `/tools/{id}` | Update tool metadata or status. | Tooling / Admin |
| GET | `/tools/scan/{code}` | Find tool by QR code. | `tooling.tool.view` |
| POST | `/tools/{id}/issue` | Issue tool to operator or production order. | `tooling.tool.issue` |
| POST | `/tools/{id}/return` | Return issued tool. | Tooling / Leader / Admin |
| POST | `/tools/{id}/calibration-events` | Add calibration event. | `tooling.calibration.update` |
| GET | `/tools/calibration/due-soon` | List tools close to calibration due date. | Tooling / Quality / Leader / Admin |

### Example calibration event request

```json
{
  "calibrationDate": "2026-07-01",
  "nextDueDate": "2027-07-01",
  "result": "passed",
  "certificateReference": "CAL-2026-001"
}
```

## Analytics and dashboards

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/analytics/production-summary` | Production progress and order status summary. | `analytics.dashboard.view` |
| GET | `/analytics/quality-summary` | Quality results and repeated issues summary. | `analytics.dashboard.view` |
| GET | `/analytics/calibration-summary` | Tool calibration status summary. | `analytics.dashboard.view` |
| GET | `/analytics/warehouse-summary` | Warehouse movement and stock summary. | `analytics.dashboard.view` |
| GET | `/analytics/kpis` | List KPI records. | `analytics.dashboard.view` |

## Audit logs

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/audit-logs` | Review sensitive system changes. | Administrator |
| GET | `/audit-logs/entity/{entityType}/{entityId}` | Review history for one entity. | Administrator |

## Licensing

| Method | Endpoint | Purpose | Permission |
|---|---|---|---|
| GET | `/license/status` | View current license state. | Administrator |
| POST | `/license/activate` | Activate license key. | `admin.license.manage` |
| POST | `/license/validate` | Validate license state. | `admin.license.manage` |

## Validation examples

### Production order validation

A production order create request should validate:

- productId exists,
- quantityPlanned is greater than 0,
- orderNumber is unique,
- plannedEndDate is not earlier than plannedStartDate,
- user has permission to create production orders.

### Measurement result validation

A measurement result should validate:

- characteristic exists,
- measurement tool exists if provided,
- measurement tool is not blocked or overdue for calibration,
- measuredValue is present when result is checked,
- measuredBy is the current user or an authorized quality user.

### Material issue validation

A material issue should validate:

- stock item exists,
- quantity is greater than 0,
- stock has sufficient quantity,
- material is not quarantined or blocked,
- production order exists and is released or in progress.

## Suggested response format

Successful response:

```json
{
  "data": {},
  "meta": {
    "requestId": "uuid"
  }
}
```

Validation error response:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed.",
    "details": [
      {
        "field": "quantityPlanned",
        "message": "Quantity must be greater than zero."
      }
    ]
  }
}
```

## Future OpenAPI direction

The next step after this draft is to convert the endpoint list into an OpenAPI YAML file.

Recommended next deliverables:

- `openapi-v0.1.yaml`,
- request / response schemas,
- Zod validation schema examples,
- API test scenarios,
- seed demo users and sample production data.
