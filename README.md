# olist-ecommerce-sql-analysis
Исследование бразильского маркетплейса Olist: PostgreSQL, SQL, pandas, Seaborn и Matplotlib. Анализ продаж, логистики, клиентов, продавцов, товарных категорий и платежей.

### **Аудит данных**

Перед анализом я провёл аудит датасета (9 таблиц, 99 441 заказ) и зафиксировал каждую проблему и принятое решение. Исходные таблицы не изменяются: очистка выполняется через SQL-представления (`sql/05_clean_views.sql`).

### Область анализа

- **Период анализа: январь 2017 – август 2018.** Объём заказов в первые месяцы (2016) и в последние месяцы 2018 года аномально низкий, поэтому выгрузка выглядит обрезанной с обоих концов. Точная причина неизвестна, поэтому эти месяцы исключены, чтобы не получить ложных провалов на графиках.
- **Основная выборка для продаж и доставки — `orders_delivered`:** заказы со статусом `delivered`, датой получения и датой покупки в январе 2017 — августе 2018. Число 96 478 относится к доставленным заказам исходной таблицы за весь период, а не обязательно к отфильтрованному представлению.

### Найденные проблемы и решения

| # | Проблема | Масштаб | Решение |
|---|----------|---------|---------|
| 1 | Неполные месяцы по краям периода | 2016 год, конец 2018 | Анализ ограничен периодом янв 2017 – авг 2018 |
| 2 | Заказы со статусом `delivered` без даты доставки клиенту | 8 заказов (~0,008%) | Исключены из метрик срока доставки |
| 3 | Дата передачи перевозчику раньше даты покупки | 166 заказов (~0,17%) | Заказы оставлены. Добавлен флаг `carrier_date_invalid`, дата перевозчика в метриках не используется. Даты оплаты и доставки клиенту у этих заказов корректны |
| 4 | `customer_id` создаётся на каждый заказ | 99 441 id против 96 096 уникальных клиентов | Клиенты считаются по `customer_unique_id` |
| 5 | Несколько отзывов на один заказ | 547 заказов | Оставлен последний отзыв (`order_reviews_clean`) |
| 6 | Заказы без отзыва | 768 заказов | Остаются в анализе выручки, из метрик оценок выпадают сами |
| 7 | Заказы без товаров | 775 заказов | В выручку не попадают; 767 `unavailable`/`canceled`; используются в воронке отмен |
| 8 | Товары без категории | 610 товаров | Помечены как `unknown`, категории не придумываются |
| 9 | Товары без веса | 2 товара | Игнорируются (вес в анализе не используется) |

### Слой очистки данных

```sql
orders_period         -- заказы с 2017-01-01 по 2018-08-31
orders_delivered      -- доставленные заказы с датой доставки клиенту
order_reviews_clean   -- один (последний) отзыв на заказ
products_clean        -- товары с английской категорией category_en
```

Другие исправления, сделанные при создании схемы (`sql/03_constraints.sql`):
- Пустые строки в `products.product_category_name` заменены на `NULL`.
- Две категории, отсутствовавшие в таблице переводов (`pc_gamer`, `portateis_cozinha_e_preparadores_de_alimentos`), добавлены, чтобы можно было создать внешний ключ.
- Комментарии в отзывах содержат переносы строк, поэтому файл загружается через `\copy`, а не через мастер импорта в графическом клиенте.

### Ограничения

- Отзывы оставляются добровольно, поэтому средняя оценка может быть смещена; направление смещения неизвестно.
- В данных нет даты отмены заказа, поэтому воронка отмен косвенная: она строится по тому, какие временные метки успели заполниться до отмены.
- Повторные клиенты встречаются редко (~3%), поэтому анализ удержания в основном показывает, что retention низкий.
- Таблица `geolocation` загружена, но не используется: город, штат и индекс уже есть в `customers` и `sellers`, а в самой таблице много строк на один индекс, из-за чего JOIN размножал бы строки.

## Навигация по исследованию

- [01_eda.ipynb](notebooks/01_eda.ipynb) — продажи, средний чек, категории и логистика.
- [02_eda.ipynb](notebooks/02_eda.ipynb) — клиенты, повторные покупки, когорты, продавцы и корреляции.
- [ROADMAP.md](ROADMAP.md) — план проекта.
- [SQL-скрипты](sql/) — создание схемы, загрузка, аудит и представления.

