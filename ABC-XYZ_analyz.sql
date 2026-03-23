-- ABC
with agregat as 
(
select 
    name,
    SUM(revenue) as amount,
    SUM(quantity) as kolvo
from pizza_full_data 
where date_part('year', date) = 2015
group by name
order by name
),

nakop_revenue as 
(
select  
    name,
    SUM(amount) over(order by amount DESC) as nakop_revenue,
    SUM(amount) over() as total,
    kolvo
from agregat
),

 -- Итог по ABC по Выручке
 abc_revenue as 
 (
 select 
    name,
    case
    	when 100 * nakop_revenue / total <= 80 then 'A'
    	when 100 * nakop_revenue / total <= 95 then 'B'
    	else 'C'
    end as abc_revenue,
    kolvo
 from nakop_revenue
 ),
 
 
nakop_kolvo as 
(
 select
    name,
    abc_revenue,
    SUM(kolvo) over(order by kolvo DESC) as nakop_kolvo,
    SUM(kolvo) over() as total
from abc_revenue
),

 -- Итог ABC
ABC as 
(
select 
    name,
    abc_revenue,
    case
    	when 100 * nakop_kolvo / total <= 80 then 'A'
    	when 100 * nakop_kolvo / total <= 95 then 'B'
    	else 'C'
    end as abc_kolvo
from nakop_kolvo
order by abc_revenue, abc_kolvo
),

combine_kovlo_pizza as 
(
select 
    CONCAT(abc_revenue, abc_kolvo) as combine_category,
    COUNT(name) as kolvo_pizza
from ABC 
group by combine_category
),


-- XYZ
kolvo_pizz_mes as 
(
select 
     name,
     date_part('month', date) as month,
     SUM(quantity) as kolvo
from pizza_full_data
where date_part('year', date) = 2015
group by 1, 2
order by name
),

-- Итог XYZ
XYZ as (
select
   name,
   case 
   	when stddev_pop(kolvo) / AVG(kolvo) <= 0.1 then 'X'
   	when stddev_pop(kolvo) / AVG(kolvo) <= 0.12 then 'Y'
   	else 'Z'
   end as xyz
from kolvo_pizz_mes
group by name
order by xyz
)


-- Общий итог

select 
    ABC.name as name,
    CONCAT(
    abc_kolvo,
    abc_revenue,
    xyz
    ) as abc_xyz
from  ABC join XYZ on XYZ.name = ABC.name
order by abc_xyz



