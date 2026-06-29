SELECT COUNT(*) AS total_rows, COUNT(DISTINCT order_id) AS distinct_orders
FROM orders;

SELECT customer_id,customer_unique_i FROM customers;


drop table orders;

select * from orders;

CREATE TABLE orders (
    order_id text,
    customer_id text,
    order_status text,
    order_purchase_timestamp text,
    order_approved_at text,
    order_delivered_carrier_date text,
    order_delivered_customer_date text,
    order_estimated_delivery_date text
);

-- Monthly revenue and order count
--INNER JOIN 
--GROUP BY 
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp::timestamp) AS order_month,
    COUNT(DISTINCT o.order_id)                                  AS total_orders,
    ROUND(SUM(oi.price + oi.freight_value), 2)                  AS total_revenue
FROM orders o
JOIN items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY 1;

-- Top product categories by revenue
-- JOIN three tables 
-- 
SELECT
    p.product_category_name  AS category,
    COUNT(oi.order_id)        AS total_orders,
    ROUND(SUM(oi.price), 2)   AS total_revenue
FROM items oi
JOIN products p     ON oi.product_id = p.product_id
JOIN orders o       ON oi.order_id  = o.order_id
WHERE o.order_status = 'delivered'
  AND p.product_category_name IS NOT NULL
GROUP BY 1
HAVING SUM(oi.price) > 10000
ORDER BY 3 DESC
LIMIT 15;


-- Rank customers by spend within each state
-- CTE RANK() window function and PARTITION BY 
WITH customer_spend AS (
    SELECT
        c.customer_state,
        c.customer_city,
        COUNT(DISTINCT o.order_id)      AS total_orders,
        ROUND(SUM(oi.price), 2)         AS total_spend
    FROM customers c
    JOIN orders o       ON c.customer_id  = o.customer_id
    JOIN items oi ON o.order_id     = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY 1, 2
)
SELECT
    customer_state,
    customer_city,
    total_orders,
    total_spend,
    RANK() OVER (PARTITION BY customer_state ORDER BY total_spend DESC) AS rank_in_state
FROM customer_spend
ORDER BY customer_state, rank_in_state;


-- Average delivery time and month-over-month comparison
-- •	LAG() •	LEAD() •	EXTRACT
WITH monthly_delivery AS (
    SELECT
        DATE_TRUNC('month', order_purchase_timestamp::timestamp ) AS order_month,
        ROUND(AVG(
            EXTRACT(EPOCH FROM (order_delivered_customer_date::timestamp 
                               - order_purchase_timestamp::timestamp )) / 86400
        ), 1) AS avg_delivery_days
    FROM orders
    WHERE order_status = 'delivered'
      AND order_delivered_customer_date  IS NOT NULL
    GROUP BY 1
)
SELECT
    order_month,
    avg_delivery_days,
    LAG(avg_delivery_days)  OVER (ORDER BY order_month) AS prev_month_days,
    LEAD(avg_delivery_days) OVER (ORDER BY order_month) AS next_month_days
FROM monthly_delivery
ORDER BY order_month;


-- Classify orders by customer satisfaction
-- •	CASE  •	LEFT JOIN 
SELECT
    CASE
        WHEN r.review_score::int = 5 THEN 'Excellent'
        WHEN r.review_score::int = 4 THEN 'Good'
        WHEN r.review_score::int = 3 THEN 'Neutral'
        WHEN r.review_score::int IN (1, 2) THEN 'Poor'
        ELSE 'No Review'
    END                         AS satisfaction_level,
    COUNT(*)                    AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 1) AS percentage
FROM orders o
LEFT JOIN reviews r ON o.order_id = r.order_id
GROUP BY 1
ORDER BY order_count DESC;
select count(*) from reviews;