\set d '/Users/a111/olist-project/data/'

\copy product_category_translation FROM :'d'product_category_name_translation.csv WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy customers      FROM :'d'olist_customers_dataset.csv      WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy sellers        FROM :'d'olist_sellers_dataset.csv        WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy products       FROM :'d'olist_products_dataset.csv       WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy orders         FROM :'d'olist_orders_dataset.csv         WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_items    FROM :'d'olist_order_items_dataset.csv    WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_payments FROM :'d'olist_order_payments_dataset.csv WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')
\copy order_reviews  FROM :'d'olist_order_reviews_dataset.csv  WITH (FORMAT csv, HEADER true, QUOTE '"', ESCAPE '"', ENCODING 'UTF8')
\copy geolocation    FROM :'d'olist_geolocation_dataset.csv    WITH (FORMAT csv, HEADER true, ENCODING 'UTF8')