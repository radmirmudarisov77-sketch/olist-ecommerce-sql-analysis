CREATE TABLE customers (
    customer_id              TEXT,
    customer_unique_id       TEXT,
    customer_zip_code_prefix INT,
    customer_city            TEXT,
    customer_state           TEXT
);

CREATE TABLE geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat             DOUBLE PRECISION,
    geolocation_lng             DOUBLE PRECISION,
    geolocation_city            TEXT,
    geolocation_state           TEXT
);

CREATE TABLE orders (
    order_id                      TEXT,
    customer_id                   TEXT,
    order_status                  TEXT,
    order_purchase_timestamp      TIMESTAMP,
    order_approved_at             TIMESTAMP,
    order_delivered_carrier_date  TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE order_items (
    order_id            TEXT,
    order_item_id       INT,
    product_id          TEXT,
    seller_id           TEXT,
    shipping_limit_date TIMESTAMP,
    price               NUMERIC(10,2),
    freight_value       NUMERIC(10,2)
);

CREATE TABLE order_payments (
    order_id             TEXT,
    payment_sequential   INT,
    payment_type         TEXT,
    payment_installments INT,
    payment_value        NUMERIC(10,2)
);

CREATE TABLE order_reviews (
    review_id               TEXT,
    order_id                TEXT,
    review_score            INT,
    review_comment_title    TEXT,
    review_comment_message  TEXT,
    review_creation_date    TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

CREATE TABLE products (
    product_id                 TEXT,
    product_category_name      TEXT,
    product_name_lenght        INT,   
    product_description_lenght INT,   
    product_photos_qty         INT,
    product_weight_g           INT,
    product_length_cm          INT,
    product_height_cm          INT,
    product_width_cm           INT
);

CREATE TABLE sellers (
    seller_id              TEXT,
    seller_zip_code_prefix INT,
    seller_city            TEXT,
    seller_state           TEXT
);

CREATE TABLE product_category_translation (
    product_category_name         TEXT,
    product_category_name_english TEXT
);