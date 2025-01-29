-- Create User Activity Table
CREATE TABLE user_activity (
    user_id INT NOT NULL,
    activity_date DATE NOT NULL,
    action VARCHAR(50) NOT NULL,
    product_id VARCHAR(20) NOT NULL
);

-- 1st Method : Aggregation Method for Deduplication of Exact Duplicates
-- Utilizing 'sum-if' clause to a Create Refined table

CREATE TABLE user_activity_refined AS
SELECT user_id, activity_date, product_id,
       sum(if(action = 'view',1,0)) as total_views,
       sum(if(action = 'add_to_cart',1,0)) as total_add_to_carts,
       sum(if(action = 'purchase',1,0)) as total_purchases
FROM user_activity
GROUP BY user_id, activity_date, product_id;


-- 2nd Method: Adding a Surrogate key for Deduplication of Exact Duplicates

CREATE TABLE user_activity_refined2 AS SELECT * FROM user_activity;

ALTER TABLE user_activity_refined2
ADD COLUMN seq_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;


-- 3rd Method: Custom Business Rule for Deduplication of Not Exact Duplicates
CREATE TABLE user_activity_refined3 AS SELECT * FROM user_activity;

-- Add the indicator column to the table
ALTER TABLE user_activity_refined3 ADD COLUMN indicator TINYINT DEFAULT 1;