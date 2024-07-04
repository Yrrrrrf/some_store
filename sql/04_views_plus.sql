-- File: 04_views.sql (continued)
-- Description: Additional useful views for the store database

-- -----------------------------------------------------------------------------
-- View: report_vendor_performance
-- Description: Aggregates sales data by vendor
-- Usage: Use this view to evaluate vendor performance and calculate commissions
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_vendor_performance;
CREATE VIEW report_vendor_performance AS
SELECT
    v.id AS id_vendedor,
    v.name AS nombre_vendedor,
    COUNT(DISTINCT s.id) AS numero_ventas,
    SUM(s.total_amount) AS importe_total_vendido,
    AVG(s.total_amount) AS promedio_venta
FROM
    store.sale s
JOIN
    store.vendor v ON s.vendor_id = v.id
GROUP BY
    v.id, v.name;

-- Comment: This view provides insights into each vendor's performance,
-- including the number of sales, total sales amount, and average sale value.
-- It's useful for performance evaluations and commission calculations.

-- -----------------------------------------------------------------------------
-- View: report_product_profitability
-- Description: Calculates profitability for each product
-- Usage: Use this view to identify most and least profitable products
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_product_profitability;
CREATE VIEW report_product_profitability AS
SELECT
    p.id AS id_articulo,
    p.description AS nombre_articulo,
    p.unit_price AS precio_venta,
    AVG(pd.unit_price) AS costo_promedio,
    p.unit_price - AVG(pd.unit_price) AS margen_bruto,
    (p.unit_price - AVG(pd.unit_price)) / p.unit_price * 100 AS porcentaje_margen
FROM
    store.product p
LEFT JOIN
    store.purchase_details pd ON p.id = pd.product_id
GROUP BY
    p.id, p.description, p.unit_price;

-- Comment: This view calculates the profitability of each product by comparing
-- its selling price to its average purchase price. It helps in identifying
-- which products are most profitable and which might need price adjustments.

-- -----------------------------------------------------------------------------
-- View: report_customer_loyalty
-- Description: Analyzes customer purchase frequency and value
-- Usage: Use this view for customer segmentation and loyalty programs
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_customer_loyalty;
CREATE VIEW report_customer_loyalty AS
SELECT
    c.id AS id_cliente,
    c.name AS nombre_cliente,
    COUNT(s.id) AS numero_compras,
    SUM(s.total_amount) AS importe_total_compras,
    AVG(s.total_amount) AS promedio_compra,
    MAX(s.sale_date) AS ultima_compra,
    CURRENT_DATE - MAX(s.sale_date) AS dias_desde_ultima_compra
FROM
    store.customer c
LEFT JOIN
    store.sale s ON c.id = s.customer_id
GROUP BY
    c.id, c.name;

-- Comment: This view provides a comprehensive look at customer behavior,
-- including purchase frequency, total spend, average purchase value, and
-- recency of last purchase. It's valuable for customer segmentation,
-- loyalty programs, and targeted marketing efforts.

-- -----------------------------------------------------------------------------
-- View: report_inventory_turnover
-- Description: Calculates inventory turnover rate for each product
-- Usage: Use this view to optimize inventory management
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_inventory_turnover;
CREATE VIEW report_inventory_turnover AS
WITH inventory_levels AS (
    SELECT
        product_id,
        SUM(CASE WHEN transaction_type = 'purchase' THEN quantity ELSE -quantity END) AS current_inventory
    FROM (
        SELECT product_id, quantity, 'purchase' AS transaction_type FROM store.purchase_details
        UNION ALL
        SELECT product_id, quantity, 'sale' AS transaction_type FROM store.sale_details
    ) AS inventory_transactions
    GROUP BY product_id
)
SELECT
    p.id AS id_articulo,
    p.description AS nombre_articulo,
    COALESCE(SUM(sd.quantity), 0) AS cantidad_vendida,
    COALESCE(il.current_inventory, 0) AS inventario_actual,
    CASE
        WHEN COALESCE(il.current_inventory, 0) > 0 THEN
            COALESCE(SUM(sd.quantity), 0) / COALESCE(il.current_inventory, 1)
        ELSE 0
    END AS tasa_rotacion_inventario
FROM
    store.product p
LEFT JOIN
    store.sale_details sd ON p.id = sd.product_id
LEFT JOIN
    inventory_levels il ON p.id = il.product_id
GROUP BY
    p.id, p.description, il.current_inventory;

-- Comment: This view calculates the inventory turnover rate for each product.
-- It helps in identifying fast-moving and slow-moving products, which is
-- crucial for inventory management and purchasing decisions.

-- -----------------------------------------------------------------------------
-- Testing and Metadata Queries for New Views
-- -----------------------------------------------------------------------------

-- Test queries for each new report view
SELECT * FROM report_vendor_performance LIMIT 5;
SELECT * FROM report_product_profitability LIMIT 5;
SELECT * FROM report_customer_loyalty LIMIT 5;
SELECT * FROM report_inventory_turnover LIMIT 5;

-- Update the query to list all views including the new ones
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';

-- Update the query to show the definition of each report view including the new ones
SELECT table_name, view_definition
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';
