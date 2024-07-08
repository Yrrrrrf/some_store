-- File: 05_data_verification.sql
-- Description: This file contains SQL queries to verify the integrity of the store database
--              and ensure that all data is accurate and consistent.

-- -----------------------------------------------------------------------------
-- Data Verification
-- -----------------------------------------------------------------------------

-- Verify the data in all tables
SELECT 'Categories' AS table_name, COUNT(*) AS row_count FROM store.category
UNION ALL
SELECT 'Products', COUNT(*) FROM store.product
UNION ALL
SELECT 'Providers', COUNT(*) FROM store.provider
UNION ALL
SELECT 'Customers', COUNT(*) FROM store.customer
UNION ALL
SELECT 'Shipping Addresses', COUNT(*) FROM store.shipping_address
UNION ALL
SELECT 'Vendors', COUNT(*) FROM store.vendor
UNION ALL
SELECT 'Purchases', COUNT(*) FROM store.purchase
UNION ALL
SELECT 'Purchase Details', COUNT(*) FROM store.purchase_details
UNION ALL
SELECT 'Sales', COUNT(*) FROM store.sale
UNION ALL
SELECT 'Sale Details', COUNT(*) FROM store.sale_details
UNION ALL
SELECT 'Cart Items', COUNT(*) FROM store.cart;

-- Verify the integrity of relationships
SELECT 'Products without Category' AS check_name, COUNT(*) AS invalid_count
FROM store.product p
LEFT JOIN store.category c ON p.category_id = c.id
WHERE c.id IS NULL
UNION ALL
SELECT 'Purchase Details without valid Purchase', COUNT(*)
FROM store.purchase_details pd
LEFT JOIN store.purchase p ON pd.purchase_id = p.id
WHERE p.id IS NULL
UNION ALL
SELECT 'Purchase Details without valid Product', COUNT(*)
FROM store.purchase_details pd
LEFT JOIN store.product p ON pd.product_id = p.id
WHERE p.id IS NULL
UNION ALL
SELECT 'Sales without valid Customer', COUNT(*)
FROM store.sale s
LEFT JOIN store.customer c ON s.customer_id = c.id
WHERE c.id IS NULL
UNION ALL
SELECT 'Sales without valid Vendor', COUNT(*)
FROM store.sale s
LEFT JOIN store.vendor v ON s.vendor_id = v.id
WHERE v.id IS NULL
UNION ALL
SELECT 'Sales without valid Shipping Address', COUNT(*)
FROM store.sale s
LEFT JOIN store.shipping_address sa ON s.shipping_address_id = sa.id
WHERE sa.id IS NULL
UNION ALL
SELECT 'Sale Details without valid Sale', COUNT(*)
FROM store.sale_details sd
LEFT JOIN store.sale s ON sd.sale_id = s.id
WHERE s.id IS NULL
UNION ALL
SELECT 'Sale Details without valid Product', COUNT(*)
FROM store.sale_details sd
LEFT JOIN store.product p ON sd.product_id = p.id
WHERE p.id IS NULL
UNION ALL
SELECT 'Cart Items without valid Customer', COUNT(*)
FROM store.cart c
LEFT JOIN store.customer cu ON c.customer_id = cu.id
WHERE cu.id IS NULL
UNION ALL
SELECT 'Cart Items without valid Product', COUNT(*)
FROM store.cart c
LEFT JOIN store.product p ON c.product_id = p.id
WHERE p.id IS NULL;

-- Verify the auto-generated sale references
SELECT id, customer_id, vendor_id, sale_date, reference
FROM store.sale
ORDER BY id
LIMIT 10;

-- Check for any negative quantities or prices
SELECT 'Negative Quantity in Purchase Details' AS check_name, COUNT(*) AS invalid_count
FROM store.purchase_details
WHERE quantity < 0
UNION ALL
SELECT 'Negative Unit Price in Purchase Details', COUNT(*)
FROM store.purchase_details
WHERE unit_price < 0
UNION ALL
SELECT 'Negative Quantity in Sale Details', COUNT(*)
FROM store.sale_details
WHERE quantity < 0
UNION ALL
SELECT 'Negative Unit Price in Sale Details', COUNT(*)
FROM store.sale_details
WHERE unit_price < 0
UNION ALL
SELECT 'Negative Quantity in Cart', COUNT(*)
FROM store.cart
WHERE quantity < 0;

-- Check for orphaned records
SELECT 'Orphaned Shipping Addresses' AS check_name, COUNT(*) AS orphaned_count
FROM store.shipping_address sa
LEFT JOIN store.customer c ON sa.customer_id = c.id
WHERE c.id IS NULL;

-- Verify product inventory
SELECT p.id, p.code, p.description,
       COALESCE(purchases.total_purchased, 0) AS total_purchased,
       COALESCE(sales.total_sold, 0) AS total_sold,
       COALESCE(purchases.total_purchased, 0) - COALESCE(sales.total_sold, 0) AS calculated_inventory
FROM store.product p
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_purchased
    FROM store.purchase_details
    GROUP BY product_id
) purchases ON p.id = purchases.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM store.sale_details
    GROUP BY product_id
) sales ON p.id = sales.product_id
ORDER BY p.id
;
