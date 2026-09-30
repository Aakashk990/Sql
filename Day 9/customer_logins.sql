--question 1
-- SQL script to create the orders table and insert sample data
-- SQL script to create the customer_logins table and insert sample data
CREATE TABLE customer_logins (
    login_id INT PRIMARY KEY,
    customer_id INT,
    login_time TIMESTAMPTZ,
    logout_time TIMESTAMPTZ,
    client_timezone VARCHAR(50)
);

-- inserting sample data into the customer_logins table

INSERT INTO customer_logins VALUES
(1,  101, '2024-01-10 03:15:00+00', '2024-01-10 03:45:00+00', 'Asia/Kolkata'),
(2,  102, '2024-01-10 14:00:00+00', '2024-01-10 14:40:00+00', 'America/New_York'),
(3,  103, '2024-01-11 09:30:00+00', '2024-01-11 10:00:00+00', 'Europe/London'),
(4,  104, '2024-01-11 22:10:00+00', '2024-01-11 22:50:00+00', 'Asia/Kolkata'),
(5,  105, '2024-01-12 05:45:00+00', '2024-01-12 06:20:00+00', 'Australia/Sydney'),
(6,  106, '2024-01-12 18:00:00+00', '2024-01-12 18:30:00+00', 'America/Los_Angeles'),
(7,  101, '2024-01-13 01:00:00+00', '2024-01-13 01:20:00+00', 'Asia/Kolkata'),
(8,  107, '2024-01-13 11:15:00+00', '2024-01-13 11:55:00+00', 'Europe/London'),
(9,  108, '2024-01-14 16:40:00+00', '2024-01-14 17:10:00+00', 'Asia/Kolkata'),
(10, 102, '2024-01-14 23:30:00+00', '2024-01-15 00:05:00+00', 'America/New_York'),
(11, 109, '2024-01-15 02:30:00+00', '2024-01-15 03:00:00+00', 'America/Los_Angeles');