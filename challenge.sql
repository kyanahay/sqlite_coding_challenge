-- SQL Sales Analysis
-- Tool used: DB Browser for SQLite
-- Database: bais_sqlite_lab.db
-- Purpose: Analyze customer spending, product revenue, employee salaries,
-- and loyalty distribution using SQL.

-- =========================================================
-- QUERY 1 — Top 5 Customers by Total Spend
-- Business Question:
-- Which customers generate the most revenue?
-- =========================================================

WITH customer_spend AS (
    SELECT
        c.id AS customer_id,
        c.first_name || ' ' || c.last_name AS customer_full_name,
        SUM(oi.quantity * oi.unit_price) AS total_spend
    FROM customers AS c
    JOIN orders AS o
        ON c.id = o.customer_id
    JOIN order_items AS oi
        ON o.id = oi.order_id
    GROUP BY
        c.id,
        c.first_name,
        c.last_name
)
SELECT
    customer_full_name,
    ROUND(total_spend, 2) AS total_spend
FROM customer_spend
ORDER BY total_spend DESC, customer_full_name
LIMIT 5;


-- =========================================================
-- QUERY 2 — Total Revenue by Product Category
-- Business Question:
-- Which product categories generate the most revenue?
-- =========================================================

SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.id
GROUP BY p.category
ORDER BY revenue DESC, category;


-- =========================================================
-- QUERY 3 — Delivered Revenue by Product Category
-- Business Question:
-- Which categories generate the most realized revenue from delivered orders?
-- =========================================================

SELECT
    p.category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS delivered_revenue
FROM products AS p
JOIN order_items AS oi
    ON p.id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.id
WHERE o.status = 'Delivered'
GROUP BY p.category
ORDER BY delivered_revenue DESC, category;


-- =========================================================
-- QUERY 4 — Employees Earning Above Department Average
-- Business Question:
-- Which employees earn more than the average salary in their department?
-- =========================================================

WITH department_avg AS (
    SELECT
        department_id,
        AVG(salary) AS avg_salary
    FROM employees
    GROUP BY department_id
)
SELECT
    e.first_name,
    e.last_name,
    d.name AS department_name,
    e.salary AS employee_salary,
    ROUND(da.avg_salary, 2) AS department_average,
    ROUND(e.salary - da.avg_salary, 2) AS amount_above_average
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.id
JOIN department_avg AS da
    ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary
ORDER BY department_name, amount_above_average DESC;


-- =========================================================
-- QUERY 5 — Cities with the Most Gold Customers
-- Business Question:
-- Which cities have the highest number of Gold-tier customers?
-- =========================================================

SELECT
    city,
    COUNT(*) AS gold_customer_count
FROM customers
WHERE loyalty_level = 'Gold'
GROUP BY city
ORDER BY gold_customer_count DESC, city ASC;


-- =========================================================
-- QUERY 6 — Loyalty Distribution by City
-- Business Question:
-- What is the loyalty-level mix across each city?
-- =========================================================

SELECT
    city,
    SUM(CASE WHEN loyalty_level = 'Gold' THEN 1 ELSE 0 END) AS gold_count,
    SUM(CASE WHEN loyalty_level = 'Silver' THEN 1 ELSE 0 END) AS silver_count,
    SUM(CASE WHEN loyalty_level = 'Bronze' THEN 1 ELSE 0 END) AS bronze_count,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY gold_count DESC, total_customers DESC, city ASC;
