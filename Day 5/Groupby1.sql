--Find the longest time that an employee has been at the studio 
select max(Years_employed) from Employees;


--For each role, find the average number of years employed by employees in that role
select Role,avg(Years_employed) from Employees group by role;