-- Enter Data to User Activity Table
INSERT INTO user_activity (user_id, activity_date, action, product_id)
VALUES
    (101, '2025-01-01', 'view', 'P1'),
    (101, '2025-01-01', 'add_to_cart', 'P1'),
    (101, '2025-01-01', 'view', 'P1'),
    (101, '2025-01-02', 'view', 'P2'),
    (102, '2025-01-01', 'view', 'P3'),
    (102, '2025-01-02', 'add_to_cart', 'P2'),
    (103, '2025-01-02', 'purchase', 'P3'),
    (103, '2025-01-02', 'view', 'P3'),
    (103, '2025-01-02', 'add_to_cart', 'P3'),
    (104, '2025-01-03', 'view', 'P4'),
    (104, '2025-01-03', 'add_to_cart', 'P4'),
    (104, '2025-01-03', 'purchase', 'P4'),
    (105, '2025-01-03', 'view', 'P1');
	

-- Custom Business Rules for Deduplication of Not Exact Duplicates
-- Rule 1: ‘view’ actions can be removed when ‘add_to_cart’ action exists.
-- Rule 2: ‘view’ and ‘add_to_cart’ actions can be removed when ‘purchase’ action exists.	
-- Update the indicator column based on the custom deduplication rule 1

UPDATE user_activity_refined3 ua1
JOIN user_activity_refined3 ua2
  ON ua1.user_id = ua2.user_id
  AND ua1.product_id = ua2.product_id
  AND ua1.action = 'view'
  AND ua2.action = 'add_to_cart'
SET ua1.indicator = 0;

-- Update the indicator column based on the custom deduplication rule 2
UPDATE user_activity_refined3 ua1
JOIN user_activity_refined3 ua2
  ON ua1.user_id = ua2.user_id
  AND ua1.product_id = ua2.product_id
  AND ua1.action = 'add_to_cart'
  AND ua2.action = 'purchase'
SET ua1.indicator = 0;