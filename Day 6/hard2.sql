-- Problem

-- A school wants an exam-attendance report containing every student and every offered subject, including combinations with no attendance. For each student-subject pair, 
-- return the number of matching rows in epc_examinations.

-- Output columns: student_id, student_name, subject_name, attended_exams

-- Examples

-- Example 1

-- Input:

-- epc_students:

-- student_id	student_name
-- 1	Alice
-- epc_subjects:

-- subject_name
-- Math
-- Physics
-- Programming
-- epc_examinations:

-- student_id	subject_name
-- 1	Math
-- 1	Physics
-- 1	Programming
-- 1	Physics
-- 1	Math
-- 1	Math
-- Output:

-- student_id	student_name	subject_name	attended_exams
-- 1	Alice	Math	3
-- 1	Alice	Physics	2
-- 1	Alice	Programming	1
-- Explanation: Alice appears three times for Math, twice for Physics, and once for Programming.


with CTE as(
select * from epc_students s cross join epc_subjects sub order by s.student_id )

select c.student_id,c.student_name,c.subject_name,count(e.subject_name) as attended_exams from CTE c
left join epc_examinations e on c.student_id=e.student_id and c.subject_name=e.subject_name
group by c.student_id,c.student_name,c.subject_name 
order by c.student_id;