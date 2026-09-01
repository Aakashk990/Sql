-- Find the number of Artists in the studio (without a HAVING clause)
select count(role) from employees where role = 'Artist';