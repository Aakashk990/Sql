--Question 1 List the third and fourth largest cities (by population) in the United States and their population 
SELECT city,Population 
FROM north_american_cities 
WHERE Country='United States'
ORDER BY Population desc limit 2 offset 2;

--o/p
-- City	Population
-- Chicago	2718782
-- Houston	2195914

