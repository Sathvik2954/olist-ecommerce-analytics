-- ============================================================
-- QUERY 5: How do customers pay and what is the average order value per method?
-- Finding: Credit card is the most dominant payment method with total value of 12,542,084.19 BRL (average order value: 163.32 BRL) and avg installments of 3.5 months. Boleto is second with 2,869,361.27 BRL.
-- ============================================================

USE olist_db;

SELECT
    payment_type,
    COUNT(DISTINCT order_id) AS total_orders,
    ROUND(AVG(payment_installments), 1) AS avg_installments,
    ROUND(AVG(payment_value), 2) AS avg_order_value,
    ROUND(SUM(payment_value), 2) AS total_revenue
FROM payments
GROUP BY payment_type
ORDER BY total_revenue DESC;
