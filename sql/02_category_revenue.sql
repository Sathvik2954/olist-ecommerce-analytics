-- ============================================================
-- QUERY 2: Which product categories drive the most revenue?
-- Finding: Top category is 'health_beauty' with 1,233,131.72 BRL in revenue (8,647 orders), followed by 'watches_gifts' with 1,166,176.98 BRL. Average price for top category is 130.28 BRL.
-- ============================================================

USE olist_db;

SELECT
    COALESCE(ct.product_category_name_english, p.product_category_name, 'Unknown') AS category,
    ROUND(SUM(oi.price), 2) AS revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders,
    ROUND(AVG(oi.price), 2) AS avg_price
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name, 'Unknown')
ORDER BY revenue DESC
LIMIT 15;
