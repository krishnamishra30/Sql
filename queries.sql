-- Week 2: SQL for Data Analysis  |  Database: data/sample_store.db (SQLite)
-- Tables: customers(customer_id, name, city) | products(product_id, product_name, category, price)
--         orders(order_id, customer_id, order_date, status) | order_items(item_id, order_id, product_id, quantity)

-- Q1. SELECT + WHERE + ORDER BY: expensive products, highest price first
SELECT product_name, category, price
FROM products
WHERE price > 5000
ORDER BY price DESC;

-- Q2. GROUP BY + aggregates: revenue, units and order lines per category (delivered orders only)
SELECT p.category,
       COUNT(*)                          AS order_lines,
       SUM(oi.quantity)                  AS units_sold,
       SUM(oi.quantity * p.price)        AS total_revenue
FROM order_items oi
JOIN products p ON p.product_id = oi.product_id
JOIN orders   o ON o.order_id   = oi.order_id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Q3. TOP CUSTOMERS: top 5 customers by total spend
SELECT c.name, c.city,
       COUNT(DISTINCT o.order_id)        AS orders,
       SUM(oi.quantity * p.price)        AS total_spent
FROM customers c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products    p  ON p.product_id  = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.name, c.city
ORDER BY total_spent DESC
LIMIT 5;

-- Q4. AVERAGE ORDER VALUE (AOV): total revenue / number of orders
SELECT ROUND(SUM(oi.quantity * p.price) * 1.0 / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN products    p  ON p.product_id = oi.product_id
WHERE o.status = 'Delivered';

-- Q5. Average order value per customer (GROUP BY on a subquery in FROM)
SELECT c.name,
       ROUND(AVG(t.order_total), 2) AS avg_order_value
FROM (SELECT o.order_id, o.customer_id, SUM(oi.quantity * p.price) AS order_total
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.order_id
      JOIN products    p  ON p.product_id = oi.product_id
      WHERE o.status = 'Delivered'
      GROUP BY o.order_id, o.customer_id) t
JOIN customers c ON c.customer_id = t.customer_id
GROUP BY c.customer_id, c.name
ORDER BY avg_order_value DESC;

-- Q6. SUBQUERY: orders whose value is above the overall average order value
SELECT order_id, order_total
FROM (SELECT o.order_id, SUM(oi.quantity * p.price) AS order_total
      FROM orders o
      JOIN order_items oi ON oi.order_id = o.order_id
      JOIN products    p  ON p.product_id = oi.product_id
      WHERE o.status = 'Delivered'
      GROUP BY o.order_id)
WHERE order_total > (SELECT AVG(order_total)
                     FROM (SELECT SUM(oi.quantity * p.price) AS order_total
                           FROM orders o
                           JOIN order_items oi ON oi.order_id = o.order_id
                           JOIN products    p  ON p.product_id = oi.product_id
                           WHERE o.status = 'Delivered'
                           GROUP BY o.order_id))
ORDER BY order_total DESC;

-- Q7. CASE: customer segments by total spend (High >= 250k, Medium >= 100k, else Low)
SELECT c.name,
       SUM(oi.quantity * p.price) AS total_spent,
       CASE WHEN SUM(oi.quantity * p.price) >= 250000 THEN 'High value'
            WHEN SUM(oi.quantity * p.price) >= 100000 THEN 'Medium value'
            ELSE 'Low value' END  AS segment
FROM customers c
JOIN orders      o  ON o.customer_id = c.customer_id
JOIN order_items oi ON oi.order_id   = o.order_id
JOIN products    p  ON p.product_id  = oi.product_id
WHERE o.status = 'Delivered'
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;

-- Q8. LEFT JOIN: customers who have never placed an order
SELECT c.customer_id, c.name, c.city
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_id IS NULL;
