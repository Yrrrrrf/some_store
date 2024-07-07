-- File: 02_tables.sql
-- Description: This file defines the complete updated table structure for the store database.
--              It includes tables for customers, vendors, products, categories, providers,
--              purchases, sales, carts, shipping addresses, and their respective details.

-- -----------------------------------------------------------------------------
-- Table: store.customer
-- Description: Stores information about customers who make purchases
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.customer CASCADE;
CREATE TABLE store.customer (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each customer
    name VARCHAR(100) NOT NULL,         -- Full name of the customer
    email VARCHAR(255) UNIQUE NOT NULL, -- Customer's email address (used for login)
    phone VARCHAR(20)                   -- Customer's phone number (optional)
);

-- -----------------------------------------------------------------------------
-- Table: store.shipping_address
-- Description: Stores shipping addresses for customers
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.shipping_address CASCADE;
CREATE TABLE store.shipping_address (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each shipping address
    customer_id INT NOT NULL,           -- Reference to the customer
    address_line1 VARCHAR(255) NOT NULL,-- First line of the shipping address
    city VARCHAR(100) NOT NULL,         -- City of the shipping address
    postal_code VARCHAR(20) NOT NULL,   -- Postal code of the shipping address
    FOREIGN KEY (customer_id) REFERENCES store.customer(id)
);

-- -----------------------------------------------------------------------------
-- Table: store.vendor
-- Description: Stores information about employees who sell products
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.vendor CASCADE;
CREATE TABLE store.vendor (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each vendor
    name VARCHAR(100) NOT NULL          -- Full name of the vendor
);

-- -----------------------------------------------------------------------------
-- Table: store.category
-- Description: Stores product categories
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.category CASCADE;
CREATE TABLE store.category (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each category
    name VARCHAR(100) NOT NULL          -- Name of the category
);

-- -----------------------------------------------------------------------------
-- Table: store.product
-- Description: Stores information about products available for sale
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.product CASCADE;
CREATE TABLE store.product (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each product
    code VARCHAR(50) UNIQUE NOT NULL,   -- Product code (SKU)
    description VARCHAR(255) NOT NULL,  -- Description of the product
    unit_price DECIMAL(10, 2) NOT NULL, -- Current price per unit
    category_id INT NOT NULL,           -- Reference to the product category
    image_url VARCHAR(255),             -- URL of the product image
    FOREIGN KEY (category_id) REFERENCES store.category(id),
    CONSTRAINT check_positive_price CHECK (unit_price > 0)
);

-- Create a function to generate the placeholder image URL
CREATE OR REPLACE FUNCTION store.generate_image_url()
RETURNS TRIGGER AS $$
BEGIN
    -- Generate image URL only if it's not provided
    IF NEW.image_url IS NULL OR NEW.image_url = '' THEN
        NEW.image_url := 'https://placehold.co/512x512?text=' || regexp_replace(NEW.description, '\s+', '+', 'g');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically generate the image URL before insert
CREATE TRIGGER tr_generate_image_url
BEFORE INSERT ON store.product
FOR EACH ROW
EXECUTE FUNCTION store.generate_image_url();

-- -----------------------------------------------------------------------------
-- Table: store.provider
-- Description: Stores information about suppliers who provide products
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.provider CASCADE;
CREATE TABLE store.provider (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each provider
    name VARCHAR(100) NOT NULL          -- Name of the provider
);

-- -----------------------------------------------------------------------------
-- Table: store.purchase
-- Description: Records purchases made from providers
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.purchase CASCADE;
CREATE TABLE store.purchase (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each purchase
    provider_id INT NOT NULL,           -- Reference to the provider
    purchase_date DATE NOT NULL,        -- Date of the purchase
    FOREIGN KEY (provider_id) REFERENCES store.provider(id)
);

-- -----------------------------------------------------------------------------
-- Table: store.purchase_details
-- Description: Stores details of products included in each purchase
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.purchase_details CASCADE;
CREATE TABLE store.purchase_details (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each purchase detail
    purchase_id INT NOT NULL,           -- Reference to the purchase
    product_id INT NOT NULL,            -- Reference to the product
    quantity INT NOT NULL,              -- Quantity of the product purchased
    unit_price DECIMAL(10, 2) NOT NULL, -- Price per unit at the time of purchase
    FOREIGN KEY (purchase_id) REFERENCES store.purchase(id),
    FOREIGN KEY (product_id) REFERENCES store.product(id)
);

-- -----------------------------------------------------------------------------
-- Table: store.sale
-- Description: Records sales made to customers
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.sale CASCADE;
CREATE TABLE store.sale (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each sale
    customer_id INT NOT NULL,           -- Reference to the customer
    vendor_id INT NOT NULL,             -- Reference to the vendor
    shipping_address_id INT NOT NULL,   -- Reference to the shipping address
    sale_date DATE NOT NULL DEFAULT CURRENT_DATE, -- Date of the sale
    reference VARCHAR(255) NOT NULL UNIQUE, -- Unique reference number for the sale
    FOREIGN KEY (customer_id) REFERENCES store.customer(id),
    FOREIGN KEY (vendor_id) REFERENCES store.vendor(id),
    FOREIGN KEY (shipping_address_id) REFERENCES store.shipping_address(id)
);

-- Create a function to generate the sale reference
CREATE OR REPLACE FUNCTION store.generate_sale_reference()
RETURNS TRIGGER AS $$
BEGIN
    -- Generate reference only if it's not provided
    IF NEW.reference IS NULL THEN
        NEW.reference := MD5(CONCAT(
            CAST(NEW.customer_id AS VARCHAR),
            CAST(NEW.vendor_id AS VARCHAR),
            CAST(NEW.sale_date AS VARCHAR),
            CAST(EXTRACT(EPOCH FROM NOW()) AS VARCHAR)
        ));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to automatically generate the reference before insert
