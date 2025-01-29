-- Input Table
select * from user_activity;

-- Method 1
select * from user_activity_refined;

-- Method 2
select * from user_activity_refined2;

-- Method 3 (Custom Business Rule)
-- Select relevant records by adding a filter for not including soft deletes.

select user_id, activity_date, product_id, action
from user_activity_refined3
where indicator = 1;