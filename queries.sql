4. customers_count

select 
count(customer_id) as customers_count
from customers;
____________________________________________
5.1 top_10_total_income

select 
e.first_name || ' ' || e.last_name AS seller,               -- объединяем имя и фамилию в поле seller
count(s.sales_id) as operations,				            -- считаем количество продаж
FLOOR(SUM(p.price * s.quantity)) AS income			        -- считаем сумму продаж, округлям ее до 2х знаков полсле запятой
from sales s 							                    -- объедтгняем 3 таблицы, sales и employees по полю s.sales_person_id = e.employee_id, sales и products по 
left join employees e on s.sales_person_id = e.employee_id	-- s.product_id = p.product_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name				            -- группируем по имени и фамилии
order by income desc, e.first_name, e.last_name asc		    -- сортируем по сумме продаж по убыванию, 
limit 10;							                        -- выводим 10 первых записей

__________________________________________________
5.2 lowest_average_income

with tab as (							    -- CTE №1 который считает средний объем продаж по всем менеджерам
select 
avg (p.price*s.quantity) as avg_income
from sales s 
left join products p on s.product_id = p.product_id
),
tab2 as (						    	    -- СТЕ №2 который считает средний объем продаж каждого менеджера
select 
e.first_name || ' ' || e.last_name AS seller,
count(s.sales_id) as operations,
sum(p.price*s.quantity) as income,
floor(avg (p.price*s.quantity)) as avg_s_income
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name
)
select								         -- основной запрос который выводит имя и фамилию менеджера - поле saller
t2.seller,
round(t2.avg_s_income, 0) as  average_income -- выводим средний объем продаж менеджеров у которых она меньше среднего объма продаж по всем менеджерам 
from tab t, tab2 t2
where  t2.avg_s_income < t.avg_income
order by t2.avg_s_income ASC
;
__________________________________________________
5.3 day_of_the_week_income

with tab as (						-- CTE  который выводит дату продаж, название дня недели на английском, присваевает воскресенью вместо числового 
select 								
s.sale_date,
    lower(TO_CHAR(s.sale_date, 'FMDay')) AS day_of_week, -- день недели пишем с маленькой буквы
    CASE 
        WHEN EXTRACT(DOW FROM s.sale_date) = 0 THEN 7  -- Присваиваем Воскресенью значения 7 вместо 0 (по умолчанию). Дни недели будут иметь значения от 1 до 7, 1- понедельник
        ELSE EXTRACT(DOW FROM s.sale_date)
    END AS day_number,
   e.first_name || ' ' || e.last_name AS seller,
(sum(p.price*s.quantity)) as income1
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, last_name, s.sale_date
)
select								-- основной запрос который выводит поля seller, day_of_week, income. Группируем по этим же полям. 
seller,
day_of_week,					
floor(round(sum(income1),2)) as income
from tab
group by seller, day_of_week, day_number    -- группируем по номеру дня недели из СТЕ, но на печать это поле не выводим
order by day_number asc, seller asc    
;
__________________________________________________
6.1 age_groups

SELECT 
    CASE                                            -- условие которое мы применяем к полю age для деления на группы по возрасту
        WHEN age BETWEEN 16 AND 25 THEN '16-25'
        WHEN age BETWEEN 26 AND 40 THEN '26-40'
        ELSE '40+'
    END AS age_category,
    COUNT(*) AS age_count                           -- подсчет количества покупателя для каждой возрастной группы
FROM 
   customers c 
GROUP BY 
    age_category
ORDER BY 
    MIN(age);                                       -- сортировка по возрасту по возрастанию
__________________________________________________
6.2 customers_by_month

select
distinct TO_CHAR(s.sale_date, 'YYYY-MM') AS selling_month,
count(distinct c.first_name || ' ' || c.last_name) as total_customers,
floor(round(SUM(p.price*s.quantity),2)) as income
from sales s 
left join customers c on s.customer_id = c.customer_id
left join products p on s.product_id = p.product_id
group by selling_month
order by selling_month asc
;
_________________________________________________
6.3 special_offer

with tab as (                                       -- CTE который выводит поля необходимые для отчета и нумерует покупки по партиции 
select
c.first_name || ' ' || c.last_name as customer, 	-- имя и фамилия покупателя
s.sale_date, 										-- дата покупки
e.first_name || ' ' || e.last_name as seller, 		-- имя и фамилия продавца
p.price,                                            -- цена
c.customer_id,                                      -- id покупателя
ROW_NUMBER() OVER (PARTITION BY c.first_name || ' ' || c.last_name) AS sell_number -- присваваем номера каждой покупке в партиции customer
from sales s 
left join customers c on s.customer_id = c.customer_id             -- объединяем таблицы
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by customer, s.sale_date, seller, price, c.customer_id
order by customer, s.sale_date
)
select                                              -- основной запрос которые выбирает нужные нам поля применяя условия 
customer,                                           -- where price =0 and sell_number =1
sale_date,
seller
from tab
where price =0 and sell_number =1
order by customer_id asc;                           -- сортировка по customer_id asc
