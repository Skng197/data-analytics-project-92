with tab as (
select 
sale_date,
    TO_CHAR(sale_date, 'FMDay') AS day_of_week,
    CASE 
        WHEN EXTRACT(DOW FROM sale_date) = 0 THEN 7
        ELSE EXTRACT(DOW FROM sale_date)
    END AS day_number
   from sales
  ),
tab2 as (  
select 
e.first_name || ' ' || e.last_name AS saller,
round(sum(p.price*s.quantity),0) as income
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, last_name
)
select
tab2.saller,
tab.day_of_week,
tab2.income
from tab, tab2
group by day_of_week, saller, tab2.income, day_number
order by day_number asc, saller asc
;
