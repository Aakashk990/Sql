/* =====================================================================
   WINDOW FUNCTIONS PRACTICE SET  (PostgreSQL)
   75 questions = 5 topics x (5 Easy + 5 Medium + 5 Hard)
   One dataset for everything: run SECTION 0 once, then only practise.
   Solutions are in a separate file: window_functions_solutions.sql
   ---------------------------------------------------------------------
   HOW TO USE
   1. Run SECTION 0 (create tables + insert data) one time.
   2. Run  SELECT * FROM employees;  and  SELECT * FROM sales;
      Look at the data for 2 minutes before you start. It helps a lot.
   3. Go topic by topic, Easy -> Medium -> Hard. Try each question
      yourself before you open the solutions file.
   ===================================================================== */


/* =====================================================================
   SECTION 0 : SETUP  (run once)
   ===================================================================== */

DROP TABLE IF EXISTS sales;
DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
    emp_id      INT PRIMARY KEY,
    emp_name    VARCHAR(50),
    department  VARCHAR(30),
    job_title   VARCHAR(50),
    salary      INT,
    hire_date   DATE,
    city        VARCHAR(30)
);

CREATE TABLE sales (
    sale_id           INT PRIMARY KEY,
    emp_id            INT REFERENCES employees(emp_id),
    sale_date         DATE,
    region            VARCHAR(20),
    product_category  VARCHAR(30),
    amount            INT
);

INSERT INTO employees VALUES
(1,  'Aarav',     'Sales',       'Sales Executive',     55000,  '2019-03-15', 'Delhi'),
(2,  'Priya',     'Sales',       'Sales Executive',     62000,  '2020-07-01', 'Mumbai'),
(3,  'Rohan',     'Sales',       'Sales Manager',       90000,  '2017-01-10', 'Delhi'),
(4,  'Sneha',     'Sales',       'Sales Executive',     62000,  '2021-11-20', 'Bangalore'),
(5,  'Vikram',    'Sales',       'Sales Executive',     48000,  '2023-02-14', 'Mumbai'),
(6,  'Ananya',    'Engineering', 'Data Engineer',       95000,  '2018-05-21', 'Bangalore'),
(7,  'Karan',     'Engineering', 'Data Engineer',       110000, '2016-09-12', 'Bangalore'),
(8,  'Meera',     'Engineering', 'Software Engineer',   95000,  '2020-01-06', 'Delhi'),
(9,  'Arjun',     'Engineering', 'Software Engineer',   78000,  '2022-08-30', 'Pune'),
(10, 'Divya',     'Engineering', 'Engineering Manager', 150000, '2015-04-01', 'Bangalore'),
(11, 'Nikhil',    'HR',          'HR Executive',        45000,  '2021-03-18', 'Delhi'),
(12, 'Pooja',     'HR',          'HR Manager',          72000,  '2018-10-25', 'Delhi'),
(13, 'Rahul',     'Marketing',   'Marketing Executive', 52000,  '2022-06-13', 'Mumbai'),
(14, 'Isha',      'Marketing',   'Marketing Executive', 52000,  '2023-09-04', 'Pune'),
(15, 'Siddharth', 'Marketing',   'Marketing Manager',   85000,  '2019-12-02', 'Mumbai');

