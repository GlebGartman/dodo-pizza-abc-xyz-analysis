# ABC-XYZ-анализ ассортимента пиццерии

## Описание проекта

Провести ABC- и XYZ-анализ ассортимента пиццерии по наименованиям пицц для оценки их значимости по количеству продаж и выручке, а также стабильности спроса с целью оптимизации ассортимента, управления запасами и прогнозирования

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

- первая буква — категория по выручке
- вторая буква — категория по количеству

Итоговая сводка должна содержать:

- `combined_category` — комбинированная категория
- `number_of_pizzas` — количество пицц в каждой комбинации
- `total_units_sold` — общий объем продаж в каждой комбинации
- `total_revenue` — общая выручка в каждой комбинации

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

**4. ОСНОВНОЙ ОТЧЕТ**

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

**5. СВОДКА ПО КОМБИНАЦИЯМ**

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
### 📊 Результаты ABC-анализа
![ABC-анализ](https://drive.google.com/uc?export=view&id=13-VqO9U4hpWdZTZNt-pE5ZDLpI7_6uhm)


### Параметры анализа

**Пороги классификации (по коэффициенту вариации):**
- Категория X — коэффициент вариации ≤ 0.1  
- Категория Y — 0.1 < коэффициент вариации ≤ 0.12  
- Категория Z — коэффициент вариации > 0.12  

---

### Ключевые показатели

- **Среднее значение** — среднемесячное количество продаж  
- **Стандартное отклонение** — разброс продаж  
- **Коэффициент вариации (CV)** — `std / mean`  

---

## Требуемые результаты

### 1. Основной отчет XYZ-анализа

- `pizza_name` — наименование пиццы  
- `variation_coefficient` — коэффициент вариации  
- `xyz_category` — категория XYZ:
  - X — стабильные продажи  
  - Y — переменные продажи  
  - Z — нестабильные продажи  

---

# XYZ-анализ ассортимента пиццерии (SQL)

## Описание

XYZ-анализ ассортимента пиццерии по наименованиям пицц для оценки стабильности спроса на основе вариативности продаж с целью оптимизации управления запасами и повышения точности прогнозирования.

## SQL-реализация

**1. Агрегация продаж по месяцам**

```sql
kolvo_pizz_mes AS (

    SELECT 
        name,
        DATE_PART('month', date) AS month,
        SUM(quantity) AS kolvo
    FROM pizza_full_data
    WHERE DATE_PART('year', date) = 2015
    GROUP BY 1, 2
    ORDER BY name
),
```

**2. Присвоение XYZ-категорий**

```sql
XYZ AS (

    SELECT
        name,
        CASE 
            WHEN STDDEV_POP(kolvo) / AVG(kolvo) <= 0.1 THEN 'X'
            WHEN STDDEV_POP(kolvo) / AVG(kolvo) <= 0.12 THEN 'Y'
            ELSE 'Z'
        END AS xyz
    FROM kolvo_pizz_mes
    GROUP BY name
    ORDER BY xyz
)
```
### 📊 Результаты XYZ-анализа
![XYZ-анализ](https://drive.google.com/uc?export=view&id=1WY4fIULUVD0CbfvJGOPb7fOu2MmLGQ54)


### 📉 Результаты ABC-XYZ анализа
![ABC-XYZ анализ](https://drive.google.com/uc?export=view&id=1l7R9KrgH5HJo_UPwOz9eGiWw9zdElcLd)
