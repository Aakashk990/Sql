-- Return `order_id`, `customer_name`, `order_date` for all orders placed 
-- between `2023-06-01` and `2023-12-31` (inclusive). Order by `order_date` ascending.



select order_id,customer_name,order_date from orders where order_date between '2023-06-01' and '2023-12-31' order by order_date;