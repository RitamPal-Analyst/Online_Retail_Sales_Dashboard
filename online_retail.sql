create database online_retail_db;

use online_retail_db;

create table retail(
InvoiceNo text,
StockCode text,
Description text,
Quantity int,
InvoiceDate	text,
UnitPrice double,
CustomerID text,
Country	text,
Revenue double
);

select * from retail;

alter table retail
add column Invoice_Date Date;

update retail
set Invoice_Date = str_to_date(InvoiceDate,"%d-%m-%Y");

alter table retail
drop column InvoiceDate; 

SELECT *
FROM retail
WHERE customerID IS NULL OR customerID = '';

set sql_safe_updates = 0;

DELETE FROM retail
WHERE customerID IS NULL OR customerID = '';

-- Total Revenue
select round(sum(Revenue),2) as total_revenue
from retail;

-- What are the top 10 best-selling products by quantity sold?
select description,sum(quantity) as Total_Quantity
from retail
group by Description
order by Total_Quantity desc
limit 10;

-- Which customers have the highest total spend?

select CustomerID,round(sum(Revenue),2) as Total_Spend
from retail
group by CustomerId
order by Total_Spend desc
limit 10;

-- What is the total revenue by month or by quarter?
select month(Invoice_Date) as Month,Round(sum(Revenue),2) as Revenue
from retail
group by month(Invoice_Date)
order by month(Invoice_Date);


-- Which countries generate the most sales revenue?

select country,Round(sum(Revenue),2) as revenue
from retail
group by country
Order by Revenue desc
limit 10;

-- What is the average order value per customer?

select Round(sum(revenue)/count(CustomerID),2) as Avg_orderValue_per_customer
from retail;

-- How many orders come from repeat customers versus new customers?

SELECT customerID, COUNT(InvoiceNo) AS OrderCount
FROM retail
GROUP BY customerID
HAVING OrderCount > 1;  -- Repeat customers

-- What is the revenue distribution by product category?

select Description,Round(Sum(Revenue),2) as revenue
from retail
group by Description
order by revenue desc;

-- Which months have the highest or lowest sales, showing seasonality?

Select monthname(Invoice_date) as Month,Round(sum(Revenue),2) as Sales
from retail
group by monthname(Invoice_date)
Order By sales desc;

-- What is the percentage of revenue from the top 20% of customers (like a Pareto analysis)?

WITH CustomerRevenue AS (
    SELECT customerID,
           SUM(Revenue) as Revenue
    FROM retail
    GROUP BY customerID
),
RankedCustomers AS (
    SELECT customerID,
           Revenue,
           SUM(Revenue) OVER () AS TotalRevenue,
           SUM(Revenue) OVER (ORDER BY Revenue DESC ROWS UNBOUNDED PRECEDING) AS CumulativeRevenue,
           Revenue * 1.0 / SUM(Revenue) OVER () AS RevenuePercent,
           SUM(Revenue) OVER (ORDER BY Revenue DESC ROWS UNBOUNDED PRECEDING) * 1.0 / SUM(Revenue) OVER () AS CumulativePercent
    FROM retail
)
SELECT customerID, Revenue, Round(RevenuePercent,2) as RevenuePercent, Round(CumulativePercent,2) as CumulativePercent
FROM RankedCustomers
WHERE CumulativePercent <= 0.20;

 -- Which products have declining sales over time?

SELECT Description, Month(Invoice_Date) AS Month, SUM(Quantity) AS MonthlySales
FROM retail
GROUP BY Description, Month
ORDER BY Description, Month;