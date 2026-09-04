A CTE turns a 50-line nested subquery monstrosity into a series of named, readable steps. If you have ever inherited a query with four levels of nesting and spent 20 minutes decoding the innermost one, you already understand why CTEs exist.

Diagram titled 'Same logic, two ways to write it': nested subqueries force you to start reading at the innermost level and work outward, holding it all in your head; chained CTEs (daily_orders, customer_summary, customer_segments, final SELECT) read top-down one step at a time.
After reviewing hundreds of SQL pull requests, here is the pattern: the biggest predictor of bugs is not complexity, it is readability. A 100-line query built from well-named CTEs is easier to debug than a 40-line query with two levels of nesting. Every time. CTEs do not make your SQL faster; they make it correct, because you can actually read it, reason about it, and verify each step.

What a CTE is

A CTE (Common Table Expression) is a named, temporary result set that exists for the duration of one query. Define it with WITH, name it, then reference it like a table:

SQL

WITH daily_revenue AS (
    SELECT
        DATE_TRUNC('day', order_date) AS order_day,
        SUM(amount) AS revenue
    FROM orders
    WHERE order_date >= '2024-01-01'
    GROUP BY 1
)
SELECT order_day, revenue
FROM daily_revenue
WHERE revenue > 10000
ORDER BY order_day;
When the query finishes, daily_revenue disappears. Not a table, not a view: just a named step.

Diagram: a query written like an essay, where each CTE is a paragraph making one clear point (daily_orders, customer_summary building on it, customer_segments building on that) and the final SELECT is the conclusion. A CTE doing more than one thing is a paragraph making two points: split it.
Key Insight
Think of CTEs as paragraphs in an essay: each makes one clear point, and the final SELECT is the conclusion. If a CTE needs more than about 20 lines, it is probably making two points. Split it.
Chained CTEs: the real power

Each CTE can reference any CTE defined before it, building logic step by step:

SQL

WITH daily_orders AS (
    -- Step 1: aggregate orders by day and customer
    SELECT
        customer_id,
        DATE_TRUNC('day', order_date) AS order_day,
        COUNT(*) AS order_count,
        SUM(amount) AS daily_spend
    FROM orders
    WHERE order_date >= '2024-01-01'
    GROUP BY 1, 2
),
customer_summary AS (
    -- Step 2: summarize each customer
    SELECT
        customer_id,
        COUNT(DISTINCT order_day) AS active_days,
        SUM(order_count) AS total_orders,
        SUM(daily_spend) AS total_spend
    FROM daily_orders
    GROUP BY 1
),
customer_segments AS (
    -- Step 3: segment by spend
    SELECT
        customer_id,
        total_orders,
        total_spend,
        CASE
            WHEN total_spend >= 10000 THEN 'whale'
            WHEN total_spend >= 1000 THEN 'regular'
            ELSE 'casual'
        END AS segment
    FROM customer_summary
)
SELECT
    segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend
FROM customer_segments
GROUP BY 1
ORDER BY avg_spend DESC;
Notice the names: daily_orders, customer_summary, customer_segments. Not t1, t2, t3. Descriptive names are the entire point.

Naming Convention
Name CTEs like dbt models: noun phrases describing the data, not the operation. daily_revenue, not calculate_revenue. The name should tell the reader what rows are inside.
And here is the debugging superpower: when the output looks wrong, run each CTE on its own (SELECT * FROM customer_summary) until you find the step where the logic breaks.

Diagram: when the output looks wrong, test each step: SELECT star from daily_orders is fine, customer_summary is fine, and the bug is isolated in customer_segments. Named steps turn debugging from archaeology into a checklist.
CTEs vs subqueries vs temp tables vs views

