--Objective
--The goal of this project is to analyze the sales data of Monday Coffee, a company that has been selling its products online since January 2023, and to recommend the top three major cities in India for opening new coffee shop locations based on consumer demand and sales performance.


--Monday Coffee -- Data Analysis
select * from city
select * from products
select * from Customers
select * from sales

--Reports and Data analysis

1. --Coffee Consumers Count**  
  -- How many people in each city are estimated to consume coffee, given that 25% of the population does?
select city_name,
round((population*.25)/1000000,2) as estimated_consumers_in_millions,
city_rank
from city order by 2 desc

2. --Total Revenue from Coffee Sales
   --What is the total revenue generated from coffee sales across all cities in the last quarter of 2023?
select ci.city_name,sum(s.total) as total_revenue
from sales as s
join customers as c on s.customer_id=c.customer_id
join city as ci on c.city_id=ci.city_id
where extract(year from s.sale_date) =2023 and extract(quarter from s.sale_date)=4
group by 1 order by 2 desc

3. --Sales Count for Each Product**  
  -- How many units of each coffee product have been sold?
select p.product_name,count(s.product_id) as sale_count 
from products as p left join sales as s on p.product_id=s.product_id 
group by p.product_name order by 2 desc

4. --Average Sales Amount per City**  
  -- What is the average sales amount per customer in each city?
select ci.city_name,sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)::numeric/count(distinct s.customer_id)::numeric,2) as avg_revenue_per_cx
from sales as s
join customers as c on s.customer_id=c.customer_id
join city as ci on c.city_id=ci.city_id
group by ci.city_name order by 4 desc

5. --City Population and Coffee Consumers**  
   --Provide a list of cities along with their populations and estimated coffee consumers.
with city_table as 
(select city_name,
round((population*.25)/1000000,2) as estimated_consumers_in_millions
from city
),
customer_table as
(select ci.city_name,
count(distinct c.customer_id) as total_unique_cx
from sales as s 
join customers as c 
on c.customer_id=s.customer_id
join city as ci
on ci.city_id=c.city_id
group by 1
)
select ct.city_name,
ct.estimated_consumers_in_millions,
cit.total_unique_cx
from city_table as ct
join 
customer_table as cit
on cit.city_name=ct.city_name


select ci.city_name,
round((ci.population*.25)/1000000,2) as estimated_consumers_in_millions,
count(distinct c.customer_id)
from city as ci
join customers as c 
on ci.city_id=c.city_id
group by ci.city_name,ci.population 

6. --Top Selling Products by City**  
   --What are the top 3 selling products in each city based on sales volume?
   select*
   from
   (select ci.city_name,p.product_name,count(s.sale_id) as total_orders,
   dense_rank()over(partition by ci.city_name order by count(s.sale_id)desc) as rank
   from products as p 
   join sales as s on p.product_id=s.product_id
   join customers as c on s.customer_id=c.customer_id
   join city as ci on c.city_id=ci.city_id group by ci.city_name,p.product_name)
   as t1
   where rank<=3


   7. --Customer Segmentation by City**  
   --How many unique customers are there in each city who have purchased coffee products?
   select ci.city_name,count(distinct c.customer_id) as unique_cx
   from city as ci join customers as c on ci.city_id=c.city_id 
   join sales as s on s.customer_id=c.customer_id
   where s.product_id in (1,2,3,4,5,6,7,8,9,10,11,12,13,14)
   group by 1 order by 2 desc


   8. --Average Sale vs Rent**  
   --Find each city and their average sale per customer and avg rent per customer
select ci.city_name,sum(s.total) as total_revenue,
count(distinct c.customer_id) as unique_cx,sum(estimated_rent) as total_rent,
round(sum(s.total)::numeric/count(distinct c.customer_id)::numeric,2) as avg_sale_per_cx, 
round(sum(estimated_rent)::numeric/count(distinct c.customer_id)::numeric,2) avg_rent_per_cx from city as ci 
join customers as c on ci.city_id=c.city_id
join sales as s on c.customer_id=s.customer_id group by 1 ;  

with city_table as
(select ci.city_name,sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)::numeric/count(distinct s.customer_id)::numeric,2) as avg_sale_per_cx
from sales as s
join customers as c on s.customer_id=c.customer_id
join city as ci on c.city_id=ci.city_id
group by ci.city_name order by 2 desc
),
city_rent as
(select city_name,estimated_rent from city 
)
select cr.city_name,cr.estimated_rent,
ct.total_cx,
ct.avg_sale_per_cx,
round(cr.estimated_rent::numeric/ct.total_cx::numeric,2) as avg_rent_per_cx
 from city_rent as cr
 join city_table as ct 
 on cr.city_name=ct.city_name
 order by 4 desc


 9. --Monthly Sales Growth**  
   --Sales growth rate: Calculate the percentage growth (or decline) in sales over different time periods (monthly).
with monthly_sales as 
(select ci.city_name,
extract(month from s.sale_date) as month,
extract(year from s.sale_date) as year,
sum(s.total) as total_sale 
from sales as s 
join customers as c
on s.customer_id=c.customer_id
join city as ci on c.city_id=ci.city_id
group by 1,2,3
order by 1,3,2
),
growth_ratio as
(
select
city_name, month,year,total_sale as cr_month_sale,
lag(total_sale,1)over(partition by city_name order by year,month) as last_month_sale
from monthly_sales
)

select city_name,month,year,
cr_month_sale,
last_month_sale,
round((cr_month_sale-last_month_sale)::numeric/last_month_sale::numeric*100,2) as growth_ratio
from growth_ratio
where last_month_sale is not null



10. --Market Potential Analysis**  
    --Identify top 3 city based on highest sales, return city name, total sale, total rent, total customers, estimated  coffee consumer
    
with city_table as
(select ci.city_name,sum(s.total) as total_revenue,
count(distinct s.customer_id) as total_cx,
round(sum(s.total)::numeric/count(distinct s.customer_id)::numeric,2) as avg_sale_per_cx
from sales as s
join customers as c on s.customer_id=c.customer_id
join city as ci on c.city_id=ci.city_id
group by ci.city_name order by 2 desc
),
city_rent as
(select city_name,
round((population*.25)/1000000,2) as estimated_coffee_consumers_in_millions,
estimated_rent from city 
)
select cr.city_name,
ct.total_revenue,
cr.estimated_rent as total_rent,
ct.total_cx,
cr.estimated_coffee_consumers_in_millions,
ct.avg_sale_per_cx,
round(cr.estimated_rent::numeric/ct.total_cx::numeric,2) as avg_rent_per_cx
 from city_rent as cr
 join city_table as ct 
 on cr.city_name=ct.city_name
 order by 2 desc
/*
--recommendations
city_1 : pune
avg rent per cx is very less ,
highest total revenue,
avg sale per cx is also high 

city_2: jaipur
highest cx no 69
avg rent per cx is very less 156
avg sale per cx is better which at 11.6k 

city_3 : chennai
Second highest avg sal per cx 22479.05 
Total cx 42
avg rent per cx 407(under 500)  
