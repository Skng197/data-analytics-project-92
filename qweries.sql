select 
e.first_name || ' ' || e.last_name AS saller,                   -- объединяем имя и фамилию в поле saller
count(s.sales_id) as operations,				-- считаем количество продаж
round(sum(p.price*s.quantity),0) as income			-- считаем сумму продаж, округлям ее до 2х знаков полсле запятой
from sales s 							-- объедтгняем 3 таблицы, sales и employees по полю s.sales_person_id = e.employee_id, sales и products по 
left join employees e on s.sales_person_id = e.employee_id	-- s.product_id = p.product_id
left join products p on s.product_id = p.product_id
group by e.first_name, e.last_name				-- группируем по имени и фамилии
order by income desc, e.first_name, e.last_name asc		-- сортируем по сумме продаж по убыванию, 
imit 10;							-- выводим 10 первых записей

__________________________________________________

with tab as (							-- CTE №1 который считает средний объем продаж по всем менеджерам
select 
avg (p.price*s.quantity) as avg_income
from sales s 
left join products p on s.product_id = p.product_id
),
tab2 as (							-- СТЕ №2 который считает средний объем продаж каждого менеджера
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
select								-- основной запрос который выводит имя и фамилию менеджера - поле saller
t2.saller,
round(t2.avg_s_income, 0) as  average_income			-- выводим средний объем продаж менеджеров у которых она меньше среднего объма продаж по всем менеджерам 
from tab t, tab2 t2
where  t2.avg_s_income < t.avg_income
order by t2.avg_s_income ASC
;
__________________________________________________

with tab as (							-- CTE №1 который выводит дату продаж, название дня недели на английском, присваевает воскресенью вместо числового 
select 								-- значения 0, 7. Затем следущему дню недели - понедельнику - 1, вторнику - 2, ит.д.
sale_date,
    TO_CHAR(sale_date, 'FMDay') AS day_of_week,
    CASE 
        WHEN EXTRACT(DOW FROM sale_date) = 0 THEN 7
        ELSE EXTRACT(DOW FROM sale_date)
    END AS day_number
   from sales
  ),
tab2 as (  							-- СТЕ №2 который считает средний объем продаж каждого менеджера с группировкои по имени и фамилии
select  
e.first_name || ' ' || e.last_name AS saller,
round(sum(p.price*s.quantity),0) as income
from sales s 
left join employees e on s.sales_person_id = e.employee_id
left join products p on s.product_id = p.product_id
group by e.first_name, last_name
)
select								-- основной запрос который выводит поля saller, day_of_week, income. Группируем по этим же полям. 
tab2.saller,
tab.day_of_week,						-- Сортируем по номеру дня недели из СТЕ 1, но на печать это поле не выводим
tab2.income
from tab, tab2
group by day_of_week, saller, tab2.income, day_number
order by day_number asc, saller asc
;
