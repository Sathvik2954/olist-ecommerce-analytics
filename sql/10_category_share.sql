-- ============================================================
-- QUERY 10: What % of total revenue does each category contribute?
-- Finding: The top category 'health_beauty' accounts for 9.33% of total revenue, followed by 'watches_gifts' representing 8.82%.
-- ============================================================

USE olist_db;

WITH category_totals AS (
    SELECT
        COALESCE(ct.product_category_name_english, p.product_category_name, 'Unknown') AS category,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN category_translation ct ON p.product_category_name = ct.product_category_name
    JOIN orders o ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY COALESCE(ct.product_category_name_english, p.product_category_name, 'Unknown')
)
SELECT
    category,
    revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS pct_of_total,
    RANK() OVER (ORDER BY revenue DESC) AS revenue_rank
FROM category_totals
ORDER BY revenue DESC
LIMIT 15;
