CREATE TABLE customer_logins (
    login_id INT PRIMARY KEY,
    customer_id INT,
    login_time TIMESTAMPTZ,
    logout_time TIMESTAMPTZ,
    client_timezone VARCHAR(50)
);
