Type	Stores	Example
DATE	Calendar date only	2022-05-24
TIMESTAMP	Date and time	2022-05-24 14:30:00
TIMESTAMPTZ	Date, time, timezone	2022-05-24 14:30:00+00

Way 1(modern) -
SELECT id, order_date::date AS order_date_only FROM orders;
SELECT id, order_date::time AS order_time FROM orders;

Way 2(legacy) -
SELECT
    id,
    order_date,
    EXTRACT(YEAR FROM order_date)   AS order_year,
    EXTRACT(MONTH FROM order_date)  AS order_month,
    EXTRACT(HOUR FROM order_date)   AS order_hour
FROM orders;



DATE_TRUNC: the most-used date function

DATE_TRUNC rounds a timestamp down to the start of a period. It is the backbone of every time-series query you will ever write:


-- Daily revenue
SELECT DATE_TRUNC('day', order_timestamp) AS order_day, SUM(amount) AS revenue
FROM orders
GROUP BY 1 ORDER BY 1;

-- Weekly active users
SELECT DATE_TRUNC('week', login_timestamp) AS login_week,
       COUNT(DISTINCT user_id) AS wau
FROM logins
GROUP BY 1 ORDER BY 1;

DATE_TRUNC('month', '2024-03-15') returns 2024-03-01; 'week' returns the Monday of that ISO week on most platforms (BigQuery and MySQL default weeks to Sunday, verify on yours).




Adding time: INTERVAL and DATEADD

SQL

-- Last 30 days
SELECT * FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days';

-- Expiration one year after signup
SELECT user_id, signup_date + INTERVAL '1 year' AS expiration_date
FROM users;



Timezones: store UTC, convert at the end

The rule that prevents the opening diagram's bug: every timestamp in the warehouse is UTC, converted to local time only in the final reporting layer.

SQL

-- PostgreSQL
SELECT order_timestamp AT TIME ZONE 'UTC' AT TIME ZONE 'America/Los_Angeles' FROM orders;

-- Snowflake
SELECT CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', order_timestamp) FROM orders;

-- BigQuery
SELECT DATETIME(order_timestamp, 'America/Los_Angeles') FROM orders;