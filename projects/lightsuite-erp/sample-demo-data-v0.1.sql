-- LightSuite ERP — Sample Demo Data v0.1
-- Status: SQL seed draft for portfolio and system-design demonstration.
-- Requirement: run schema-v0.1.sql first.
-- Note: password hashes and license hash are fake placeholders.

BEGIN;

-- ============================================================
-- LICENSE
-- ============================================================

INSERT INTO licenses (
    id,
    license_key_hash,
    organization_name,
    status,
    valid_from,
    valid_until,
    max_users
) VALUES (
    '00000000-0000-0000-0000-000000001001',
    'demo-license-hash-not-real',
    'Demo Manufacturing Company',
    'active',
    '2026-01-01',
    '2026-12-31',
    10
);

-- ============================================================
-- USERS
-- ============================================================

INSERT INTO users (id, name, email, password_hash, status, license_id) VALUES
('00000000-0000-0000-0000-000000000001', 'Alice Admin', 'alice.admin@example.com', 'demo_hash_admin_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000002', 'Leon Leader', 'leon.leader@example.com', 'demo_hash_leader_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000003', 'Olivia Operator', 'olivia.operator@example.com', 'demo_hash_operator_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000004', 'Walter Warehouse', 'walter.warehouse@example.com', 'demo_hash_warehouse_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000005', 'Quinn Quality', 'quinn.quality@example.com', 'demo_hash_quality_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000006', 'Theo Tooling', 'theo.tooling@example.com', 'demo_hash_tooling_not_real', 'active', '00000000-0000-0000-0000-000000001001'),
('00000000-0000-0000-0000-000000000007', 'Anna Analyst', 'anna.analyst@example.com', 'demo_hash_analyst_not_real', 'active', '00000000-0000-0000-0000-000000001001');

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000001', id FROM roles WHERE name = 'Administrator';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000002', id FROM roles WHERE name = 'Leader';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000003', id FROM roles WHERE name = 'Operator';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000004', id FROM roles WHERE name = 'Warehouse User';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000005', id FROM roles WHERE name = 'Quality User';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000006', id FROM roles WHERE name = 'Tooling / Calibration Owner';

INSERT INTO user_roles (user_id, role_id)
SELECT '00000000-0000-0000-0000-000000000007', id FROM roles WHERE name = 'Analyst';

-- ============================================================
-- MASTER DATA
-- ============================================================

INSERT INTO customers (id, name, customer_code, status) VALUES
('00000000-0000-0000-0000-000000002001', 'Demo Automotive Customer', 'CUST-DEMO-AUTO', 'active');

INSERT INTO suppliers (id, name, supplier_code, status) VALUES
('00000000-0000-0000-0000-000000002101', 'Demo Metals Supplier', 'SUP-DEMO-METALS', 'active');

INSERT INTO documents (
    id,
    document_number,
    title,
    document_type,
    owner_id,
    status
) VALUES (
    '00000000-0000-0000-0000-000000003001',
    'DRW-BRACKET-001',
    'Aluminium Mounting Bracket Drawing',
    'drawing',
    '00000000-0000-0000-0000-000000000005',
    'active'
);

INSERT INTO document_revisions (
    id,
    document_id,
    revision,
    file_path,
    approved_by,
    approved_at,
    valid_from
) VALUES (
    '00000000-0000-0000-0000-000000003002',
    '00000000-0000-0000-0000-000000003001',
    'A',
    'documents/demo/DRW-BRACKET-001_REV_A.pdf',
    '00000000-0000-0000-0000-000000000005',
    '2026-01-10T09:00:00Z',
    '2026-01-10'
);

INSERT INTO products (
    id,
    sku,
    name,
    revision,
    default_document_id,
    status
) VALUES (
    '00000000-0000-0000-0000-000000004001',
    'BRACKET-ALU-001',
    'Aluminium Mounting Bracket',
    'A',
    '00000000-0000-0000-0000-000000003001',
    'active'
);

