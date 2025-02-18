
-- postgres JSON
-- lightweight data interchange format which is easy to read and parse
-- Structure: composed of objects and arrays
-- Object: {}, Arrays: Ordered List within []
-- JSON data types
-- JSON: exact copy; JSONB: binary format
-- Operator -> extract JSON object field by key as it is
-- Operator ->> extract JSON object field by key as text

CREATE TABLE orders(
    id SERIAL PRIMARY KEY,
    user_id INT,
    order_dt DATE,
    total_amt DECIMAL(10,2),
    details jsonb
);

truncate orders;

INSERT INTO orders(user_id, total_amt, order_dt, details)
VALUES
(1001, 1250, '2024-01-01', '{"product":[{"id":101, "quantity": 1, "price": 250}, {"id":102, "quantity": 1, "price": 1000}]}'),
(1002, 100, '2024-01-02', '{"product":[{"id":103, "quantity": 2, "price": 50}]}'),
(1003, 180, '2024-01-03','{"product":[{"id":105, "quantity": 1, "price": 180}]}'),
(1004, 450, '2024-01-01', '{"product":[{"id":104, "quantity": 4, "price": 40}, {"id":106, "quantity": 1, "price": 410}]}'),
(1005, 910, '2024-01-04', '{"product":[{"id":107, "quantity": 1, "price": 50}, {"id":101, "quantity": 2, "price": 250}, {"id":105, "quantity": 2, "price": 180}]}');

-- Some basic queries to fetch JSON elements
select user_id, order_dt, details -> 'product' as prod_dtls
from orders;

-- Fetching values for nested JSON array elements as individual columns
select user_id, order_dt, details -> 'product' -> 0 -> 'id' as prod_ids,
       details -> 'product' -> 0 -> 'quantity' as prod_qty,
       details -> 'product' -> 0 -> 'price' as prod_price
from orders;


-- Retrieve orders where a specific product is present
-- The @> operator checks if the JSONB column contains the specified JSON structure.
SELECT *
FROM orders
WHERE details @> '{"product": [{"id": 101}]}' :: jsonb;


-- List all unique product IDs from all orders
SELECT DISTINCT product->>'id' AS product_id
FROM orders, jsonb_array_elements(details->'product') AS product;


-- Count of all unique product IDs from all orders
SELECT COUNT(DISTINCT product->>'id') AS product_id
FROM orders, jsonb_array_elements(details->'product') AS product;

-- Find Total quantity of all products ordered
SELECT SUM((product->'quantity') :: INT) AS total_quantity
FROM orders, jsonb_array_elements(details->'product') AS product;


-- Find total quantity of a specific product across all orders
-- jsonb_array_elements() expands the 'product' array inside the JSON.
SELECT SUM((product->'quantity') :: INT) AS total_quantity
FROM orders, jsonb_array_elements(details->'product') AS product
where product ->> 'id' = '105';


-- Find the highest-priced product in any order
SELECT MAX((product->>'price')::DECIMAL) AS highest_price
FROM orders, jsonb_array_elements(details->'product') AS product;


-- Identify Users Who Ordered a Specific Product
SELECT DISTINCT user_id
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
WHERE product->>'id' = '101';


-- All Products purchased by users
-- jsonb_array_elements(details->'product') extracts each item from the JSON array inside 'details'. (Expanding top-level JSON array)
-- The LATERAL join allows us to work with the extracted elements as if they were table rows.
-- jsonb_agg(product->>'id') collects all product IDs into an array for the given user_id.

SELECT
    user_id,
    jsonb_agg(product->'id') AS product_ids
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY user_id;


-- Return Product IDs as Text
SELECT
    user_id,
    jsonb_agg(product->>'id') AS product_ids
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY user_id;


-- Get the total revenue generated per product
SELECT product->>'id' AS product_id,
       SUM((product->>'price')::DECIMAL * (product->>'quantity')::INT) AS revenue
FROM orders, jsonb_array_elements(details->'product') AS product
GROUP BY product->>'id'
ORDER BY revenue DESC;


-- Show Product IDs with Quantity for Each User
SELECT
    user_id,
    jsonb_agg(jsonb_build_object(
        'product_id', (product->>'id')::INT,
        'quantity', (product->>'quantity')::INT
    )) AS product_details
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY user_id;


-- Extract Total Quantity of Products Purchased by Each User
SELECT
    user_id,
    SUM((product->>'quantity')::INT) AS total_quantity
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY user_id
ORDER BY total_quantity DESC;

-- jsonb_array_elements(details->'product') extracts each product in the order.
-- (product->>'quantity')::INT converts the JSON quantity to an integer.
-- SUM(quantity) gives the total number of products ordered by each user.

-- Find the Most Popular Products (Based on Total Quantity Sold)
SELECT
    product->>'id' AS product_id,
    SUM((product->>'quantity')::INT) AS total_sold
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY product_id
ORDER BY total_sold DESC;


