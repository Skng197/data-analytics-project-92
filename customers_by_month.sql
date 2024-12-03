INSERT INTO "select
distinct TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
count(distinct c.first_name || ' ' || c.last_name) as total_customers,
floor(round(SUM(p.price*s.quantity),2)) as income
from sales s 
left join customers c on s.customer_id = c.customer_id
left join products p on s.product_id = p.product_id
group by selling_month
order by selling_month asc
" (selling_month,total_customers,income) VALUES
	 ('1992-09',226,2618930332),
	 ('1992-10',230,8358113698),
	 ('1992-11',228,8031353737),
	 ('1992-12',229,7708189846);
