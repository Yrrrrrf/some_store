-- Expanded sample data for Products
INSERT INTO store.product (code, description, unit_price, image_url) VALUES
('LASER1000', 'LaserJet 1000 Printer', 1900.00, 'https://via.placeholder.com/150?text=LaserJet+1000'),
('PROJEPSON', 'Epson Projector', 8000.00, 'https://via.placeholder.com/150?text=Epson+Projector'),
('LAPH6100', 'HP 6100 Laptop', 7000.00, 'https://via.placeholder.com/150?text=HP+6100+Laptop'),
('DELLXPS15', 'Dell XPS 15 Laptop', 9500.00, 'https://via.placeholder.com/150?text=Dell+XPS+15'),
('MACBOOKPRO', 'Apple MacBook Pro', 12000.00, 'https://via.placeholder.com/150?text=MacBook+Pro'),
('SAMSUNGTV', 'Samsung 4K Smart TV', 5500.00, 'https://via.placeholder.com/150?text=Samsung+TV'),
('LOGIMOUSE', 'Logitech Wireless Mouse', 350.00, 'https://via.placeholder.com/150?text=Logitech+Mouse'),
('CORSKEY', 'Corsair Mechanical Keyboard', 800.00, 'https://via.placeholder.com/150?text=Corsair+Keyboard'),
('CANONCAM', 'Canon DSLR Camera', 4500.00, 'https://via.placeholder.com/150?text=Canon+Camera'),
('BOSEHDPHN', 'Bose Noise Cancelling Headphones', 2000.00, 'https://via.placeholder.com/150?text=Bose+Headphones');

-- Expanded sample data for Providers
INSERT INTO store.provider (name) VALUES
('CT Internacional'),
('Ingram'),
('Tech Data'),
('Synnex'),
('D&H Distributing'),
('Arrow Electronics'),
('Avnet'),
('Westcon-Comstor'),
('ScanSource'),
('ASI');

-- Expanded sample data for Customers
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

-- Expanded sample data for Vendors
INSERT INTO store.vendor (name) VALUES
('Juan Perez'),
('Carmen Garcia'),
('Michael Johnson'),
('Emily Wong'),
('David Miller'),
('Sarah Thompson'),
('Robert Chen'),
('Maria Rodriguez'),
('James Smith'),
('Lisa Brown');

-- Expanded sample data for Purchases
INSERT INTO store.purchase (provider_id, purchase_date, total_amount) VALUES
(1, '2024-04-01', 78000.00),
(2, '2024-04-01', 152000.00),
(3, '2024-04-05', 95000.00),
(4, '2024-04-10', 120000.00),
(5, '2024-04-15', 85000.00),
(1, '2024-04-20', 110000.00),
(2, '2024-04-25', 130000.00),
(3, '2024-05-01', 98000.00),
(4, '2024-05-05', 115000.00),
(5, '2024-05-10', 105000.00);

-- Expanded sample data for Purchase Details
INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
(1, 1, 20, 1900.00),
(1, 2, 5, 8000.00),
(2, 1, 10, 2000.00),
(2, 3, 22, 6000.00),
(3, 4, 15, 9000.00),
(3, 5, 8, 11500.00),
(4, 6, 25, 5200.00),
(4, 7, 50, 300.00),
(5, 8, 30, 750.00),
(5, 9, 12, 4200.00),
(6, 10, 18, 1900.00),
(6, 1, 25, 1850.00),
(7, 2, 10, 7800.00),
(7, 3, 20, 6800.00),
(8, 4, 12, 9200.00),
(8, 5, 6, 11800.00),
(9, 6, 30, 5300.00),
(9, 7, 60, 320.00),
(10, 8, 35, 780.00),
(10, 9, 15, 4300.00);

-- Expanded sample data for Sales
INSERT INTO store.sale (customer_id, vendor_id, sale_date) VALUES
(1, 1, '2024-04-08'),
(2, 2, '2024-04-09'),
(2, 1, '2024-04-10'),
(3, 1, '2024-05-02'),
(2, 2, '2024-05-03'),
(4, 3, '2024-05-05'),
(5, 4, '2024-05-07'),
(6, 5, '2024-05-10'),
(7, 6, '2024-05-12'),
(8, 7, '2024-05-15'),
(9, 8, '2024-05-18'),
(10, 9, '2024-05-20'),
(11, 10, '2024-05-22'),
(12, 1, '2024-05-25'),
(13, 2, '2024-05-28'),
(14, 3, '2024-06-01'),
(15, 4, '2024-06-03'),
(1, 5, '2024-06-05'),
(2, 6, '2024-06-08'),
(3, 7, '2024-06-10');

-- Expanded sample data for Sale Details
INSERT INTO store.sale_details (sale_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 2200.00),
(1, 3, 1, 7000.00),
(1, 2, 1, 9500.00),
(2, 3, 2, 7000.00),
(2, 2, 1, 10000.00),
(3, 1, 1, 2200.00),
(3, 3, 2, 7000.00),
(3, 2, 1, 9500.00),
(4, 1, 2, 2200.00),
(4, 3, 3, 7000.00),
(4, 2, 1, 9500.00),
(5, 3, 1, 7000.00),
(6, 4, 2, 9800.00),
(6, 5, 1, 12500.00),
(7, 6, 3, 5800.00),
(7, 7, 5, 380.00),
(8, 8, 2, 850.00),
(8, 9, 1, 4800.00),
(9, 10, 3, 2100.00),
(9, 1, 2, 2250.00),
(10, 2, 1, 8500.00),
(10, 3, 2, 7200.00),
(11, 4, 1, 9800.00),
(11, 5, 1, 12500.00),
(12, 6, 2, 5800.00),
(12, 7, 4, 380.00),
(13, 8, 3, 850.00),
(13, 9, 1, 4800.00),
(14, 10, 2, 2100.00),
(14, 1, 3, 2250.00),
(15, 2, 1, 8500.00),
(15, 3, 1, 7200.00),
(16, 4, 2, 9800.00),
(16, 5, 1, 12500.00),
(17, 6, 3, 5800.00),
(17, 7, 6, 380.00),
(18, 8, 2, 850.00),
(18, 9, 1, 4800.00),
(19, 10, 2, 2100.00),
(19, 1, 2, 2250.00),
(20, 2, 1, 8500.00),
(20, 3, 2, 7200.00);

-- Verify the data
SELECT 'Products' AS table_name, COUNT(*) AS row_count FROM store.product
UNION ALL
SELECT 'Providers', COUNT(*) FROM store.provider
UNION ALL
SELECT 'Customers', COUNT(*) FROM store.customer
UNION ALL
SELECT 'Vendors', COUNT(*) FROM store.vendor
UNION ALL
SELECT 'Purchases', COUNT(*) FROM store.purchase
UNION ALL
SELECT 'Purchase Details', COUNT(*) FROM store.purchase_details
UNION ALL
SELECT 'Sales', COUNT(*) FROM store.sale
UNION ALL
SELECT 'Sale Details', COUNT(*) FROM store.sale_details;

-- Verify the auto-generated references in the sale table
SELECT id, customer_id, vendor_id, sale_date, reference FROM store.sale;