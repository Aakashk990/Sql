# PostgreSQL Date & Time Practice — Full Question Bank

**How to use this:** Run the setup block once. Then go topic by topic, in order, Easy → Medium → Hard. Attempt each query yourself before looking at the Solutions section at the bottom. Don't skip around — one topic fully done beats three topics half-done.

---

## ⚠️ Important: Syntax mapping (read this first)

PostgreSQL does **not** have `DATEADD()`, `DATEDIFF()`, or `CONVERT_TZ()` as functions — those are SQL Server / MySQL syntax. If you search for them in Postgres docs you'll find nothing, and that's expected, not a mistake on your end. Here's what Postgres uses instead:

| SQL Server / MySQL | PostgreSQL equivalent |
|---|---|
| `DATEADD(day, 7, order_date)` | `order_date + INTERVAL '7 days'` |
| `DATEDIFF(day, date1, date2)` | `date2 - date1` (for `DATE` columns), or `AGE(date2, date1)` / `EXTRACT(EPOCH FROM (ts2 - ts1))` for timestamps |
| `CONVERT_TZ(col, 'UTC', 'IST')` | `col AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata'` (for naive timestamps) or `col AT TIME ZONE 'Asia/Kolkata'` (for `timestamptz`) |

This practice set is built entirely around the PostgreSQL-native syntax on the right.

---

## Setup — run this once

```sql
-- Table 1: orders (main dataset — covers DATE, TIMESTAMP, TIMESTAMPTZ, EXTRACT, DATE_TRUNC, INTERVAL, DATEDIFF-equivalent)
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    customer_name VARCHAR(50),
    order_date DATE,
    order_timestamp TIMESTAMP,
    order_timestamp_tz TIMESTAMPTZ,
    ship_date DATE,
    delivery_timestamp TIMESTAMP,
    amount NUMERIC(10,2),
    order_status VARCHAR(20)
);

INSERT INTO orders VALUES
(1,  101, 'Ananya', '2023-01-15', '2023-01-15 09:23:00', '2023-01-15 09:23:00+05:30', '2023-01-17', '2023-01-20 14:00:00', 2499.00, 'Delivered'),
(2,  102, 'Rohan',  '2023-02-10', '2023-02-10 18:45:00', '2023-02-10 18:45:00+05:30', '2023-02-12', '2023-02-15 11:30:00', 1599.50, 'Delivered'),
(3,  101, 'Ananya', '2023-03-05', '2023-03-05 23:10:00', '2023-03-05 23:10:00+05:30', '2023-03-08', '2023-03-11 09:00:00', 799.00,  'Delivered'),
(4,  103, 'Priya',  '2023-03-20', '2023-03-20 12:00:00', '2023-03-20 12:00:00+05:30', NULL,         NULL,                  4599.00, 'Cancelled'),
(5,  104, 'Karan',  '2023-04-01', '2023-04-01 00:15:00', '2023-04-01 00:15:00+05:30', '2023-04-02', '2023-04-05 16:45:00', 2199.00, 'Delivered'),
(6,  102, 'Rohan',  '2023-05-18', '2023-05-18 15:30:00', '2023-05-18 15:30:00+05:30', '2023-05-19', '2023-05-21 10:00:00', 999.00,  'Delivered'),
(7,  105, 'Sneha',  '2023-06-25', '2023-06-25 21:05:00', '2023-06-25 21:05:00+05:30', '2023-06-27', '2023-06-30 13:20:00', 3299.00, 'Delivered'),
(8,  101, 'Ananya', '2023-07-09', '2023-07-09 08:40:00', '2023-07-09 08:40:00+05:30', '2023-07-10', '2023-07-12 17:00:00', 1299.00, 'Delivered'),
(9,  106, 'Vikram', '2023-08-14', '2023-08-14 19:55:00', '2023-08-14 19:55:00+05:30', '2023-08-16', '2023-08-19 12:00:00', 599.00,  'Delivered'),
(10, 103, 'Priya',  '2023-09-02', '2023-09-02 10:20:00', '2023-09-02 10:20:00+05:30', '2023-09-04', NULL,                  2899.00, 'Shipped'),
(11, 107, 'Meera',  '2023-10-11', '2023-10-11 14:00:00', '2023-10-11 14:00:00+05:30', '2023-10-12', '2023-10-15 09:30:00', 1899.00, 'Delivered'),
(12, 104, 'Karan',  '2023-11-20', '2023-11-20 22:30:00', '2023-11-20 22:30:00+05:30', '2023-11-22', '2023-11-25 15:00:00', 3499.00, 'Delivered'),
(13, 108, 'Arjun',  '2023-12-05', '2023-12-05 09:00:00', '2023-12-05 09:00:00+05:30', '2023-12-07', '2023-12-10 11:00:00', 799.50,  'Delivered'),
(14, 101, 'Ananya', '2023-12-25', '2023-12-25 16:10:00', '2023-12-25 16:10:00+05:30', NULL,         NULL,                  1999.00, 'Cancelled'),
(15, 105, 'Sneha',  '2024-01-03', '2024-01-03 11:45:00', '2024-01-03 11:45:00+05:30', '2024-01-04', '2024-01-06 14:30:00', 2599.00, 'Delivered'),
(16, 109, 'Divya',  '2024-02-14', '2024-02-14 20:00:00', '2024-02-14 20:00:00+05:30', '2024-02-16', '2024-02-19 10:00:00', 4999.00, 'Delivered'),
(17, 102, 'Rohan',  '2024-03-08', '2024-03-08 13:15:00', '2024-03-08 13:15:00+05:30', '2024-03-09', '2024-03-11 16:00:00', 1399.00, 'Delivered'),
(18, 110, 'Aditya', '2024-04-22', '2024-04-22 07:30:00', '2024-04-22 07:30:00+05:30', '2024-04-23', NULL,                  899.00,  'Shipped'),
(19, 106, 'Vikram', '2024-05-30', '2024-05-30 23:59:00', '2024-05-30 23:59:00+05:30', '2024-06-01', '2024-06-04 12:00:00', 3199.00, 'Delivered'),
(20, 103, 'Priya',  '2024-06-17', '2024-06-17 09:10:00', '2024-06-17 09:10:00+05:30', '2024-06-18', '2024-06-21 15:45:00', 2199.00, 'Delivered');


-- Table 2: customer_logins (for timezone / AT TIME ZONE practice)
CREATE TABLE customer_logins (
    login_id INT PRIMARY KEY,
    customer_id INT,
    login_time TIMESTAMPTZ,
    logout_time TIMESTAMPTZ,
    client_timezone VARCHAR(50)
);

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
```

