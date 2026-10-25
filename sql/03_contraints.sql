-- Cleaning: missing categories were loaded as empty strings instead of NULL
UPDATE products SET product_category_name = NULL WHERE product_category_name = '';

-- Cleaning: two categories in products have no translation
INSERT INTO product_category_translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer'),
       ('portateis_cozinha_e_preparadores_de_alimentos', 'portable_kitchen_and_food_preparers')
ON CONFLICT DO NOTHING;

-- Primary keys
ALTER TABLE customers                    ADD PRIMARY KEY (customer_id);
ALTER TABLE orders                       ADD PRIMARY KEY (order_id);
ALTER TABLE products                     ADD PRIMARY KEY (product_id);
ALTER TABLE sellers                      ADD PRIMARY KEY (seller_id);
ALTER TABLE order_items                  ADD PRIMARY KEY (order_id, order_item_id);
ALTER TABLE order_payments               ADD PRIMARY KEY (order_id, payment_sequential);
ALTER TABLE product_category_translation ADD PRIMARY KEY (product_category_name);

-- Foreign keys
ALTER TABLE orders         ADD FOREIGN KEY (customer_id)           REFERENCES customers(customer_id);
ALTER TABLE order_items    ADD FOREIGN KEY (order_id)              REFERENCES orders(order_id);
ALTER TABLE order_items    ADD FOREIGN KEY (product_id)            REFERENCES products(product_id);
ALTER TABLE order_items    ADD FOREIGN KEY (seller_id)             REFERENCES sellers(seller_id);
ALTER TABLE order_payments ADD FOREIGN KEY (order_id)              REFERENCES orders(order_id);
ALTER TABLE order_reviews  ADD FOREIGN KEY (order_id)              REFERENCES orders(order_id);
ALTER TABLE products       ADD FOREIGN KEY (product_category_name) REFERENCES product_category_translation(product_category_name);

CREATE INDEX idx_items_product  ON order_items(product_id);
CREATE INDEX idx_items_seller   ON order_items(seller_id);
CREATE INDEX idx_reviews_order  ON order_reviews(order_id);
CREATE INDEX idx_orders_customer ON orders(customer_id);