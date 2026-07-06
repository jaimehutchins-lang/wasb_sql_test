USE memory.default;

CREATE TABLE supplier (
    supplier_id TINYINT,
    name VARCHAR
);

CREATE TABLE invoice (
    supplier_id TINYINT,
    invoice_ammount DECIMAL(8, 2),
    due_date DATE
);

INSERT INTO supplier (supplier_id, name) VALUES
    (1, 'Catering Plus'),
    (2, 'Dave''s Discos'),
    (3, 'Entertainment tonight'),
    (4, 'Ice Ice Baby'),
    (5, 'Party Animals');

INSERT INTO invoice (supplier_id, invoice_ammount, due_date) VALUES
    (1, 1500.00, last_day_of_month(date_add('month', 3, current_date))),
    (1, 2000.00, last_day_of_month(date_add('month', 2, current_date))),
    (2, 500.00, last_day_of_month(date_add('month', 1, current_date))),
    (3, 6000.00, last_day_of_month(date_add('month', 3, current_date))),
    (4, 4000.00, last_day_of_month(date_add('month', 6, current_date))),
    (5, 6000.00, last_day_of_month(date_add('month', 3, current_date)));
