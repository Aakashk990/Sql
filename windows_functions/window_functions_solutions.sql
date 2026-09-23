/* =====================================================================
   WINDOW FUNCTIONS PRACTICE SET - SOLUTIONS  (PostgreSQL)
   Try the question first! Tables come from window_functions_practice.sql.
   Tip: when a sale ordering needs to be exact, we order by
   (sale_date, sale_id) so ties on the same date always give the same result.
   ===================================================================== */


/* =====================================================================
   TOPIC 1 : RANKING
   ===================================================================== */

-- T1-E1
SELECT emp_name, department, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num
FROM employees;

-- T1-E2  (ties get the same rank, and the next rank is skipped: 1,2,3,3,5)
SELECT emp_name, salary,
       RANK() OVER (ORDER BY salary DESC) AS salary_rank
FROM employees;

-- T1-E3  (ties get the same rank, NO numbers skipped: 1,2,3,3,4)
SELECT emp_name, salary,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_dense_rank
FROM employees;

-- T1-E4
SELECT emp_name, hire_date,
       ROW_NUMBER() OVER (ORDER BY hire_date) AS seniority_no
FROM employees;

-- T1-E5
SELECT emp_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) AS row_num,
       RANK()       OVER (ORDER BY salary DESC) AS rnk,
       DENSE_RANK() OVER (ORDER BY salary DESC) AS dense_rnk
FROM employees;

-- T1-M1
SELECT emp_name, department, salary,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dept_rank
FROM employees
ORDER BY department, dept_rank;

-- T1-M2  (window functions can't go in WHERE, so use a CTE)
WITH ranked AS (
    SELECT emp_name, department, salary,
           ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT department, emp_name, salary
FROM ranked
WHERE rn = 1;

-- T1-M3  (DENSE_RANK so that ties both come back and "2nd" means 2nd distinct salary)
WITH ranked AS (
    SELECT emp_name, department, salary,
           DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT department, emp_name, salary
FROM ranked
WHERE dr = 2;

-- T1-M4
WITH ranked AS (
    SELECT emp_name, city, hire_date,
           ROW_NUMBER() OVER (PARTITION BY city ORDER BY hire_date DESC) AS rn
    FROM employees
)
SELECT city, emp_name, hire_date
FROM ranked
WHERE rn = 1;

-- T1-M5
WITH ranked AS (
    SELECT e.emp_name, s.sale_date, s.amount,
           ROW_NUMBER() OVER (PARTITION BY s.emp_id ORDER BY s.amount DESC, s.sale_id) AS rn
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
)
SELECT emp_name, sale_date, amount
FROM ranked
WHERE rn <= 2
ORDER BY emp_name, amount DESC;

-- T1-H1  (classic "remove duplicates" pattern with ROW_NUMBER)
WITH ranked AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY department, salary ORDER BY hire_date) AS rn
    FROM employees
)
SELECT emp_id, emp_name, department, salary, hire_date
FROM ranked
WHERE rn = 1
ORDER BY department, salary DESC;

-- T1-H2
WITH totals AS (
    SELECT s.region, e.emp_name, SUM(s.amount) AS total_sales
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    GROUP BY s.region, e.emp_name
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY region ORDER BY total_sales DESC) AS rnk
    FROM totals
)
SELECT region, emp_name, total_sales
FROM ranked
WHERE rnk = 1;

-- T1-H3
WITH ranked AS (
    SELECT emp_name, salary,
           DENSE_RANK() OVER (ORDER BY salary DESC) AS dr
    FROM employees
)
SELECT emp_name, salary
FROM ranked
WHERE dr = 3;

-- T1-H4  (RANK keeps ties: April has two winners)
WITH monthly AS (
    SELECT DATE_TRUNC('month', s.sale_date)::date AS sale_month,
           e.emp_name,
           SUM(s.amount) AS total_sales
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    GROUP BY 1, 2
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY sale_month ORDER BY total_sales DESC) AS rnk
    FROM monthly
)
SELECT sale_month, emp_name, total_sales
FROM ranked
WHERE rnk = 1
ORDER BY sale_month;

-- T1-H5
WITH ranked AS (
    SELECT emp_name, department, salary, hire_date,
           RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
           RANK() OVER (PARTITION BY department ORDER BY hire_date)   AS seniority_rank
    FROM employees
)
SELECT *
FROM ranked
WHERE salary_rank = seniority_rank
ORDER BY department, salary_rank;


