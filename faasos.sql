drop table if exists driver;
CREATE TABLE driver(driver_id integer,reg_date date); 

INSERT INTO driver(driver_id,reg_date) 
 VALUES (1,'01-01-2021'),
(2,'01-03-2021'),
(3,'01-08-2021'),
(4,'01-15-2021');


drop table if exists ingredients;
CREATE TABLE ingredients(ingredients_id integer,ingredients_name varchar(60)); 

INSERT INTO ingredients(ingredients_id ,ingredients_name) 
 VALUES (1,'BBQ Chicken'),
(2,'Chilli Sauce'),
(3,'Chicken'),
(4,'Cheese'),
(5,'Kebab'),
(6,'Mushrooms'),
(7,'Onions'),
(8,'Egg'),
(9,'Peppers'),
(10,'schezwan sauce'),
(11,'Tomatoes'),
(12,'Tomato Sauce');

drop table if exists rolls;
CREATE TABLE rolls(roll_id integer,roll_name varchar(30)); 

INSERT INTO rolls(roll_id ,roll_name) 
 VALUES (1	,'Non Veg Roll'),
(2	,'Veg Roll');

drop table if exists rolls_recipes;
CREATE TABLE rolls_recipes(roll_id integer,ingredients varchar(24)); 

INSERT INTO rolls_recipes(roll_id ,ingredients) 
 VALUES (1,'1,2,3,4,5,6,8,10'),
(2,'4,6,7,9,11,12');

drop table if exists driver_order;
CREATE TABLE driver_order(order_id integer,driver_id integer,pickup_time datetime,distance VARCHAR(7),duration VARCHAR(10),cancellation VARCHAR(23));
INSERT INTO driver_order(order_id,driver_id,pickup_time,distance,duration,cancellation) 
 VALUES(1,1,'01-01-2021 18:15:34','20km','32 minutes',''),
(2,1,'01-01-2021 19:10:54','20km','27 minutes',''),
(3,1,'01-03-2021 00:12:37','13.4km','20 mins','NaN'),
(4,2,'01-04-2021 13:53:03','23.4','40','NaN'),
(5,3,'01-08-2021 21:10:57','10','15','NaN'),
(6,3,null,null,null,'Cancellation'),
(7,2,'01-08-2021 21:30:45','25km','25mins',null),
(8,2,'01-10-2021 00:15:02','23.4 km','15 minute',null),
(9,2,null,null,null,'Customer Cancellation'),
(10,1,'01-11-2021 18:50:20','10km','10minutes',null);


drop table if exists customer_orders;
CREATE TABLE customer_orders(order_id integer,customer_id integer,roll_id integer,not_include_items VARCHAR(4),extra_items_included VARCHAR(4),order_date datetime);
INSERT INTO customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date)
values (1,101,1,'','','01-01-2021  18:05:02'),
(2,101,1,'','','01-01-2021 19:00:52'),
(3,102,1,'','','01-02-2021 23:51:23'),
(3,102,2,'','NaN','01-02-2021 23:51:23'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,1,'4','','01-04-2021 13:23:46'),
(4,103,2,'4','','01-04-2021 13:23:46'),
(5,104,1,null,'1','01-08-2021 21:00:29'),
(6,101,2,null,null,'01-08-2021 21:03:13'),
(7,105,2,null,'1','01-08-2021 21:20:29'),
(8,102,1,null,null,'01-09-2021 23:54:33'),
(9,103,1,'4','1,5','01-10-2021 11:22:59'),
(10,104,1,null,null,'01-11-2021 18:34:49'),
(10,104,1,'2,6','1,4','01-11-2021 18:34:49');

select * from customer_orders;
select * from driver_order;
select * from ingredients;
select * from driver;
select * from rolls;
select * from rolls_recipes;


1 How many rolls are ordered?

Select * from
customer_orders a join driver_order b
on a.order_id=b.order_id
where b.cancellation is NULL OR b.cancellation in ("NaN", "")

2 How many successful orders by  EACH driver?

Select driver_id, count(*) 
from driver_order
where duration is not NULL
group by driver_id

