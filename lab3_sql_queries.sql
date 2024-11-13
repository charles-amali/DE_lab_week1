-- Window Functions
SELECT o.product_id,
       SUM(o.quantity * p.price) AS total_sales,
       ROW_NUMBER() OVER (ORDER BY SUM(o.quantity * p.price) DESC) AS row_number_rank,
       RANK() OVER (ORDER BY SUM(o.quantity * p.price) DESC) AS ranks,
       DENSE_RANK() OVER (ORDER BY SUM(o.quantity * p.price) DESC) AS dense_ranks
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY o.product_id
ORDER BY total_sales DESC;

-- Running totals
SELECT category,
       order_id,
       order_date,
       SUM(quantity * price) OVER (PARTITION BY category ORDER BY order_date) AS running_total_sales
FROM orders
JOIN products ON orders.product_id = products.product_id
ORDER BY category, order_date;

-- Partition
SELECT Cutomer_id,
       order_id,
       SUM(quantity * price) AS order_value,
       AVG(SUM(quantity * price)) OVER (PARTITION BY Cutomer_id) AS avg_order_value_per_customer
FROM orders
JOIN products ON orders.product_id = products.product_id
GROUP BY Cutomer_id, order_id
ORDER BY Cutomer_id;

-- LAG & LEAD
SELECT YEAR(order_date) AS year,
       MONTH(order_date) AS month,
       SUM(quantity * price) AS monthly_sales,
       LAG(SUM(quantity * price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS previous_month_sales,
       LEAD(SUM(quantity * price)) OVER (ORDER BY YEAR(order_date), MONTH(order_date)) AS next_month_sales
FROM orders
JOIN products ON orders.product_id = products.product_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;

-- Complex Analysis with window function
WITH customer_sales AS (
    SELECT 
        Cutomer_id,
        order_id,
        order_date,
        quantity * price AS order_value
    FROM orders
    JOIN products ON orders.product_id = products.product_id
),
cumulative_data AS (
    SELECT 
        Cutomer_id,
        order_id,
        order_date,
        SUM(order_value) OVER (PARTITION BY Cutomer_id ORDER BY order_date) AS cumulative_sales,
        AVG(order_value) OVER (PARTITION BY Cutomer_id) AS avg_order_value
    FROM customer_sales
),
total_sales AS (
    SELECT 
        Cutomer_id,
        SUM(order_value) AS total_sales
    FROM customer_sales
    GROUP BY Cutomer_id
)
SELECT 
    cd.Cutomer_id,
    cd.order_id,
    cd.order_date,
    cd.cumulative_sales,
    cd.avg_order_value,
    RANK() OVER (ORDER BY ts.total_sales DESC) AS customer_rank
FROM cumulative_data cd
JOIN total_sales ts ON cd.Cutomer_id = ts.Cutomer_id
ORDER BY customer_rank;