---

## Topic 1: DATE vs TIMESTAMP vs TIMESTAMPTZ fundamentals

**Easy** — Return `order_id`, `customer_name`, `order_date` for all orders placed between `2023-06-01` and `2023-12-31` (inclusive). Order by `order_date` ascending.

**Medium** — Return `order_id`, `order_timestamp_tz`, and a second column `order_ts_notz` that shows the same value cast to a plain `TIMESTAMP` (no timezone). Look closely at what changes in the output value and think about why.

**Hard** — Return `order_id`, `order_date`, `order_timestamp`, and a boolean column `dates_match` that checks whether `order_date` equals the date portion of `order_timestamp`. This is a common "sanity check" pattern in real pipelines — you're verifying two related date columns agree.

---

## Topic 2: EXTRACT

**Easy** — Return `order_id` and two separate columns, `order_year` and `order_month`, extracted from `order_date`.

**Medium** — Count the number of orders placed on each day of the week (`EXTRACT(DOW FROM order_date)`, 0 = Sunday). Return `day_of_week` and `order_count`, sorted by `order_count` descending.

**Hard** — Return `order_id`, `order_timestamp`, and `quarter` (via `EXTRACT(QUARTER FROM order_timestamp)`) for orders placed in **Q1 of any year**, restricted further to orders placed during "business hours" — hour >= 9 and hour < 18.

---

## Topic 3: DATE_TRUNC

**Easy** — Return `order_id` and `order_month_start`, where `order_month_start` truncates `order_timestamp` down to the start of its month.

**Medium** — Calculate total order `amount` grouped by month, using `DATE_TRUNC('month', order_date)`. Return `month_start` and `total_amount`, ordered chronologically.

**Hard** — Find the single month in 2023 with the highest number of orders. Return just that one `month_start` and its `order_count`.

---

## Topic 4: INTERVAL & date arithmetic (the `DATEADD` equivalent)

**Easy** — For every order, add 7 days to `order_date` to produce `expected_delivery_date`.

**Medium** — Find all orders where the actual `ship_date` is more than 3 days after `order_date`. Return `order_id`, `order_date`, `ship_date`, and the day difference.

**Hard** — For each customer, find their most recent `order_date`, then compute a `next_expected_order` date assuming a 45-day repurchase cycle (`most_recent_order_date + INTERVAL '45 days'`). Only return customers whose computed next-expected-order date falls before `2024-07-01`.

---

## Topic 5: Date differences (the `DATEDIFF` equivalent)

**Easy** — For every order with a non-null `ship_date`, calculate `days_to_ship` (the number of days between `order_date` and `ship_date`).

**Medium** — For every order with a non-null `delivery_timestamp`, return the raw interval between `order_timestamp` and `delivery_timestamp`, plus a `total_hours` column computed via `EXTRACT(EPOCH FROM ...)`.

**Hard** — Classify every delivered order into a speed bucket based on days between `order_date` and `delivery_timestamp`'s date: `'Fast'` (≤3 days), `'Standard'` (4–6 days), `'Slow'` (7+ days). Return `order_id`, `days_taken`, `delivery_speed`.

---

## Topic 6: Time zones & `AT TIME ZONE` (the `CONVERT_TZ` equivalent)

Uses `customer_logins`.