3 How many of each type of roll was delivered?

Select a.roll_id , count(*) from
customer_orders a join driver_order b
on a.order_id=b.order_id
where b.cancellation not like '%Cancellation%' or b.cancellation is Null
group by a.roll_id
Select * from driver_order 
Select * from driver_order where cancellation IS NOT NULL



4 How many Veg and Non Veg rolls were ordered by each customer?

select a.customer_id,a.roll_id,b.roll_name, count(*) as no_of_rolls
from customer_orders a join rolls b 
on a.roll_id=b.roll_id
group by  a.roll_id, b.roll_name,a.customer_id

5 How many maximum number of rolls were delivered in a single order?

select TOP 1 a.order_id, count(a.roll_id) cnt
from customer_orders a join driver_order b
on a.order_id= b.order_id
where b.cancellation not like '%Cancellation%' or b.cancellation is Null
group by a.order_id
order by cnt DESC

6 For each customer, how many delivered rolls had at least 1 change and how many had no change?

/*select b.customer_id, count(*)
from ( select customer_id, count(*) cnt1
from customer_orders
where not_include_items is NULL and extra_items_included is NULL
group by customer_id) a right join customer_orders b 
on a.order_id!=b.order_id
group by b.customer_id

select * from customer_orders

Select *, case when not_include_items='0' and extra_items_included='0' then 'no change' else 'change' end as chg_no_chg from
(Select tco.customer_id , count(*) from temp_customer_orders tco  where tco.order_id in (
Select tdo.order_id from temp_driver_order tdo where tdo.cancellation ='1') group by tco.customer_id)*/


With temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(	
	Select order_id,customer_id,roll_id, 
	case when not_include_items= ' ' or not_include_items is NULL then '0' else not_include_items end as new_not_include_items,
	case when extra_items_included is Null or extra_items_included=' ' or extra_items_included ='NaN' then '0' else extra_items_included end as new_extra_items_included,
	order_date from customer_orders
)

,
temp_driver_order(order_id,driver_id ,pickup_time,distance,duration,cancellation) as
(
	Select order_id,driver_id,pickup_time,distance,duration,	
	case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else '1'  end as new_cancellation
	from driver_order
)


select customer_id, chg_no_chg,count(*) from 
(select * ,case when not_include_items='0' and extra_items_included ='0' then 'no change' else 'change' end as chg_no_chg 
from temp_customer_orders where order_id in (select order_id from temp_driver_order where cancellation ='1')) a 
group by customer_id, chg_no_chg

/*select customer_id, chg_no_chg, count(no_of_orders) from (select *, case when c.not_include_items='0' and c.extra_items_included ='0' then 'no change' else 'change' end as chg_no_chg from (
select a.customer_id, count(*) as no_of_orders
from temp_customer_orders a join temp_driver_order b
on a.order_id=b.order_id
where b.cancellation = '1'
group by a.customer_id) q1 join temp_customer_orders c on q1.customer_id=c.customer_id ) group by customer_id, chg_no_chg */


7 How many rolls were delivered that had both exclusions and extras?

With temp_customer_orders(order_id,customer_id,roll_id,not_include_items,extra_items_included,order_date) as
(	
	Select order_id,customer_id,roll_id, 
	case when not_include_items= ' ' or not_include_items is NULL then '0' else not_include_items end as new_not_include_items,
	case when extra_items_included is Null or extra_items_included=' ' or extra_items_included ='NaN' then '0' else extra_items_included end as new_extra_items_included,
	order_date from customer_orders
)

,
temp_driver_order(order_id,driver_id ,pickup_time,distance,duration,cancellation) as
(
	Select order_id,driver_id,pickup_time,distance,duration,	
	case when cancellation in ('Cancellation', 'Customer Cancellation') then '0' else '1'  end as new_cancellation
	from driver_order
)

Select order_id, count(*) from temp_customer_orders where order_id  in 
(Select order_id from temp_driver_order where cancellation!='0') and not_include_items!='0' and extra_items_included!='0'
group by order_id


8 what was the total number of rolls ordered for each hour of the day?


