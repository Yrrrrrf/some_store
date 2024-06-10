DROP TABLE IF EXISTS store.customer CASCADE;
CREATE TABLE store.customer (  -- Client
    id SERIAL PRIMARY KEY,              -- Unique identifier for each customer (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Name of the customer (cannot be NULL)
);

DROP TABLE IF EXISTS store.vendor CASCADE;
CREATE TABLE store.vendor (  -- Employee that sells products...
    id SERIAL PRIMARY KEY,              -- Unique identifier for each vendor (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Name of the vendor (cannot be NULL)
);

DROP TABLE IF EXISTS store.product CASCADE;
CREATE TABLE store.product (  -- Some generic products
    id SERIAL PRIMARY KEY,              -- Unique identifier for each product (auto-incremented)
    code VARCHAR(50) UNIQUE NOT NULL,   -- Unique code for the product (cannot be NULL)
    description VARCHAR(255) NOT NULL,  -- Description of the product (cannot be NULL)
    unit_price DECIMAL(10, 2) NOT NULL  -- Unit price of the product (cannot be NULL)
);

DROP TABLE IF EXISTS store.provider CASCADE;
CREATE TABLE store.provider (  -- Supplier
    id SERIAL PRIMARY KEY,              -- Unique identifier for each provider (auto-incremented)
    name VARCHAR(100) NOT NULL          -- Name of the provider (cannot be NULL)
);

DROP TABLE IF EXISTS store.purchase CASCADE;
CREATE TABLE store.purchase (
    id SERIAL PRIMARY KEY,
    provider_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (provider_id) REFERENCES store.provider(id)
);

DROP TABLE IF EXISTS store.purchase_details CASCADE;
CREATE TABLE store.purchase_details (
    id SERIAL PRIMARY KEY,
    purchase_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (purchase_id) REFERENCES store.purchase(id),
    FOREIGN KEY (product_id) REFERENCES store.product(id)
);

DROP TABLE IF EXISTS store.sale CASCADE;
CREATE TABLE store.sale (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    vendor_id INT NOT NULL,
    sale_date DATE NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES store.customer(id),
    FOREIGN KEY (vendor_id) REFERENCES store.vendor(id)
);

DROP TABLE IF EXISTS store.sale_details CASCADE;
CREATE TABLE store.sale_details (
    id SERIAL PRIMARY KEY,
    sale_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (sale_id) REFERENCES store.sale(id),
    FOREIGN KEY (product_id) REFERENCES store.product(id)
);
