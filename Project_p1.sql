-- SQL Retail Sales Analysis - P1

-- Create Table
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
		(
			transactions_id	INT PRIMARY KEY,
			sale_date DATE,
			sale_time TIME,
			customer_id	INT,
			gender VARCHAR(10),
			age	INT,
			category VARCHAR(15),
			quantity INT,
			price_per_unit FLOAT,
			cogs FLOAT,
			total_sale FLOAT
		);

SELECT *
FROM retail_sales
LIMIT 100;

-- Data Cleaning
SELECT COUNT(*)
FROM retail_sales;

DELETE FROM retail_sales
WHERE transactions_id IS NULL
	OR
	sale_date IS NULL
	OR
	sale_time IS NULL
	OR
	customer_id IS NULL
	OR
	gender IS NULL
	OR
	category IS NULL
	OR
	quantity IS NULL
	OR
	price_per_unit IS NULL
	OR
	cogs IS NULL
	OR
	total_sale IS NULL;

-- Data Exploration

-- How many sales we have?
SELECT COUNT(*) AS total_sale
FROM retail_sales;

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- How many unique categories we have?
SELECT COUNT(DISTINCT category) AS unqiue_categories
FROM retail_sales;

-- Data Analysis & Business Key Problems and Answers

-- Q.1 Write a SQL query to retrieve all records for sales made on 2022-11-05

SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is atleast 4 in the month of Nov-2022

SELECT *
FROM retail_sales
WHERE 
	category = 'Clothing'
	AND 
	TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
	AND
	quantity >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT 
	category, 
	COUNT(*) AS total_orders,
	SUM(total_sale) AS net_sale
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category

SELECT 
	ROUND(AVG(age), 2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT *
FROM retail_sales
WHERE total_sale > 1000;

-- Q.6 Write a SQL query to find the total number of transactions (transactions_id) made by each gender in each category.

SELECT 
	category, 
	gender, 
	COUNT(*) AS transactions
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best (avg) selling month in each year.

SELECT
	TO_CHAR(sale_date, 'YYYY-MM') AS month,
	AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY 1
ORDER BY 1;

SELECT DISTINCT ON (year)
    EXTRACT(YEAR FROM sale_date) AS year,
	EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

SELECT 
		year,
		month,
		avg_sale
FROM (
	SELECT
    	EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month,
        ROUND(CAST(AVG(total_sale) AS numeric), 3) AS avg_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY AVG(total_sale) DESC) AS RANK
	FROM retail_sales
	GROUP BY 1, 2
) AS t1
WHERE RANK = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales

SELECT
	customer_id,
	SUM(total_sale) AS customers_total_sale
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY 1;

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <= 12, Afternoon Between 12 and 17, Evening > 17)

SELECT
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	COUNT(*) AS number_of_orders
FROM retail_sales
GROUP BY 1;

-- Using CTE method

WITH hourly_sales 
AS
(
	SELECT
	CASE
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift
	FROM retail_sales
)
SELECT 
	shift, 
	COUNT(*) AS number_of_orders
FROM hourly_sales
GROUP BY 1;

-- Find the number of transactions by gender:

SELECT 
	gender, 
	COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY 1;

-- Find the average total_sale by product category:

SELECT 
	category, 
	ROUND(AVG(total_sale)::numeric, 2) AS avg_sale
FROM retail_sales
GROUP BY category;

-- Find the top 3 customers who spent the most:

SELECT 
	customer_id, 
	SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Identify which gender spends the most on average:

SELECT 
	gender, 
	ROUND(AVG(total_sale)::numeric, 2) AS avg_spent
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Find the month with the highest total sales:

SELECT 
	TO_CHAR(sale_date, 'YYYY-MM') AS "year-month",
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Calculate profit (total_sale - cogs*quantity) for each transaction:

SELECT 
	*, 
	(total_sale - cogs*quantity) AS profit
FROM retail_sales;

-- Which age group (e.g., 31-40, 41-50) spends the most?

SELECT 
	CASE 
		WHEN age < 20 THEN 'Less than 20'
		WHEN age BETWEEN 21 AND 30 THEN '21-30'
	    WHEN age BETWEEN 31 AND 40 THEN '31-40'
	    WHEN age BETWEEN 41 AND 50 THEN '41-50'
		WHEN age BETWEEN 51 AND 60 THEN '51-60'
	    ELSE 'Other'
	END AS age_group, 
SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC;

-- Find the customer with the most repeated purchases:

SELECT
	customer_id, 
	COUNT(*) AS purchase_count
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;


---- END OF PROJECT ----