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
