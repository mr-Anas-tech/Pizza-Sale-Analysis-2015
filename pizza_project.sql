

select * from pizzas;
SELECT * FROM order_detail;
select * from pizza_type;
select * from orders;
-------------------------------------Relationship
Alter table order_detail add primary key(order_detail_id);

Alter table order_detail add constraint fk_orders FOREIGN KEY (order_id) References orders(order_id);

alter table orders add primary key(order_id);

Alter table pizza_type add primary key (pizza_type_id);
alter table pizzas add primary key (pizza_id);

ALTER TABLE order_detail add constraint fk_pizza_detail_link foreign key (pizza_id) references pizzas(pizza_id) ;

alter table pizzas add constraint fk_pizza_type_link foreign key (pizza_type_id) references pizza_type(pizza_type_id);




-------------------------------------------Questions With Solutions
--Total Revenue
select sum(p.price * od.quantity) as Total_revenue 
from pizzas as p join order_detail as od
ON p.pizza_id=od.pizza_id;
---total orders or total orders sold
select sum(quantity) as total_orders from order_detail;
---count pizza
select count(distinct order_id) as total_pizza
from order_detail;
--Top 10 sellig pizza by quantity
SELECT od.pizza_id,pt.name,sum(od.quantity) as total_sold
from order_detail as od
JOIN pizzas as p
on od.pizza_id=p.pizza_id
JOIN pizza_type as pt
On p.pizza_type_id=pt.pizza_type_id
GROUP by od.pizza_id,pt.name
Order by total_sold desc limit 10;
--Revenue by category
SELECT pt.category,sum(p.price * od.quantity) as Total_revenue 
from pizzas as p join order_detail as od
ON p.pizza_id=od.pizza_id
JOIN pizza_type as pt 
ON p.pizza_type_id=pt.pizza_type_id
GROUP by pt.category
Order by Total_revenue desc;
--Peak hours
select count(order_id) as total_orders,extract(hour from time::time) as hours
from orders
Group by hours
order by total_orders desc;
-- Average  order value
select sum(p.price * od.quantity)/count(distinct o.order_id) as Avg_order_value
FROM order_detail as od
JOin pizzas as p
ON p.pizza_id=od.pizza_id
JOIN orders as o
on o.order_id=od.order_id;
--Average order per day
select 
      Avg(total_orders) as total_orders_per_day,category
	  FROM (select o.date,pt.category,sum(od.quantity) as total_orders
from orders as o
join order_detail as od
ON o.order_id=od.order_id
JOIN pizzas as p
ON od.pizza_id=p.pizza_id
JOIN pizza_type as pt
ON 
pt.pizza_type_id=p.pizza_type_id
group by o.date,pt.category)
AS total_orders_per_day
group by category;
--Cumulated Revenue (daily)
select date,sum(revenue) over(order by date) As cumulative_Revenue 
FROM (
SELECT o.date,sum(od.quantity * p.price) as revenue
FROM pizzas as p join order_detail as od
ON p.pizza_id=od.pizza_id
JOIN orders as o
ON o.order_id=od.order_id
GROUP BY o.date
) AS sale_data;

--Which category contributes more percentage of revenue
select pt.category,sum(p.price * od.quantity) AS Revenue,
sum(p.price * od.quantity)/sum(sum(p.price * od.quantity)) over()*100
AS Revenue_perc
FROM pizza_type as pt
JOIN pizzas as p
on pt.pizza_type_id=p.pizza_type_id
JOIN order_detail as od 
ON od.pizza_id=p.pizza_id
group by pt.category
Order  by Revenue_perc desc;

---top 3 most revenue generating pizzas from each category

select category, name , Revenue from (
  SELECT 
pt.category,pt.name,sum(p.price * od.quantity) AS Revenue,
dense_rank() over(partition by pt.category ORDER BY sum(p.price * od.quantity)DESC) AS cat_rev
FROM pizza_type as pt
join pizzas as p
ON 
pt.pizza_type_id=p.pizza_type_id
join order_detail as od
ON od.pizza_id=p.pizza_id
group by pt.category,pt.name
) as dence_sale             
where cat_rev<=1;
--Peak month
SELECT extract(month from o.date::date) as MOnth_no,
To_char(o.date::date,'Month')as month_name,
sum(od.quantity*p.price) as Revenue
from orders as o
Join order_detail as od
ON o.order_id=od.order_id
JOIN pizzas as p
On od.pizza_id=p.pizza_id
group by MOnth_no,month_name
order by  Revenue desc limit 3;