CREATE TRIGGER tr_generate_sale_reference
BEFORE INSERT ON store.sale
FOR EACH ROW
EXECUTE FUNCTION store.generate_sale_reference();

-- -----------------------------------------------------------------------------
-- Table: store.sale_details
-- Description: Stores details of products included in each sale
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.sale_details CASCADE;
CREATE TABLE store.sale_details (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each sale detail
    sale_id INT NOT NULL,               -- Reference to the sale
    product_id INT NOT NULL,            -- Reference to the product
    quantity INT NOT NULL,              -- Quantity of the product sold
    unit_price DECIMAL(10, 2) NOT NULL, -- Price per unit at the time of sale
    FOREIGN KEY (sale_id) REFERENCES store.sale(id),
    FOREIGN KEY (product_id) REFERENCES store.product(id),
    CONSTRAINT check_positive_quantity CHECK (quantity > 0)
);

-- -----------------------------------------------------------------------------
-- Table: store.cart
-- Description: Stores products in a user's cart
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS store.cart CASCADE;
CREATE TABLE store.cart (
    id SERIAL PRIMARY KEY,              -- Unique identifier for each cart item
    customer_id INT NOT NULL,           -- Reference to the customer
    product_id INT NOT NULL,            -- Reference to the product
    quantity INT NOT NULL,              -- Quantity of the product in the cart
    FOREIGN KEY (customer_id) REFERENCES store.customer(id),
    FOREIGN KEY (product_id) REFERENCES store.product(id),
    CONSTRAINT check_positive_quantity CHECK (quantity > 0),
    CONSTRAINT unique_customer_product UNIQUE (customer_id, product_id)
);

-- Function to update cart
CREATE OR REPLACE FUNCTION store.update_cart()
RETURNS TRIGGER AS $$
BEGIN
    -- If the product already exists in the cart, update the quantity
    IF TG_OP = 'INSERT' THEN
        UPDATE store.cart
        SET quantity = quantity + NEW.quantity
        WHERE customer_id = NEW.customer_id AND product_id = NEW.product_id;

        IF FOUND THEN
            RETURN NULL; -- Prevent the insertion of a new row
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to handle cart updates
CREATE TRIGGER tr_update_cart
BEFORE INSERT ON store.cart
FOR EACH ROW EXECUTE FUNCTION store.update_cart();

-- -----------------------------------------------------------------------------
-- Function: store.get_purchase_total
-- Description: Calculates the total amount of a purchase based on purchase_details
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION store.get_purchase_total(p_purchase_id INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    v_total DECIMAL(10, 2);
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM store.purchase_details
    WHERE purchase_id = p_purchase_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Function: store.get_sale_total
-- Description: Calculates the total amount of a sale based on sale_details
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION store.get_sale_total(p_sale_id INT)
RETURNS DECIMAL(10, 2) AS $$
DECLARE
    v_total DECIMAL(10, 2);
BEGIN
    SELECT COALESCE(SUM(quantity * unit_price), 0)
    INTO v_total
    FROM store.sale_details
    WHERE sale_id = p_sale_id;

    RETURN v_total;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Function: store.get_product_inventory
-- Description: Calculates the current inventory of a product
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION store.get_product_inventory(p_product_id INT)
RETURNS INT AS $$
DECLARE
    v_inventory INT;
BEGIN
    SELECT
        COALESCE(SUM(CASE WHEN t.type = 'purchase' THEN t.quantity ELSE -t.quantity END), 0)
    INTO v_inventory
    FROM (
        SELECT 'purchase' as type, product_id, quantity
        FROM store.purchase_details
        UNION ALL
        SELECT 'sale' as type, product_id, quantity
        FROM store.sale_details
    ) t
    WHERE t.product_id = p_product_id;

    RETURN v_inventory;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Function: store.convert_cart_to_sale
-- Description: Converts a customer's cart to a sale
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION store.convert_cart_to_sale(
    p_customer_id INT,
    p_vendor_id INT,
    p_shipping_address_id INT
)
RETURNS INT AS $$
DECLARE
    v_sale_id INT;
BEGIN
    -- Create a new sale
    INSERT INTO store.sale (customer_id, vendor_id, shipping_address_id, sale_date)
    VALUES (p_customer_id, p_vendor_id, p_shipping_address_id, CURRENT_DATE)
    RETURNING id INTO v_sale_id;

    -- Insert cart items into sale_details
    INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price)
    SELECT v_sale_id, c.product_id, c.quantity, p.unit_price
    FROM store.cart c
    JOIN store.product p ON c.product_id = p.id
    WHERE c.customer_id = p_customer_id;

    -- Clear the customer's cart
    DELETE FROM store.cart
    WHERE customer_id = p_customer_id;

    RETURN v_sale_id;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Indexes for improved performance
-- -----------------------------------------------------------------------------
CREATE INDEX idx_product_category ON store.product(category_id);
CREATE INDEX idx_cart_customer ON store.cart(customer_id);
CREATE INDEX idx_shipping_address_customer ON store.shipping_address(customer_id);
CREATE INDEX idx_sale_customer ON store.sale(customer_id);
CREATE INDEX idx_sale_details_sale ON store.sale_details(sale_id);


-- SELECT * FROM get_sale_total(1);
-- iter over all the row of the sale table
-- SELECT COUNT(*) FROM store.sale

-- now exec the get_sale_total for all the sales
SELECT get_sale_total(id) FROM store.sale;
