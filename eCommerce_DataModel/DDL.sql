CREATE DATABASE if not exists eCom;

use eCom;

-- Users Table
CREATE TABLE users (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    address VARCHAR(100),
    email VARCHAR(100)
);

-- Products table
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    description VARCHAR(100),
    price DECIMAL(10, 2)
);

-- Orders Table
CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,
    total_amt DECIMAL(10, 2),
    order_date DATE,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Order Details Table
CREATE TABLE orderDetails (
    id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES orders(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

-- User Activity Table
CREATE TABLE userActivity (
    id INT PRIMARY KEY,
    user_id INT,
    product_id INT,
    activity_type VARCHAR(50),
    activity_date TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (product_id) REFERENCES products(id)
);

