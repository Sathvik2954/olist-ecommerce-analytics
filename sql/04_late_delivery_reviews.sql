-- ============================================================
-- QUERY 4: Do late deliveries cause worse reviews?
-- Finding: Yes, late deliveries cause significantly worse reviews. Early deliveries score 4.29 on average, whereas deliveries that are 'Late 4+ Days' average a very low review score of 1.86.
-- ============================================================

USE olist_db;

SELECT
    CASE
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) < 0  THEN 'Early'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) = 0  THEN 'On Time'
        WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) <= 3 THEN 'Late 1-3 Days'
        ELSE 'Late 4+ Days'
    END AS delivery_status,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
    AND o.order_delivered_customer_date IS NOT NULL
    AND o.order_estimated_delivery_date IS NOT NULL
GROUP BY delivery_status
ORDER BY avg_review_score DESC;
