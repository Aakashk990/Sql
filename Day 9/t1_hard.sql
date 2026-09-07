-- Return `order_id`, `order_date`, `order_timestamp`, and a boolean column `dates_match` that checks whether `order_date` equals 
-- the date portion of `order_timestamp`. This is a common "sanity check" pattern 
-- in real pipelines — you're verifying two related date columns agree.

select order_id,order_date,order_timestamp,(order_date=cast(order_timestamp as date)) as dates_match from orders;

SELECT order_id, order_date, order_timestamp, (order_date = order_timestamp::date) AS dates_match FROM orders;