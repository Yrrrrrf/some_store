DROP TABLE IF EXISTS store.customer CASCADE;
CREATE TABLE store.customer (  -- Client
    id SERIAL PRIMARY KEY, -- Unique identifier for each customer (auto-incremented)
    name VARCHAR(100) NOT NULL -- Name of the customer (cannot be NULL)
);

DROP TABLE IF EXISTS store.vendor CASCADE;
CREATE TABLE store.vendor (  -- Employee that sells products...
    id SERIAL PRIMARY KEY, -- Unique identifier for each vendor (auto-incremented)
    name VARCHAR(100) NOT NULL -- Name of the vendor (cannot be NULL)
);

DROP TABLE IF EXISTS store.product CASCADE;
CREATE TABLE store.product (  -- Some generic products
    id SERIAL PRIMARY KEY, -- Unique identifier for each product (auto-incremented)
    code VARCHAR(50) UNIQUE NOT NULL, -- Unique code for the product (cannot be NULL)
    description VARCHAR(255) NOT NULL, -- Description of the product (cannot be NULL)
    unit_price DECIMAL(10, 2) NOT NULL  -- Unit price of the product (cannot be NULL)
);

DROP TABLE IF EXISTS store.provider CASCADE;
CREATE TABLE store.provider (  -- Supplier
    id SERIAL PRIMARY KEY, -- Unique identifier for each provider (auto-incremented)
    name VARCHAR(100) NOT NULL -- Name of the provider (cannot be NULL)
);

DROP TABLE IF EXISTS store.purchase CASCADE;
CREATE TABLE store.purchase (  -- Purchase of products
    id SERIAL PRIMARY KEY, -- Unique identifier for each purchase (auto-incremented)
    provider_id INT NOT NULL, -- Provider that sold the products
    purchase_date DATE NOT NULL, -- Date of the purchase
    total_amount DECIMAL(10, 2) NOT NULL,  -- Total amount of the purchase
    FOREIGN KEY (provider_id) REFERENCES store.provider(id)  -- Reference to the provider
);

DROP TABLE IF EXISTS store.purchase_details CASCADE;
CREATE TABLE store.purchase_details (  -- Details of the purchase (products purchased to the provider)
    id SERIAL PRIMARY KEY,  -- Unique identifier for each purchase detail (auto-incremented)
    purchase_id INT NOT NULL,  -- Purchase to which the detail belongs
    product_id INT NOT NULL,  -- Product that was purchased
    quantity INT NOT NULL,  -- Quantity of the product that was purchased
    unit_price DECIMAL(10, 2) NOT NULL,  -- Unit price of the product
    FOREIGN KEY (purchase_id) REFERENCES store.purchase(id),  -- Reference to the purchase
    FOREIGN KEY (product_id) REFERENCES store.product(id)  -- Reference to the product
);

DROP TABLE IF EXISTS store.sale CASCADE;
CREATE TABLE store.sale (  -- Sale of products (to customers)
    id SERIAL PRIMARY KEY,  -- Unique identifier for each sale (auto-incremented)
    customer_id INT NOT NULL,  -- Customer that bought the products
    vendor_id INT NOT NULL,  -- Vendor that sold the products
    sale_date DATE NOT NULL,  -- Date of the sale

    -- * Add a new 'reference' column on this store.sale table that is some kind of 'hash' of the sale details
    -- * This hash must be created from the other fields of this same table
    -- * The 'hash' must be unique for each sale and has a default value created from the other fields
    -- * The 'hash' must be a VARCHAR(255) and cannot be NULL and the user can also provide a custom value
    -- * The 'hash' must be created using the following formula:
        -- *   hash = MD5(CONCAT(customer_id, vendor_id, sale_date)) or something similar

    FOREIGN KEY (customer_id) REFERENCES store.customer(id),  -- Reference to the customer
    FOREIGN KEY (vendor_id) REFERENCES store.vendor(id)  -- Reference to the vendor
);

DROP TABLE IF EXISTS store.sale_details CASCADE;
CREATE TABLE store.sale_details (  -- Details of the sale (products sold to the customer)
    id SERIAL PRIMARY KEY,  -- Unique identifier for each sale detail (auto-incremented)
    sale_id INT NOT NULL,  -- Sale to which the detail belongs
    product_id INT NOT NULL,  -- Product that was sold
    quantity INT NOT NULL,  -- Quantity of the product that was sold
    unit_price DECIMAL(10, 2) NOT NULL,  -- Unit price of the product
    FOREIGN KEY (sale_id) REFERENCES store.sale(id),  -- Reference to the sale
    FOREIGN KEY (product_id) REFERENCES store.product(id)  -- Reference to the product
);
