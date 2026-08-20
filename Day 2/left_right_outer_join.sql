-- question 1 Find the list of all buildings that have employees 
select distinct(b.Building_name) from Buildings b left join Employees e on b.Building_name = e.Building where e.Building is not null;

--o/p
-- Building_name
-- 1e
-- 2w


--question 2 List all buildings and the distinct employee roles in each building (including empty buildings) 
select distinct(Building_name), Role from Buildings 
left join
Employees on Buildings.Building_name = Employees.Building;

-- o/p
-- Building_name	Role
-- 1e	Engineer
-- 1e	Manager
-- 1w	
-- 2e	
-- 2w	Artist
-- 2w	Manager
