=====================================================
Enterprise Supply Chain & Inventory Optimization
 Author: Sai Srihari
 Description: Business SQL analysis using Instacart dataset
=====================================================
SELECT * 
FROM orders
LIMIT 10;

SELECT *
FROM order_products__prior
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM aisles
LIMIT 10;

SELECT *
FROM departments
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM order_products__prior
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT *
FROM aisles
LIMIT 10;

SELECT
    COUNT(*) AS total_products,
    COUNT(DISTINCT product_id) AS unique_products
FROM products;

SELECT
    COUNT(*) AS total_orders,
    COUNT(DISTINCT order_id) AS unique_orders
FROM orders;

SELECT COUNT(*) AS missing_product_names
FROM products
WHERE product_name IS NULL;

SELECT COUNT(*) AS missing_department_ids
FROM products
WHERE department_id IS NULL;

SELECT COUNT(*) AS missing_aisle_ids
FROM products
WHERE aisle_id IS NULL;

SELECT
    p.product_id,
    p.product_name,
    COUNT(op.product_id) AS total_purchases
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_purchases DESC
LIMIT 10;

SELECT
    p.product_id,
    p.product_name,
    COUNT(*) AS total_reorders
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
WHERE op.reordered = 1
GROUP BY
    p.product_id,
    p.product_name
ORDER BY
    total_reorders DESC
LIMIT 10;

SELECT
    d.department,
    COUNT(op.product_id) AS total_purchases
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY
    d.department
ORDER BY
    total_purchases DESC;
    
SELECT
    a.aisle,
    COUNT(op.product_id) AS total_purchases
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN aisles a
    ON p.aisle_id = a.aisle_id
GROUP BY
    a.aisle
ORDER BY
    total_purchases DESC
LIMIT 10;

SELECT
    order_dow,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_dow
ORDER BY total_orders DESC;

SELECT
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC;

SELECT
    ROUND(AVG(days_since_prior_order), 2) AS avg_days_between_orders
FROM orders
WHERE days_since_prior_order IS NOT NULL;

SELECT
    ROUND(AVG(product_count), 2) AS avg_products_per_order
FROM (
    SELECT
        order_id,
        COUNT(product_id) AS product_count
    FROM order_products__prior
    GROUP BY order_id
) AS order_summary;


SELECT
    user_id,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY user_id
ORDER BY total_orders DESC
LIMIT 10;

