-- note: This file contains SQL queries for Day 10 practice exercises.

Important: Syntax mapping (read this first)

PostgreSQL does not have DATEADD(), DATEDIFF(), or CONVERT_TZ() as functions — those are SQL Server / MySQL syntax. If you search for them 
in Postgres docs you'll find nothing, and that's expected, not a mistake on your end. Here's what Postgres uses instead:



SQL Server / MySQL	PostgreSQL equivalent
DATEADD(day, 7, order_date)	order_date + INTERVAL '7 days'
DATEDIFF(day, date1, date2)	date2 - date1 (for DATE columns), or AGE(date2, date1) / EXTRACT(EPOCH FROM (ts2 - ts1)) for timestamps
CONVERT_TZ(col, 'UTC', 'IST')	col AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Kolkata' (for naive timestamps) or col AT TIME ZONE 'Asia/Kolkata' (for timestamptz)