INSERT INTO sales VALUES
(1,  1, '2026-01-05', 'North', 'Electronics', 12000),
(2,  1, '2026-01-20', 'North', 'Furniture',    4500),
(3,  1, '2026-02-10', 'North', 'Electronics', 15000),
(4,  1, '2026-03-08', 'North', 'Clothing',     9000),
(5,  1, '2026-04-15', 'North', 'Electronics', 18000),
(6,  1, '2026-05-12', 'North', 'Furniture',   18000),
(7,  1, '2026-06-18', 'North', 'Electronics', 21000),
(8,  2, '2026-01-08', 'West',  'Clothing',    15000),
(9,  2, '2026-01-25', 'West',  'Electronics', 16000),
(10, 2, '2026-02-14', 'West',  'Furniture',   11000),
(11, 2, '2026-02-28', 'West',  'Clothing',     7000),
(12, 2, '2026-04-03', 'West',  'Electronics', 25000),
(13, 2, '2026-05-19', 'West',  'Electronics', 34000),
(14, 2, '2026-06-22', 'West',  'Furniture',   13000),
(15, 3, '2026-01-15', 'North', 'Electronics', 30000),
(16, 3, '2026-02-18', 'North', 'Electronics', 18000),
(17, 3, '2026-03-22', 'North', 'Furniture',   27000),
(18, 3, '2026-04-10', 'North', 'Electronics', 25000),
(19, 3, '2026-05-05', 'North', 'Clothing',    12000),
(20, 3, '2026-05-28', 'North', 'Electronics', 19000),
(21, 3, '2026-06-14', 'North', 'Furniture',   32000),
(22, 4, '2026-02-02', 'South', 'Clothing',     6000),
(23, 4, '2026-02-20', 'South', 'Electronics', 14000),
(24, 4, '2026-03-11', 'South', 'Furniture',   10000),
(25, 4, '2026-03-30', 'South', 'Clothing',     5500),
(26, 4, '2026-06-09', 'South', 'Electronics', 20000),
(27, 5, '2026-03-03', 'West',  'Clothing',     4000),
(28, 5, '2026-04-21', 'West',  'Electronics',  9000),
(29, 5, '2026-05-16', 'West',  'Furniture',    7500),
(30, 5, '2026-06-25', 'West',  'Electronics', 11000);

-- Quick check: should return 15 and 30
SELECT (SELECT COUNT(*) FROM employees) AS employees, (SELECT COUNT(*) FROM sales) AS sales;


/* =====================================================================
   5-MINUTE PRIMER  (read this once before you start)
   ---------------------------------------------------------------------
   A normal aggregate (GROUP BY) squashes many rows into one row.
   A WINDOW function calculates across a group of rows but KEEPS every
   row. The "window" is described inside OVER ( ... ):

       function_name(...) OVER (
           PARTITION BY col      -- split rows into groups (optional)
           ORDER BY col          -- order rows inside each group (optional)
           ROWS BETWEEN ...      -- which rows around the current row (optional)
       )

   Examples:
     SUM(salary) OVER ()                               -- total of ALL rows, on every row
     SUM(salary) OVER (PARTITION BY department)        -- total of my department, on every row
     SUM(amount) OVER (ORDER BY sale_date)             -- running total
     ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC)

   Two rules beginners get stuck on:
   - You CANNOT use a window function in WHERE. Put it in a CTE/subquery
     first, then filter in the outer query.
   - Window functions run AFTER GROUP BY, so you can window over an
     aggregate, e.g.  SUM(SUM(amount)) OVER (...)
   ===================================================================== */


/* =====================================================================
   TOPIC 1 : RANKING  -  ROW_NUMBER, RANK, DENSE_RANK
   ===================================================================== */

-- ---------- EASY ----------
-- T1-E1. Show every employee with a row number, ordered by salary from highest to lowest.

-- T1-E2. Rank employees by salary (highest first) using RANK(). Look at what happens to employees with the same salary.

-- T1-E3. Do the same with DENSE_RANK(). Compare with T1-E2: what is different after a tie?

-- T1-E4. Give each employee a "seniority number": 1 for the person who joined first, 2 for the next, and so on.

-- T1-E5. Show ROW_NUMBER, RANK and DENSE_RANK side by side for salary (highest first) in one query.


-- ---------- MEDIUM ----------
-- T1-M1. Rank employees by salary WITHIN each department (highest = 1). Use DENSE_RANK.

-- T1-M2. Find the single highest-paid employee in each department (one row per department).

-- T1-M3. Find the employee(s) with the SECOND highest salary in each department. If two people share it, show both.

-- T1-M4. Find the most recently hired employee in each city.

-- T1-M5. For each sales employee, show only their top 2 sales by amount (show employee name, sale_date, amount).


-- ---------- HARD ----------
-- T1-H1. De-duplication: some employees in the same department have the same salary. Keep only ONE employee
--        per (department, salary) combination - the one who was hired earliest. Show the remaining rows.

-- T1-H2. For each region, find the sales rep with the highest TOTAL sales amount. (Hint: aggregate first, then rank.)

-- T1-H3. Find the employee(s) with the 3rd highest DISTINCT salary in the company without using LIMIT/OFFSET.

