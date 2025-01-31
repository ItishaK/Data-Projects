INSERT INTO ecom.users (id, name, address, email) VALUES
(1, 'Alice', '123 Main St, NY', 'alice.johnson@example.com'),
(2, 'Bob', '456 Park Ave, CA', 'bob.smith@example.com'),
(3, 'Charlie', '789 Oak St, TX', 'charlie.brown@example.com'),
(4, 'David', '321 Elm St, FL', 'david.williams@example.com'),
(5, 'Emma', '654 Pine St, WA', 'emma.davis@example.com'),
(6, 'Frank', '987 Maple St, CO', 'frank.miller@example.com'),
(7, 'Grace', '246 Birch St, IL', 'grace.wilson@example.com'),
(8, 'Hannah', '135 Cedar St, NV', 'hannah.moore@example.com'),
(9, 'Ian', '579 Aspen St, AZ', 'ian.taylor@example.com'),
(10, 'Jack', '864 Redwood St, NJ', 'jack.anderson@example.com');


INSERT INTO ecom.products (id, name, description, price) VALUES
(101, 'Laptop', '15-inch gaming laptop', 1200),
(102, 'Smartphone', 'Flagship 5G smartphone', 999),
(103, 'Headphones', 'Noise-canceling wireless headphones', 250),
(104, 'Smartwatch', 'Waterproof fitness tracker', 180),
(105, 'Tablet', '10-inch Android tablet', 350),
(106, 'Monitor', '27-inch 4K UHD display', 450),
(107, 'Keyboard', 'Mechanical RGB gaming keyboard', 120),
(108, 'Mouse', 'Wireless ergonomic mouse', 80),
(109, 'Printer', 'All-in-one color printer', 200),
(110, 'External HDD', '2TB portable hard drive', 100);


INSERT INTO ecom.orders (id, user_id, total_amt, order_date) VALUES
(1001, 1, 1250, '2024-01-01'),
(1002, 2, 1999, '2024-01-02'),
(1003, 3, 250, '2024-01-03'),
(1004, 4, 450, '2024-01-04'),
(1005, 5, 180, '2024-01-05'),
(1006, 6, 999, '2024-01-06'),
(1007, 7, 350, '2024-01-07'),
(1008, 8, 120, '2024-01-08'),
(1009, 9, 80, '2024-01-09'),
(1010, 10, 100, '2024-01-10');


INSERT INTO ecom.orderDetails (id, order_id, product_id, quantity, price) VALUES
(1, 1001, 101, 1, 1200),
(2, 1001, 103, 1, 50),
(3, 1002, 102, 2, 999),
(4, 1003, 103, 1, 250),
(5, 1004, 106, 1, 450),
(6, 1005, 104, 1, 180),
(7, 1006, 102, 1, 999),
(8, 1007, 105, 1, 350),
(9, 1008, 107, 1, 120),
(10, 1009, 108, 1, 80);


INSERT INTO ecom.userActivity (id, user_id, product_id, activity_type, activity_date) VALUES
(1, 1, 101, 'view', '2024-01-01 10:00:00'),
(2, 1, 101, 'add_to_cart', '2024-01-01 10:05:00'),
(3, 2, 102, 'view', '2024-01-02 12:00:00'),
(4, 2, 102, 'purchase', '2024-01-02 12:10:00'),
(5, 3, 103, 'view', '2024-01-03 14:00:00'),
(6, 3, 103, 'add_to_cart', '2024-01-03 14:05:00'),
(7, 4, 106, 'view', '2024-01-04 16:00:00'),
(8, 5, 104, 'add_to_cart', '2024-01-05 18:00:00'),
(9, 6, 102, 'view', '2024-01-06 20:00:00'),
(10, 6, 102, 'purchase', '2024-01-06 20:05:00');


