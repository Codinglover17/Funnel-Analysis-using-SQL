-- ============================================
-- Project: A/B Testing Analysis using SQL
-- Tool: SQL Server (SSMS)
-- Description: Simulating A/B testing by splitting users into Control and Test groups
-- ============================================

-- Step 1: Create Experiment Groups (Control vs Test)
-- Logic: Even customer_id → Control | Odd → Test

SELECT 
    customerid,
    CASE 
        WHEN customerid % 2 = 0 THEN 'Control'
        ELSE 'Test'
    END AS experiment_group
FROM sales.customers;


-- Step 2: Revenue Comparison Between Groups

WITH customer_groups AS (
    SELECT 
        customerid,
        CASE 
            WHEN customerid % 2 = 0 THEN 'Control'
            ELSE 'Test'
        END AS experiment_group
    FROM sales.customers
)

SELECT 
    cg.experiment_group,
    SUM(o.sales) AS total_revenue
FROM customer_groups cg
JOIN sales.orders o
    ON cg.customerid = o.customerid
GROUP BY cg.experiment_group;


-- Step 3: Conversion Rate per Group

WITH customer_groups AS (
    SELECT 
        customerid,
        CASE 
            WHEN customerid % 2 = 0 THEN 'Control'
            ELSE 'Test'
        END AS experiment_group
    FROM sales.customers
),
group_stats AS (
    SELECT 
        cg.experiment_group,
        COUNT(DISTINCT cg.customerid) AS total_users,
        COUNT(DISTINCT o.customerid) AS purchasing_users
    FROM customer_groups cg
    LEFT JOIN sales.orders o
        ON cg.customerid = o.customerid
    GROUP BY cg.experiment_group
)

SELECT 
    experiment_group,
    total_users,
    purchasing_users,
    (purchasing_users * 100.0 / total_users) AS conversion_rate
FROM group_stats;


-- Step 4: Average Revenue per User (ARPU)

WITH customer_groups AS (
    SELECT 
        customerid,
        CASE 
            WHEN customerid % 2 = 0 THEN 'Control'
            ELSE 'Test'
        END AS experiment_group
    FROM sales.customers
)

SELECT 
    cg.experiment_group,
    AVG(o.sales) AS avg_revenue_per_user
FROM customer_groups cg
JOIN sales.orders o
    ON cg.customerid = o.customerid
GROUP BY cg.experiment_group;
