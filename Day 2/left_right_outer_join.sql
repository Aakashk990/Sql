-- question 1 Find the list of all buildings that have employees 
select distinct(b.Building_name) from Buildings b left join Employees e on b.Building_name = e.Building where e.Building is not null;

--o/p
-- Building_name
-- 1e
-- 2w

