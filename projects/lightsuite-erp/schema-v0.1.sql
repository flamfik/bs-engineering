-- LightSuite ERP — SQL Schema v0.1
-- Status: technical schema draft for PostgreSQL
-- Purpose: translate the conceptual data model into a first relational database structure.
-- This is not a production-ready schema yet. It is a portfolio and system-design draft.

-- Recommended database: PostgreSQL
-- UUID generation requires pgcrypto.
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ============================================================
-- ENUM TYPES
-- ============================================================

CREATE TYPE user_status AS ENUM ('active', 'inactive', 'locked');
CREATE TYPE order_status AS ENUM ('draft', 'confirmed', 'planned', 'released', 'in_progress', 'on_hold', 'completed', 'cancelled');
CREATE TYPE operation_status AS ENUM ('planned', 'active', 'paused', 'completed', 'cancelled');
CREATE TYPE stock_status AS ENUM ('available', 'reserved', 'quarantined', 'consumed', 'blocked');
CREATE TYPE stock_movement_type AS ENUM ('receipt', 'issue', 'transfer', 'correction', 'return');
CREATE TYPE quality_status AS ENUM ('draft', 'in_review', 'approved', 'rejected');
CREATE TYPE quality_result AS ENUM ('pass', 'fail', 'conditional');
CREATE TYPE result_status AS ENUM ('ok', 'nok', 'not_checked');
CREATE TYPE nonconformity_severity AS ENUM ('minor', 'major', 'critical');
CREATE TYPE nonconformity_status AS ENUM ('open', 'under_review', 'closed');
CREATE TYPE nonconformity_disposition AS ENUM ('rework', 'scrap', 'use_as_is', 'hold', 'not_decided');
CREATE TYPE document_status AS ENUM ('draft', 'active', 'archived', 'obsolete');
CREATE TYPE document_type AS ENUM ('drawing', 'work_instruction', 'regulation', 'form', 'other');
CREATE TYPE tool_status AS ENUM ('available', 'issued', 'calibration_due', 'blocked', 'retired');
CREATE TYPE tool_issue_status AS ENUM ('issued', 'returned', 'overdue', 'lost');
CREATE TYPE calibration_result AS ENUM ('passed', 'failed', 'adjusted', 'blocked');
CREATE TYPE audit_action AS ENUM ('create', 'update', 'delete', 'approve', 'login', 'export');
CREATE TYPE location_type AS ENUM ('warehouse', 'production_buffer', 'quarantine', 'tool_room', 'other');

-- ============================================================
-- SHARED TIMESTAMP TRIGGER
-- ============================================================

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- IDENTITY AND ACCESS
-- ============================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    status user_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    is_system_role BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_roles_updated_at
BEFORE UPDATE ON roles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_roles (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE role_permissions (
    role_id UUID NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID NOT NULL REFERENCES permissions(id) ON DELETE CASCADE,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (role_id, permission_id)
);

-- ============================================================
-- MASTER DATA
-- ============================================================

CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    customer_code TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customers_updated_at
BEFORE UPDATE ON customers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    supplier_code TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_suppliers_updated_at
BEFORE UPDATE ON suppliers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_number TEXT NOT NULL UNIQUE,
    title TEXT NOT NULL,
    document_type document_type NOT NULL DEFAULT 'other',
    owner_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status document_status NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_documents_updated_at
BEFORE UPDATE ON documents
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE document_revisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_id UUID NOT NULL REFERENCES documents(id) ON DELETE CASCADE,
    revision TEXT NOT NULL,
    file_path TEXT,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    valid_from DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (document_id, revision)
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sku TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    revision TEXT,
    default_document_id UUID REFERENCES documents(id) ON DELETE SET NULL,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_code TEXT NOT NULL UNIQUE,
    ean_code TEXT UNIQUE,
    qr_code TEXT UNIQUE,
    name TEXT NOT NULL,
    unit TEXT NOT NULL DEFAULT 'pcs',
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_materials_updated_at
BEFORE UPDATE ON materials
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE product_material_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
    quantity_required NUMERIC(14, 4) NOT NULL CHECK (quantity_required > 0),
    unit TEXT NOT NULL DEFAULT 'pcs',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (product_id, material_id)
);

