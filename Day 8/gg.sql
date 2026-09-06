-- select ul.user_id,us.email, us.subscription_tier from public.user_login ul left join users us on ul.user_id=us.user_id 
-- and us.subscription_tier ='free' and us.user_id is not null 
-- group by ul.user_id,us.email, us.subscription_tier;

