-- ============================================================
-- QUERY 6: How is total revenue growing month by month?
-- Finding: Monthly revenue peaked in November 2017 at 1,153,364.2 BRL across 7,289 orders. This was likely driven by Black Friday.
-- ============================================================

USE olist_db;

WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    month,
    revenue,
    total_orders,
    ROUND(revenue / total_orders, 2) AS avg_order_value
FROM monthly
ORDER BY month;