INSERT INTO materials (
    id,
    material_code,
    ean_code,
    qr_code,
    name,
    unit,
    status
) VALUES (
    '00000000-0000-0000-0000-000000004101',
    'MAT-ALU-6082-BAR',
    '5900000000001',
    'QR-MAT-ALU-6082-BAR',
    'Aluminium bar 6082',
    'pcs',
    'active'
);

INSERT INTO product_material_requirements (
    id,
    product_id,
    material_id,
    quantity_required,
    unit
) VALUES (
    '00000000-0000-0000-0000-000000004201',
    '00000000-0000-0000-0000-000000004001',
    '00000000-0000-0000-0000-000000004101',
    1.0000,
    'pcs'
);

-- ============================================================
-- PRODUCTION
-- ============================================================

INSERT INTO customer_orders (
    id,
    customer_id,
    order_number,
    status,
    due_date
) VALUES (
    '00000000-0000-0000-0000-000000005001',
    '00000000-0000-0000-0000-000000002001',
    'CO-2026-0001',
    'confirmed',
    '2026-07-10'
);

INSERT INTO production_orders (
    id,
    customer_order_id,
    product_id,
    order_number,
    quantity_planned,
    quantity_completed,
    status,
    priority,
    planned_start_date,
    planned_end_date
) VALUES (
    '00000000-0000-0000-0000-000000005002',
    '00000000-0000-0000-0000-000000005001',
    '00000000-0000-0000-0000-000000004001',
    'PO-2026-0001',
    100.0000,
    24.0000,
    'in_progress',
    2,
    '2026-07-01',
    '2026-07-05'
);

INSERT INTO workstations (id, code, name, description, status) VALUES
('00000000-0000-0000-0000-000000006001', 'CNC-01', 'CNC Machining Station 01', 'Demo CNC workstation for bracket machining.', 'active');

INSERT INTO operations (
    id,
    production_order_id,
    workstation_id,
    sequence_number,
    name,
    status,
    planned_time_minutes,
    actual_time_minutes
) VALUES (
    '00000000-0000-0000-0000-000000006002',
    '00000000-0000-0000-0000-000000005002',
    '00000000-0000-0000-0000-000000006001',
    10,
    'CNC milling operation',
    'completed',
    180,
    195
);

INSERT INTO operation_assignments (
    id,
    operation_id,
    user_id,
    assigned_by
) VALUES (
    '00000000-0000-0000-0000-000000006003',
    '00000000-0000-0000-0000-000000006002',
    '00000000-0000-0000-0000-000000000003',
    '00000000-0000-0000-0000-000000000002'
);

INSERT INTO production_reports (
    id,
    operation_id,
    user_id,
    quantity_ok,
    quantity_nok,
    notes,
    reported_at
) VALUES (
    '00000000-0000-0000-0000-000000006101',
    '00000000-0000-0000-0000-000000006002',
    '00000000-0000-0000-0000-000000000003',
    24.0000,
    1.0000,
    'One part marked for quality review because of visible surface scratch.',
    '2026-07-01T12:30:00Z'
);

-- ============================================================
-- WAREHOUSE
-- ============================================================

INSERT INTO warehouse_locations (id, code, name, type, qr_code) VALUES
('00000000-0000-0000-0000-000000007001', 'WH-RAW-01', 'Raw Material Rack 01', 'warehouse', 'QR-WH-RAW-01'),
('00000000-0000-0000-0000-000000007002', 'PROD-BUF-01', 'Production Buffer 01', 'production_buffer', 'QR-PROD-BUF-01'),
('00000000-0000-0000-0000-000000007003', 'TOOL-ROOM-01', 'Tool Room 01', 'tool_room', 'QR-TOOL-ROOM-01');

INSERT INTO stock_items (
    id,
    material_id,
    location_id,
    lot_number,
    quantity,
    status
) VALUES (
    '00000000-0000-0000-0000-000000007101',
    '00000000-0000-0000-0000-000000004101',
    '00000000-0000-0000-0000-000000007001',
    'LOT-ALU-6082-2026-01',
    110.0000,
    'available'
);

