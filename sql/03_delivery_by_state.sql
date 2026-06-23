-- ============================================================
-- QUERY 3: Which states have the slowest deliveries?
-- Finding: Slowest state is AL with an average delivery delay of -8.7 days (avg delivery time: 24.5 days). State AC has the best delivery performance with average delay of -20.7 days (meaning it delivers ahead of estimate).
-- ============================================================

USE olist_db;

SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_purchase_timestamp
    )), 1) AS avg_delivery_days,
    ROUND(AVG(DATEDIFF(
        o.order_estimated_delivery_date,
        o.order_purchase_timestamp
    )), 1) AS avg_estimated_days,
    ROUND(AVG(DATEDIFF(
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date
    )), 1) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING total_orders > 50
ORDER BY avg_delay_days DESC;
