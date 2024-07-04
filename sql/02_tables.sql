-- File: 02_tables.sql
-- Description: This file defines the table structure for the store database.
--              It includes tables for customers, vendors, products, providers,
--              purchases, sales, and their respective details.

-- -----------------------------------------------------------------------------
-- Table: store.customer
-- Description: Stores information about customers who make purchases
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.customer CASCADE;
CREATE TABLE store.customer (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each customer (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Full name of the customer
);

-- -----------------------------------------------------------------------------
-- Table: store.vendor
-- Description: Stores information about employees who sell products
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.vendor CASCADE;
CREATE TABLE store.vendor (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each vendor (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Full name of the vendor
);


-- -----------------------------------------------------------------------------
-- Table: store.product
-- Description: Stores information about products available for sale
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.product CASCADE;
CREATE TABLE store.product (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each product (auto-incremented)
    code VARCHAR(50) UNIQUE NOT NULL,   -- Unique product code for easy identification
    description VARCHAR(255) NOT NULL,  -- Detailed description of the product
    unit_price DECIMAL(10, 2) NOT NULL, -- Price per unit of the product
    image_url VARCHAR(255) DEFAULT ''  -- URL of the product image
--     image_url VARCHAR(255) DEFAULT 'https://via.placeholder.com/150'  -- URL of the product image
);
ALTER TABLE store.product ADD CONSTRAINT check_positive_price CHECK (unit_price > 0);

-- -----------------------------------------------------------------------------
-- Table: store.provider
-- Description: Stores information about suppliers who provide products
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.provider CASCADE;
CREATE TABLE store.provider (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each provider (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Name of the provider company
);

-- -----------------------------------------------------------------------------
-- Table: store.purchase
-- Description: Records purchases made from providers
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.purchase CASCADE;
CREATE TABLE store.purchase (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each purchase (auto-incremented)
    provider_id INT NOT NULL,           -- Reference to the provider who supplied the products
    purchase_date DATE NOT NULL,        -- Date when the purchase was made
    total_amount DECIMAL(10, 2) NOT NULL, -- Total cost of the purchase
    FOREIGN KEY (provider_id) REFERENCES store.provider(id)  -- Ensures data integrity with provider table
);

-- -----------------------------------------------------------------------------
-- Table: store.purchase_details
-- Description: Stores details of products included in each purchase
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.purchase_details CASCADE;
CREATE TABLE store.purchase_details (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each purchase detail (auto-incremented)
    purchase_id INT NOT NULL,           -- Reference to the associated purchase
    product_id INT NOT NULL,            -- Reference to the product purchased
    quantity INT NOT NULL,              -- Number of units purchased
    unit_price DECIMAL(10, 2) NOT NULL, -- Price per unit at the time of purchase
    FOREIGN KEY (purchase_id) REFERENCES store.purchase(id),  -- Ensures data integrity with purchase table
    FOREIGN KEY (product_id) REFERENCES store.product(id)     -- Ensures data integrity with product table
);

-- -----------------------------------------------------------------------------
-- Table: store.sale
-- Description: Records sales made to customers
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.sale CASCADE;
CREATE TABLE store.sale (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each sale (auto-incremented)
    customer_id INT NOT NULL,           -- Reference to the customer who made the purchase
    vendor_id INT NOT NULL,             -- Reference to the vendor who made the sale
    sale_date DATE NOT NULL,            -- Date when the sale was made
    reference VARCHAR(255) NOT NULL UNIQUE DEFAULT MD5(CONCAT(CAST(customer_id AS VARCHAR), CAST(vendor_id AS VARCHAR), CAST(sale_date AS VARCHAR))),
    -- 'reference' is a unique hash generated from other fields, can be overridden with custom value
    FOREIGN KEY (customer_id) REFERENCES store.customer(id),  -- Ensures data integrity with customer table
    FOREIGN KEY (vendor_id) REFERENCES store.vendor(id)       -- Ensures data integrity with vendor table
);

-- -----------------------------------------------------------------------------
-- Table: store.sale_details
-- Description: Stores details of products included in each sale
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.sale_details CASCADE;
CREATE TABLE store.sale_details (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each sale detail (auto-incremented)
    sale_id INT NOT NULL,               -- Reference to the associated sale
    product_id INT NOT NULL,            -- Reference to the product sold
    quantity INT NOT NULL,              -- Number of units sold
    unit_price DECIMAL(10, 2) NOT NULL, -- Price per unit at the time of sale
    FOREIGN KEY (sale_id) REFERENCES store.sale(id),      -- Ensures data integrity with sale table
    FOREIGN KEY (product_id) REFERENCES store.product(id) -- Ensures data integrity with product table
);

ALTER TABLE store.sale_details ADD CONSTRAINT check_positive_quantity CHECK (quantity > 0);




-- -----------------------------------------------------------------------------
-- Ideas for Future Database Improvements:
-- -----------------------------------------------------------------------------

-- 1. Add inventory tracking:
--    Create an inventory table to track current stock levels for each product.
--    Implement triggers to update inventory on purchases and sales.

-- 2. Implement user authentication:
--    Add a users table for system access control.
--    Include roles (admin, manager, salesperson) for fine-grained permissions.

-- 3. Enhance customer information:
--    Expand the customer table with fields like email, phone, address.
--    Consider creating a separate addresses table for multiple customer addresses.

-- 4. Add product categories:
--    Create a categories table and link products to categories.
--    This would allow for better organization and reporting of product data.

-- 5. Implement a discount system:
--    Add fields for discounts in the sale and sale_details tables.
--    Create a separate discounts table for managing various types of discounts.

-- 6. Add payment tracking:
--    Create a payments table to track multiple payments for a single sale.
--    Include payment methods (cash, credit card, etc.) and payment status.

-- 7. Implement a review system:
--    Add a reviews table linked to products and customers.
--    This would allow tracking of customer feedback on products.

-- 8. Version control for products:
--    Implement a system to track changes in product details over time.
--    This could help in historical analysis of pricing and description changes.

-- 9. Supplier performance tracking:
--    Add fields to the provider table to track metrics like delivery time, quality, etc.
--    This could help in supplier evaluation and selection.

-- 10. Implement a loyalty program:
--     Add a points system for customers, tracking points earned and redeemed.
--     This could encourage repeat business and allow for targeted marketing.
