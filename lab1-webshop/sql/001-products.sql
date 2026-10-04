CREATE TABLE IF NOT EXISTS products (
    id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL,
    price NUMERIC(10, 2) NOT NULL CHECK (price >= 0)
);

INSERT INTO products (name, description, price)
VALUES
    ('Keyboard', 'USB keyboard with Swedish layout', 399),
    ('Mouse', 'Wireless optical mouse', 249),
    ('Monitor', '24-inch Full HD monitor', 1499)
ON CONFLICT (name) DO NOTHING;