/* =====================================================================
   TOPIC 2 : AGGREGATE WINDOW FUNCTIONS
   ===================================================================== */

-- T2-E1  (empty OVER () = the whole table is one window)
SELECT emp_name, salary,
       SUM(salary) OVER () AS company_total_salary
FROM employees;

-- T2-E2
SELECT emp_name, department, salary,
       ROUND(AVG(salary) OVER (PARTITION BY department), 2) AS dept_avg_salary
FROM employees;

-- T2-E3
SELECT emp_name, department,
       COUNT(*) OVER (PARTITION BY department) AS dept_headcount
FROM employees;

-- T2-E4
SELECT emp_name, department, salary,
       MAX(salary) OVER (PARTITION BY department) AS dept_max_salary,
       MIN(salary) OVER (PARTITION BY department) AS dept_min_salary
FROM employees;

-- T2-E5
SELECT sale_id, emp_id, sale_date, amount,
       SUM(amount) OVER (PARTITION BY emp_id) AS emp_total_sales
FROM sales;

-- T2-M1
SELECT emp_name, department, salary,
       ROUND(salary - AVG(salary) OVER (PARTITION BY department), 2) AS diff_from_dept_avg
FROM employees;

-- T2-M2  (100.0 forces decimal division; 100 * int / int would drop decimals)
SELECT emp_name, department, salary,
       ROUND(100.0 * salary / SUM(salary) OVER (PARTITION BY department), 2) AS pct_of_dept_salary
FROM employees;

-- T2-M3
WITH d AS (
    SELECT emp_name, department, salary,
           AVG(salary) OVER (PARTITION BY department) AS dept_avg
    FROM employees
)
SELECT emp_name, department, salary, ROUND(dept_avg, 2) AS dept_avg
FROM d
WHERE salary > dept_avg;

-- T2-M4
SELECT sale_id, region, amount,
       ROUND(100.0 * amount / SUM(amount) OVER (PARTITION BY region), 2) AS pct_of_region
FROM sales;

-- T2-M5
WITH a AS (
    SELECT sale_id, emp_id, amount,
           AVG(amount) OVER (PARTITION BY emp_id) AS emp_avg
    FROM sales
)
SELECT sale_id, emp_id, amount, ROUND(emp_avg, 2) AS emp_avg,
       CASE WHEN amount > emp_avg THEN 'Above'
            WHEN amount < emp_avg THEN 'Below'
            ELSE 'Equal' END AS vs_avg
FROM a;

-- T2-H1
WITH d AS (
    SELECT emp_name, department, salary,
           MAX(salary) OVER (PARTITION BY department)
         - MIN(salary) OVER (PARTITION BY department) AS salary_gap
    FROM employees
)
SELECT emp_name, department, salary, salary_gap
FROM d
WHERE salary_gap > 40000;

-- T2-H2  (several windows with different PARTITION BYs in one SELECT)
SELECT sale_id, emp_id, region, amount,
       SUM(amount) OVER (PARTITION BY emp_id) AS emp_total,
       SUM(amount) OVER (PARTITION BY region) AS region_total,
       SUM(amount) OVER ()                    AS grand_total,
       ROUND(100.0 * SUM(amount) OVER (PARTITION BY emp_id)
                   / SUM(amount) OVER (PARTITION BY region), 2) AS emp_share_of_region_pct
FROM sales
ORDER BY region, emp_id, sale_id;

-- T2-H3
WITH m AS (
    SELECT emp_name, city, department, salary,
           MAX(salary) OVER (PARTITION BY city)       AS city_max,
           MAX(salary) OVER (PARTITION BY department) AS dept_max
    FROM employees
)
SELECT emp_name, city, department, salary
FROM m
WHERE salary = city_max
  AND salary < dept_max;

-- T2-H4
WITH totals AS (
    SELECT s.product_category, e.emp_name, SUM(s.amount) AS cat_total
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    GROUP BY s.product_category, e.emp_name
),
with_avg AS (
    SELECT *, AVG(cat_total) OVER (PARTITION BY product_category) AS cat_avg
    FROM totals
)
SELECT product_category, emp_name, cat_total, ROUND(cat_avg, 2) AS cat_avg
FROM with_avg
WHERE cat_total > cat_avg
ORDER BY product_category, cat_total DESC;
-- Shortcut you can also use: AVG(SUM(s.amount)) OVER (PARTITION BY s.product_category) in the first query.

