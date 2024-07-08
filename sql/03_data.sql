-- File: 03_data.sql
-- Description: This file contains sample data insertion scripts for the store database.
--              It populates all tables with realistic data for testing and development purposes.

-- -----------------------------------------------------------------------------
-- Populate store.category table
-- -----------------------------------------------------------------------------
INSERT INTO store.category (id, name) VALUES
(1, 'Electronics'),    -- General electronic devices
(2, 'Computers'),      -- Computer systems and components
(3, 'Audio & Video'),  -- Audio and video equipment
(4, 'Office Equipment'),-- Office-related hardware
(5, 'Gaming'),         -- Gaming consoles and accessories
(6, 'Smart Home'),     -- Smart home devices and systems
(7, 'Photography'),    -- Cameras and photography equipment
(8, 'Accessories');    -- Various accessories for electronic devices

-- Reset the category id sequence to ensure future inserts use the correct ID
SELECT setval('store.category_id_seq', (SELECT MAX(id) FROM store.category));

-- -----------------------------------------------------------------------------
-- Populate store.product table
-- -----------------------------------------------------------------------------

--insert this data on the product table but with a image_url
INSERT INTO store.product (code, description, unit_price, category_id, image_url) VALUES
('LASER1000', 'LaserJet 1000 Printer', 1900.00, 4, 'uploads/LASER1000.jpg'),  -- Office Equipment: High-quality laser printer
('MACBOOKPRO', 'Apple MacBook Pro', 12000.00, 2, 'uploads/MACBOOKPRO.png'),  -- Computers: High-end Apple laptop
('SAMSUNGTV', 'Samsung 4K Smart TV', 5500.00, 3, 'uploads/SAMSUNGTV.png'),  -- Audio & Video: 4K resolution smart TV
('LOGIMOUSE', 'Logitech Wireless Mouse', 350.00, 8, 'uploads/LOGIMOUSE.jpg'),  -- Accessories: Ergonomic wireless mouse
('CORSKEY', 'Corsair Mechanical Keyboard', 800.00, 8, 'uploads/CORSKEY.jpg'),  -- Accessories: High-performance mechanical keyboard

('PROJEPSON', 'Epson Projector', 8000.00, 3, 'uploads/PROJEPSON.jpg'), -- Audio & Video: High-quality projector
('HPLAPTOP', 'HP 6100 Laptop', 7000.00, 2, 'uploads/HPLAPTOP.jpg'),     -- Computers: High-performance laptop
('DELLXPS15', 'Dell XPS 15 Laptop', 9500.00, 2, 'uploads/DELLXPS15.png'),     -- Computers: High-end Dell laptop
('CANONCAM', 'Canon DSLR Camera', 4500.00, 7, 'uploads/CANONCAM.jpg'),       -- Photography: Professional DSLR camera
('BOSEHDPHN', 'Bose Noise Cancelling Headphones', 2000.00, 3, 'uploads/BOSEHDPHN.jpg') -- Audio & Video: Noise-cancelling headphones
;

INSERT INTO store.product (code, description, unit_price, category_id) VALUES
('DESKPRO', 'Professional Office Desk', 3500.00, 4), -- Office Equipment: Ergonomic office desk
('SMARTHUB', 'Smart Home Control Hub', 1200.00, 6),  -- Smart Home: Central control hub for smart devices
('GAMEPADT', 'Wireless Gaming Controller', 600.00, 5), -- Gaming: High-precision wireless controller
('TABLETPC', 'High-Performance Tablet', 5000.00, 2), -- Computers: Powerful tablet computer
('SMARTWATCH', 'Fitness Tracking Smartwatch', 1500.00, 1), -- Electronics: Advanced fitness tracking watch
('DRONEFLY', 'Professional Camera Drone', 3000.00, 7), -- Photography: High-quality camera drone
('SPEAKERSMART', 'AI-Powered Smart Speaker', 800.00, 6), -- Smart Home: Voice-controlled smart speaker
('CONSOLEGAME', 'Next-Gen Gaming Console', 4500.00, 5), -- Gaming: Latest generation gaming console
('SECUCAM', 'Wireless Security Camera', 1200.00, 6), -- Smart Home: Wi-Fi enabled security camera
('PORTCHARGER', 'Portable Power Bank', 500.00, 8);   -- Accessories: High-capacity portable charger

