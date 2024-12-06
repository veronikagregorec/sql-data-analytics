use SalesDB;

-- Find the total sales for each product
-- Additionally provide details such order id, order date
select ProductID, OrderDate, OrderID,
	   SUM(Sales) OVER(PARTITION BY ProductID) as TotalSalesByProducts
from Sales.Orders

-- Find the total sales across all orders 
-- Find the total sales all orders
-- Find the total sales each product
-- Additionally provide details such order id, order date
select ProductID, OrderID, OrderDate, Sales, OrderStatus,
       SUM(Sales) OVER() as TotalSales, 
	   SUM(Sales) OVER(PARTITION BY ProductID) as TotalSalesByProducts,
	   SUM(Sales) OVER(PARTITION BY ProductID, OrderStatus) as SalesByProductsAndStatus
from Sales.Orders
order by SUM(Sales) OVER(PARTITION BY ProductID) desc

-- Rank each order based on their sales form highest to lowest
-- Additionally provide details such order id, order date
select OrderID, OrderDate, Sales,
	  RANK() OVER(ORDER BY Sales DESC) as RankSales
from Sales.Orders

-- Frame Clause
select OrderID, OrderDate, OrderStatus, Sales,
	  SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate
	  ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING) as TotalSales
from Sales.Orders

select OrderID, OrderDate, OrderStatus, Sales,
	  SUM(Sales) OVER(PARTITION BY OrderStatus ORDER BY OrderDate
	  ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as TotalSales
from Sales.Orders

-- Find the total number of orders 
-- Find the total sales for each customers
-- Additionally provide details such order id, order date
select OrderID, OrderDate, CustomerID,
	  Count(*) OVER() as TotalOrders,
	  Count(*) OVER(PARTITION BY CustomerID) as OrdersByCustomers
from Sales.Orders

-- Find the total number of customers: * = 1
-- Find the total numbers of scores for customers
-- Additionally provide customers details
select *,
	  COUNT(*) OVER() TotalCustomers,
	  COUNT(Score) OVER() TotalScores
from Sales.Customers

-- Check for duplicates
select OrderID,
COUNT(*) OVER(PARTITION by OrderID) as CheckPKey
from Sales.Orders

-- Count
select * from (
	select OrderID,
	COUNT(*) OVER(PARTITION by OrderID) as CheckPKey
	from Sales.OrdersArchive
) as t where CheckPKey > 1

-- Find the percentage
select OrderID, ProductID, Sales,
SUM(Sales) OVER() as TotalSales,
ROUND (CAST (Sales as FLOAT) / SUM(Sales) OVER() * 100,2) as PercetnageOfTotal
from Sales.Orders

-- Find the average scores of customers
-- Additionally provide details such CustmoerID, and LastName
select 
CustomerID,LastName, Score,
	-- replace NULL with 0
	COALESCE(Score, 0) as CustomerScore,
	AVG(COALESCE(Score, 0)) OVER() as AvgWithoutNull,
	AVG(Score) OVER() as AvgScore
from Sales.Customers

-- Find the highest and lowest sales of orders
-- Find the highest and lowest sales for each product
-- Additionally provide details such order id and order date
select OrderID, OrderDate, ProductID, Sales,
	-- replace NULL with 0
	MAX(Sales) OVER() as HighestSales,
	MIN(Sales) OVER() as LowestSales,
	MAX(Sales) OVER(PARTITION BY ProductID) as HighestSalesByProduct,
	MIN(Sales) OVER(PARTITION BY ProductID) as LowestSalesByProduct,
	Sales - MIN(Sales) OVER() as DeviFromMin,
	MAX(Sales) OVER() - Sales as DeviFromMax
from Sales.Orders

-- Highest salary for eployees
select * from
(select *,
	MAX(Salary) OVER() as HighSalary
from Sales.Employees) as t where Salary = HighSalary

--Rank from highest to lowest
select OrderID, productID, Sales,
	ROW_NUMBER() OVER(ORDER BY Sales DESC) as SalesRank_Row,
	RANK() OVER(ORDER BY Sales DESC) as SalesRank_Rank,
	DENSE_RANK() OVER(ORDER BY Sales DESC) as SalesRank_Dense
from Sales.Orders

-- Find the top highest sales for each product
select * from (
select OrderID, ProductID, Sales,
	ROW_NUMBER() OVER(PARTITION BY ProductID ORDER BY Sales DESC) as RankByProducts
from Sales.Orders) as t where RankByProducts = 1

-- NTILE
-- Bucket Size = Number of Rows / Number of Buckets (Bucket Size = Bucket Gruop)
select OrderID, Sales,
	NTILE(1) OVER (ORDER BY Sales DESC) as OneBucket,
	NTILE(2) OVER (ORDER BY Sales DESC) as TwoBucket,
	NTILE(3) OVER (ORDER BY Sales DESC) as ThreeBucket,
	NTILE(4) OVER (ORDER BY Sales DESC) as FourBucket
from Sales.Orders

-- Segment all orders into high, medium, low slaes categories
select *, 
	case when Buckets = 1 then 'High'
		 when Buckets = 2 then 'Medium'
		 when Buckets = 3 then 'Low'
	end SalesSegmentations
from (
select OrderID, Sales,
	NTILE(3) OVER (ORDER BY Sales DESC) as Buckets
from Sales.Orders) as t

-- Find the products that fall within the higest 40% of the price
select *, 
	CONCAT(DistRank * 100, '%') as DiskRankPerc 
from(
select Product, Price,
	CUME_DIST() OVER(ORDER BY Price DESC) as DistRank
from Sales.Products) as t where DistRank <= 0.4