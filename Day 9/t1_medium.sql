-- Return `order_id`, `order_timestamp_tz`, and a second column `order_ts_notz` that shows the same value cast to a plain `TIMESTAMP` (no timezone). 
-- Look closely at what changes in the output value and think about why.


-- method 1
SELECT order_id, order_timestamp_tz, order_timestamp_tz::timestamp AS order_ts_notz FROM orders;

-- method 2
select order_id,order_timestamp_tz,CAST(order_timestamp_tz as timestamp) as order_ts_notz from orders ;
