USE memory.default;

WITH RECURSIVE
manager_walk(start_employee_id, next_manager_id, visited_path) AS (
    SELECT employee_id, manager_id, ARRAY[employee_id]
    FROM employee
    WHERE manager_id IS NOT NULL

    UNION ALL

    SELECT
        mw.start_employee_id,
        e.manager_id,
        mw.visited_path || e.employee_id
    FROM manager_walk mw
    INNER JOIN employee e ON mw.next_manager_id = e.employee_id
    WHERE NOT contains(mw.visited_path, e.employee_id)
),
raw_cycles(start_employee_id, cycle_path) AS (
    SELECT
        start_employee_id,
        slice(
            visited_path,
            array_position(visited_path, next_manager_id),
            cardinality(visited_path) - array_position(visited_path, next_manager_id) + 1
        )
    FROM manager_walk
    WHERE contains(visited_path, next_manager_id)
),
canonical_cycles(cycle_path) AS (
    SELECT cycle_path
    FROM raw_cycles
    WHERE contains(cycle_path, start_employee_id)
      AND start_employee_id = (SELECT min(x) FROM unnest(cycle_path) AS t(x))
)
SELECT
    c.employee_id,
    cc.cycle_path AS manager_cycle
FROM canonical_cycles cc
CROSS JOIN unnest(cc.cycle_path) AS c(employee_id)
ORDER BY c.employee_id;
