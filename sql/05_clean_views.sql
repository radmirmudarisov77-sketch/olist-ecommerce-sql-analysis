-- 05_clean_views.sql
-- Cleaning layer: raw tables are NOT modified, only views are created.
-- Safe to re-run (views are dropped and recreated in dependency order).

DROP VIEW IF EXISTS orders_delivered;
DROP VIEW IF EXISTS orders_period;
DROP VIEW IF EXISTS order_reviews_clean;
DROP VIEW IF EXISTS products_clean;

-- 1. Orders inside the analysis period (Jan 2017 - Aug 2018)
CREATE VIEW orders_period AS
SELECT *
FROM orders
WHERE order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01';

-- 2. Delivered orders with a customer delivery date.
--    carrier_date_invalid flags orders where the carrier handover date
--    is earlier than the purchase date (do not use that date in metrics).
CREATE VIEW orders_delivered AS
SELECT *,
       (order_delivered_carrier_date < order_purchase_timestamp) AS carrier_date_invalid
FROM orders_period
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL;

-- 3. One (latest) review per order
CREATE VIEW order_reviews_clean AS
SELECT DISTINCT ON (order_id) *
FROM order_reviews
ORDER BY order_id, review_answer_timestamp DESC;

-- 4. Products with a readable category; missing category -> 'unknown'
CREATE VIEW products_clean AS
SELECT p.*,
       COALESCE(t.product_category_name_english, 'unknown') AS category_en
FROM products p
LEFT JOIN product_category_translation t
       ON t.product_category_name = p.product_category_name;

SELECT 'orders_period'        AS view_name, COUNT(*) FROM orders_period
UNION ALL SELECT 'orders_delivered',      COUNT(*) FROM orders_delivered
UNION ALL SELECT 'order_reviews_clean',   COUNT(*) FROM order_reviews_clean
UNION ALL SELECT 'products_clean',        COUNT(*) FROM products_clean;