-- ============================================================
-- PRODUCTION
-- ============================================================

CREATE TABLE customer_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
    order_number TEXT NOT NULL UNIQUE,
    status order_status NOT NULL DEFAULT 'draft',
    due_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_customer_orders_updated_at
BEFORE UPDATE ON customer_orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE production_orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_order_id UUID REFERENCES customer_orders(id) ON DELETE SET NULL,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
    order_number TEXT NOT NULL UNIQUE,
    quantity_planned NUMERIC(14, 4) NOT NULL CHECK (quantity_planned > 0),
    quantity_completed NUMERIC(14, 4) NOT NULL DEFAULT 0 CHECK (quantity_completed >= 0),
    status order_status NOT NULL DEFAULT 'planned',
    priority INTEGER NOT NULL DEFAULT 0,
    planned_start_date DATE,
    planned_end_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_production_orders_updated_at
BEFORE UPDATE ON production_orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE workstations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_workstations_updated_at
BEFORE UPDATE ON workstations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE operations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    production_order_id UUID NOT NULL REFERENCES production_orders(id) ON DELETE CASCADE,
    workstation_id UUID REFERENCES workstations(id) ON DELETE SET NULL,
    sequence_number INTEGER NOT NULL CHECK (sequence_number > 0),
    name TEXT NOT NULL,
    status operation_status NOT NULL DEFAULT 'planned',
    planned_time_minutes INTEGER CHECK (planned_time_minutes IS NULL OR planned_time_minutes >= 0),
    actual_time_minutes INTEGER CHECK (actual_time_minutes IS NULL OR actual_time_minutes >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (production_order_id, sequence_number)
);

CREATE TRIGGER trg_operations_updated_at
BEFORE UPDATE ON operations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE operation_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operation_id UUID NOT NULL REFERENCES operations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    assigned_by UUID REFERENCES users(id) ON DELETE SET NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (operation_id, user_id)
);

CREATE TABLE production_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    operation_id UUID NOT NULL REFERENCES operations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    quantity_ok NUMERIC(14, 4) NOT NULL DEFAULT 0 CHECK (quantity_ok >= 0),
    quantity_nok NUMERIC(14, 4) NOT NULL DEFAULT 0 CHECK (quantity_nok >= 0),
    notes TEXT,
    reported_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- WAREHOUSE
-- ============================================================

CREATE TABLE warehouse_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code TEXT NOT NULL UNIQUE,
    name TEXT NOT NULL,
    type location_type NOT NULL DEFAULT 'warehouse',
    qr_code TEXT UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_warehouse_locations_updated_at
BEFORE UPDATE ON warehouse_locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE stock_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
    location_id UUID NOT NULL REFERENCES warehouse_locations(id) ON DELETE RESTRICT,
    lot_number TEXT,
    quantity NUMERIC(14, 4) NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    status stock_status NOT NULL DEFAULT 'available',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_stock_items_updated_at
BEFORE UPDATE ON stock_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE stock_movements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    stock_item_id UUID NOT NULL REFERENCES stock_items(id) ON DELETE RESTRICT,
    production_order_id UUID REFERENCES production_orders(id) ON DELETE SET NULL,
    movement_type stock_movement_type NOT NULL,
    quantity NUMERIC(14, 4) NOT NULL CHECK (quantity > 0),
    from_location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    to_location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (from_location_id IS NOT NULL OR to_location_id IS NOT NULL)
);

-- ============================================================
-- QUALITY
-- ============================================================

CREATE TABLE quality_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    production_order_id UUID NOT NULL REFERENCES production_orders(id) ON DELETE CASCADE,
    operation_id UUID REFERENCES operations(id) ON DELETE SET NULL,
    inspector_id UUID REFERENCES users(id) ON DELETE SET NULL,
    status quality_status NOT NULL DEFAULT 'draft',
    result quality_result,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_at TIMESTAMPTZ
);

