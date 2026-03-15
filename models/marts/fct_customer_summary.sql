SELECT
    customer_name,
    COUNT(order_id)                                         AS total_orders,
    SUM(CASE WHEN status = 'completed' THEN amount END)    AS total_revenue,
    SUM(CASE WHEN status = 'returned'  THEN amount END)    AS total_returned,
    ROUND(
        100.0 * COUNT(CASE WHEN status = 'returned' THEN 1 END)
        / COUNT(order_id),
    1)                                                      AS return_rate_pct
FROM {{ ref('stg_orders') }}
GROUP BY customer_name
ORDER BY total_revenue DESC
