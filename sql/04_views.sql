-- Sales by Invoice
DROP VIEW IF EXISTS sales_by_invoice;
CREATE VIEW sales_by_invoice AS
SELECT s.id AS folio_venta, c.name AS nombre_cliente, s.sale_date AS fecha_venta, s.total_amount AS importe_total
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id;

-- Sales by Product
DROP VIEW IF EXISTS sales_by_product;
CREATE VIEW sales_by_product AS
SELECT p.id AS cod_art, p.description AS nom_articulo, SUM(sd.quantity) AS cantidad_total_vend, SUM(sd.quantity * sd.unit_price) AS importe_total_vend
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description;

-- Sales by Customer
DROP VIEW IF EXISTS sales_by_customer;
CREATE VIEW sales_by_customer AS
SELECT c.id AS id_cliente, c.name AS nom_cliente, SUM(s.total_amount) AS importe_total_vendido
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY c.id, c.name;

-- Sales by Month
DROP VIEW IF EXISTS sales_by_month;
CREATE VIEW sales_by_month AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS mes, SUM(s.total_amount) AS importe_total_vendido
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM');

-- Sales by Month by Customer
DROP VIEW IF EXISTS sales_by_month_by_customer;
CREATE VIEW sales_by_month_by_customer AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS mes, c.name AS nom_cliente, SUM(s.total_amount) AS importe_total_vendido
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), c.name;

-- Inventory of Products
DROP VIEW IF EXISTS product_inventory;
CREATE VIEW product_inventory AS
SELECT p.id AS cod_art, p.description AS nom_articulo, p.unit_price AS precio_unitario
FROM store.product p;

-- Top Selling Products
DROP VIEW IF EXISTS top_selling_products;
CREATE VIEW top_selling_products AS
SELECT p.id AS cod_art, p.description AS nom_articulo, SUM(sd.quantity) AS cantidad_total_vend
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description
ORDER BY SUM(sd.quantity) DESC
LIMIT 10;

-- Revenue by Vendor
DROP VIEW IF EXISTS revenue_by_vendor;
CREATE VIEW revenue_by_vendor AS
SELECT v.id AS vendor_id, v.name AS vendor_name, SUM(s.total_amount) AS total_revenue
FROM store.sale s
JOIN store.vendor v ON s.vendor_id = v.id
GROUP BY v.id, v.name;

-- Purchases by Provider
DROP VIEW IF EXISTS purchases_by_provider;
CREATE VIEW purchases_by_provider AS
SELECT pr.id AS provider_id, pr.name AS provider_name, SUM(p.total_amount) AS total_spent
FROM store.purchase p
JOIN store.provider pr ON p.provider_id = pr.id
GROUP BY pr.id, pr.name;

-- Monthly Revenue
DROP VIEW IF EXISTS monthly_revenue;
CREATE VIEW monthly_revenue AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS month, SUM(s.total_amount) AS total_revenue
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY month;

-- Reporte de ventas (id_venta, fecha_venta, cliente, importe_total) con filtrado por fecha de inicio y fecha fin
DROP VIEW IF EXISTS report_sales;
CREATE VIEW report_sales AS
SELECT s.id AS id_venta, s.sale_date AS fecha_venta, c.name AS cliente, s.total_amount AS importe_total
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id;

-- Reporte de venta por cliente (id_cliente, nom_cliente, importe total)
DROP VIEW IF EXISTS report_sales_by_customer;
CREATE VIEW report_sales_by_customer AS
SELECT c.id AS id_cliente, c.name AS nombre_cliente, SUM(s.total_amount) AS importe_total_vendido
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY c.id, c.name;

-- Reporte de venta por articulo (id_articulo, nom_articulo, cantidad vendida, importe total)
DROP VIEW IF EXISTS report_sales_by_product;
CREATE VIEW report_sales_by_product AS
SELECT p.id AS id_articulo, p.description AS nombre_articulo, SUM(sd.quantity) AS cantidad_vendida, SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description;

-- Reporte de ventas por mes (mes, importe total de ventas)
DROP VIEW IF EXISTS report_sales_by_month;
CREATE VIEW report_sales_by_month AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS mes, SUM(s.total_amount) AS importe_total_vendido
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM');

-- Reporte de ventas por mes por articulo (mes, articulo, cantidad_vendida, importe total ventas)
DROP VIEW IF EXISTS report_sales_by_month_by_product;
CREATE VIEW report_sales_by_month_by_product AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS mes, p.description AS nombre_articulo, SUM(sd.quantity) AS cantidad_vendida, SUM(sd.quantity * sd.unit_price) AS importe_total_vendido
FROM store.sale_details sd
JOIN store.sale s ON sd.sale_id = s.id
JOIN store.product p ON sd.product_id = p.id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), p.description;

-- Reporte de existencias (id_articulo, nombre_articulo, existencias)
DROP VIEW IF EXISTS report_product_inventory;
CREATE VIEW report_product_inventory AS
SELECT p.id AS id_articulo, p.description AS nombre_articulo, p.unit_price AS precio_unitario
FROM store.product p;

-- Testing the report views
SELECT * FROM report_sales;
SELECT * FROM report_sales_by_customer;
SELECT * FROM report_sales_by_product;
SELECT * FROM report_sales_by_month;
SELECT * FROM report_sales_by_month_by_product;
SELECT * FROM report_product_inventory;

-- Select all the views in the database
SELECT table_name
FROM information_schema.views
WHERE table_schema = 'store';

-- Select all the views in the database with their respective metadata information
SELECT table_name, view_definition
FROM information_schema.views
WHERE table_schema = 'store';