**Запуск:** необходима локальная PostgreSQL с загруженным датасетом Olist. Скрипты SQL запускаются по порядку, затем ноутбуки. Путь к CSV в `sql/02_load_data.sql` и строку соединения `create_engine(...)` в ноутбуках нужно изменить под свою систему. Графики сохраняются относительно папки `notebooks/` в `../images/`.

**Определения:** `SUM(order_items.price)` — стоимость товаров без доставки, `SUM(order_payments.payment_value)` — сумма платежей (может включать доставку). Эти показатели нельзя без пояснения считать взаимозаменяемыми. Для анализа оплаты кредитной картой используется сумма именно карточной платёжной записи. Для заказов с несколькими способами оплаты это не полная стоимость заказа.

## Галерея всех графиков

Ниже перечислены **все изображения, сохранённые в папке `images/`**. Некоторые графики являются альтернативными способами показать одну и ту же метрику; для быстрого чтения можно начать с кривых Парето, когортной карты, графиков доставки и рассрочек.

<details>
<summary><strong>Продажи и категории</strong> (11 графиков)</summary>

#### orders by status

![orders_by_status.png](images/orders_by_status.png)

#### revenue per month

![revenue_per_month.png](images/revenue_per_month.png)

#### monthly rev delta pct

![monthly_rev_delta_pct.png](images/monthly_rev_delta_pct.png)

#### monthly rev delta mln

![monthly_rev_delta_mln.png](images/monthly_rev_delta_mln.png)

#### aov by month

![aov_by_month.png](images/aov_by_month.png)

#### sales volume

![sales_volume.png](images/sales_volume.png)

#### top 10 cats

![top_10_cats.png](images/top_10_cats.png)

#### revenue by cats

![revenue_by_cats.png](images/revenue_by_cats.png)

#### volume vs avg price

![volume_vs_avg_price.png](images/volume_vs_avg_price.png)

#### categories pareto

![categories_pareto.png](images/categories_pareto.png)

#### metrics top cats

![metrics_top_cats.png](images/metrics_top_cats.png)

</details>

<details>
<summary><strong>Доставка</strong> (7 графиков)</summary>

#### percentage late del

![percentage_late_del.png](images/percentage_late_del.png)

#### Delivery days distr

![Delivery_days_distr.png](images/Delivery_days_distr.png)

#### late delivery vs reviews

![late_delivery_vs_reviews.png](images/late_delivery_vs_reviews.png)

#### late vs score

![late_vs_score.png](images/late_vs_score.png)

#### on time del vs late del

![on_time_del_vs_late_del.png](images/on_time_del_vs_late_del.png)

#### score late vs ontime

![score_late_vs_ontime.png](images/score_late_vs_ontime.png)

#### delivery across states

![delivery_across_states.png](images/delivery_across_states.png)

</details>

<details>
<summary><strong>Клиенты и продавцы</strong> (4 графиков)</summary>

#### days to return distr

![days_to_return_distr.png](images/days_to_return_distr.png)

#### repeat by first score

![repeat_by_first_score.png](images/repeat_by_first_score.png)

#### cohort heatmap

![cohort_heatmap.png](images/cohort_heatmap.png)

#### sellers pareto

![sellers_pareto.png](images/sellers_pareto.png)

</details>

<details>
<summary><strong>Платежи и рассрочки</strong> (5 графиков)</summary>

#### distr pay methods

![distr_pay_methods.png](images/distr_pay_methods.png)

#### cc inst count

![cc_inst_count.png](images/cc_inst_count.png)

#### cc inst group count

![cc_inst_group_count.png](images/cc_inst_group_count.png)

#### cc inst count pie

![cc_inst_count_pie.png](images/cc_inst_count_pie.png)

#### cc payment amount by inst gr

![cc_payment_amount_by_inst_gr.png](images/cc_payment_amount_by_inst_gr.png)

</details>

## Статус финальной проверки

В ветке `final-check` проведена проверка ноутбуков: исправлены отдельные ошибки построения графиков и SQL-метрик, использование очищенных отзывов и фильтрация некорректных дат передачи перевозчику. **Результаты исправленных запросов требуют повторного запуска на локальной базе:** здесь база недоступна, поэтому сохранённые PNG и старые числовые выводы ещё могут отражать предыдущую версию кода. Перед публикацией нужно перезапустить ноутбуки, обновить соответствующие графики и сверить цифры в Markdown. Бизнес-рекомендации и стратегические альтернативы будут подготовлены отдельным этапом.
