-- Inserting sample data into Products
INSERT INTO store.product (code, description, unit_price) VALUES
('LASER1000', 'LaserJet 1000 Printer', 1900.00),
('PROJEPSON', 'Epson Projector', 8000.00),
('LAPH6100', 'HP 6100 Laptop', 7000.00);

-- Inserting sample data into Providers
INSERT INTO store.provider (name) VALUES
('CT Internacional'),
('Ingram');

-- Inserting sample data into Customers
INSERT INTO store.customer (name) VALUES
('ARQUITECTOS ASOCIADOS'),
('CONSULTORES EN SISTEMAS'),
('INMOBILIARIA DASHUR');

-- Inserting sample data into Vendors
INSERT INTO store.vendor (name) VALUES
('Juan Perez'),
('Carmen Garcia');

-- Inserting sample data into Purchases
INSERT INTO store.purchase (provider_id, purchase_date, total_amount) VALUES
(1, '2024-04-01', 78000.00),
(2, '2024-04-01', 152000.00);

-- Inserting sample data into Purchase Details
INSERT INTO store.purchase_details (purchase_id, product_id, quantity, unit_price) VALUES
(1, 1, 20, 1900.00),
(1, 2, 5, 8000.00),
(2, 1, 10, 2000.00),
(2, 3, 22, 6000.00);

-- Inserting sample data into Sales
INSERT INTO store.sale (customer_id, vendor_id, sale_date, total_amount) VALUES
(1, 1, '2024-04-08', 18700.00),
(2, 2, '2024-04-09', 24000.00),
(2, 1, '2024-04-10', 25700.00),
(3, 1, '2024-05-02', 34900.00),
(2, 2, '2024-05-03', 7000.00);

-- Inserting sample data into Sale Details
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
(5, 3, 1, 7000.00);
