-- Problem
-- The growth team wants to win back free users who are drifting away. Assume today's date is 2024-04-10. 
-- Find all users on the free tier who have been inactive for more than 30 days, where days inactive is the number of days between today and the user's most recent login. 
-- Return each such user's id, email, subscription tier, last login date, and days inactive, with the longest-inactive users first.

-- Output columns: user_id, email, subscription_tier, last_login_date, days_inactive

SELECT 
    u.user_id,
    u.email,
    u.subscription_tier,
    MAX(l.login_date) AS last_login_date,
    DATE '2024-04-10' - MAX(l.login_date) AS days_inactive
FROM 
    users u
JOIN 
    user_login l ON u.user_id = l.user_id
WHERE 
    u.subscription_tier = 'free'
GROUP BY 
    u.user_id,
    u.email,
    u.subscription_tier
HAVING 
    DATE '2024-04-10' - MAX(l.login_date) > 30
ORDER BY 
    days_inactive DESC;
