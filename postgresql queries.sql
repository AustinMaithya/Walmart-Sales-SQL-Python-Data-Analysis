select * from  walmart;
select  count(*) from walmart ;
select
  payment_method ,
  count(*)
  
from walmart
group by payment_method;

select count(distinct branch) 
from walmart;




select max(quantity)
from walmart;


--Business Problem 
-- Q1 Find different payment methods and number of transactions, number of quantity sold 

select distinct payment_method as payment_method,
       count(payment_method) as number_of_transactions,
       sum(quantity) as number_of_quantity_sold 
from walmart
group by payment_method
order by number_of_quantity_sold desc;

-- Q2 Identify the Highest-Rated Category in Each Branch,dispaying branch,category and avg ranking

select *
from
   ( select 
   branch,
   category,
   avg(rating) as avg_rating,
   rank() over(partition by branch order by avg(rating) desc ) as rank
from walmart
group by 1,2
   )
where rank = 1;



-- Q3 Identify the busiest day for each branch based on number of transactions 
select * 
from 
    (select  
    branch, 
    to_char(to_date(date,'DD/MM/YY'),'Day' )as day_name,
    count(*) as no_of_transactions,
    rank() over(partition by branch order by count(*) desc) as rank
  from walmart
  group by branch,day_name
  

)
where rank = 1; 


 -- Q4  Calculate the total quantity of items sold per payment method.List payment_method and total_quantity

 select payment_method,
    sum(quantity) as total_quantity
from walmart
group by payment_method;
    

  -- Q5 determine the average,minimum and maximum rating of category  in each city
  --list  city,avg_rating,min_rating,max_rating 

  select city,
    category,
    min(rating)as min_rating,
    max(rating) as max_rating,
    avg(rating) as avg_rating
from walmart
group by 1,2;

-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total*quantity) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH cte 
AS
(SELECT 
	branch,
	payment_method,
	COUNT(*) as total_trans,
	RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as rank
FROM walmart
GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE rank = 1


-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT
	branch,
CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC

-- 
-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) as formated_date
FROM walmart

-- 2022 sales
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5