-- -----------------------------------------------------------------------------
-- Populate store.provider table
-- -----------------------------------------------------------------------------
INSERT INTO store.provider (name) VALUES
('CT Internacional'),   -- Large international tech distributor
('Ingram'),             -- Major hardware and software distributor
('Tech Data'),          -- Global IT products and services distributor
('Synnex'),             -- Multinational IT supply chain services company
('D&H Distributing'),   -- North American technology distributor
('Arrow Electronics'),  -- Global provider of electronic components and enterprise computing solutions
('Avnet'),              -- Worldwide distributor of electronic components and services
('Westcon-Comstor'),    -- Global technology distributor specializing in network infrastructure
('ScanSource'),         -- International provider of technology products and solutions
('ASI');                -- Distributor of IT hardware, software, and services

-- -----------------------------------------------------------------------------
-- Populate store.customer table
-- -----------------------------------------------------------------------------
INSERT INTO store.customer (name) VALUES
('ARQUITECTOS ASOCIADOS'),
('CONSULTORES EN SISTEMAS'),
('INMOBILIARIA DASHUR'),
('TECH SOLUTIONS INC'),
('GLOBAL INNOVATIONS LLC'),
('CREATIVE DESIGNS CO'),
('PACIFIC TRADERS'),
('MOUNTAIN VIEW ENTERPRISES'),
('SUNSET CORPORATION'),
('RIVER VALLEY TECHNOLOGIES'),
('CENTRAL CITY SERVICES'),
('BLUE OCEAN CONSULTING'),
('GREEN FIELDS AGRICULTURE'),
('GOLDEN STATE MANUFACTURING'),
('SILVER LINING CLOUD SERVICES');

-- -----------------------------------------------------------------------------
-- Populate store.shipping_address table
-- -----------------------------------------------------------------------------
INSERT INTO store.shipping_address (customer_id, address_line1, city, postal_code) VALUES
(1, '123 Main St', 'New York', '10001'),
(2, '456 Elm St', 'Los Angeles', '90001'),
(3, '789 Oak St', 'Chicago', '60601'),
(4, '321 Pine St', 'Houston', '77001'),
(5, '654 Maple St', 'Phoenix', '85001'),
(6, '987 Cedar St', 'Philadelphia', '19101'),
(7, '147 Birch St', 'San Antonio', '78201'),
(8, '258 Walnut St', 'San Diego', '92101'),
(9, '369 Cherry St', 'Dallas', '75201'),
(10, '159 Spruce St', 'San Jose', '95101'),
(11, '753 Ash St', 'Austin', '78701'),
(12, '951 Fir St', 'Jacksonville', '32201'),
(13, '357 Redwood St', 'San Francisco', '94101'),
(14, '852 Sequoia St', 'Columbus', '43201'),
(15, '426 Sycamore St', 'Fort Worth', '76101');

-- -----------------------------------------------------------------------------
-- Populate store.vendor table
-- -----------------------------------------------------------------------------
INSERT INTO store.vendor (name) VALUES
('Juan Perez'),       -- Experienced salesperson specializing in electronics
('Carmen Garcia'),    -- Expert in computer systems and software
('Michael Johnson'),  -- Specializes in audio and video equipment
('Emily Wong'),       -- Office equipment specialist
('David Miller'),     -- Gaming products expert
('Sarah Thompson'),   -- Smart home technology consultant
('Robert Chen'),      -- Photography equipment specialist
('Maria Rodriguez'),  -- Accessories and general products expert
('James Smith'),      -- Customer service and general sales
('Lisa Brown');       -- Technical support and sales

-- -----------------------------------------------------------------------------
-- Populate store.purchase table
-- -----------------------------------------------------------------------------
INSERT INTO store.purchase (provider_id, purchase_date) VALUES
(1, '2024-04-01'),
(2, '2024-04-01'),
(3, '2024-04-05'),
(4, '2024-04-10'),
(5, '2024-04-15'),
(1, '2024-04-20'),
(2, '2024-04-25'),
(3, '2024-05-01'),
(4, '2024-05-05'),
(5, '2024-05-10');