CREATE TABLE inspection_characteristics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quality_record_id UUID NOT NULL REFERENCES quality_records(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    nominal_value NUMERIC(14, 4),
    lower_tolerance NUMERIC(14, 4),
    upper_tolerance NUMERIC(14, 4),
    unit TEXT,
    method TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE measurement_results (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    characteristic_id UUID NOT NULL REFERENCES inspection_characteristics(id) ON DELETE CASCADE,
    measurement_tool_id UUID,
    measured_value NUMERIC(14, 4),
    result_status result_status NOT NULL DEFAULT 'not_checked',
    measured_by UUID REFERENCES users(id) ON DELETE SET NULL,
    measured_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE nonconformities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    quality_record_id UUID NOT NULL REFERENCES quality_records(id) ON DELETE CASCADE,
    severity nonconformity_severity NOT NULL DEFAULT 'minor',
    description TEXT NOT NULL,
    disposition nonconformity_disposition NOT NULL DEFAULT 'not_decided',
    status nonconformity_status NOT NULL DEFAULT 'open',
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closed_at TIMESTAMPTZ
);

-- ============================================================
-- DOCUMENT LINKS
-- ============================================================

CREATE TABLE document_links (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    document_revision_id UUID NOT NULL REFERENCES document_revisions(id) ON DELETE CASCADE,
    production_order_id UUID REFERENCES production_orders(id) ON DELETE CASCADE,
    quality_record_id UUID REFERENCES quality_records(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (
        production_order_id IS NOT NULL
        OR quality_record_id IS NOT NULL
        OR product_id IS NOT NULL
    )
);

-- ============================================================
-- TOOLING AND CALIBRATION
-- ============================================================

CREATE TABLE measurement_tools (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tool_code TEXT NOT NULL UNIQUE,
    qr_code TEXT UNIQUE,
    name TEXT NOT NULL,
    type TEXT,
    status tool_status NOT NULL DEFAULT 'available',
    current_location_id UUID REFERENCES warehouse_locations(id) ON DELETE SET NULL,
    calibration_due_date DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_measurement_tools_updated_at
BEFORE UPDATE ON measurement_tools
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

ALTER TABLE measurement_results
ADD CONSTRAINT fk_measurement_results_tool
FOREIGN KEY (measurement_tool_id) REFERENCES measurement_tools(id) ON DELETE SET NULL;

CREATE TABLE tool_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    measurement_tool_id UUID NOT NULL REFERENCES measurement_tools(id) ON DELETE RESTRICT,
    issued_to_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    production_order_id UUID REFERENCES production_orders(id) ON DELETE SET NULL,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    returned_at TIMESTAMPTZ,
    status tool_issue_status NOT NULL DEFAULT 'issued'
);

CREATE TABLE calibration_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    measurement_tool_id UUID NOT NULL REFERENCES measurement_tools(id) ON DELETE CASCADE,
    calibration_date DATE NOT NULL,
    next_due_date DATE NOT NULL,
    result calibration_result NOT NULL,
    certificate_reference TEXT,
    performed_by TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (next_due_date >= calibration_date)
);

-- ============================================================
-- ANALYTICS, NOTIFICATIONS AND LICENSING
-- ============================================================

CREATE TABLE kpi_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    production_order_id UUID REFERENCES production_orders(id) ON DELETE SET NULL,
    quality_record_id UUID REFERENCES quality_records(id) ON DELETE SET NULL,
    kpi_name TEXT NOT NULL,
    kpi_value NUMERIC(14, 4),
    unit TEXT,
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    measurement_tool_id UUID REFERENCES measurement_tools(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE licenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    license_key_hash TEXT NOT NULL UNIQUE,
    organization_name TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'active',
    valid_from DATE,
    valid_until DATE,
    max_users INTEGER CHECK (max_users IS NULL OR max_users > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_licenses_updated_at
BEFORE UPDATE ON licenses
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Optional link between users and license state.
ALTER TABLE users
ADD COLUMN license_id UUID REFERENCES licenses(id) ON DELETE SET NULL;

-- ============================================================
-- AUDIT LOG
-- ============================================================

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    action audit_action NOT NULL,
    old_value JSONB,
    new_value JSONB,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_customer_orders_customer_id ON customer_orders(customer_id);
CREATE INDEX idx_customer_orders_status ON customer_orders(status);
CREATE INDEX idx_production_orders_product_id ON production_orders(product_id);
CREATE INDEX idx_production_orders_status ON production_orders(status);
CREATE INDEX idx_operations_production_order_id ON operations(production_order_id);
CREATE INDEX idx_operations_status ON operations(status);
CREATE INDEX idx_production_reports_operation_id ON production_reports(operation_id);
CREATE INDEX idx_stock_items_material_id ON stock_items(material_id);
CREATE INDEX idx_stock_items_location_id ON stock_items(location_id);
CREATE INDEX idx_stock_movements_stock_item_id ON stock_movements(stock_item_id);
CREATE INDEX idx_stock_movements_production_order_id ON stock_movements(production_order_id);
CREATE INDEX idx_quality_records_production_order_id ON quality_records(production_order_id);
CREATE INDEX idx_quality_records_status ON quality_records(status);
CREATE INDEX idx_measurement_results_characteristic_id ON measurement_results(characteristic_id);
CREATE INDEX idx_measurement_results_tool_id ON measurement_results(measurement_tool_id);
CREATE INDEX idx_document_revisions_document_id ON document_revisions(document_id);
CREATE INDEX idx_document_links_production_order_id ON document_links(production_order_id);
CREATE INDEX idx_measurement_tools_status ON measurement_tools(status);
CREATE INDEX idx_measurement_tools_calibration_due_date ON measurement_tools(calibration_due_date);
CREATE INDEX idx_tool_issues_measurement_tool_id ON tool_issues(measurement_tool_id);
CREATE INDEX idx_calibration_events_tool_id ON calibration_events(measurement_tool_id);
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ============================================================
-- INITIAL ROLE AND PERMISSION SEED DRAFT
-- ============================================================

INSERT INTO roles (name, description, is_system_role) VALUES
('Operator', 'Performs assigned production tasks and reports progress or issues.', TRUE),
('Leader', 'Coordinates work, assigns tasks and monitors performance.', TRUE),
('Warehouse User', 'Handles material receipts, stock movements, locations and issues to production.', TRUE),
('Quality User', 'Creates and reviews inspection records and measurement-related data.', TRUE),
('Tooling / Calibration Owner', 'Manages measurement tools, issue history and calibration due dates.', TRUE),
('Document Controller', 'Manages controlled documents, drawings, work instructions and revisions.', TRUE),
('Analyst', 'Reviews dashboards, reports and KPIs without changing operational data.', TRUE),
('Administrator', 'Manages users, roles, modules, system configuration and licensing.', TRUE);

INSERT INTO permissions (code, description) VALUES
('production.task.view', 'View assigned production tasks.'),
('production.report.create', 'Create production progress reports.'),
('production.issue.report', 'Report production issues.'),
('production.order.create', 'Create production orders.'),
('warehouse.stock.view', 'View warehouse stock.'),
('warehouse.material.receive', 'Receive material.'),
('warehouse.material.issue', 'Issue material to production.'),
('quality.record.create', 'Create inspection records.'),
('quality.record.approve', 'Approve inspection records.'),
('document.view', 'View controlled documents.'),
('document.revision.create', 'Upload or create document revisions.'),
('document.revision.approve', 'Approve document revisions.'),
('tooling.tool.view', 'View measurement tools.'),
('tooling.tool.issue', 'Issue tools to operators or production.'),
('tooling.calibration.update', 'Update calibration data.'),
('analytics.dashboard.view', 'View analytics dashboards.'),
('admin.user.manage', 'Manage users.'),
('admin.role.manage', 'Manage roles and permissions.'),
('admin.license.manage', 'Manage license settings.');

-- ============================================================
-- OPEN QUESTIONS FOR v0.2
-- ============================================================

-- 1. Should stock reservations become a separate table?
-- 2. Should quality approvals require two users or electronic signatures?
-- 3. Should calibration providers be modeled as suppliers or a separate entity?
-- 4. Should measurement results support repeated samples for MSA studies?
-- 5. Should document storage use local files, object storage or external references?
-- 6. Should license validation be stored locally only as cache from an external license server?
