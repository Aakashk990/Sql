-- Return `order_id`, `customer_name`, `order_date` for all orders placed 
-- between `2023-06-01` and `2023-12-31` (inclusive). Order by `order_date` ascending.



select order_id,customer_name,order_date from orders where order_date between '2023-06-01' and '2023-12-31' order by order_date;


o/p

"order_id"	"customer_name"	"order_date"
7	"Sneha"	"2023-06-25"
8	"Ananya"	"2023-07-09"
9	"Vikram"	"2023-08-14"
10	"Priya"	"2023-09-02"
11	"Meera"	"2023-10-11"
12	"Karan"	"2023-11-20"
13	"Arjun"	"2023-12-05"
14	"Ananya"	"2023-12-25"