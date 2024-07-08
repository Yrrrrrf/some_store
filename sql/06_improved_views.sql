-- -----------------------------------------------------------------------------
-- View: store.view_sale_products
-- Description: Returns the list of products for a specific sale
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW store.view_sale_products AS
SELECT
    sd.sale_id,                    -- The ID of the sale
    p.code AS product_code,        -- The product code (SKU)
    p.description AS product_name, -- The product description/name
    sd.quantity,                   -- The quantity of the product sold in this sale
    sd.unit_price,                 -- The unit price of the product at the time of sale
    (sd.quantity * sd.unit_price) AS total_price -- The total price for this product in this sale
FROM
    store.sale_details sd          -- Join with the sale_details table
JOIN
    store.product p ON sd.product_id = p.id -- Join with the product table to get product information
-- Note: This view can be queried with "WHERE sale_id = X" to get products for a specific sale

-- -----------------------------------------------------------------------------
-- View: store.view_neo_sale
-- Description: Returns sale data including vendor name and shipping address
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW store.view_neo_sale AS
SELECT
    s.id AS sale_id,               -- The unique identifier for the sale
    v.name AS vendor_name,         -- The name of the vendor who made the sale
    sa.address_line1,              -- The first line of the shipping address
    sa.city,                       -- The city of the shipping address
    sa.postal_code,                -- The postal code of the shipping address
    s.sale_date                    -- The date of the sale
FROM
    store.sale s                   -- Start with the sale table
JOIN
    store.vendor v ON s.vendor_id = v.id -- Join with the vendor table to get the vendor name
JOIN
    store.shipping_address sa ON s.shipping_address_id = sa.id -- Join with shipping_address to get address details

-- -----------------------------------------------------------------------------
-- View: store.view_purchase_products
-- Description: Returns the list of products for a specific purchase
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW store.view_purchase_products AS
SELECT
    pd.purchase_id,                -- The ID of the purchase
    p.code AS product_code,        -- The product code (SKU)
    p.description AS product_name, -- The product description/name
    pd.quantity,                   -- The quantity of the product purchased
    pd.unit_price,                 -- The unit price of the product at the time of purchase
    (pd.quantity * pd.unit_price) AS total_price -- The total price for this product in this purchase
FROM
    store.purchase_details pd      -- Join with the purchase_details table
JOIN
    store.product p ON pd.product_id = p.id -- Join with the product table to get product information
-- Note: This view can be queried with "WHERE purchase_id = X" to get products for a specific purchase

-- -----------------------------------------------------------------------------
-- View: store.view_neo_purchase
-- Description: Returns purchase data including provider name
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW store.view_neo_purchase AS
SELECT
    p.id AS purchase_id,           -- The unique identifier for the purchase
    pr.name AS provider_name,      -- The name of the provider who supplied the products
    p.purchase_date                -- The date of the purchase
FROM
    store.purchase p               -- Start with the purchase table
JOIN
    store.provider pr ON p.provider_id = pr.id -- Join with the provider table to get the provider name


-- -----------------------------------------------------------------------------
-- View: store.view_product_details
-- Description: Returns detailed product information including category and inventory
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW store.view_product_details AS
SELECT
    p.id AS product_id,            -- The unique identifier for the product
    p.code AS product_code,        -- The product code (SKU)
    p.description AS product_name, -- The product description/name
    c.name AS category_name,       -- The name of the category the product belongs to
    p.unit_price,                  -- The current unit price of the product
    store.get_product_inventory(p.id) AS inventory, -- The current inventory of the product
    p.image_url                    -- The image URL of the product
FROM
    store.product p                -- Start with the product table
JOIN
    store.category c ON p.category_id = c.id -- Join with the category table to get the category name

-- Example usage:
-- This will return all products with their details, category, and current inventory

-- -----------------------------------------------------------------------------
-- Example usage of the views:
-- -----------------------------------------------------------------------------

SELECT * FROM store.view_sale_products;
SELECT * FROM store.view_neo_sale;
SELECT * FROM store.view_purchase_products;
SELECT * FROM store.view_neo_purchase;
SELECT * FROM store.view_product_details;
