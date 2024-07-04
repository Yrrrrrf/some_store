-- File: 05_triggers.sql
-- Description: This file contains triggers for the store database to automate
--              inventory management and sale total calculations.

-- -----------------------------------------------------------------------------
-- Trigger: decrease_inventory
-- Description: Automatically decreases the product inventory when a sale is made
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION decrease_inventory()
RETURNS TRIGGER AS $$
BEGIN
    -- Update the inventory of the sold product
    UPDATE store.product
    SET inventory = inventory - NEW.quantity
    WHERE id = NEW.product_id;

    -- Check if inventory went below zero
    IF (SELECT inventory FROM store.product WHERE id = NEW.product_id) < 0 THEN
        RAISE EXCEPTION 'Inventory cannot be negative for product ID %', NEW.product_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to execute after inserting a new sale detail
CREATE OR REPLACE TRIGGER after_sale_insert
AFTER INSERT ON store.sale_details
FOR EACH ROW
EXECUTE FUNCTION decrease_inventory();

-- -----------------------------------------------------------------------------
-- Trigger: update_sale_total
-- Description: Automatically updates the total amount of a sale when sale details
--              are inserted or updated
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_sale_total()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate and update the total amount for the sale
    UPDATE store.sale
    SET total_amount = (
        SELECT SUM(quantity * unit_price)
        FROM store.sale_details
        WHERE sale_id = NEW.sale_id
    )
    WHERE id = NEW.sale_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to execute after inserting or updating sale details
CREATE OR REPLACE TRIGGER after_sale_detail_insert_or_update
AFTER INSERT OR UPDATE ON store.sale_details
FOR EACH ROW
EXECUTE FUNCTION update_sale_total();

-- -----------------------------------------------------------------------------
-- Trigger: prevent_price_decrease
-- Description: Prevents the unit price of a product from being decreased
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION prevent_price_decrease()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.unit_price < OLD.unit_price THEN
        RAISE EXCEPTION 'Price decrease not allowed. Old price: %, New price: %', OLD.unit_price, NEW.unit_price;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger to execute before updating a product
CREATE TRIGGER before_product_update
BEFORE UPDATE OF unit_price ON store.product
FOR EACH ROW
EXECUTE FUNCTION prevent_price_decrease();

-- -----------------------------------------------------------------------------
-- Table Alteration: Add inventory column to product table
-- -----------------------------------------------------------------------------
-- Add an 'inventory' column to the product table if it doesn't exist

-- todo: Find a better way to count the inventory of a product...
--       This is a temporary solution to add the inventory column to the product table
--       and set the default value to 0.
ALTER TABLE store.product
ADD COLUMN IF NOT EXISTS inventory INTEGER DEFAULT 0;

-- -----------------------------------------------------------------------------
-- Test Section
-- -----------------------------------------------------------------------------
-- Insert a product
INSERT INTO store.product (code, description, unit_price, inventory)
VALUES ('TEST002', 'Test Product', 167.00, 22);

-- Create a sale
INSERT INTO store.sale (customer_id, vendor_id, sale_date, total_amount)
VALUES (1, 1, CURRENT_DATE, 0);

-- Add sale details
INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price)
VALUES ((SELECT MAX(id) FROM store.sale), (SELECT id FROM store.product WHERE code = 'TEST002'), 6, 100.00);

-- Check results
SELECT inventory FROM store.product WHERE code = 'TEST002';
SELECT total_amount FROM store.sale WHERE id = (SELECT MAX(id) FROM store.sale);

-- Test price decrease prevention (this should raise an exception)
-- Uncomment the following line to test:
UPDATE store.product SET unit_price = 90.00 WHERE code = 'TEST001';
