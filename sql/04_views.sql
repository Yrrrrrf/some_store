-- Sales by Invoice
DROP VIEW IF EXISTS sales_by_invoice;
CREATE VIEW sales_by_invoice AS
SELECT s.id AS "Folio Venta", c.name AS "Nombre del cliente", s.sale_date AS "Fecha Venta", s.total_amount AS "Importe Total"
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id;

-- Sales by Product
DROP VIEW IF EXISTS sales_by_product;
CREATE VIEW sales_by_product AS
SELECT p.id AS "Cod Art", p.description AS "Nom Articulo", SUM(sd.quantity) AS "Cantidad Total Vend", SUM(sd.quantity * sd.unit_price) AS "Importe Total Vend"
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description;

-- Sales by Customer
DROP VIEW IF EXISTS sales_by_customer;
CREATE VIEW sales_by_customer AS
SELECT c.id AS "Id_cliente", c.name AS "Nom Cliente", SUM(s.total_amount) AS "Importe Total Vendido"
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY c.id, c.name;

-- Sales by Month
DROP VIEW IF EXISTS sales_by_month;
CREATE VIEW sales_by_month AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS "MES", SUM(s.total_amount) AS "Importe Total Vendido"
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM');

-- Sales by Month by Customer
DROP VIEW IF EXISTS sales_by_month_by_customer;
CREATE VIEW sales_by_month_by_customer AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS "MES", c.name AS "Nom Cliente", SUM(s.total_amount) AS "Importe Total Vendido"
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), c.name;

-- Inventory of Products
DROP VIEW IF EXISTS product_inventory;
CREATE VIEW product_inventory AS
SELECT p.id AS "Cod Art", p.description AS "Nom Artículo", p.unit_price AS "Precio Unitario"
FROM store.product p;

-- Top Selling Products
DROP VIEW IF EXISTS top_selling_products;
CREATE VIEW top_selling_products AS
SELECT p.id AS "Cod Art", p.description AS "Nom Articulo", SUM(sd.quantity) AS "Cantidad Total Vend"
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description
ORDER BY SUM(sd.quantity) DESC
LIMIT 10;  -- Adjust the limit as needed

-- Revenue by Vendor
DROP VIEW IF EXISTS revenue_by_vendor;
CREATE VIEW revenue_by_vendor AS
SELECT v.id AS "Vendor ID", v.name AS "Vendor Name", SUM(s.total_amount) AS "Total Revenue"
FROM store.sale s
JOIN store.vendor v ON s.vendor_id = v.id
GROUP BY v.id, v.name;

-- Purchases by Provider
DROP VIEW IF EXISTS purchases_by_provider;
CREATE VIEW purchases_by_provider AS
SELECT pr.id AS "Provider ID", pr.name AS "Provider Name", SUM(p.total_amount) AS "Total Spent"
FROM store.purchase p
JOIN store.provider pr ON p.provider_id = pr.id
GROUP BY pr.id, pr.name;

-- Monthly Revenue
DROP VIEW IF EXISTS monthly_revenue;
CREATE VIEW monthly_revenue AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS "Month", SUM(s.total_amount) AS "Total Revenue"
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY "Month";


SELECT * FROM sales_by_invoice;
SELECT * FROM sales_by_product;
SELECT * FROM sales_by_customer;
SELECT * FROM sales_by_month;
SELECT * FROM sales_by_month_by_customer;
SELECT * FROM product_inventory;
SELECT * FROM top_selling_products;
SELECT * FROM revenue_by_vendor;
SELECT * FROM purchases_by_provider;
SELECT * FROM monthly_revenue;

-- * The views below are named as 'report_*' to indicate that they are intended for reporting purposes
-- ^ This obeys the naming convention of the views that are REQUESTED on the requirements for the project
-- Reporte de ventas (id_venta, fecha_venta, cliente, importe_total) con filtrado por fecha de inicio y fecha fin
DROP VIEW IF EXISTS report_sales;
CREATE VIEW report_sales AS
SELECT s.id AS "Id Venta", s.sale_date AS "Fecha Venta", c.name AS "Cliente", s.total_amount AS "Importe Total"
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id;

-- Reporte de venta por cliente (id_cliente, nom_cliente, importe total)
DROP VIEW IF EXISTS report_sales_by_customer;
CREATE VIEW report_sales_by_customer AS
SELECT c.id AS "Id Cliente", c.name AS "Nombre Cliente", SUM(s.total_amount) AS "Importe Total Vendido"
FROM store.sale s
JOIN store.customer c ON s.customer_id = c.id
GROUP BY c.id, c.name;

-- Reporte de venta por articulo (id_articulo, nom_articulo, cantidad vendida, importe total)
DROP VIEW IF EXISTS report_sales_by_product;
CREATE VIEW report_sales_by_product AS
SELECT p.id AS "Id Articulo", p.description AS "Nombre Articulo", SUM(sd.quantity) AS "Cantidad Vendida", SUM(sd.quantity * sd.unit_price) AS "Importe Total Vendido"
FROM store.sale_details sd
JOIN store.product p ON sd.product_id = p.id
GROUP BY p.id, p.description;

-- Reporte de ventas por mes (mes, importe total de ventas)
DROP VIEW IF EXISTS report_sales_by_month;
CREATE VIEW report_sales_by_month AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS "Mes", SUM(s.total_amount) AS "Importe Total Vendido"
FROM store.sale s
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM');

-- Reporte de ventas por mes por articulo (mes, articulo, cantidad_vendida, importe total ventas)
DROP VIEW IF EXISTS report_sales_by_month_by_product;
CREATE VIEW report_sales_by_month_by_product AS
SELECT TO_CHAR(s.sale_date, 'YYYY-MM') AS "Mes", p.description AS "Nombre Articulo", SUM(sd.quantity) AS "Cantidad Vendida", SUM(sd.quantity * sd.unit_price) AS "Importe Total Vendido"
FROM store.sale_details sd
JOIN store.sale s ON sd.sale_id = s.id
JOIN store.product p ON sd.product_id = p.id
GROUP BY TO_CHAR(s.sale_date, 'YYYY-MM'), p.description;

-- Reporte de existencias (id_articulo, nombre_articulo, existencias)
DROP VIEW IF EXISTS report_product_inventory;
CREATE VIEW report_product_inventory AS
SELECT p.id AS "Id Articulo", p.description AS "Nombre Articulo", p.unit_price AS "Precio Unitario"
FROM store.product p;

-- ? Testing the report views
SELECT * FROM report_sales;
SELECT * FROM report_sales_by_customer;
SELECT * FROM report_sales_by_product;
SELECT * FROM report_sales_by_month;
SELECT * FROM report_sales_by_month_by_product;
SELECT * FROM report_product_inventory;