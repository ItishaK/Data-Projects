-- 1. Identify Users Who Added to Cart but Didn't Purchase
-- Business Need: Find users who have added a product to the cart but never completed a purchase.
-- Insight: Helps in retargeting users who abandoned their carts.

-- The tables that can answer the above question are : users and userActivity
-- 1st Method
select u.id, u.name, u.email
from users u
join
    (select distinct ua1.user_id
from userActivity ua1
join userActivity ua2
where
ua1.user_id = ua2.user_id
and ua1.product_id = ua2.product_id
and ua1.activity_type = 'add_to_cart'
and ua2.activity_type != 'purchase'
    )temp
on u.id = temp.user_id;

-- 2nd Method
select u.id, u.name, u.email
from users u
join(
SELECT DISTINCT ua.user_id
FROM userActivity ua
WHERE ua.activity_type = 'add_to_cart'
AND NOT EXISTS (
    SELECT 1 FROM userActivity ua2
    WHERE ua2.user_id = ua.user_id
    AND ua2.product_id = ua.product_id
    AND ua2.activity_type = 'purchase'
))temp
on u.id = temp.user_id;


-- 2. Find the Most Popular Products Based on User Engagement
-- Business Need: Determine which products are the most viewed or added to carts before purchase.
-- Insight: Helps in identifying high-engagement products for promotions.

-- The tables that can answer the above question are : products and userActivity
-- 1st Method (Using Subquery and count window function)
select p.id, p.name, p.description, temp.cnt as counts
from products p
join
( select distinct ua.product_id, count(ua.product_id) over (partition by ua.product_id) as cnt
from userActivity ua)temp
on p.id = temp.product_id
order by counts desc
limit 5;

-- 2nd Method (Using count along with Case statement to bifurcate the user_activity)
SELECT p.id, p.name,
       COUNT(CASE WHEN ua.activity_type = 'view' THEN 1 END) AS total_views,
       COUNT(CASE WHEN ua.activity_type = 'add_to_cart' THEN 1 END) AS total_adds,
       COUNT(CASE WHEN ua.activity_type = 'purchase' THEN 1 END) AS total_purchases
FROM products p
JOIN userActivity ua ON p.id = ua.product_id
GROUP BY p.id, p.name
ORDER BY total_purchases DESC, total_adds DESC, total_views DESC
LIMIT 5;

-- 3rd Method (Using Sum-IF statement to bifurcate the user_activity)
SELECT p.id, p.name,
       SUM(IF(ua.activity_type = 'view', 1, 0)) AS total_views,
       SUM(IF(ua.activity_type = 'add_to_cart', 1, 0)) AS total_adds,
       SUM(IF(ua.activity_type = 'purchase', 1, 0)) AS total_purchases
FROM products p
JOIN userActivity ua ON p.id = ua.product_id
GROUP BY p.id, p.name
ORDER BY total_purchases DESC, total_adds DESC, total_views DESC
LIMIT 5;


-- 3. Calculate Customer Lifetime Value (CLV)
-- Business Need: Find the total amount each user has spent.
-- Insight: Helps in segmenting high-value customers for exclusive deals.

-- The tables that can answer the above question are : users and orders

select u.id, u.name, u.email, temp.lifetime_val
from users u
join
    (select o.user_id, sum(total_amt) as lifetime_val
from orders o
group by o.user_id)temp
on u.id = temp.user_id
order by temp.lifetime_val desc
;

-- 4. Find Users Who Buy Frequently (Repeat Customers)
-- Business Need: Identify users who have placed more than one order.
-- Insight: Helps in customer retention strategies.

-- The tables that can answer the above question are : users and orders

SELECT u.id, u.name,
       COUNT(o.id) AS total_orders
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name
HAVING total_orders > 1
ORDER BY total_orders DESC;


-- 5. Deduplicate User Activity Using Window Functions
-- Business Need: For the same user_id, product_id, and activity_date,
-- prioritize activities in this order: purchase → add_to_cart → view and mark others as soft deleted.
-- Insight: Ensures deduplication and keeps only the most important event for each user-product combination.

-- Selection query
SELECT *,
       CASE
           WHEN ua1.activity_type = 'purchase' THEN 1
           WHEN ua1.activity_type = 'add_to_cart' AND EXISTS (
               SELECT 1 FROM userActivity ua2
               WHERE ua1.user_id = ua2.user_id
               AND ua1.product_id = ua2.product_id
               AND ua2.activity_type = 'purchase'
               ) THEN 0
           WHEN ua1.activity_type = 'view' AND EXISTS (
               SELECT 1 FROM userActivity ua2
               WHERE ua1.user_id = ua2.user_id
               AND ua1.product_id = ua2.product_id
               AND ua2.activity_type IN ('add_to_cart', 'purchase')
           ) THEN 0
           ELSE 1
       END AS indicator
FROM userActivity ua1
HAVING indicator = 1;

-- 1st Method
-- Update query
create table userActivity_ref as select * from userActivity;
alter table userActivity_ref add column indicator tinyint default 1;

update userActivity_ref ua1
join
userActivity_ref ua2
on ua1.user_id = ua2.user_id
and ua1.product_id = ua2.product_id
and ua1.activity_type = 'view'
and ua2.activity_type = 'add_to_cart'
set ua1.indicator = 0;


update userActivity_ref ua1
join
userActivity_ref ua2
on ua1.user_id = ua2.user_id
and ua1.product_id = ua2.product_id
and ua1.activity_type = 'add_to_cart'
and ua2.activity_type = 'purchase'
set ua1.indicator = 0;


-- 2nd Method
CREATE TABLE user_activity_dedup AS
SELECT * FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY user_id, product_id
               ORDER BY FIELD(activity_type, 'purchase','add_to_cart', 'view')
           ) AS indicator
    FROM userActivity
) ranked
WHERE indicator = 1;