-- -----------------------------------------------------------------------------
-- Additional Purchase Data for Previously Out-of-Stock Products
-- -----------------------------------------------------------------------------
-- Description: This section adds purchase data for products that were previously
-- out of stock, ensuring a consistent and realistic inventory for the store.
-- The purchases are made from various providers to maintain diversity in the supply chain.

-- New purchase from Tech Data (provider_id: 3)
INSERT INTO store.purchase (provider_id, purchase_date) VALUES
(3, '2024-05-15');  -- Tech Data, mid-May purchase

-- Retrieve the ID of the newly inserted purchase
DO $$
DECLARE
    new_purchase_id INT;
BEGIN
    SELECT currval(pg_get_serial_sequence('store.purchase', 'id')) INTO new_purchase_id;

    -- Insert purchase details for the new purchase
    INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'SPEAKERSMART'), 50, 700.00),  -- AI-Powered Smart Speaker
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'SMARTWATCH'), 100, 1300.00),  -- Fitness Tracking Smartwatch
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'TABLETPC'), 30, 4500.00),     -- High-Performance Tablet
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'CONSOLEGAME'), 25, 4000.00);  -- Next-Gen Gaming Console

    -- Log the purchase for tracking
    RAISE NOTICE 'Inserted purchase % with 4 product lines from Tech Data', new_purchase_id;
END $$;

-- New purchase from Arrow Electronics (provider_id: 6)
INSERT INTO store.purchase (provider_id, purchase_date) VALUES
(6, '2024-05-20');  -- Arrow Electronics, late-May purchase

-- Retrieve the ID of the newly inserted purchase
DO $$
DECLARE
    new_purchase_id INT;
BEGIN
    SELECT currval(pg_get_serial_sequence('store.purchase', 'id')) INTO new_purchase_id;

    -- Insert purchase details for the new purchase
    INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'PORTCHARGER'), 200, 450.00),  -- Portable Power Bank
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'DRONEFLY'), 15, 2800.00),     -- Professional Camera Drone
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'GAMEPADT'), 75, 550.00);      -- Wireless Gaming Controller

    -- Log the purchase for tracking
    RAISE NOTICE 'Inserted purchase % with 3 product lines from Arrow Electronics', new_purchase_id;
END $$;

-- -----------------------------------------------------------------------------
-- Update product prices based on recent purchases
-- -----------------------------------------------------------------------------
-- Description: This section updates the unit prices of the products in the store.product table
-- to reflect the most recent purchase prices. This ensures that the store's pricing
-- is up-to-date with the latest acquisition costs.

UPDATE store.product p
SET unit_price = pd.unit_price
FROM (
    SELECT product_id, unit_price
    FROM store.purchase_details
    WHERE (purchase_id, product_id) IN (
        SELECT purchase_id, product_id
        FROM store.purchase_details
        JOIN store.purchase ON purchase_details.purchase_id = purchase.id
        WHERE (product_id, purchase.purchase_date) IN (
            SELECT product_id, MAX(purchase_date)
            FROM store.purchase_details
            JOIN store.purchase ON purchase_details.purchase_id = purchase.id
            GROUP BY product_id
        )
    )
) pd
WHERE p.id = pd.product_id;

-- Log the price update operation
DO $$
BEGIN
    RAISE NOTICE 'Updated product prices based on most recent purchases';
END $$;

