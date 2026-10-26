SELECT MIN(order_purchase_timestamp) AS first_order,
       MAX(order_purchase_timestamp) AS last_order
FROM orders;

SELECT DATE_TRUNC('month', order_purchase_timestamp)::date AS month,
       COUNT(*) AS orders
FROM orders
GROUP BY month
ORDER BY month;

SELECT order_status,
       COUNT(*) AS total,
       COUNT(*) - COUNT(order_approved_at)            AS no_approved,
       COUNT(*) - COUNT(order_delivered_carrier_date) AS no_carrier_date,
       COUNT(*) - COUNT(order_delivered_customer_date) AS no_delivery_date
FROM orders
GROUP BY order_status
ORDER BY total DESC;

SELECT
    COUNT(*) FILTER (WHERE order_approved_at < order_purchase_timestamp)            AS approved_before_purchase,
    COUNT(*) FILTER (WHERE order_delivered_carrier_date < order_purchase_timestamp) AS carrier_before_purchase,
    COUNT(*) FILTER (WHERE order_delivered_customer_date < order_delivered_carrier_date) AS delivered_before_carrier
FROM orders;

SELECT COUNT(*) AS customer_ids,
       COUNT(DISTINCT customer_unique_id) AS real_customers
FROM customers;

SELECT COUNT(*) FILTER (WHERE cnt > 1) AS orders_with_many_reviews,
       COUNT(*) AS orders_with_reviews
FROM (SELECT order_id, COUNT(*) AS cnt FROM order_reviews GROUP BY order_id) t;

SELECT COUNT(*) AS orders_without_review
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_reviews r WHERE r.order_id = o.order_id);

SELECT COUNT(*) AS orders_without_items
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id);

SELECT MIN(price) AS min_price, MAX(price) AS max_price,
       MIN(freight_value) AS min_freight, MAX(freight_value) AS max_freight
FROM order_items;

SELECT COUNT(*) AS products,
       COUNT(*) FILTER (WHERE product_category_name IS NULL) AS no_category,
       COUNT(*) FILTER (WHERE product_weight_g IS NULL)      AS no_weight
FROM products;

--проверка доставленных заказов, не имеющих дату доставки
SELECT order_id, order_status, order_purchase_timestamp, order_delivered_carrier_date
FROM orders
WHERE order_status = 'delivered' AND order_delivered_customer_date IS NULL;

SELECT
    COUNT(*) AS total,
    COUNT(*) FILTER (WHERE order_approved_at < order_purchase_timestamp)           AS approved_before_purchase,
    COUNT(*) FILTER (WHERE order_delivered_customer_date < order_purchase_timestamp) AS customer_delivery_before_purchase,
    COUNT(*) FILTER (WHERE order_delivered_customer_date < order_delivered_carrier_date) AS customer_before_carrier
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;

SELECT order_status, COUNT(*) AS orders
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp
GROUP BY order_status
ORDER BY orders DESC;

SELECT
    COUNT(*)                                  AS total,
    COUNT(order_approved_at)                  AS has_approved,
    COUNT(order_delivered_customer_date)      AS has_customer_delivery
FROM orders
WHERE order_delivered_carrier_date < order_purchase_timestamp;

SELECT o.order_status, COUNT(*) AS orders
FROM orders o
WHERE NOT EXISTS (SELECT 1 FROM order_items i WHERE i.order_id = o.order_id)
GROUP BY o.order_status
ORDER BY orders DESC;

-- повторные клиенты 
SELECT COUNT(*) AS repeat_customers
FROM (SELECT customer_unique_id FROM customers GROUP BY 1 HAVING COUNT(*) > 1) t;


select order_status, count(*) from orders o 
where not exists (select 1 from order_items i where i.order_id = o.order_id)
group by order_status