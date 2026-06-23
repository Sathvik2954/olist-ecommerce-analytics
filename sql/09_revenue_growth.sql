-- ============================================================
-- QUERY 9: What is the revenue growth percentage each month?
-- Finding: MoM revenue growth fluctuated significantly. The highest MoM growth occurred in Jan 2017 (growing by 649657.2% MoM) and Nov 2017 (growing by 53.6% MoM).
-- ============================================================

USE olist_db;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS month,
        ROUND(SUM(oi.price + oi.freight_value), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
        AND o.order_purchase_timestamp IS NOT NULL
    GROUP BY DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
    1) AS growth_pct
FROM monthly_revenue
ORDER BY month;
