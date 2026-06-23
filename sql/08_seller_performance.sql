-- ============================================================
-- QUERY 8: Who are the top sellers and what are their average review scores?
-- Finding: The top seller is '4869f7a5dfa277a7dca6462dcf3b52b2' based in SP with total revenue of 226,987.93 BRL across 1,124 orders and an average review score of 4.14.
-- ============================================================

USE olist_db;

WITH seller_stats AS (
    SELECT
        oi.seller_id,
        s.seller_state,
        ROUND(SUM(oi.price), 2) AS total_revenue,
        COUNT(DISTINCT oi.order_id) AS total_orders,
        ROUND(AVG(r.review_score), 2) AS avg_review_score
    FROM order_items oi
    JOIN sellers s ON oi.seller_id = s.seller_id
    JOIN orders o ON oi.order_id = o.order_id
    LEFT JOIN reviews r ON o.order_id = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.seller_id, s.seller_state
    HAVING total_orders > 10
)
SELECT
    seller_id,
    seller_state,
    total_revenue,
    total_orders,
    avg_review_score
FROM seller_stats
ORDER BY total_revenue DESC
LIMIT 20;