-- T2-H5  (every row of a department has the same window values, so DISTINCT collapses them)
SELECT DISTINCT department,
       COUNT(*)    OVER (PARTITION BY department)            AS headcount,
       ROUND(AVG(salary) OVER (PARTITION BY department), 2)  AS avg_salary,
       SUM(salary) OVER (PARTITION BY department)            AS total_salary
FROM employees
ORDER BY department;


/* =====================================================================
   TOPIC 3 : RUNNING TOTALS & WINDOW FRAMES
   ===================================================================== */

-- T3-E1  (ORDER BY inside OVER turns SUM into a running total)
SELECT sale_id, sale_date, amount,
       SUM(amount) OVER (ORDER BY sale_date, sale_id) AS running_total
FROM sales;

-- T3-E2
SELECT emp_id, sale_id, sale_date, amount,
       SUM(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS emp_running_total
FROM sales
ORDER BY emp_id, sale_date;

-- T3-E3
SELECT emp_id, sale_id, sale_date, amount,
       COUNT(*) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS sale_number
FROM sales
ORDER BY emp_id, sale_date;

-- T3-E4
SELECT emp_name, hire_date, salary,
       SUM(salary) OVER (ORDER BY hire_date) AS cumulative_salary_bill
FROM employees;

-- T3-E5
SELECT emp_id, sale_date, amount,
       MAX(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS best_so_far
FROM sales
ORDER BY emp_id, sale_date;

-- T3-M1
SELECT emp_id, sale_date, amount,
       ROUND(AVG(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id
                               ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS moving_avg_3
FROM sales
ORDER BY emp_id, sale_date;

-- T3-M2
WITH monthly AS (
    SELECT DATE_TRUNC('month', sale_date)::date AS sale_month,
           SUM(amount) AS monthly_total
    FROM sales
    GROUP BY 1
)
SELECT sale_month, monthly_total,
       SUM(monthly_total) OVER (ORDER BY sale_month) AS running_total
FROM monthly
ORDER BY sale_month;

-- T3-M3
SELECT emp_id, sale_date, amount,
       SUM(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id
                         ROWS BETWEEN CURRENT ROW AND 1 FOLLOWING) AS this_plus_next
FROM sales
ORDER BY emp_id, sale_date;

-- T3-M4
SELECT emp_name, salary,
       SUM(salary) OVER (ORDER BY salary
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS rows_running_total,
       SUM(salary) OVER (ORDER BY salary) AS range_running_total
FROM employees
ORDER BY salary;
/* Why different?
   With ORDER BY and no frame, the default frame is
   RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW. RANGE treats all rows
   with the SAME salary as "peers" and includes all of them at once, so tied
   rows show the same total. ROWS moves one physical row at a time.
   Lesson: when you want a true row-by-row running total, write ROWS explicitly
   or add a unique tie-breaker to ORDER BY. */

-- T3-M5
SELECT emp_id, sale_date, amount,
       COALESCE(SUM(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING), 0) AS previous_sales_total
FROM sales
ORDER BY emp_id, sale_date;

-- T3-H1
WITH r AS (
    SELECT sale_id, sale_date, amount,
           SUM(amount) OVER (ORDER BY sale_date, sale_id) AS running_total
    FROM sales
),
crossed AS (
    SELECT *, ROW_NUMBER() OVER (ORDER BY sale_date, sale_id) AS rn
    FROM r
    WHERE running_total >= 200000
)
SELECT sale_id, sale_date, amount, running_total
FROM crossed
WHERE rn = 1;

-- T3-H2  (partition by employee AND month -> total restarts each month)
SELECT emp_id, sale_date, amount,
       SUM(amount) OVER (PARTITION BY emp_id, DATE_TRUNC('month', sale_date)
                         ORDER BY sale_date, sale_id) AS month_to_date_total
FROM sales
ORDER BY emp_id, sale_date;

-- T3-H3  (RANGE with an INTERVAL looks at date VALUES, not row counts)
SELECT region, sale_id, sale_date, amount,
       SUM(amount) OVER (PARTITION BY region ORDER BY sale_date
                         RANGE BETWEEN INTERVAL '30 days' PRECEDING AND CURRENT ROW) AS rolling_30d_total
FROM sales
ORDER BY region, sale_date;

-- T3-H4
SELECT emp_id, sale_date, amount,
       ROUND(100.0 * SUM(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id)
                   / SUM(amount) OVER (PARTITION BY emp_id), 2) AS pct_of_emp_total
FROM sales
ORDER BY emp_id, sale_date;

-- T3-H5
WITH totals AS (
    SELECT e.emp_name, SUM(s.amount) AS total_sales
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    GROUP BY e.emp_name
),
cum AS (
    SELECT emp_name, total_sales,
           SUM(total_sales) OVER (ORDER BY total_sales DESC
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total,
           SUM(total_sales) OVER () AS grand_total
    FROM totals
)
SELECT emp_name, total_sales,
       ROUND(100.0 * running_total / grand_total, 2) AS cumulative_pct
FROM cum
WHERE running_total - total_sales < 0.8 * grand_total   -- still below 80% BEFORE adding this rep
ORDER BY total_sales DESC;


/* =====================================================================
   TOPIC 4 : LAG & LEAD
   ===================================================================== */

-- T4-E1
SELECT sale_id, sale_date, amount,
       LAG(amount) OVER (ORDER BY sale_date, sale_id) AS prev_amount
FROM sales;

-- T4-E2
SELECT emp_id, sale_date, amount,
       LAG(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS prev_amount
FROM sales
ORDER BY emp_id, sale_date;

-- T4-E3
SELECT emp_id, sale_date, amount,
       LEAD(sale_date) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS next_sale_date
FROM sales
ORDER BY emp_id, sale_date;

-- T4-E4  (LAG(column, how_many_rows_back, default_value))
SELECT emp_id, sale_date, amount,
       LAG(amount, 1, 0) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS prev_amount
FROM sales
ORDER BY emp_id, sale_date;

-- T4-E5
SELECT emp_name, hire_date,
       LAG(emp_name) OVER (ORDER BY hire_date) AS hired_just_before
FROM employees;

-- T4-M1
SELECT emp_id, sale_date, amount,
       amount - LAG(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS change_vs_prev
FROM sales
ORDER BY emp_id, sale_date;

-- T4-M2  (in PostgreSQL, date - date = number of days)
SELECT emp_id, sale_date,
       sale_date - LAG(sale_date) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS days_since_prev
FROM sales
ORDER BY emp_id, sale_date;

-- T4-M3
WITH monthly AS (
    SELECT DATE_TRUNC('month', sale_date)::date AS sale_month,
           SUM(amount) AS monthly_total
    FROM sales
    GROUP BY 1
),
with_prev AS (
    SELECT sale_month, monthly_total,
           LAG(monthly_total) OVER (ORDER BY sale_month) AS prev_month_total
    FROM monthly
)
SELECT sale_month, monthly_total, prev_month_total,
       monthly_total - prev_month_total AS mom_change,
       ROUND(100.0 * (monthly_total - prev_month_total) / prev_month_total, 2) AS mom_growth_pct
FROM with_prev
ORDER BY sale_month;

-- T4-M4
WITH p AS (
    SELECT emp_id, sale_date, amount,
           LAG(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS prev_amount
    FROM sales
)
SELECT emp_id, sale_date, amount, prev_amount,
       CASE WHEN prev_amount IS NULL   THEN 'First'
            WHEN amount > prev_amount  THEN 'Up'
            WHEN amount < prev_amount  THEN 'Down'
            ELSE 'Same' END AS trend
FROM p
ORDER BY emp_id, sale_date;

-- T4-M5  (a colleague with the same salary shows a gap of 0; the top earner shows NULL)
SELECT emp_name, department, salary,
       LEAD(salary) OVER (PARTITION BY department ORDER BY salary, emp_id) AS next_higher_salary,
       LEAD(salary) OVER (PARTITION BY department ORDER BY salary, emp_id) - salary AS gap_to_next
FROM employees
ORDER BY department, salary;

-- T4-H1
WITH n AS (
    SELECT emp_id, sale_date, amount,
           LAG(amount)  OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS prev_amount,
           LEAD(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS next_amount
    FROM sales
)
SELECT emp_id, sale_date, amount, prev_amount, next_amount
FROM n
WHERE amount > prev_amount
  AND amount > next_amount;

-- T4-H2
WITH months AS (
    SELECT DISTINCT emp_id, DATE_TRUNC('month', sale_date)::date AS sale_month
    FROM sales
),
g AS (
    SELECT emp_id, sale_month,
           LAG(sale_month) OVER (PARTITION BY emp_id ORDER BY sale_month) AS prev_month
    FROM months
)
SELECT e.emp_name,
       g.prev_month  AS last_active_month,
       g.sale_month  AS next_active_month,
       (EXTRACT(YEAR FROM AGE(g.sale_month, g.prev_month)) * 12
        + EXTRACT(MONTH FROM AGE(g.sale_month, g.prev_month)))::int - 1 AS months_missed
FROM g
JOIN employees e ON e.emp_id = g.emp_id
WHERE g.sale_month > g.prev_month + INTERVAL '1 month';

-- T4-H3  (LAG(x, 2) looks two rows back)
WITH monthly AS (
    SELECT emp_id, DATE_TRUNC('month', sale_date)::date AS sale_month, SUM(amount) AS total
    FROM sales
    GROUP BY 1, 2
),
l AS (
    SELECT emp_id, sale_month, total,
           LAG(total, 1) OVER (PARTITION BY emp_id ORDER BY sale_month) AS prev1,
           LAG(total, 2) OVER (PARTITION BY emp_id ORDER BY sale_month) AS prev2
    FROM monthly
)
SELECT e.emp_name, l.sale_month, l.prev2, l.prev1, l.total
FROM l
JOIN employees e ON e.emp_id = l.emp_id
WHERE l.total > l.prev1
  AND l.prev1 > l.prev2;

-- T4-H4  (gaps & islands)
WITH months AS (
    SELECT DISTINCT emp_id, DATE_TRUNC('month', sale_date)::date AS sale_month
    FROM sales
),
flagged AS (
    SELECT emp_id, sale_month,
           CASE WHEN LAG(sale_month) OVER (PARTITION BY emp_id ORDER BY sale_month)
                     = sale_month - INTERVAL '1 month'
                THEN 0 ELSE 1 END AS new_streak        -- 1 = a new streak starts here
    FROM months
),
grouped AS (
    SELECT *,
           SUM(new_streak) OVER (PARTITION BY emp_id ORDER BY sale_month) AS streak_id
    FROM flagged
)
SELECT e.emp_name,
       MIN(g.sale_month) AS streak_start,
       MAX(g.sale_month) AS streak_end,
       COUNT(*)          AS streak_months
FROM grouped g
JOIN employees e ON e.emp_id = g.emp_id
GROUP BY e.emp_name, g.emp_id, g.streak_id
ORDER BY e.emp_name, streak_start;

-- T4-H5  (RANK, not ROW_NUMBER: if two sales tie for the biggest jump in a region, both are shown)
WITH j AS (
    SELECT sale_id, region, sale_date, amount,
           amount - LAG(amount) OVER (PARTITION BY region ORDER BY sale_date, sale_id) AS jump
    FROM sales
),
ranked AS (
    SELECT *, RANK() OVER (PARTITION BY region ORDER BY jump DESC NULLS LAST) AS rnk
    FROM j
)
SELECT region, sale_id, sale_date, amount, jump
FROM ranked
WHERE rnk = 1
ORDER BY region;


/* =====================================================================
   TOPIC 5 : VALUE & DISTRIBUTION FUNCTIONS
   ===================================================================== */

-- T5-E1
SELECT emp_name, department, salary,
       FIRST_VALUE(emp_name) OVER (PARTITION BY department ORDER BY salary DESC) AS dept_top_earner
FROM employees;

-- T5-E2
SELECT emp_id, sale_date, amount,
       FIRST_VALUE(amount) OVER (PARTITION BY emp_id ORDER BY sale_date, sale_id) AS first_sale_amount
FROM sales
ORDER BY emp_id, sale_date;

-- T5-E3
SELECT emp_name, salary,
       NTILE(4) OVER (ORDER BY salary DESC) AS salary_group
FROM employees;

-- T5-E4  (PERCENT_RANK = (rank - 1) / (rows - 1); it returns double precision, so cast to numeric to ROUND)
SELECT emp_name, salary,
       ROUND(PERCENT_RANK() OVER (ORDER BY salary)::numeric, 2) AS pct_rank
FROM employees;

-- T5-E5  (CUME_DIST = rows with value <= mine / total rows; never 0, highest is 1)
SELECT emp_name, salary,
       ROUND(CUME_DIST() OVER (ORDER BY salary)::numeric, 2) AS cume_dist
FROM employees;

-- T5-M1
-- Wrong: default frame ends at the CURRENT ROW, so LAST_VALUE just returns the current row (or its tie peers).
SELECT emp_name, department, salary,
       LAST_VALUE(emp_name) OVER (PARTITION BY department ORDER BY salary DESC) AS wrong_lowest
FROM employees;
-- Right: extend the frame to the whole partition.
SELECT emp_name, department, salary,
       LAST_VALUE(emp_name) OVER (PARTITION BY department ORDER BY salary DESC, emp_id
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS dept_lowest_earner
FROM employees;

-- T5-M2  (NTH_VALUE picks the 2nd ROW - with ties it can equal the 1st value. Needs the full frame too.)
SELECT emp_name, department, salary,
       NTH_VALUE(salary, 2) OVER (PARTITION BY department ORDER BY salary DESC
                                  ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS second_highest_salary
FROM employees;

-- T5-M3
SELECT emp_id, sale_date, amount,
       FIRST_VALUE(amount) OVER (PARTITION BY emp_id ORDER BY amount DESC) - amount AS below_best_by
FROM sales
ORDER BY emp_id, sale_date;

-- T5-M4
SELECT region, sale_id, amount,
       CASE NTILE(3) OVER (PARTITION BY region ORDER BY amount DESC)
            WHEN 1 THEN 'High'
            WHEN 2 THEN 'Mid'
            ELSE 'Low' END AS bucket
FROM sales
ORDER BY region, amount DESC;

-- T5-M5
WITH p AS (
    SELECT emp_name, salary,
           PERCENT_RANK() OVER (ORDER BY salary DESC) AS pr
    FROM employees
)
SELECT emp_name, salary
FROM p
WHERE pr <= 0.25;

-- T5-H1
SELECT emp_name, department, salary,
       MIN(salary)           OVER w AS dept_min,
       MAX(salary)           OVER w AS dept_max,
       ROUND(AVG(salary) OVER w, 2) AS dept_avg,
       FIRST_VALUE(emp_name) OVER w AS dept_top_earner
FROM employees
WINDOW w AS (PARTITION BY department ORDER BY salary DESC
             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING);

-- T5-H2
WITH fl AS (
    SELECT DISTINCT e.emp_name,
           FIRST_VALUE(s.sale_date) OVER w AS first_sale_date,
           LAST_VALUE(s.sale_date)  OVER w AS last_sale_date,
           FIRST_VALUE(s.amount)    OVER w AS first_amount,
           LAST_VALUE(s.amount)     OVER w AS last_amount
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    WINDOW w AS (PARTITION BY s.emp_id ORDER BY s.sale_date, s.sale_id
                 ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
SELECT *,
       CASE WHEN last_amount > first_amount THEN 'Improved'
            WHEN last_amount < first_amount THEN 'Declined'
            ELSE 'Same' END AS trend
FROM fl
ORDER BY emp_name;

-- T5-H3
WITH c AS (
    SELECT emp_name, salary,
           CUME_DIST() OVER (ORDER BY salary) AS cd
    FROM employees
)
SELECT emp_name, salary, ROUND(cd::numeric, 2) AS cume_dist
FROM c
WHERE cd > 0.25 AND cd <= 0.75
ORDER BY salary;

-- T5-H4  (April has a tie at the top: emp_name is added as a tie-breaker so the result is always the same)
WITH monthly AS (
    SELECT DATE_TRUNC('month', s.sale_date)::date AS sale_month,
           e.emp_name,
           SUM(s.amount) AS total_sales
    FROM sales s
    JOIN employees e ON e.emp_id = s.emp_id
    GROUP BY 1, 2
)
SELECT DISTINCT sale_month,
       FIRST_VALUE(emp_name)    OVER w AS top_seller,
       FIRST_VALUE(total_sales) OVER w AS top_amount,
       LAST_VALUE(emp_name)     OVER w AS lowest_seller,
       LAST_VALUE(total_sales)  OVER w AS lowest_amount
FROM monthly
WINDOW w AS (PARTITION BY sale_month ORDER BY total_sales DESC, emp_name
             ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
ORDER BY sale_month;

-- T5-H5
WITH b AS (
    SELECT emp_name, department, salary,
           CASE NTILE(3) OVER (PARTITION BY department ORDER BY salary DESC)
                WHEN 1 THEN 'Senior band'
                WHEN 2 THEN 'Mid band'
                ELSE 'Junior band' END AS band
    FROM employees
)
SELECT department, band, COUNT(*) AS headcount
FROM b
GROUP BY department, band
ORDER BY department, band;
-- HR has only 2 rows, so NTILE(3) fills buckets 1 and 2 only - there is no 'Junior band' row for HR.
