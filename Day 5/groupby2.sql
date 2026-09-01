-- Find the number of Artists in the studio (without a HAVING clause)
select count(role) from employees where role = 'Artist';

--Find the number of Employees of each role in the studio 
select Role,count(Name) from employees group by Role;

--Find the total number of years employed by all Engineers 
select sum(Years_employed)from employees where role = 'Engineer';