
USE sales;
CREATE TEMPORARY TABLE order_info AS
    SELECT o.order_id, o.order_date, p.product_name, c.customer_name, o.quantity, p.price, (o.quantity * p.price) AS total_revenue
    FROM orders o
    JOIN products p ON o.product_id = p.product_id
    JOIN customers c ON o.Cutomer_id = c.customer_id;

-- SUBQUERRIES
SELECT product_id, total_sales
FROM (
    SELECT o.product_id, SUM(o.quantity * p.price) AS total_sales
    FROM order_info o
    JOIN products p ON o.product_id = p.product_id
    WHERE o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
    GROUP BY o.product_id
) AS monthly_sales
ORDER BY total_sales DESC
LIMIT 5;

-- cASE STATEMENTS
SELECT order_id, total_revenue,
    CASE
        WHEN total_revenue > 1000 THEN 'High'
        WHEN total_revenue BETWEEN 500 AND 1000 THEN 'Medium'
        ELSE 'Low'
    END AS revenue_category
FROM (
    SELECT order_id, SUM(quantity * price) AS total_revenue
    FROM orders_info
    GROUP BY order_id
) AS revenue_data;


-- QUERY OPTIMIZATION
EXPLAIN SELECT * FROM orders WHERE order_date = '2024-11-01';
-- Indexing
CREATE INDEX idx_order_date ON orders(order_date);

DROP TEMPORARY TABLE order_info;





