-- File: 05_triggers.sql
-- Description: This file defines triggers and functions to manage inventory and sale totals
--              in the store database without using an explicit inventory column.

-- -----------------------------------------------------------------------------
-- Function: calculate_inventory
-- Description: Calculates the current inventory for a given product
-- Parameters:
--   p_product_id INT - The ID of the product to calculate inventory for
-- Returns: INT - The current inventory count
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_inventory(p_product_id INT) RETURNS INT AS $$
DECLARE
    total_purchased INT;
    total_sold INT;
BEGIN
    -- Calculate total purchased
    SELECT COALESCE(SUM(quantity), 0) INTO total_purchased
    FROM store.purchase_details
    WHERE product_id = p_product_id;

    -- Calculate total sold
    SELECT COALESCE(SUM(quantity), 0) INTO total_sold
    FROM store.sale_details
    WHERE product_id = p_product_id;

    -- Return the difference
    RETURN total_purchased - total_sold;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- Function: check_and_update_inventory
-- Description: Checks if there's enough inventory before a sale
-- Trigger: Fires BEFORE INSERT on store.sale_details
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_and_update_inventory() RETURNS TRIGGER AS $$
DECLARE
    current_inventory INT;
BEGIN
    -- Calculate current inventory
    current_inventory := calculate_inventory(NEW.product_id);

    -- Check if we have enough inventory
    IF current_inventory < NEW.quantity THEN
        RAISE EXCEPTION 'Not enough inventory for product %. Current inventory: %, Attempted to sell: %',
                        NEW.product_id, current_inventory, NEW.quantity;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the trigger
CREATE TRIGGER before_sale_detail_insert
BEFORE INSERT ON store.sale_details
FOR EACH ROW
EXECUTE FUNCTION check_and_update_inventory();

-- -----------------------------------------------------------------------------
-- Function: update_sale_total
-- Description: Updates the total amount of a sale
-- Triggers: Fires AFTER INSERT, UPDATE, DELETE on store.sale_details
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION update_sale_total() RETURNS TRIGGER AS $$
DECLARE
    new_total DECIMAL(10, 2);
BEGIN
    -- Calculate the new total for the sale
    SELECT COALESCE(SUM(quantity * unit_price), 0) INTO new_total
    FROM store.sale_details
    WHERE sale_id = CASE
        WHEN TG_OP = 'DELETE' THEN OLD.sale_id
        ELSE NEW.sale_id
    END;

    -- Update the total in the sale table
    UPDATE store.sale
    SET total_amount = new_total
    WHERE id = CASE
        WHEN TG_OP = 'DELETE' THEN OLD.sale_id
        ELSE NEW.sale_id
    END;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create the triggers
CREATE TRIGGER after_sale_detail_insert_update
AFTER INSERT OR UPDATE ON store.sale_details
FOR EACH ROW
EXECUTE FUNCTION update_sale_total();

CREATE TRIGGER after_sale_detail_delete
AFTER DELETE ON store.sale_details
FOR EACH ROW
EXECUTE FUNCTION update_sale_total();

-- -----------------------------------------------------------------------------
-- Test Section
-- Description: Comprehensive tests for the triggers and functions
-- -----------------------------------------------------------------------------

-- Ensure we have a total_amount column in the sale table
ALTER TABLE store.sale ADD COLUMN IF NOT EXISTS total_amount DECIMAL(10, 2) DEFAULT 0;

-- Clear existing data for clean tests
TRUNCATE store.sale, store.sale_details, store.purchase, store.purchase_details CASCADE;

-- Reset sequences
ALTER SEQUENCE store.sale_id_seq RESTART WITH 1;
ALTER SEQUENCE store.sale_details_id_seq RESTART WITH 1;
ALTER SEQUENCE store.purchase_id_seq RESTART WITH 1;
ALTER SEQUENCE store.purchase_details_id_seq RESTART WITH 1;

-- Test 1: Add inventory
INSERT INTO store.purchase (provider_id, purchase_date, total_amount) VALUES (1, CURRENT_DATE, 10000);
INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price)
VALUES (1, 1, 10, 1000);

-- Verify inventory
SELECT calculate_inventory(1) AS inventory_after_purchase;

-- Test 2: Attempt to sell more than available (should fail)
INSERT INTO store.sale (customer_id, vendor_id, sale_date) VALUES (1, 1, CURRENT_DATE);
DO $$
BEGIN
    BEGIN
        INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price)
        VALUES (1, 1, 11, 1200);
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Expected error caught: %', SQLERRM;
    END;
END $$;

-- Test 3: Sell a valid amount
INSERT INTO store.sale (customer_id, vendor_id, sale_date) VALUES (2, 1, CURRENT_DATE);
INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price)
VALUES (2, 1, 5, 1200);

-- Verify sale total and remaining inventory
SELECT id, total_amount FROM store.sale WHERE id = 2;
SELECT calculate_inventory(1) AS inventory_after_sale;

-- Test 4: Update a sale detail
UPDATE store.sale_details SET quantity = 3 WHERE sale_id = 2 AND product_id = 1;

-- Verify updated sale total and inventory
SELECT id, total_amount FROM store.sale WHERE id = 2;
SELECT calculate_inventory(1) AS inventory_after_update;

-- Test 5: Delete a sale detail
DELETE FROM store.sale_details WHERE sale_id = 2 AND product_id = 1;

-- Verify final sale total and inventory
SELECT id, total_amount FROM store.sale WHERE id = 2;
SELECT calculate_inventory(1) AS final_inventory;

-- Test 6: Multiple products in a sale
INSERT INTO store.purchase (provider_id, purchase_date, total_amount) VALUES (1, CURRENT_DATE, 20000);
INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price)
VALUES (2, 2, 20, 1000);

INSERT INTO store.sale (customer_id, vendor_id, sale_date) VALUES (3, 1, CURRENT_DATE);
INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price) VALUES
(3, 1, 2, 1200),
(3, 2, 3, 1100);

-- Verify multi-product sale total and inventory
SELECT id, total_amount FROM store.sale WHERE id = 3;
SELECT calculate_inventory(1) AS product_1_inventory, calculate_inventory(2) AS product_2_inventory;

-- Final inventory check
SELECT p.id, p.description, calculate_inventory(p.id) AS current_inventory
FROM store.product p
WHERE p.id IN (1, 2);