-- Calculate the Total Revenue Generated by Each Product
SELECT
    product->>'id' AS product_id,
    SUM((product->>'quantity')::INT * (product->>'price')::DECIMAL) AS total_revenue
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY product_id
ORDER BY total_revenue DESC;


-- Show Detailed Order Breakdown (Unnesting JSON)
SELECT
    id AS order_id,
    user_id,
    order_dt,
    product->>'id' AS product_id,
    (product->>'quantity')::INT AS quantity,
    (product->>'price')::DECIMAL AS price,
    (product->>'quantity')::INT * (product->>'price')::DECIMAL AS total_price
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
ORDER BY order_id;



-- Get a Monthly Sales Report (Aggregated Revenue Per Month)
SELECT
    DATE_TRUNC('month', order_dt) AS order_month,
    SUM((product->>'quantity')::INT * (product->>'price')::DECIMAL) AS total_revenue
FROM orders,
LATERAL jsonb_array_elements(details->'product') AS product
GROUP BY order_month
ORDER BY order_month;

-- Analyzing user_activity with orders
CREATE TABLE user_activity (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    prod_id VARCHAR(20) NOT NULL,
    activity_dt DATE NOT NULL,
    action VARCHAR(50) NOT NULL
);


INSERT INTO user_activity (user_id, prod_id, activity_dt, action) VALUES
(1001, 101, '2024-01-01 10:00:00', 'view'),
(1005, 101, '2024-01-01 10:05:00', 'purchase'),
(1001, 101, '2024-01-01 10:05:00', 'purchase'),
(1001, 102, '2024-01-02 12:00:00', 'view'),
(1001, 102, '2024-01-02 12:10:00', 'purchase'),
(1002, 103, '2024-01-03 14:00:00', 'purchase'),
(1008, 103, '2024-01-03 14:00:00', 'add_to_cart'),
(1007, 103, '2024-01-03 14:00:00', 'view'),
(1002, 103, '2024-01-03 14:05:00', 'add_to_cart'),
(1004, 106, '2024-01-04 16:00:00', 'purchase'),
(1004, 104, '2024-01-05 18:00:00', 'add_to_cart'),
(1004, 104, '2024-01-05 18:00:00', 'purchase'),
(1001, 107, '2024-01-06 20:00:00', 'view'),
(1005, 107, '2024-01-06 20:00:00', 'purchase'),
(1005, 105, '2024-01-06 20:05:00', 'purchase'),
(1003, 105, '2024-01-06 20:05:00', 'purchase');


-- Identify Users Who Viewed a Product Before Purchasing It
SELECT DISTINCT ua.user_id, ua.prod_id
FROM user_activity ua
JOIN orders o ON ua.user_id = o.user_id
JOIN jsonb_array_elements(o.details->'product') AS product
    ON product->>'id' = ua.prod_id
WHERE ua.action = 'view'
AND EXISTS (
    SELECT 1 FROM user_activity ua2
    WHERE ua2.user_id = ua.user_id AND ua2.prod_id = ua.prod_id AND ua2.action = 'purchase'
);


-- Count How Many Users Added a Product to Cart but Did Not Purchase
SELECT ua.prod_id, COUNT(DISTINCT ua.user_id) AS abandoned_carts
FROM user_activity ua
LEFT JOIN orders o ON ua.user_id = o.user_id
LEFT JOIN jsonb_array_elements(o.details->'product') AS product
    ON product->>'id' = ua.prod_id
WHERE ua.action = 'add_to_cart'
AND NOT EXISTS (
    SELECT 1 FROM user_activity ua2
    WHERE ua2.user_id = ua.user_id AND ua2.prod_id = ua.prod_id AND ua2.action = 'purchase'
)
GROUP BY ua.prod_id;


-- Find Users Who Placed Orders But Did Not View or Add to Cart the Product
-- Using 'on true' when we are using lateral without additional join conditions.
SELECT DISTINCT o.user_id, jsonb_agg(product->>'id') AS purchased_products
FROM orders o
JOIN LATERAL jsonb_array_elements(o.details->'product') AS product ON TRUE
LEFT JOIN user_activity ua
    ON o.user_id = ua.user_id
    AND ua.prod_id = product->>'id'
    AND ua.action IN ('view', 'add_to_cart')
WHERE ua.user_id IS NULL
group by o.user_id;


-- Find Products That Were Viewed But Never Purchased
SELECT DISTINCT ua.user_id, ua.prod_id
FROM user_activity ua
LEFT JOIN orders o ON ua.user_id = o.user_id
LEFT JOIN jsonb_array_elements(o.details->'product') AS product
    ON product->>'id' = ua.prod_id
WHERE ua.action = 'view'
AND NOT EXISTS (
    SELECT 1 FROM user_activity ua2
    WHERE ua2.user_id = ua.user_id AND ua2.prod_id = ua.prod_id AND ua2.action = 'purchase'
);