-- T1-H4. For every month, find the employee(s) with the highest total sales in that month. Show month, name, total.
--        If two employees tie, show both.

-- T1-H5. Find employees whose salary rank inside their department (highest salary = 1) is EXACTLY equal to
--        their seniority rank inside their department (earliest hire = 1).


/* =====================================================================
   TOPIC 2 : AGGREGATE WINDOW FUNCTIONS  -  SUM / AVG / COUNT / MIN / MAX  OVER (PARTITION BY ...)
   ===================================================================== */

-- ---------- EASY ----------
-- T2-E1. Show every employee with the total salary of the WHOLE company on each row.

-- T2-E2. Show every employee with the average salary of their department (round to 2 decimals).

-- T2-E3. Show every employee with the number of employees in their department.

-- T2-E4. Show every employee with the highest and lowest salary in their department.

-- T2-E5. Show every sale with the total sales amount of the employee who made it.


-- ---------- MEDIUM ----------
-- T2-M1. Show each employee's salary and how much it is above or below their department average.

-- T2-M2. Show each employee's salary as a percentage of their department's total salary.

-- T2-M3. List only the employees who earn MORE than their department's average salary.

-- T2-M4. For each sale, show what percentage it contributes to its region's total sales.

-- T2-M5. For each sale, show the employee's average sale amount and a column that says 'Above', 'Below'
--        or 'Equal' when comparing this sale to that average.


-- ---------- HARD ----------
-- T2-H1. Find departments where (highest salary - lowest salary) is more than 40,000.
--        List ALL employees of those departments along with that gap.

-- T2-H2. In ONE query, show for every sale: employee total, region total, grand total, and the employee's
--        share (%) of their region total.

-- T2-H3. Find employees who have the highest salary in their CITY but are NOT the highest paid in their DEPARTMENT.

-- T2-H4. For each product_category, calculate each employee's total sales in that category and the average of
--        those employee totals for the category. Return only employees who are above the category average.

-- T2-H5. Without using GROUP BY, return exactly one row per department with: department, headcount,
--        average salary and total salary.


/* =====================================================================
   TOPIC 3 : RUNNING TOTALS & WINDOW FRAMES  -  ORDER BY inside OVER, ROWS / RANGE BETWEEN
   ===================================================================== */

-- ---------- EASY ----------
-- T3-E1. Show a running total of ALL sales ordered by sale_date (use sale_id as a tie-breaker).

-- T3-E2. Show a running total of sales for EACH employee separately, ordered by sale_date.

-- T3-E3. For each sale, show which number sale it is for that employee (1st, 2nd, 3rd ...) using COUNT() as a window.

-- T3-E4. Order employees by hire_date and show the cumulative salary bill as each person joined.

-- T3-E5. For each employee's sales in date order, show the biggest sale amount they had "so far".


-- ---------- MEDIUM ----------
-- T3-M1. For each employee, show a 3-sale moving average (current sale + 2 sales before it).

-- T3-M2. Calculate total sales per month, then show a running total of those monthly totals.

-- T3-M3. For each sale, show the sum of this sale and the employee's NEXT sale.

-- T3-M4. ROWS vs RANGE: order employees by salary and compute a running total of salary twice - once with
--        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW and once with just ORDER BY salary (default frame).
--        Look at the rows with equal salaries. Why are the two columns different?

-- T3-M5. For each sale, show the total of all the employee's PREVIOUS sales (not including the current one).
--        Show 0 for the first sale.


-- ---------- HARD ----------
-- T3-H1. On which sale (date + sale_id) did the company's cumulative sales first reach 200,000 or more?

-- T3-H2. Show a running total per employee that RESETS at the start of every month.

-- T3-H3. For each region, show a rolling 30-day sales total: for each sale, the sum of that region's sales
--        within the 30 days up to and including that sale_date. (Hint: RANGE with INTERVAL.)

-- T3-H4. For each employee's sales in date order, show the running total as a percentage of that
--        employee's full total (the last sale should show 100%).

-- T3-H5. Pareto (80/20): rank sales reps by total sales (highest first) and find the smallest group of top
--        reps who together bring in at least 80% of total company sales.


/* =====================================================================
   TOPIC 4 : LAG & LEAD  (looking at previous / next rows)
   ===================================================================== */

