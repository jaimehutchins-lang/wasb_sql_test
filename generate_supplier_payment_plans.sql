USE memory.default;

WITH invoice_schedule AS (
    SELECT
        i.supplier_id,
        i.invoice_ammount,
        last_day_of_month(current_date) AS first_payment_date,
        last_day_of_month(date_add('day', -1, date_trunc('month', i.due_date))) AS last_payment_date
    FROM invoice i
),
invoice_months AS (
    SELECT
        supplier_id,
        invoice_ammount,
        first_payment_date,
        last_payment_date,
        date_diff('month', date_trunc('month', first_payment_date), date_trunc('month', last_payment_date)) + 1 AS num_months
    FROM invoice_schedule
    WHERE last_payment_date >= first_payment_date
),
invoice_payments AS (
    SELECT
        im.supplier_id,
        last_day_of_month(date_add('month', t.month_offset, im.first_payment_date)) AS payment_date,
        CASE
            WHEN t.month_offset = im.num_months - 1 THEN
                im.invoice_ammount - (CAST(im.invoice_ammount / im.num_months AS DECIMAL(8, 2)) * (im.num_months - 1))
            ELSE CAST(im.invoice_ammount / im.num_months AS DECIMAL(8, 2))
        END AS payment_amount
    FROM invoice_months im
    CROSS JOIN unnest(sequence(0, im.num_months - 1)) AS t(month_offset)
),
supplier_payments AS (
    SELECT
        supplier_id,
        payment_date,
        SUM(payment_amount) AS payment_amount
    FROM invoice_payments
    GROUP BY supplier_id, payment_date
),
supplier_totals AS (
    SELECT
        supplier_id,
        SUM(invoice_ammount) AS total_invoiced
    FROM invoice
    GROUP BY supplier_id
),
payment_plan AS (
    SELECT
        sp.supplier_id,
        sp.payment_date,
        sp.payment_amount,
        CAST(
            st.total_invoiced - SUM(sp.payment_amount) OVER (
                PARTITION BY sp.supplier_id
                ORDER BY sp.payment_date
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) AS DECIMAL(8, 2)
        ) AS balance_outstanding
    FROM supplier_payments sp
    INNER JOIN supplier_totals st ON sp.supplier_id = st.supplier_id
)
SELECT
    pp.supplier_id,
    s.name AS supplier_name,
    pp.payment_amount,
    pp.balance_outstanding,
    pp.payment_date
FROM payment_plan pp
INNER JOIN supplier s ON pp.supplier_id = s.supplier_id
ORDER BY pp.supplier_id, pp.payment_date;