-- -----------------------------------------------------------------------------
-- Populate store.purchase_details table
-- -----------------------------------------------------------------------------
INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
(1, 1, 20, 1900.00),  -- 20 LaserJet 1000 Printers
(1, 6, 12, 8000.00),  -- 12 Epson Projectors
(2, 1, 10, 2000.00),  -- 10 LaserJet 1000 Printers (different price)
(2, 7, 22, 6000.00),  -- 22 HP 6100 Laptops
(3, 8, 15, 9000.00),  -- 15 Dell XPS 15 Laptops
(3, 2, 8, 11500.00),  -- 8 Apple MacBook Pros
(4, 3, 25, 5200.00),  -- 25 Samsung 4K Smart TVs
(4, 4, 50, 300.00),   -- 50 Logitech Wireless Mice
(5, 5, 30, 750.00),   -- 30 Corsair Mechanical Keyboards
(5, 9, 12, 4200.00),  -- 12 Canon DSLR Cameras
(6, 10, 18, 1900.00), -- 18 Bose Noise Cancelling Headphones
(6, 1, 25, 1850.00),  -- 25 LaserJet 1000 Printers (different price)
(7, 6, 10, 7800.00),  -- 10 Epson Projectors (different price)
(7, 7, 20, 6800.00),  -- 20 HP 6100 Laptops (different price)
(8, 8, 12, 9200.00),  -- 12 Dell XPS 15 Laptops (different price)
(8, 2, 12, 11800.00), -- 12 Apple MacBook Pros (different price)
(9, 3, 30, 5300.00),  -- 30 Samsung 4K Smart TVs (different price)
(9, 4, 60, 320.00),   -- 60 Logitech Wireless Mice (different price)
(10, 5, 35, 780.00),  -- 35 Corsair Mechanical Keyboards (different price)
(10, 9, 15, 4300.00); -- 15 Canon DSLR Cameras (different price)

-- -----------------------------------------------------------------------------
-- Populate store.sale table
-- -----------------------------------------------------------------------------
INSERT INTO store.sale (customer_id, vendor_id, shipping_address_id, sale_date) VALUES
(1, 1, 1, '2024-04-08'),
(2, 2, 2, '2024-04-09'),
(2, 1, 2, '2024-04-10'),
(3, 1, 3, '2024-05-02'),
(2, 2, 2, '2024-05-03'),
(4, 3, 4, '2024-05-05'),
(5, 4, 5, '2024-05-07'),
(6, 5, 6, '2024-05-10'),
(7, 6, 7, '2024-05-12'),
(8, 7, 8, '2024-05-15'),
(9, 8, 9, '2024-05-18'),
(10, 9, 10, '2024-05-20'),
(11, 10, 11, '2024-05-22'),
(12, 1, 12, '2024-05-25'),
(13, 2, 13, '2024-05-28'),
(14, 3, 14, '2024-06-01'),
(15, 4, 15, '2024-06-03'),
(1, 5, 1, '2024-06-05'),
(2, 6, 2, '2024-06-08'),
(3, 7, 3, '2024-06-10');

-- -----------------------------------------------------------------------------
-- Populate store.sale_details table
-- -----------------------------------------------------------------------------
INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1900.00),  -- 1 LaserJet 1000 Printer
(1, 3, 1, 7000.00),  -- 1 HP 6100 Laptop
(1, 2, 1, 8000.00),  -- 1 Epson Projector
(2, 3, 2, 7000.00),  -- 2 HP 6100 Laptops
(2, 2, 1, 8000.00),  -- 1 Epson Projector
(3, 1, 1, 1900.00),  -- 1 LaserJet 1000 Printer
(3, 3, 2, 7000.00),  -- 2 HP 6100 Laptops
(3, 2, 1, 8000.00),  -- 1 Epson Projector
(4, 1, 2, 1900.00),  -- 2 LaserJet 1000 Printers
(4, 3, 3, 7000.00),  -- 3 HP 6100 Laptops
(4, 2, 1, 8000.00),  -- 1 Epson Projector
(5, 3, 1, 7000.00),  -- 1 HP 6100 Laptop
(6, 4, 2, 9500.00),  -- 2 Dell XPS 15 Laptops
(6, 5, 1, 12000.00), -- 1 Apple MacBook Pro
(7, 6, 3, 5500.00),  -- 3 Samsung 4K Smart TVs
(7, 7, 5, 350.00),   -- 5 Logitech Wireless Mice
(8, 8, 2, 800.00),   -- 2 Corsair Mechanical Keyboards
(8, 9, 1, 4500.00),  -- 1 Canon DSLR Camera
(9, 10, 3, 2000.00), -- 3 Bose Noise Cancelling Headphones
(9, 1, 2, 1900.00),  -- 2 LaserJet 1000 Printers
(10, 2, 1, 8000.00); -- 1 Epson Projector