Select count(*), hour_bracket from 
(Select *, concat(cast(datepart(hour,order_date) as varchar),'-', cast(datepart(hour, order_date)+1 as varchar)) as hour_bracket from customer_orders)q1
group by hour_bracket

9 What was the number of orders for each day of the week?

select count(distinct order_id), day_day  from (sELECT* , Datepart(WEEKDAY,order_date) day_day FROM CUSTOMER_ORDERS)a
group by day_day

or


select day_day ,count(distinct order_id) from
(sELECT* , Datename(dw,order_date) day_day FROM CUSTOMER_ORDERS)a
group by day_day

B. Driver and Customer Experience

1. what was the average time in minutes it took for each driver to arrive at the faasos HQ TO PICK UP THE ORDER?

Select* from driver_order
Select * from customer_orders

Select driver_id, sum(diff)/count(roll_id) as Avg_pickup_tym_per_driver from
(Select * from 
(Select *, row_number() over(partition by order_id order by DIFF) rnk from
(Select a.order_id,a.customer_id, a.roll_id,a.not_include_items, a.extra_items_included,
a.order_date,b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation ,datediff(minute,a.order_date,b.pickup_time) DIFF 
from customer_orders a join driver_order b
on a.order_id=b.order_id
where b.pickup_time IS NOT NULL)c)d where rnk=1)m
group by driver_id



2. Is there any relationship beween the number of rolls and how  long the order takes to preapare?

Select order_id, count(roll_id) as cnt , sum(DIFF)/count(roll_id) as Tym_Diff_per_order from
(Select a.order_id,a.customer_id, a.roll_id,a.not_include_items, a.extra_items_included,
a.order_date,b.driver_id,b.pickup_time,b.distance,b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) DIFF
from customer_orders a join driver_order b
on a.order_id=b.order_id 
where b.pickup_time IS NOT NULL) as c 
group by order_id


3. What was the avg distance travelled for each customer?

/*select * from driver_order
select * from customer_orders

select avg(b.distance), a.customer_id
from driver_order b join customer_orders a
on a.order_id=b.order_id
where b.distance is not null
group by a.customer_id*/


Select customer_id, sum(distance)/count(order_id) as avg_distance_of_customer from
(Select a.order_id,a.customer_id, a.roll_id,a.not_include_items, a.extra_items_included,
a.order_date,b.driver_id,b.pickup_time,
cast(trim(replace(lower(b.distance),'km',''))as decimal) distance,
b.duration,b.cancellation,datediff(minute,a.order_date,b.pickup_time) DIFF
from customer_orders a join driver_order b
on a.order_id=b.order_id 
where b.pickup_time IS NOT NULL) c
group by customer_id


4 What was the difference between the longest and the shortest delivery times for all orders?

/*Select* from driver_order

Select duration, charindex('m',duration) from driver_order*/

Select max(duration)-min(duration) from
(Select cast(case when duration Like '%min%' then left(duration,(charindex('m',duration)-1)) else duration 
end as decimal)as duration from driver_order where duration is not null)a

5 What was the average speed of each driver for each delivery and do you notice any trend for these values?

Select driver_id, order_id, sum(distance)/sum(duration) as speed_km_per_min from
(Select a.order_id,a.customer_id, a.roll_id,a.not_include_items, a.extra_items_included,
a.order_date,b.driver_id,b.pickup_time,
cast(trim(replace(lower(b.distance),'km',''))as decimal) distance,
cast(case when b.duration Like '%min%' then left(b.duration,(charindex('m',b.duration)-1)) else b.duration 
end as decimal)as duration,
b.cancellation,datediff(minute,a.order_date,b.pickup_time) DIFF
from customer_orders a join driver_order b
on a.order_id=b.order_id 
where b.pickup_time IS NOT NULL)c
group by driver_id, order_id
order by order_id

6 What is the successful delivery percentage for each customer?

Select driver_id, (s*1.0/t)*100 from
(Select driver_id, sum(can_per) s ,count(*) t from
(Select driver_id, case when lower(cancellation) Like '%cancel%' then 0 else 1 end as can_per from driver_order)b
group by driver_id)c
