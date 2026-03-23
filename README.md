# ABC-анализ ассортимента пиццерии

## Описание проекта

Провести ABC-анализ ассортимента пиццерии по наименованиям пицц на основе количества продаж и выручки для выявления наиболее и наименее значимых товаров.

## Реализация

Код представлен в файле `ABC-XYZ_analysis.sql`.

## Исходные данные

**Таблица:** `pizza_sales`

### Атрибуты таблицы `pizza_sales`

- `order_id` — идентификатор заказа
- `date` — дата заказа
- `full_date` — дата и время заказа
- `year` — год заказа
- `month_year` — месяц-год заказа
- `month` — месяц заказа
- `day_of_week` — день недели
- `hour` — час заказа
- `name` — название заказанного товара
- `size` — размер
- `category` — категория товара
- `price` — цена товара
- `quantity` — количество заказанного товара
- `revenue` — выручка с заказанного товара
- `ingredients` — ингредиенты для товара
- `quantity_str` — количество единиц заказанных единиц

## Логика анализа

Анализ проводится по **наименованиям пицц**, агрегировано по всем размерам.

### ABC-анализ по количеству продаж

**Метрика:** `SUM(quantity)`

**Пороги классификации:**
- Категория A — кумулятивная доля ≤ 80%
- Категория B — кумулятивная доля ≤ 95%
- Категория C — кумулятивная доля > 95%

### ABC-анализ по выручке

**Метрика:** `SUM(revenue)`

**Пороги классификации:**
- Категория A — кумулятивная доля ≤ 80%
- Категория B — кумулятивная доля ≤ 95%
- Категория C — кумулятивная доля > 95%

## Требуемые результаты

### 1. Основной отчет ABC-анализа

- `pizza_name` — наименование пиццы
- `total_units_sold` — общее количество проданных единиц
- `total_revenue` — общая выручка
- `abc_category_by_units` — категория ABC по количеству проданных единиц
- `abc_category_by_revenue` — категория ABC по выручке

### 2. Сводная статистика по комбинированным категориям

Комбинированная категория формируется в формате `AA`, `BC` и т.д., где:

- первая буква — категория по количеству
- вторая буква — категория по выручке

Итоговая сводка должна содержать:

- `combined_category` — комбинированная категория
- `number_of_pizzas` — количество пицц в каждой комбинации
- `total_units_sold` — общий объем продаж в каждой комбинации
- `total_revenue` — общая выручка в каждой комбинации
- 
# ABC-анализ ассортимента пиццерии (SQL)

## Описание

ABC-анализ ассортимента пиццерии по наименованиям пицц на основе количества продаж и выручки для выявления наиболее и наименее значимых товаров.

---

## SQL-реализация

**1. Агрегация по пиццам**

```sql
WITH base AS (

    SELECT
        name AS pizza_name,
        SUM(quantity) AS total_units_sold,
        SUM(revenue) AS total_revenue
    FROM pizza_sales
    GROUP BY name
),
```
**2. Расчет долей и кумулятивных значений**
```sql
calc AS (
    
    SELECT
        *,
        total_units_sold * 1.0 / SUM(total_units_sold) OVER() AS share_units,
        total_revenue * 1.0 / SUM(total_revenue) OVER() AS share_revenue,
        
        SUM(total_units_sold) OVER(ORDER BY total_units_sold DESC) * 1.0 
            / SUM(total_units_sold) OVER() AS cum_share_units,
            
        SUM(total_revenue) OVER(ORDER BY total_revenue DESC) * 1.0 
            / SUM(total_revenue) OVER() AS cum_share_revenue
    FROM base
),
```

 **3. Присвоение ABC-категорий**
```sql
abc AS (

    SELECT
        *,
        CASE
            WHEN cum_share_units <= 0.8 THEN 'A'
            WHEN cum_share_units <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_category_by_units,

        CASE
            WHEN cum_share_revenue <= 0.8 THEN 'A'
            WHEN cum_share_revenue <= 0.95 THEN 'B'
            ELSE 'C'
        END AS abc_category_by_revenue
    FROM calc
)
```

**📊 ОСНОВНОЙ ОТЧЕТ**

```sql
SELECT
    pizza_name,
    total_units_sold,
    total_revenue,
    abc_category_by_units,
    abc_category_by_revenue
FROM abc
ORDER BY total_revenue DESC;
```

**📊 СВОДКА ПО КОМБИНАЦИЯМ**

```sql
SELECT
    CONCAT(abc_category_by_units, abc_category_by_revenue) AS combined_category,
    COUNT(*) AS number_of_pizzas,
    SUM(total_units_sold) AS total_units_sold,
    SUM(total_revenue) AS total_revenue
FROM abc
GROUP BY combined_category
ORDER BY combined_category;
```

### 📉 Результаты ABC-XYZ анализа

![ABC-XYZ анализ](https://drive.google.com/uc?export=view&id=1l7R9KrgH5HJo_UPwOz9eGiWw9zdElcLd)
