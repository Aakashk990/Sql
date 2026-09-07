-- Return `order_id`, `order_date`, `order_timestamp`, and a boolean column `dates_match` that checks whether `order_date` equals 
-- the date portion of `order_timestamp`. This is a common "sanity check" pattern 
-- in real pipelines — you're verifying two related date columns agree.

select order_id,order_date,order_timestamp,(order_date=cast(order_timestamp as date)) as dates_match from orders;

SELECT order_id, order_date, order_timestamp, (order_date = order_timestamp::date) AS dates_match FROM orders;


o/p

"order_id"	"order_date"	"order_timestamp"	"dates_match"
1	"2023-01-15"	"2023-01-15 09:23:00"	true
2	"2023-02-10"	"2023-02-10 18:45:00"	true
3	"2023-03-05"	"2023-03-05 23:10:00"	true
4	"2023-03-20"	"2023-03-20 12:00:00"	true
5	"2023-04-01"	"2023-04-01 00:15:00"	true
6	"2023-05-18"	"2023-05-18 15:30:00"	true
7	"2023-06-25"	"2023-06-25 21:05:00"	true
8	"2023-07-09"	"2023-07-09 08:40:00"	true
9	"2023-08-14"	"2023-08-14 19:55:00"	true
10	"2023-09-02"	"2023-09-02 10:20:00"	true
11	"2023-10-11"	"2023-10-11 14:00:00"	true
12	"2023-11-20"	"2023-11-20 22:30:00"	true
13	"2023-12-05"	"2023-12-05 09:00:00"	true
14	"2023-12-25"	"2023-12-25 16:10:00"	true
15	"2024-01-03"	"2024-01-03 11:45:00"	true
16	"2024-02-14"	"2024-02-14 20:00:00"	true
17	"2024-03-08"	"2024-03-08 13:15:00"	true
18	"2024-04-22"	"2024-04-22 07:30:00"	true
19	"2024-05-30"	"2024-05-30 23:59:00"	true
20	"2024-06-17"	"2024-06-17 09:10:00"	true