INSERT INTO stock_movements (
    id,
    stock_item_id,
    production_order_id,
    movement_type,
    quantity,
    from_location_id,
    to_location_id,
    created_by,
    created_at
) VALUES
(
    '00000000-0000-0000-0000-000000007201',
    '00000000-0000-0000-0000-000000007101',
    NULL,
    'receipt',
    120.0000,
    NULL,
    '00000000-0000-0000-0000-000000007001',
    '00000000-0000-0000-0000-000000000004',
    '2026-06-28T08:15:00Z'
),
(
    '00000000-0000-0000-0000-000000007202',
    '00000000-0000-0000-0000-000000007101',
    '00000000-0000-0000-0000-000000005002',
    'issue',
    10.0000,
    '00000000-0000-0000-0000-000000007001',
    '00000000-0000-0000-0000-000000007002',
    '00000000-0000-0000-0000-000000000004',
    '2026-07-01T07:45:00Z'
);

-- ============================================================
-- TOOLING AND CALIBRATION
-- ============================================================

INSERT INTO measurement_tools (
    id,
    tool_code,
    qr_code,
    name,
    type,
    status,
    current_location_id,
    calibration_due_date
) VALUES (
    '00000000-0000-0000-0000-000000008001',
    'CAL-150-001',
    'QR-CAL-150-001',
    'Digital Caliper 150 mm',
    'caliper',
    'issued',
    '00000000-0000-0000-0000-000000007003',
    '2027-01-15'
);

INSERT INTO calibration_events (
    id,
    measurement_tool_id,
    calibration_date,
    next_due_date,
    result,
    certificate_reference,
    performed_by
) VALUES (
    '00000000-0000-0000-0000-000000008002',
    '00000000-0000-0000-0000-000000008001',
    '2026-01-15',
    '2027-01-15',
    'passed',
    'CERT-CAL-2026-001',
    'Demo Calibration Provider'
);

INSERT INTO tool_issues (
    id,
    measurement_tool_id,
    issued_to_user_id,
    production_order_id,
    issued_at,
    returned_at,
    status
) VALUES (
    '00000000-0000-0000-0000-000000008003',
    '00000000-0000-0000-0000-000000008001',
    '00000000-0000-0000-0000-000000000005',
    '00000000-0000-0000-0000-000000005002',
    '2026-07-01T10:00:00Z',
    NULL,
    'issued'
);

-- ============================================================
-- QUALITY
-- ============================================================

INSERT INTO quality_records (
    id,
    production_order_id,
    operation_id,
    inspector_id,
    status,
    result,
    created_at,
    approved_at
) VALUES (
    '00000000-0000-0000-0000-000000009001',
    '00000000-0000-0000-0000-000000005002',
    '00000000-0000-0000-0000-000000006002',
    '00000000-0000-0000-0000-000000000005',
    'in_review',
    'conditional',
    '2026-07-01T13:00:00Z',
    NULL
);

INSERT INTO inspection_characteristics (
    id,
    quality_record_id,
    name,
    nominal_value,
    lower_tolerance,
    upper_tolerance,
    unit,
    method
) VALUES
(
    '00000000-0000-0000-0000-000000009002',
    '00000000-0000-0000-0000-000000009001',
    'Main width',
    12.5000,
    -0.1000,
    0.1000,
    'mm',
    'Digital caliper measurement'
),
(
    '00000000-0000-0000-0000-000000009003',
    '00000000-0000-0000-0000-000000009001',
    'Surface condition',
    NULL,
    NULL,
    NULL,
    NULL,
    'Visual inspection'
);

INSERT INTO measurement_results (
    id,
    characteristic_id,
    measurement_tool_id,
    measured_value,
    result_status,
    measured_by,
    measured_at
) VALUES
(
    '00000000-0000-0000-0000-000000009101',
    '00000000-0000-0000-0000-000000009002',
    '00000000-0000-0000-0000-000000008001',
    12.4800,
    'ok',
    '00000000-0000-0000-0000-000000000005',
    '2026-07-01T13:10:00Z'
),
(
    '00000000-0000-0000-0000-000000009102',
    '00000000-0000-0000-0000-000000009003',
    NULL,
    NULL,
    'nok',
    '00000000-0000-0000-0000-000000000005',
    '2026-07-01T13:15:00Z'
);

