-- NoSQl in Postgres

Create Database ecom ;

-- Modification to the datamodel (Relational + NoSQL)
-- Users Table with Arrays [] Datatype
-- Syntax: Column_name DataType []
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(100),
    email VARCHAR(100),
    phone TEXT []
);

select * from users;
-- Inserting data
-- Two methods:
-- 1st Method: ARRAY['value1', 'value2', '....']
-- 2nd Method: '{"value1", "value2"}'
INSERT INTO users  (id, name, address, email, phone)
VALUES
(1, 'Alice', '123 Main St, NY', 'alice.johnson@example.com', ARRAY['(408)-589-5846','(408)-589-5555']),
(2, 'Bob', '456 Park Ave, CA', 'bob.smith@example.com', ARRAY['(408)-589-5841']),
(3, 'Charlie', '789 Oak St, TX', 'charlie.brown@example.com', ARRAY['(408)-589-5842','(402)-589-5555', '(401)-589-5155']),
(4, 'David', '321 Elm St, FL', 'david.williams@example.com', ARRAY['(406)-589-5842','(406)-509-5555']),
(5, 'Emma', '654 Pine St, WA', 'emma.davis@example.com', '{"(406)-589-5002", "(406)-589-5800"}'),
(6, 'Frank', '987 Maple St, CO', 'frank.miller@example.com', '{"(402)-589-5002", "(402)-589-5800"}'),
(7, 'Grace', '246 Birch St, IL', 'grace.wilson@example.com', '{"(407)-589-5002"}');

-- Accessing data within array
select *, phone[1]
from users;

select id, name, address, email, coalesce(phone[2], phone[1], 'Unknown') as phone
from users;


-- Filtering Array elements
select id, name, phone[3]
from users
where phone[3] is not null;

select id, name, phone[1]
from users
where phone[1] like '(408)%';

-- Updating Array elements
UPDATE users
set phone[2] = '(402)-589-5155'
where id = 3
returning *;

-- Update the whole array
UPDATE users
set phone = '{"(402)-589-5155"}'
where id = 3
returning *;


update users
set phone = '{"(408)-589-5842", "(408)-589-5811"}'
where id = 3
returning *
;

-- Array append
update users
set phone = array_append(phone, '(402)-589-5155')
where id = 3
returning *
;

-- Array remove
update users
set phone = array_remove(phone, '(402)-589-5155')
where id = 3
returning *;


-- Search for a particular phone number
select id, name, address, email
from users
where '(402)-589-5155' = ANY(phone);


-- Expanding Arrays
select id, name, address, email, unnest(phone)
from users;


-- hstore datatype (for storing key-value pairs in a single value)
-- keys and values are text strings
-- Usecase: Beneficial in cases with semi-structured data with many attributes.

-- Enable postgres hstore extension (loads contrib module to postgres instance)

CREATE EXTENSION hstore;


-- Products table with attributes
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL(10, 2),
    description hstore
);

select * from products;

-- Insert data in key-value pairs
INSERT INTO products (id, name, price, description) VALUES
(101, 'Laptop', 1200, '"screen" => "15-inch", "color" => "silver", "RAM" => "16GB", "processor" => "Intel Core 7"'),
(102, 'Smartphone', 999, '"screen" => "6.1inch", "color" => "blue", "RAM" => "16GB", "os" => "Android 14"' ),
(103, 'Headphones', 250, '"color" => "red", "feature" => "Noise-canceling", "charge-time" => "1 hr"'),
(104, 'Smartwatch', 180, '"brand" => "samsung", "color" => "black", "Waterproof" => "Yes"'),
(105, 'Tablet', 350, '"brand" => "lenovo", "screen-size" => "10-inch", "os" => "Android"');

-- Querying Data
select description
from products;

-- Query for a specific key (use -> operator)

select description -> 'color' as color
from products;

select description -> 'color' as color
from products
where description -> 'color' is not null;


select description -> 'color' as color
from products
where description -> 'color' = 'red';


select description
from products
where description -> 'os' = 'Android';


-- Add key-value pairs to existing rows
UPDATE products
SET description = description || '"color" => "grey"' :: hstore
where id = 105
returning *;

-- Update existing key-value pair
UPDATE products
SET description = description || '"color" => "yellow"' :: hstore
where id = 105
returning *;

-- Remove existing key-value pair
UPDATE products
set description = delete(description, 'color')
where id = 105
returning *;

-- Check for a specific key in hstore column
select id, name, description -> 'color' as product_color,
       description
from products
where description ? 'color';

-- Check for key-value pair, using @> operator
select id, name, description -> 'color' as product_color
from products
where description @> '"color" => "blue"' :: hstore;

-- Rows that contain multiple specified keys, using ?&
select id, name, description -> 'color' as color, description -> 'os' as os
from products
where description ?& ARRAY['color', 'os'];

-- To check if any of the keys is present, use ?|
select id, name, description -> 'color' as color, description -> 'os' as os
from products
where description ?| ARRAY['color', 'os'];


-- Fetch all keys from hstore column, using akeys()
select id, name, akeys(description)
from products;

-- Fetch all keys from hstore column, using skeys()
select id, name, skeys(description)
from products;

-- Fetch all values from hstore column, using avals()
select id, name, avals(description)
from products;

-- Fetch all values from hstore column, using svals()
select id, name, svals(description)
from products;

-- Convert hstore data to JSON, using function: hstore_to_json()
select id, name, price,
       hstore_to_json(description) json
from products;

-- Convert hstore data to sets
select id, name, (EACH(description)).*
from products;
















