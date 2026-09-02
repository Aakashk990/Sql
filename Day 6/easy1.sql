
-- You are given a table of messages exchanged on a messaging platform. Your task is to identify the top 2 
-- users who sent the highest number of messages in August 2022. Objective Write a SQL query to: Count the total number of messages sent by each user in August 2022.

-- ttu_messages:

-- message_id	sender_id	receiver_id	content	sent_date
-- 901	3601	4500	You up?	2022-08-03 00:00:00
-- 902	4500	3601	Only if you are buying	2022-08-03 00:00:00
-- 743	3601	8752	Went offline	2022-06-14 00:00:00
-- 922	3601	4500	Get on the call	2022-08-10 00:00:00
-- Output:

-- sender_id	message_count
-- 3601	2
-- 4500	1

select sender_id,count(message_id) as message_count from ttu_messages where DATE_PART('year', sent_date) = 2022 AND DATE_PART('month', sent_date) = 8
group by sender_id
order by message_count desc
limit 2;