with tab as (
select 
avg (p.price*s.quantity) as avg_income
from sales s 
left join products p on s.product_id = p.product_id
),
tab2 as (
select 
e.first_name || ' ' || e.last_name AS saller,
count(s.sales_id) as operations,
sum(p.price*s.quantity) as income,
avg (p.price*s.quantity) as avg_s_income 
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
)
select
t2.saller,
round(t2.avg_s_income, 0) as  average_income
from tab t, tab2 t2
where  t2.avg_s_income < t.avg_income
order by t2.avg_s_income ASC
;