Four homes for intermediate logic: CTE for multi-step logic in one query (lives for one statement), subquery for trivial one-liners in WHERE (nesting past depth one hurts), temp table for a big result used many times (lives until the session ends), and view for logic shared across queries (lives permanently). CTE is the right call about 80% of the time.
Feature	CTE	Subquery	Temp table	View
Readability	Excellent	Poor at depth 2+	Good	Excellent
Reusable within the query	Yes	No	Yes	Yes
Persists after the query	No	No	Until session ends	Permanently
Can be indexed	No	No	Yes	No
Best for	Multi-step logic	One-off filters	Large reused results	Shared logic
CTE for multi-step logic in one statement (80% of cases), subquery for trivial one-liners, temp table when a large intermediate result is referenced many times, view when logic is shared across queries and people. The full decision matrix comes later in the course.

CTE performance: mostly a non-issue

The truth that surprises people: in modern engines, CTEs are free. Snowflake, BigQuery, PostgreSQL 12+, Redshift, and Spark SQL all inline CTEs: the optimizer substitutes the definition into the main query and plans the whole thing at once. The execution plan is identical to the subquery version. (Pre-12 PostgreSQL treated CTEs as optimization fences, which is where the old "CTEs are slow" folklore comes from.)

The one real exception:

Diagram titled 'Reference a CTE 3 times, pay for it 3 times': an expensive aggregation CTE referenced three times is re-run by most engines for each reference. The fix: AS MATERIALIZED or a temp table, computed once. The one case where CTEs cost you.
The Multi-Reference Trap
Reference the same expensive CTE three times and most engines execute it three times. PostgreSQL 12+ lets you force one execution with WITH expensive_calc AS MATERIALIZED (...). Elsewhere, use a temp table.
Recursive CTEs: a preview

CTEs have one superpower mode: recursion, for walking hierarchies like org charts and category trees.

SQL

WITH RECURSIVE org_chart AS (
    -- Base case: the top of the tree
    SELECT employee_id, name, manager_id, 1 AS depth
    FROM employees
    WHERE manager_id IS NULL

    UNION ALL

    -- Recursive case: everyone reporting to the previous level
    SELECT e.employee_id, e.name, e.manager_id, oc.depth + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart ORDER BY depth, name;
You will use these rarely, but when you need one, nothing else works. They get a full lesson in the Advanced module.

Walkthrough

Filtering with a CTE:

SQL

WITH high_salary_employees AS (
    SELECT name, salary
    FROM employees
    WHERE salary >= 50000
)
SELECT * FROM high_salary_employees;
name	salary
Jane Smith	55000
Bob Johnson	65000
Alice Lee	75000
Two CTEs joined in the final SELECT:

SQL

WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(quantity * price) AS total_revenue
    FROM sales
    JOIN items ON sales.item_id = items.id
    GROUP BY month
),
monthly_items_sold AS (
    SELECT
        DATE_TRUNC('month', sale_date) AS month,
        SUM(quantity) AS total_items_sold
    FROM sales
    GROUP BY month
)
SELECT
    monthly_sales.month,
    monthly_items_sold.total_items_sold,
    monthly_sales.total_revenue
FROM monthly_sales
JOIN monthly_items_sold ON monthly_sales.month = monthly_items_sold.month;
month	total_items_sold	total_revenue
2022-01-01	17	3100
2022-02-01	34	8100
2022-03-01	51	14100
Each CTE solves one piece; the final query joins the pieces. Compare that to nesting all of it inside subqueries.

Common mistakes

Naming CTEs like variables. t1, tmp, data force the reader to scroll up and re-read constantly. daily_revenue documents itself.
Over-CTEing. A simple SELECT-WHERE-GROUP BY does not need ceremony. CTEs earn their keep on multi-step logic.
Assuming CTEs are materialized. Usually they are not; a CTE referenced four times may run four times.
Using CTEs to "optimize." They do not change the plan in modern engines. Slow queries need indexes or a different approach, not more WITH clauses.
Forgetting the comma between CTEs. WITH a AS (...), b AS (...), comma between, none before the final SELECT. Trips up everyone once.
One habit to take into interviews: when given a complex problem, say "let me break this into steps" and write 2 or 3 chained CTEs. It shows structured thinking, and if one step has a bug, the interviewer can still follow (and credit) the rest.

Next: set operations. Stacking result sets on top of each other with UNION, INTERSECT, and EXCEPT.