**Easy** — For each login, return `login_time` converted into the customer's own `client_timezone` as `local_login_time`, using `AT TIME ZONE`.

**Medium** — For each session, return `duration_minutes` (minutes between `login_time` and `logout_time`) and `login_time_ist` — the login time converted specifically to `'Asia/Kolkata'`, regardless of the customer's actual timezone.

**Hard** — Find all sessions where the calendar date of `login_time` differs depending on whether you view it in UTC vs. the customer's `client_timezone` (i.e., logins that happened close enough to midnight locally that the date "flips" across the two views). Return `login_id`, `client_timezone`, `utc_date`, `local_date`.

---
---

# Solutions

*Only check these after attempting. Compare logic, not just output — there's often more than one correct way to write these.*

### Topic 1

```sql
-- Easy
SELECT order_id, customer_name, order_date
FROM orders
WHERE order_date BETWEEN '2023-06-01' AND '2023-12-31'
ORDER BY order_date;

-- Medium
SELECT order_id, order_timestamp_tz, order_timestamp_tz::timestamp AS order_ts_notz
FROM orders;

-- Hard
SELECT order_id, order_date, order_timestamp,
       (order_date = order_timestamp::date) AS dates_match
FROM orders;
```

### Topic 2

```sql
-- Easy
SELECT order_id,
       EXTRACT(YEAR FROM order_date) AS order_year,
       EXTRACT(MONTH FROM order_date) AS order_month
FROM orders;

-- Medium
SELECT EXTRACT(DOW FROM order_date) AS day_of_week, COUNT(*) AS order_count
FROM orders
GROUP BY 1
ORDER BY order_count DESC;

-- Hard
SELECT order_id, order_timestamp, EXTRACT(QUARTER FROM order_timestamp) AS quarter
FROM orders
WHERE EXTRACT(QUARTER FROM order_timestamp) = 1
  AND EXTRACT(HOUR FROM order_timestamp) >= 9
  AND EXTRACT(HOUR FROM order_timestamp) < 18;
```

### Topic 3

```sql
-- Easy
SELECT order_id, DATE_TRUNC('month', order_timestamp) AS order_month_start
FROM orders;

-- Medium
SELECT DATE_TRUNC('month', order_date) AS month_start, SUM(amount) AS total_amount
FROM orders
GROUP BY 1
ORDER BY 1;

-- Hard
SELECT DATE_TRUNC('month', order_date) AS month_start, COUNT(*) AS order_count
FROM orders
WHERE order_date >= '2023-01-01' AND order_date < '2024-01-01'
GROUP BY 1
ORDER BY order_count DESC
LIMIT 1;
```

### Topic 4

```sql
-- Easy
SELECT order_id, order_date, order_date + INTERVAL '7 days' AS expected_delivery_date
FROM orders;

-- Medium
SELECT order_id, order_date, ship_date, (ship_date - order_date) AS days_diff
FROM orders
WHERE ship_date > order_date + INTERVAL '3 days';

-- Hard
SELECT customer_id,
       MAX(order_date) AS most_recent_order,
       MAX(order_date) + INTERVAL '45 days' AS next_expected_order
FROM orders
GROUP BY customer_id
HAVING MAX(order_date) + INTERVAL '45 days' < '2024-07-01';
```

### Topic 5

```sql
-- Easy
SELECT order_id, order_date, ship_date, (ship_date - order_date) AS days_to_ship
FROM orders
WHERE ship_date IS NOT NULL;

-- Medium
SELECT order_id, order_timestamp, delivery_timestamp,
       (delivery_timestamp - order_timestamp) AS raw_interval,
       EXTRACT(EPOCH FROM (delivery_timestamp - order_timestamp)) / 3600 AS total_hours
FROM orders
WHERE delivery_timestamp IS NOT NULL;

-- Hard
SELECT order_id,
       (delivery_timestamp::date - order_date) AS days_taken,
       CASE
           WHEN (delivery_timestamp::date - order_date) <= 3 THEN 'Fast'
           WHEN (delivery_timestamp::date - order_date) BETWEEN 4 AND 6 THEN 'Standard'
           ELSE 'Slow'
       END AS delivery_speed
FROM orders
WHERE delivery_timestamp IS NOT NULL;
```

### Topic 6

```sql
-- Easy
SELECT login_id, login_time, client_timezone,
       login_time AT TIME ZONE client_timezone AS local_login_time
FROM customer_logins;

-- Medium
SELECT login_id,
       EXTRACT(EPOCH FROM (logout_time - login_time)) / 60 AS duration_minutes,
       login_time AT TIME ZONE 'Asia/Kolkata' AS login_time_ist
FROM customer_logins;

-- Hard
SELECT login_id, client_timezone,
       (login_time AT TIME ZONE 'UTC')::date AS utc_date,
       (login_time AT TIME ZONE client_timezone)::date AS local_date
FROM customer_logins
WHERE (login_time AT TIME ZONE 'UTC')::date
      <> (login_time AT TIME ZONE client_timezone)::date;
```
