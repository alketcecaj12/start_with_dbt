SELECT
    order_id::INTEGER          AS order_id,
    TRIM(customer_name)        AS customer_name,
    amount::DECIMAL(10, 2)     AS amount,
    LOWER(TRIM(status))        AS status
FROM {{ ref('raw_orders') }}
