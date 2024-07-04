-- File: 04_views.sql
-- Description: This file contains SQL views for generating various reports
--              in the store database. These views are designed to provide
--              quick access to commonly needed sales and inventory data.

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
    s.total_amount AS importe_total
FROM
    store.sale s
JOIN
    store.customer c ON s.customer_id = c.id;

-- Comment: This view joins the sale and customer tables to provide
-- a comprehensive view of each sale, including the customer name.
-- It can be filtered by date range in queries to generate time-specific reports.

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
    SUM(s.total_amount) AS importe_total_vendido
FROM
    store.sale s
JOIN
    store.customer c ON s.customer_id = c.id
GROUP BY
    c.id, c.name;

-- Comment: This view calculates the total sales amount for each customer.
-- It's useful for customer segmentation and identifying high-value customers.

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
    SUM(sd.quantity) AS cantidad_vendida,
    SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM
    store.sale_details sd
JOIN
    store.product p ON sd.product_id = p.id
GROUP BY
    p.id, p.description;

-- Comment: This view aggregates sales data for each product, showing both
-- the quantity sold and the total revenue generated. It's essential for
-- inventory management and identifying popular products.

-- -----------------------------------------------------------------------------
-- View: report_sales_by_month
-- Description: Aggregates monthly sales data
-- Usage: Use this view for trend analysis and month-over-month comparisons
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_month;
CREATE VIEW report_sales_by_month AS
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS mes,
    SUM(s.total_amount) AS importe_total_vendido
FROM
    store.sale s
GROUP BY
    TO_CHAR(s.sale_date, 'YYYY-MM');

-- Comment: This view provides a monthly breakdown of total sales.
-- It's useful for tracking seasonal trends and overall business performance.

-- -----------------------------------------------------------------------------
-- View: report_sales_by_month_by_product
-- Description: Detailed monthly sales data broken down by product
-- Usage: Use this view for in-depth analysis of product performance over time
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_sales_by_month_by_product;
CREATE VIEW report_sales_by_month_by_product AS
SELECT
    TO_CHAR(s.sale_date, 'YYYY-MM') AS mes,
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
    TO_CHAR(s.sale_date, 'YYYY-MM'), p.description;

-- Comment: This view combines monthly aggregation with product-specific data.
-- It's particularly useful for identifying seasonal product trends and
-- analyzing the performance of specific products over time.

-- -----------------------------------------------------------------------------
-- View: report_product_inventory
-- Description: Current inventory status for all products
-- Usage: Use this view for quick inventory checks and pricing information
-- -----------------------------------------------------------------------------
DROP VIEW IF EXISTS report_product_inventory;
CREATE VIEW report_product_inventory AS
SELECT
    p.id AS id_articulo,
    p.description AS nombre_articulo,
    p.unit_price AS precio_unitario
FROM
    store.product p;

-- Comment: This view provides a snapshot of the current product inventory.
-- It's useful for quick price checks and basic inventory management.
-- Note: This view doesn't include the actual inventory count. Consider
-- adding an 'inventory' column to the product table if needed.

-- -----------------------------------------------------------------------------
-- Testing and Metadata Queries
-- -----------------------------------------------------------------------------

-- Test queries for each report view
SELECT * FROM report_sales LIMIT 5;
SELECT * FROM report_sales_by_customer LIMIT 5;
SELECT * FROM report_sales_by_product LIMIT 5;
SELECT * FROM report_sales_by_month LIMIT 5;
SELECT * FROM report_sales_by_month_by_product LIMIT 5;
SELECT * FROM report_product_inventory LIMIT 5;

-- Query to list all views in the 'store' schema
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';

-- Query to show the definition of each report view
SELECT table_name, view_definition
FROM information_schema.views
WHERE table_schema = 'store' AND table_name LIKE 'report_%';