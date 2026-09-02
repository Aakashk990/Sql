-- Problem
-- A group of passengers is waiting in line to board a bus. However, the bus has a maximum weight capacity of 1000 kilograms. 
-- Passengers board one at a time based on their boarding order, and the boarding process stops as soon as 
-- the next passenger would cause the total weight to exceed the limit.

-- Input:

-- mcb_sample:

-- passenger_id	passenger_name	weight_kg	boarding_order
-- 5	            Alice	        250	        1
-- 4	            Bob	            175	        5
-- 3	            Alex	        350	        2
-- 6	            John Cena	    400	        3


-- Output:

-- passenger_name
-- John Cena


WITH OrderedPassengers AS (
    SELECT 
        passenger_name,
        weight,
        turn,
        SUM(weight) OVER (ORDER BY turn ASC) AS cumulative_weight
    FROM 
        Queue
)
SELECT 
    passenger_name
FROM 
    OrderedPassengers
WHERE 
    cumulative_weight <= 1000
ORDER BY 
    turn DESC
LIMIT 1;