-- -----------------------------------------------------------------------------
-- Additional Sale Details for Existing Sales (indices 11-20)
-- -----------------------------------------------------------------------------
-- Description: This section adds sale details for previously empty sales,
-- utilizing newly stocked products and creating a more diverse sales record.

INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price) VALUES
-- Sale 11 (Customer: SUNSET CORPORATION, Date: 2024-05-18)
(11, (SELECT id FROM store.product WHERE code = 'SPEAKERSMART'), 2, 800.00),  -- 2 AI-Powered Smart Speakers
(11, (SELECT id FROM store.product WHERE code = 'SECUCAM'), 3, 1200.00),      -- 3 Wireless Security Cameras

-- Sale 12 (Customer: RIVER VALLEY TECHNOLOGIES, Date: 2024-05-20)
(12, (SELECT id FROM store.product WHERE code = 'TABLETPC'), 1, 5000.00),     -- 1 High-Performance Tablet
(12, (SELECT id FROM store.product WHERE code = 'PORTCHARGER'), 5, 500.00),   -- 5 Portable Power Banks

-- Sale 13 (Customer: CENTRAL CITY SERVICES, Date: 2024-05-22)
(13, (SELECT id FROM store.product WHERE code = 'SMARTWATCH'), 3, 1500.00),   -- 3 Fitness Tracking Smartwatches
(13, (SELECT id FROM store.product WHERE code = 'LOGIMOUSE'), 10, 350.00),    -- 10 Logitech Wireless Mice

-- Sale 14 (Customer: BLUE OCEAN CONSULTING, Date: 2024-05-25)
(14, (SELECT id FROM store.product WHERE code = 'MACBOOKPRO'), 2, 12000.00),  -- 2 Apple MacBook Pros
(14, (SELECT id FROM store.product WHERE code = 'DRONEFLY'), 1, 3000.00),     -- 1 Professional Camera Drone

-- Sale 15 (Customer: GREEN FIELDS AGRICULTURE, Date: 2024-05-28)
(15, (SELECT id FROM store.product WHERE code = 'SECUCAM'), 5, 1200.00),      -- 5 Wireless Security Cameras
(15, (SELECT id FROM store.product WHERE code = 'SMARTHUB'), 1, 1200.00),     -- 1 Smart Home Control Hub

-- Sale 16 (Customer: GOLDEN STATE MANUFACTURING, Date: 2024-06-01)
(16, (SELECT id FROM store.product WHERE code = 'CONSOLEGAME'), 1, 4500.00),  -- 1 Next-Gen Gaming Console
(16, (SELECT id FROM store.product WHERE code = 'GAMEPADT'), 2, 600.00),      -- 2 Wireless Gaming Controllers

-- Sale 17 (Customer: SILVER LINING CLOUD SERVICES, Date: 2024-06-03)
(17, (SELECT id FROM store.product WHERE code = 'DELLXPS15'), 3, 9500.00),    -- 3 Dell XPS 15 Laptops
(17, (SELECT id FROM store.product WHERE code = 'BOSEHDPHN'), 3, 2000.00),    -- 3 Bose Noise Cancelling Headphones

-- Sale 18 (Customer: ARQUITECTOS ASOCIADOS, Date: 2024-06-05)
(18, (SELECT id FROM store.product WHERE code = 'CANONCAM'), 1, 4500.00),     -- 1 Canon DSLR Camera
(18, (SELECT id FROM store.product WHERE code = 'DRONEFLY'), 1, 3000.00),     -- 1 Professional Camera Drone

-- Sale 19 (Customer: CONSULTORES EN SISTEMAS, Date: 2024-06-08)
(19, (SELECT id FROM store.product WHERE code = 'SPEAKERSMART'), 5, 800.00),  -- 5 AI-Powered Smart Speakers
(19, (SELECT id FROM store.product WHERE code = 'SMARTHUB'), 2, 1200.00),     -- 2 Smart Home Control Hubs

-- Sale 20 (Customer: INMOBILIARIA DASHUR, Date: 2024-06-10)
(20, (SELECT id FROM store.product WHERE code = 'SAMSUNGTV'), 2, 5500.00),    -- 2 Samsung 4K Smart TVs
(20, (SELECT id FROM store.product WHERE code = 'PROJEPSON'), 1, 8000.00);    -- 1 Epson Projector

