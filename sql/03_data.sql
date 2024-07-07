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
('CORSKEY', 'Corsair Mechanical Keyboard', 800.00, 8, 'uploads/CORSKEY.jpg');  -- Accessories: High-performance mechanical keyboard


INSERT INTO store.product (code, description, unit_price, category_id) VALUES
('PROJEPSON', 'Epson Projector', 8000.00, 3),        -- Audio & Video: Professional-grade projector
('LAPH6100', 'HP 6100 Laptop', 7000.00, 2),          -- Computers: High-performance HP laptop
('DELLXPS15', 'Dell XPS 15 Laptop', 9500.00, 2),     -- Computers: Premium Dell laptop
('CANONCAM', 'Canon DSLR Camera', 4500.00, 7),       -- Photography: Professional DSLR camera
('BOSEHDPHN', 'Bose Noise Cancelling Headphones', 2000.00, 3), -- Audio & Video: Premium noise-cancelling headphones
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
INSERT INTO store.customer (name, email, phone) VALUES
('ARQUITECTOS ASOCIADOS', 'info@arquitectosasociados.com', '+1234567890'),
('CONSULTORES EN SISTEMAS', 'contact@consultoresensistemas.com', '+2345678901'),
('INMOBILIARIA DASHUR', 'sales@inmobiliariadashur.com', '+3456789012'),
('TECH SOLUTIONS INC', 'support@techsolutions.com', '+4567890123'),
('GLOBAL INNOVATIONS LLC', 'info@globalinnovations.com', '+5678901234'),
('CREATIVE DESIGNS CO', 'hello@creativedesigns.co', '+6789012345'),
('PACIFIC TRADERS', 'trade@pacifictraders.com', '+7890123456'),
('MOUNTAIN VIEW ENTERPRISES', 'info@mountainview.com', '+8901234567'),
('SUNSET CORPORATION', 'contact@sunsetcorp.com', '+9012345678'),
('RIVER VALLEY TECHNOLOGIES', 'support@rivervalleytech.com', '+0123456789'),
('CENTRAL CITY SERVICES', 'info@centralcityservices.com', '+1122334455'),
('BLUE OCEAN CONSULTING', 'consult@blueocean.com', '+2233445566'),
('GREEN FIELDS AGRICULTURE', 'info@greenfields.com', '+3344556677'),
('GOLDEN STATE MANUFACTURING', 'sales@goldenstate.com', '+4455667788'),
('SILVER LINING CLOUD SERVICES', 'cloud@silverlining.com', '+5566778899');

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
