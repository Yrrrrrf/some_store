-- File: 04_views.sql
-- Description: This file contains SQL views for generating various reports
--              in the store database. These views provide quick access to
--              commonly needed sales, inventory, and performance data.

-- -----------------------------------------------------------------------------
-- View: report_sales
-- Description: Provides a detailed view of individual sales transactions
-- Usage: Use this view to get an overview of all sales or filter by date range
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales;
CREATE VIEW report_sales AS
SELECT
    s.id AS id_venta,
    s.sale_date AS fecha_venta,
    c.name AS cliente,
    v.name AS vendedor,
    s.reference AS referencia,
    SUM(sd.quantity * sd.unit_price) AS importe_total
FROM
    store.sale s
JOIN
    store.customer c ON s.customer_id = c.id
JOIN
    store.vendor v ON s.vendor_id = v.id
JOIN
    store.sale_details sd ON s.id = sd.sale_id
GROUP BY
    s.id, s.sale_date, c.name, v.name, s.reference;

-- -----------------------------------------------------------------------------
-- View: report_sales_by_customer
-- Description: Aggregates total sales by customer
-- Usage: Use this view to analyze customer purchasing patterns and identify top customers
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_customer;
CREATE VIEW report_sales_by_customer AS
SELECT
    c.id AS id_cliente,
    c.name AS nombre_cliente,
    COUNT(DISTINCT s.id) AS numero_ventas,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM
    store.customer c
LEFT JOIN
    store.sale s ON c.id = s.customer_id
LEFT JOIN
    store.sale_details sd ON s.id = sd.sale_id
GROUP BY
    c.id, c.name;

-- -----------------------------------------------------------------------------
-- View: report_sales_by_product
-- Description: Provides sales data aggregated by product
-- Usage: Use this view to analyze product performance and identify best-selling items
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_product;
CREATE VIEW report_sales_by_product AS
SELECT
    p.id AS id_articulo,
    p.description AS nombre_articulo,
    p.code AS codigo_articulo,
    SUM(sd.quantity) AS cantidad_vendida,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido,
    p.unit_price AS precio_actual
FROM
    store.product p
LEFT JOIN
    store.sale_details sd ON p.id = sd.product_id
GROUP BY
    p.id, p.description, p.code, p.unit_price;

-- -----------------------------------------------------------------------------
-- View: report_sales_by_month
-- Description: Aggregates monthly sales data
-- Usage: Use this view for trend analysis and month-over-month comparisons
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_month;
CREATE VIEW report_sales_by_month AS
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS mes,
    COUNT(DISTINCT s.id) AS numero_ventas,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM
    store.sale s
JOIN
    store.sale_details sd ON s.id = sd.sale_id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM');

-- -----------------------------------------------------------------------------
-- View: report_sales_by_month_by_product
-- Description: Detailed monthly sales data broken down by product
-- Usage: Use this view for in-depth analysis of product performance over time
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_month_by_product;
CREATE VIEW report_sales_by_month_by_product AS
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS mes,
    p.id AS id_articulo,
    p.description AS nombre_articulo,
    SUM(sd.quantity) AS cantidad_vendida,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM
    store.sale_details sd
JOIN
    store.sale s ON sd.sale_id = s.id
JOIN
    store.product p ON sd.product_id = p.id
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM'), p.id, p.description;

-- -----------------------------------------------------------------------------
-- View: report_product_inventory
-- Description: Current inventory status for all products
-- Usage: Use this view for quick inventory checks and pricing information
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_product_inventory;
CREATE VIEW report_product_inventory AS
SELECT
    p.id AS id_articulo,
    p.code AS codigo_articulo,
    p.description AS nombre_articulo,
    p.unit_price AS precio_unitario,
    COALESCE(purchases.total_purchased, 0) - COALESCE(sales.total_sold, 0) AS inventario_actual
FROM
    store.product p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_purchased
    FROM store.purchase_details
    GROUP BY product_id
) purchases ON p.id = purchases.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM store.sale_details
    GROUP BY product_id
) sales ON p.id = sales.product_id;

-- -----------------------------------------------------------------------------
-- New View: report_vendor_performance
-- Description: Analyzes sales performance by vendor
-- Usage: Use this view to evaluate vendor effectiveness and calculate commissions
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_vendor_performance;
CREATE VIEW report_vendor_performance AS
SELECT
    v.id AS id_vendedor,
    v.name AS nombre_vendedor,
    COUNT(DISTINCT s.id) AS numero_ventas,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido,
    AVG(sd.quantity * sd.unit_price) AS promedio_venta
FROM
    store.vendor v
LEFT JOIN
    store.sale s ON v.id = s.vendor_id
LEFT JOIN
    store.sale_details sd ON s.id = sd.sale_id
GROUP BY
    v.id, v.name;

-- -----------------------------------------------------------------------------
-- New View: report_product_profitability
-- Description: Calculates profitability for each product
-- Usage: Use this view to identify most and least profitable products
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_product_profitability;
CREATE VIEW report_product_profitability AS
SELECT
    p.id AS id_articulo,
    p.code AS codigo_articulo,
    p.description AS nombre_articulo,
    p.unit_price AS precio_venta,
    COALESCE(AVG(pd.unit_price), 0) AS costo_promedio,
    p.unit_price - COALESCE(AVG(pd.unit_price), 0) AS margen_bruto,
    CASE
        WHEN p.unit_price > 0 THEN
            ((p.unit_price - COALESCE(AVG(pd.unit_price), 0)) / p.unit_price) * 100
        ELSE 0
    END AS porcentaje_margen
FROM
    store.product p
LEFT JOIN
    store.purchase_details pd ON p.id = pd.product_id
GROUP BY
    p.id, p.code, p.description, p.unit_price;

-- -----------------------------------------------------------------------------
-- New View: report_customer_loyalty
-- Description: Analyzes customer purchase frequency and value
-- Usage: Use this view for customer segmentation and loyalty programs
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_customer_loyalty;
CREATE VIEW report_customer_loyalty AS
SELECT
    c.id AS id_cliente,
    c.name AS nombre_cliente,
    COUNT(DISTINCT s.id) AS numero_compras,
    SUM(sd.quantity * sd.unit_price) AS importe_total_compras,
    AVG(sd.quantity * sd.unit_price) AS promedio_compra,
    MAX(s.sale_date) AS fecha_ultima_compra,
    CURRENT_DATE - MAX(s.sale_date) AS dias_desde_ultima_compra
FROM
    store.customer c
LEFT JOIN
    store.sale s ON c.id = s.customer_id
LEFT JOIN
    store.sale_details sd ON s.id = sd.sale_id
GROUP BY
    c.id, c.name;

-- -----------------------------------------------------------------------------
-- Testing and Metadata Queries
-- -----------------------------------------------------------------------------

-- Test queries for each report view
SELECT * FROM report_sales LIMIT 5;
SELECT * FROM report_sales_by_customer LIMIT 5;
SELECT * FROM report_sales_by_product LIMIT 5;
SELECT * FROM report_sales_by_month LIMIT 5;
SELECT * FROM report_sales_by_month_by_product LIMIT 5;
SELECT * FROM report_product_inventory;
SELECT * FROM report_vendor_performance LIMIT 5;
SELECT * FROM report_product_profitability LIMIT 5;
SELECT * FROM report_customer_loyalty LIMIT 5;

-- Query to list all views in the 'store' schema
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';

-- Query to show the definition of each report view
SELECT table_name, view_definition
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';