-- -----------------------------------------------------------------------------
-- New Sample Data: Additional Sales and Sale Details
-- -----------------------------------------------------------------------------
-- Description: This section adds new sales and their corresponding details,
-- further diversifying the sales data and utilizing all product categories.

-- New sales
INSERT INTO store.sale (customer_id, vendor_id, shipping_address_id, sale_date) VALUES
(4, 8, 4, '2024-06-15'),  -- TECH SOLUTIONS INC
(7, 3, 7, '2024-06-18'),  -- PACIFIC TRADERS
(10, 5, 10, '2024-06-20'); -- RIVER VALLEY TECHNOLOGIES

-- Retrieve the IDs of the newly inserted sales
DO $$
DECLARE
    new_sale_id_1 INT;
    new_sale_id_2 INT;
    new_sale_id_3 INT;
BEGIN
    SELECT currval(pg_get_serial_sequence('store.sale', 'id')) INTO new_sale_id_3;
    new_sale_id_2 := new_sale_id_3 - 1;
    new_sale_id_1 := new_sale_id_3 - 2;

    -- Insert sale details for the new sales
    INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price) VALUES
    (new_sale_id_1, (SELECT id FROM store.product WHERE code = 'DESKPRO'), 5, 3500.00),      -- 5 Professional Office Desks
    (new_sale_id_1, (SELECT id FROM store.product WHERE code = 'CORSKEY'), 10, 800.00),      -- 10 Corsair Mechanical Keyboards
    (new_sale_id_1, (SELECT id FROM store.product WHERE code = 'SMARTWATCH'), 5, 1500.00),   -- 5 Fitness Tracking Smartwatches

    (new_sale_id_2, (SELECT id FROM store.product WHERE code = 'TABLETPC'), 3, 5000.00),     -- 3 High-Performance Tablets
    (new_sale_id_2, (SELECT id FROM store.product WHERE code = 'PORTCHARGER'), 15, 500.00),  -- 15 Portable Power Banks
    (new_sale_id_2, (SELECT id FROM store.product WHERE code = 'LOGIMOUSE'), 20, 350.00),    -- 20 Logitech Wireless Mice

    (new_sale_id_3, (SELECT id FROM store.product WHERE code = 'SAMSUNGTV'), 1, 5500.00),    -- 1 Samsung 4K Smart TV
    (new_sale_id_3, (SELECT id FROM store.product WHERE code = 'BOSEHDPHN'), 2, 2000.00),    -- 2 Bose Noise Cancelling Headphones
    (new_sale_id_3, (SELECT id FROM store.product WHERE code = 'CONSOLEGAME'), 1, 4500.00);  -- 1 Next-Gen Gaming Console

    -- Log the new sales for tracking
    RAISE NOTICE 'Inserted 3 new sales with IDs: %, %, %', new_sale_id_1, new_sale_id_2, new_sale_id_3;
END $$;


-- -----------------------------------------------------------------------------
-- Populate store.cart table
-- -----------------------------------------------------------------------------
INSERT INTO store.cart (customer_id, product_id, quantity) VALUES
(1, 3, 1),  -- Customer 1 has 1 HP 6100 Laptop in cart
(1, 7, 2),  -- Customer 1 has 2 Logitech Wireless Mice in cart
(2, 5, 1),  -- Customer 2 has 1 Apple MacBook Pro in cart
(3, 10, 1), -- Customer 3 has 1 Bose Noise Cancelling Headphones in cart
(4, 1, 3),  -- Customer 4 has 3 LaserJet 1000 Printers in cart
(5, 8, 2),  -- Customer 5 has 2 Corsair Mechanical Keyboards in cart
(6, 6, 1),  -- Customer 6 has 1 Samsung 4K Smart TV in cart
(7, 9, 1),  -- Customer 7 has 1 Canon DSLR Camera in cart
(8, 2, 1),  -- Customer 8 has 1 Epson Projector in cart
(9, 4, 1);  -- Customer 9 has 1 Dell XPS 15 Laptop in cart





