INSERT INTO nonconformities (
    id,
    quality_record_id,
    severity,
    description,
    disposition,
    status,
    created_by,
    created_at
) VALUES (
    '00000000-0000-0000-0000-000000009201',
    '00000000-0000-0000-0000-000000009001',
    'minor',
    'Visible surface scratch on one produced bracket. Dimensional result remains within tolerance.',
    'hold',
    'open',
    '00000000-0000-0000-0000-000000000005',
    '2026-07-01T13:20:00Z'
);

-- ============================================================
-- DOCUMENT LINKS
-- ============================================================

INSERT INTO document_links (
    id,
    document_revision_id,
    production_order_id,
    quality_record_id,
    product_id
) VALUES (
    '00000000-0000-0000-0000-000000003101',
    '00000000-0000-0000-0000-000000003002',
    '00000000-0000-0000-0000-000000005002',
    '00000000-0000-0000-0000-000000009001',
    '00000000-0000-0000-0000-000000004001'
);

-- ============================================================
-- REPORTING, NOTIFICATIONS AND AUDIT
-- ============================================================

INSERT INTO kpi_records (
    id,
    production_order_id,
    quality_record_id,
    kpi_name,
    kpi_value,
    unit,
    recorded_at
) VALUES
(
    '00000000-0000-0000-0000-000000010001',
    '00000000-0000-0000-0000-000000005002',
    NULL,
    'quantity_ok_reported',
    24.0000,
    'pcs',
    '2026-07-01T14:00:00Z'
),
(
    '00000000-0000-0000-0000-000000010002',
    '00000000-0000-0000-0000-000000005002',
    NULL,
    'quantity_nok_reported',
    1.0000,
    'pcs',
    '2026-07-01T14:00:00Z'
),
(
    '00000000-0000-0000-0000-000000010003',
    NULL,
    '00000000-0000-0000-0000-000000009001',
    'open_quality_records',
    1.0000,
    'count',
    '2026-07-01T14:00:00Z'
),
(
    '00000000-0000-0000-0000-000000010004',
    NULL,
    NULL,
    'tools_due_soon',
    0.0000,
    'count',
    '2026-07-01T14:00:00Z'
);

INSERT INTO notifications (
    id,
    user_id,
    measurement_tool_id,
    title,
    message,
    is_read,
    created_at
) VALUES (
    '00000000-0000-0000-0000-000000011001',
    '00000000-0000-0000-0000-000000000005',
    NULL,
    'Quality record requires decision',
    'Quality record for PO-2026-0001 contains a minor nonconformity and requires disposition review.',
    FALSE,
    '2026-07-01T13:25:00Z'
);

INSERT INTO audit_logs (
    id,
    user_id,
    entity_type,
    entity_id,
    action,
    old_value,
    new_value,
    created_at
) VALUES
(
    '00000000-0000-0000-0000-000000012001',
    '00000000-0000-0000-0000-000000000002',
    'ProductionOrder',
    '00000000-0000-0000-0000-000000005002',
    'update',
    '{"status":"planned"}'::jsonb,
    '{"status":"in_progress"}'::jsonb,
    '2026-07-01T07:30:00Z'
),
(
    '00000000-0000-0000-0000-000000012002',
    '00000000-0000-0000-0000-000000000004',
    'StockMovement',
    '00000000-0000-0000-0000-000000007202',
    'create',
    NULL,
    '{"movement_type":"issue","quantity":10,"production_order":"PO-2026-0001"}'::jsonb,
    '2026-07-01T07:45:00Z'
),
(
    '00000000-0000-0000-0000-000000012003',
    '00000000-0000-0000-0000-000000000005',
    'QualityRecord',
    '00000000-0000-0000-0000-000000009001',
    'create',
    NULL,
    '{"status":"in_review","result":"conditional"}'::jsonb,
    '2026-07-01T13:00:00Z'
);

COMMIT;