SELECT
    d.department,
    COUNT(CASE WHEN op.reordered = 1 THEN 1 END) AS total_reorders,
    COUNT(*) AS total_purchases,
    ROUND(
        COUNT(CASE WHEN op.reordered = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS reorder_rate_percentage
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY reorder_rate_percentage DESC
LIMIT 10;


SELECT
    a.aisle,
    COUNT(CASE WHEN op.reordered = 1 THEN 1 END) AS total_reorders,
    COUNT(*) AS total_purchases,
    ROUND(
        COUNT(CASE WHEN op.reordered = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS reorder_rate_percentage
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN aisles a
    ON p.aisle_id = a.aisle_id
GROUP BY a.aisle
ORDER BY reorder_rate_percentage DESC
LIMIT 10;

SELECT
    p.product_name,
    COUNT(CASE WHEN op.reordered = 1 THEN 1 END) AS total_reorders,
    COUNT(*) AS total_purchases,
    ROUND(
        COUNT(CASE WHEN op.reordered = 1 THEN 1 END) * 100.0 / COUNT(*),
        2
    ) AS reorder_rate_percentage
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
HAVING COUNT(*) >= 50
ORDER BY reorder_rate_percentage DESC, total_purchases DESC
LIMIT 10;


SELECT
    d.department,
    ROUND(COUNT(op.product_id) * 1.0 / COUNT(DISTINCT op.order_id), 2) AS avg_products_per_order
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_products_per_order DESC;


SELECT
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    COUNT(*) AS times_bought_together
FROM order_products__prior op1
JOIN order_products__prior op2
    ON op1.order_id = op2.order_id
   AND op1.product_id < op2.product_id
JOIN products p1
    ON op1.product_id = p1.product_id
JOIN products p2
    ON op2.product_id = p2.product_id
GROUP BY
    p1.product_name,
    p2.product_name
ORDER BY
    times_bought_together DESC
LIMIT 10;

SELECT
    o.user_id,
    COUNT(op.product_id) AS total_products_purchased
FROM orders o
JOIN order_products__prior op
    ON o.order_id = op.order_id
GROUP BY o.user_id
ORDER BY total_products_purchased DESC
LIMIT 10;

WITH product_sales AS (
    SELECT
        d.department,
        p.product_name,
        COUNT(*) AS total_purchases
    FROM order_products__prior op
    JOIN products p
        ON op.product_id = p.product_id
    JOIN departments d
        ON p.department_id = d.department_id
    GROUP BY
        d.department,
        p.product_name
),
ranked_products AS (
    SELECT
        department,
        product_name,
        total_purchases,
        ROW_NUMBER() OVER (
            PARTITION BY department
            ORDER BY total_purchases DESC
        ) AS rn
    FROM product_sales
)
SELECT
    department,
    product_name,
    total_purchases
FROM ranked_products
WHERE rn = 1
ORDER BY total_purchases DESC;

WITH department_sales AS (
    SELECT
        d.department,
        COUNT(*) AS total_purchases
    FROM order_products__prior op
    JOIN products p
        ON op.product_id = p.product_id
    JOIN departments d
        ON p.department_id = d.department_id
    GROUP BY d.department
)
SELECT
    department,
    total_purchases,
    RANK() OVER (ORDER BY total_purchases DESC) AS department_rank
FROM department_sales
ORDER BY department_rank;


SELECT
    order_hour_of_day,
    COUNT(*) AS hourly_orders,
    SUM(COUNT(*)) OVER (
        ORDER BY order_hour_of_day
    ) AS cumulative_orders
FROM orders
GROUP BY order_hour_of_day
ORDER BY order_hour_of_day;

WITH product_counts AS (
    SELECT
        d.department,
        p.product_name,
        COUNT(*) AS total_purchases
    FROM order_products__prior op
    JOIN products p
        ON op.product_id = p.product_id
    JOIN departments d
        ON p.department_id = d.department_id
    GROUP BY
        d.department,
        p.product_name
),
ranked_products AS (
    SELECT
        department,
        product_name,
        total_purchases,
        ROW_NUMBER() OVER (
            PARTITION BY department
            ORDER BY total_purchases DESC
        ) AS rn
    FROM product_counts
)
SELECT
    department,
    product_name,
    total_purchases
FROM ranked_products
WHERE rn <= 5
ORDER BY
    department,
    rn;
    
    WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        COUNT(*) AS total_purchases
    FROM order_products__prior op
    JOIN products p
        ON op.product_id = p.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_name,
    total_purchases,
    CASE
        WHEN total_purchases >= 100 THEN 'A - High Demand'
        WHEN total_purchases >= 50 THEN 'B - Medium Demand'
        ELSE 'C - Low Demand'
    END AS inventory_category
FROM product_sales
ORDER BY total_purchases DESC;


SELECT
    o.order_dow,
    p.product_name,
    COUNT(*) AS total_orders,
    RANK() OVER (
        PARTITION BY o.order_dow
        ORDER BY COUNT(*) DESC
    ) AS product_rank
FROM orders o
JOIN order_products__prior op
    ON o.order_id = op.order_id
JOIN products p
    ON op.product_id = p.product_id
GROUP BY
    o.order_dow,
    p.product_name
ORDER BY
    o.order_dow,
    product_rank;
    
SELECT
    d.department,
    ROUND(AVG(op.reordered) * 100, 2) AS avg_reorder_rate_percentage
FROM order_products__prior op
JOIN products p
    ON op.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_reorder_rate_percentage DESC;

SELECT
    CASE
        WHEN total_orders >= 50 THEN 'High Frequency'
        WHEN total_orders >= 20 THEN 'Medium Frequency'
        ELSE 'Low Frequency'
    END AS customer_segment,
    COUNT(*) AS total_customers
FROM (
    SELECT
        user_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY user_id
) customer_orders
GROUP BY customer_segment
ORDER BY total_customers DESC;

SELECT
    order_dow,
    order_hour_of_day,
    COUNT(*) AS total_orders
FROM orders
GROUP BY
    order_dow,
    order_hour_of_day
ORDER BY total_orders DESC
LIMIT 10;

SELECT
    d.department,
    COUNT(DISTINCT o.user_id) AS unique_customers
FROM orders o
JOIN order_products__prior op
    ON o.order_id = op.order_id
JOIN products p
    ON op.product_id = p.product_id
JOIN departments d
    ON p.department_id = d.department_id
GROUP BY d.department
ORDER BY unique_customers DESC
LIMIT 10;
