-- ============================================================
-- QUERY 7: What percentage of customers come back for a second order?
-- Finding: The customer repeat purchase rate is very low at 3.0%: out of 93,358.0 unique customers, only 2,801.0 returned for repeat purchases, while 90,557.0 were one-time buyers.
-- ============================================================

USE olist_db;

WITH customer_order_count AS (
    SELECT
        c.customer_unique_id,
        COUNT(o.order_id) AS total_orders
    FROM orders o
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN total_orders = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
    SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) AS repeat_buyers,
    ROUND(
        SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
    2) AS repeat_rate_pct
FROM customer_order_count;
