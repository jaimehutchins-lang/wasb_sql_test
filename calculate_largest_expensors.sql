USE memory.default;

SELECT
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.manager_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    SUM(x.unit_price * x.quantity) AS total_expensed_amount
FROM employee e
INNER JOIN expense x ON e.employee_id = x.employee_id
INNER JOIN employee m ON e.manager_id = m.employee_id
GROUP BY
    e.employee_id,
    e.first_name,
    e.last_name,
    e.manager_id,
    m.first_name,
    m.last_name
HAVING SUM(x.unit_price * x.quantity) > 1000
ORDER BY total_expensed_amount DESC;
