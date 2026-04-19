-- SQLite Coding Challenge
-- Tool used: Written for SQLite syntax. Designed to run in VS Code with SQLTools (SQLite driver) or any SQLite viewer.
-- Validation approach: Queries were structured to match the stated schema, checked for valid SQLite syntax,
-- and written with readable aliases and deterministic ordering. Replace the database path as needed and run
-- each task against bais_sqlite_lab.db to confirm exact results before submission.

-- =========================================================
-- TASK 1 — Top 5 Customers by Total Spend
-- Goal: Identify the five customers with the highest lifetime spend.
-- Logic: Calculate line totals at the item level, roll up to customer.
-- Note: This version includes all order statuses, per assignment guidance.
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
-- TASK 2 — Total Revenue by Product Category
-- Goal: Determine total revenue for each product category.
-- Logic: Sum item-level line totals grouped by product category.
-- =========================================================
SELECT
    p.category AS category,
    ROUND(SUM(oi.quantity * oi.unit_price), 2) AS revenue
FROM products AS p
JOIN order_items AS oi
    ON p.id = oi.product_id
JOIN orders AS o
    ON oi.order_id = o.id
GROUP BY p.category
ORDER BY revenue DESC, category;

-- =========================================================
-- TASK 2 (OPTIONAL VARIANT) — Revenue by Product Category
-- Using only Delivered orders for a realized-revenue view.
-- =========================================================
SELECT
    p.category AS category,
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
-- TASK 3 — Employees Earning Above Their Department Average
-- Goal: List employees whose salary is strictly greater than their own department’s average.
-- Logic: Compute department averages, then compare each employee to the average for their department.
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
    ROUND(da.avg_salary, 2) AS department_average
FROM employees AS e
JOIN departments AS d
    ON e.department_id = d.id
JOIN department_avg AS da
    ON e.department_id = da.department_id
WHERE e.salary > da.avg_salary
ORDER BY department_name, employee_salary DESC, e.last_name, e.first_name;

-- =========================================================
-- TASK 4 — Cities with the Most Loyal Customers
-- Goal: Rank cities by count of Gold loyalty customers.
-- Logic: Count customers labeled Gold grouped by city.
-- =========================================================
SELECT
    city,
    COUNT(*) AS gold_customer_count
FROM customers
WHERE loyalty_level = 'Gold'
GROUP BY city
ORDER BY gold_customer_count DESC, city ASC;

-- =========================================================
-- TASK 4 (RECOMMENDED EXTENSION) — Loyalty Distribution by City
-- Goal: Show Gold / Silver / Bronze customer mix by city.
-- =========================================================
SELECT
    city,
    SUM(CASE WHEN loyalty_level = 'Gold' THEN 1 ELSE 0 END) AS gold_count,
    SUM(CASE WHEN loyalty_level = 'Silver' THEN 1 ELSE 0 END) AS silver_count,
    SUM(CASE WHEN loyalty_level = 'Bronze' THEN 1 ELSE 0 END) AS bronze_count,
    COUNT(*) AS total_customers
FROM customers
GROUP BY city
ORDER BY gold_count DESC, city ASC;