-- -----------------------------------------------------------------------------
-- Inventory Correction Purchase
-- -----------------------------------------------------------------------------
-- Description: This section adds a new purchase to correct negative inventory
-- levels for specific products. It ensures that all products have a positive
-- inventory count after all sales transactions.

-- New purchase from Ingram (provider_id: 2)
INSERT INTO store.purchase (provider_id, purchase_date) VALUES
(2, '2024-06-25');  -- Ingram, late-June purchase for inventory correction

-- Retrieve the ID of the newly inserted purchase
DO $$
DECLARE
    new_purchase_id INT;
BEGIN
    SELECT currval(pg_get_serial_sequence('store.purchase', 'id')) INTO new_purchase_id;

    -- Insert purchase details for the inventory correction
    INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'DESKPRO'), 20, 3200.00),   -- 20 Professional Office Desks
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'SMARTHUB'), 15, 1100.00),  -- 15 Smart Home Control Hubs
    (new_purchase_id, (SELECT id FROM store.product WHERE code = 'SECUCAM'), 25, 1150.00);   -- 25 Wireless Security Cameras

    -- Log the purchase for tracking
    RAISE NOTICE 'Inserted inventory correction purchase % with 3 product lines from Ingram', new_purchase_id;

    -- Update product prices based on this new purchase
    UPDATE store.product
    SET unit_price = CASE
        WHEN code = 'DESKPRO' THEN 3200.00
        WHEN code = 'SMARTHUB' THEN 1100.00
        WHEN code = 'SECUCAM' THEN 1150.00
        ELSE unit_price
    END
    WHERE code IN ('DESKPRO', 'SMARTHUB', 'SECUCAM');

    RAISE NOTICE 'Updated prices for DESKPRO, SMARTHUB, and SECUCAM based on the new purchase';
END $$;

-- -----------------------------------------------------------------------------
-- Inventory Check After Correction
-- -----------------------------------------------------------------------------
-- Description: This section calculates and displays the current inventory levels
-- for the products that were previously showing negative inventory.

DO $$
DECLARE
    deskpro_inventory INT;
    smarthub_inventory INT;
    secucam_inventory INT;
BEGIN
    -- Calculate current inventory for DESKPRO
    SELECT COALESCE(SUM(CASE WHEN event_type = 'purchase' THEN quantity ELSE -quantity END), 0)
    INTO deskpro_inventory
    FROM (
        SELECT 'purchase' as event_type, product_id, quantity
        FROM store.purchase_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'DESKPRO')
        UNION ALL
        SELECT 'sale' as event_type, product_id, quantity
        FROM store.sale_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'DESKPRO')
    ) events;

    -- Calculate current inventory for SMARTHUB
    SELECT COALESCE(SUM(CASE WHEN event_type = 'purchase' THEN quantity ELSE -quantity END), 0)
    INTO smarthub_inventory
    FROM (
        SELECT 'purchase' as event_type, product_id, quantity
        FROM store.purchase_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'SMARTHUB')
        UNION ALL
        SELECT 'sale' as event_type, product_id, quantity
        FROM store.sale_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'SMARTHUB')
    ) events;

    -- Calculate current inventory for SECUCAM
    SELECT COALESCE(SUM(CASE WHEN event_type = 'purchase' THEN quantity ELSE -quantity END), 0)
    INTO secucam_inventory
    FROM (
        SELECT 'purchase' as event_type, product_id, quantity
        FROM store.purchase_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'SECUCAM')
        UNION ALL
        SELECT 'sale' as event_type, product_id, quantity
        FROM store.sale_details
        WHERE product_id = (SELECT id FROM store.product WHERE code = 'SECUCAM')
    ) events;

    -- Display the current inventory levels
    RAISE NOTICE 'Current inventory levels after correction:';
    RAISE NOTICE 'DESKPRO (Professional Office Desk): %', deskpro_inventory;
    RAISE NOTICE 'SMARTHUB (Smart Home Control Hub): %', smarthub_inventory;
    RAISE NOTICE 'SECUCAM (Wireless Security Camera): %', secucam_inventory;
END $$;



