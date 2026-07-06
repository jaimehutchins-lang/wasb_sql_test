USE memory.default;

CREATE TABLE expense (
    employee_id TINYINT,
    unit_price DECIMAL(8, 2),
    quantity TINYINT
);

INSERT INTO expense (employee_id, unit_price, quantity) VALUES
    (2, 17.50, 4),
    (9, 300.00, 1),
    (3, 13.00, 75),
    (4, 40.00, 9),
    (3, 22.00, 18),
    (3, 11.00, 20),
    (3, 6.50, 14);