-- ---------- EASY ----------
-- T4-E1. Show every sale with the amount of the previous sale in the company (ordered by sale_date, sale_id).

-- T4-E2. Show every sale with the previous sale amount of the SAME employee.

-- T4-E3. Show every sale with the date of the same employee's NEXT sale.

-- T4-E4. Same as T4-E2, but show 0 instead of NULL when there is no previous sale (use LAG's 3rd argument).

-- T4-E5. Order employees by hire_date and show the name of the person who was hired just before each of them.


-- ---------- MEDIUM ----------
-- T4-M1. For each sale, show how much the amount went up or down compared to the employee's previous sale.

-- T4-M2. For each sale, show the number of days since the employee's previous sale.

-- T4-M3. Calculate company sales per month and show month-over-month change (amount) and growth (%).

-- T4-M4. Label each sale 'Up', 'Down', 'Same' compared with the employee's previous sale, or 'First' if there is none.

-- T4-M5. Within each department, order employees by salary and show how much more the next higher-paid
--        colleague earns.


-- ---------- HARD ----------
-- T4-H1. Find "peak" sales: sales where the amount is higher than BOTH the previous and the next sale of the same employee.

-- T4-H2. Find gaps in activity: for each employee, find places where they skipped at least one month between
--        sales. Show the last active month, the next active month and how many months were missed.

-- T4-H3. Using monthly totals per employee, find employee-months where the total grew for the 2nd time in a row
--        (this month > previous active month > the active month before that).

-- T4-H4. Gaps & islands: for each employee find streaks of CONSECUTIVE months with at least one sale.
--        Show streak start month, end month and length in months.
--        (Hint: use LAG to flag where a new streak starts, then a running SUM of that flag.)

-- T4-H5. For each region, find the sale with the biggest jump in amount compared to the previous sale in
--        that region (ordered by date).


/* =====================================================================
   TOPIC 5 : VALUE & DISTRIBUTION FUNCTIONS
             FIRST_VALUE, LAST_VALUE, NTH_VALUE, NTILE, PERCENT_RANK, CUME_DIST
   ===================================================================== */

-- ---------- EASY ----------
-- T5-E1. Show every employee with the name of the highest-paid person in their department.

-- T5-E2. Show every sale with the amount of that employee's very first sale.

-- T5-E3. Split all employees into 4 salary groups (highest salaries in group 1) using NTILE.

-- T5-E4. Show each employee's PERCENT_RANK by salary (lowest salary = 0). Round to 2 decimals.

-- T5-E5. Show each employee's CUME_DIST by salary. Round to 2 decimals. How is it different from PERCENT_RANK?


-- ---------- MEDIUM ----------
-- T5-M1. The LAST_VALUE trap: show every employee with the name of the LOWEST-paid person in their
--        department using LAST_VALUE (ordered by salary DESC). First write it without a frame and see why
--        the answer is wrong, then fix it.

-- T5-M2. Show every employee with the second highest salary value in their department using NTH_VALUE.

-- T5-M3. For each sale, show how far it is below that employee's best sale ever.

-- T5-M4. Within each region, divide sales into 3 buckets by amount and label them 'High', 'Mid', 'Low'.

-- T5-M5. List employees in the top 25% of salaries company-wide using PERCENT_RANK.


-- ---------- HARD ----------
-- T5-H1. Named windows: using the WINDOW clause (WINDOW w AS (...)), show for each employee the department's
--        min salary, max salary, average salary and the name of the top earner - defining the window only once.

-- T5-H2. One row per sales employee showing: first sale date, last sale date, first sale amount,
--        last sale amount, and 'Improved' / 'Declined' comparing last vs first amount.

-- T5-H3. Find employees whose salary sits in the MIDDLE 50% of the company (between the 25th and 75th
--        percentile) using CUME_DIST.

-- T5-H4. For every month, show on ONE row the top-selling employee and amount, and the lowest-selling
--        employee and amount (only employees who sold that month).

-- T5-H5. Inside each department, use NTILE(3) on salary (highest first) to label employees 'Senior band',
--        'Mid band', 'Junior band'. Then show how many employees fall in each department + band.
--        Look at HR (only 2 people): what does NTILE do when there are fewer rows than buckets?
