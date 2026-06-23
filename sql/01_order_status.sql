-- ============================================================
-- QUERY 1: What percentage of orders are delivered, cancelled, or still in progress?
-- Finding: Delivered represents 97.02% of all orders (96,478 orders). Canceled orders account for 0.63% (625 orders).
-- ============================================================

USE olist_db;

SELECT
    order_status,
    COUNT(*) AS total_orders,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders), 2) AS pct_of_total
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;
