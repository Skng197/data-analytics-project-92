select 
e.first_name || ' ' || e.last_name AS saller,
count(s.sales_id) as operations,
round(sum(p.price*s.quantity),0) as income
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
order by income desc, e.first_name, e.last_name asc
limit 10;