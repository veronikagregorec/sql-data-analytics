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


-- Analyze the month-over-month preformance by finding the percentage change
-- in sales between the current and previous months
select *, CurrentMonthSales - PrevMontSales as MoM_Change, 
ROUND(CAST((CurrentMonthSales - PrevMontSales) as float) / PrevMontSales * 100, 1) as MoM_Perc
from
(
select 
	MONTH(OrderDate) as OrderMonth,
	Sum(Sales) as CurrentMonthSales,
	LAG(SUM(Sales)) OVER (order by MONTH(OrderDate)) as PrevMontSales
from Sales.Orders
group by MONTH(OrderDate)) as t 


-- In order to analyze customer loyality, 
-- rank customers based on the average days between their orders
select 
	CustomerID,
	AVG(DaysUntilNextorder) as AvgDays,
	RANK() over(order by AVG(DaysUntilNextorder)) as RankAvg
from(
select 
	OrderID, 
	CustomerID, 
	OrderDate as CurrentDate,
	LEAD(OrderDate) over (partition by CustomerID Order by OrderDate) as NextOrder,
	DATEDIFF(day, OrderDate, LEAD(OrderDate) over (partition by CustomerID Order by OrderDate)) as DaysUntilNextorder
from Sales.Orders ) as t
group by CustomerID


-- Find the lowest and the higest sales for each product
select 
	OrderID,
	ProductID,
	Sales,
	FIRST_VALUE(Sales) over(partition by ProductID order by Sales) as LowestSales,
	-- LAST_VALUE(Sales) over(partition by ProductID order by Sales
	-- rows between current row and unbounded following) as HigheststSales,
	FIRST_VALUE(Sales) over(partition by ProductID order by Sales desc) as LowestSales
from Sales.Orders


-- Combine the data from employees and customers into one table
select 
	FirstName as First_Name,
	LastName as Last_Name
from Sales.Customers
-- union
-- union all
-- except
intersect
select 
	FirstName,
	LastName
from Sales.Employees
order by First_Name


-- Showing total sales for each category - High, Medium and Low
select 
	Category, 
	Sum(Sales) as TotalSales 
from (
select 
	OrderID, 
	Sales,
	case
		when Sales > 50 then 'High'
		when Sales > 20 then 'Medium'
		else 'Low'
	end as Category
from Sales.Orders) as t
group by Category
order by TotalSales desc


-- Dates
select 
	OrderID,  
	CreationTime,
	GETDATE() as Today,
	YEAR(CreationTime) as YearDate,
	MONTH(CreationTime) as MOnthDate,
	DAY(CreationTime) as DayDate,
	--DATEPART()
	DATEPART(year, CreationTime) as Year_datpart,
	DATEPART(month, CreationTime) as Month_detapart,
	DATEPART(quarter, CreationTime) as Quarter_detapart,
	DATEPART(weekday, CreationTime) as Weekday_detapart,
	--DATENAME()
	DATENAME(month, CreationTime) as Mont_DateName,
	--DATETRUNC()
	DATETRUNC(minute, CreationTime) as Minute_DateTrunc,
	DATETRUNC(day, CreationTime) as Day_DateTrunc,
	--ENDOFMOTNH - EOMONTH()
	EOMONTH(CreationTime) as Enf_of_the_month,
	--FORMAT()	
	FORMAT(CreationTime, 'dddd.MMMM.yyyy') as FormatDate,
	--CAST()
	CAST(CreationTime as date) as DateCast,
	--DATEDIFF()
	DATEDIFF(day, OrderDate, ShipDate) as DaysOrderAndShip
from Sales.Orders


-- Subqueries
-- select (only 1 value)
select 
	ProductID, 
	Product, 
	Price,
	(select count(*) from Sales.Orders) as TotalOrders
from Sales.Products;


-- join
select 
	c.*, 
	o.TotalOrders 
from Sales.Customers c
left join (
	select CustomerID, COUNT(*) TotalOrders
	from Sales.Orders group by CustomerID
	) as o
on c.CustomerID = o.CustomerID;


-- where
select 
	ProductID, 
	Price 
from Sales.Products
where Price > (select AVG(Price) from Sales.Products)


-- in (list of multiple values), any, all
select *
from Sales.Orders
where CustomerID in (select CustomerID from Sales.Customers where Country != 'Germany')


-- Correlated subquery
select 
	*, 
	(select COUNT(*) from Sales.Orders o where o.CustomerID = c.CustomerID) as TotalSales
from Sales.Customers c


-- CTE
-- None-Recursive CTE
with CTE_Total_Sales as 
(
select 
	CustomerID, 
	SUM(Sales) as TotalSales
from Sales.Orders
group by CustomerID
), 

CTE_Last_Order as 
(
	select CustomerID, 
		   MAX(OrderDate) as Last_Order
		   from Sales.Orders
		   group by CustomerID
)

-- main query
select 
	c.CustomerID, 
	c.FirstName, 
	c.LastName, 
	cts.TotalSales,
	clo.Last_Order
from Sales.Customers c
left join CTE_Total_Sales cts on cts.CustomerID = c.CustomerID
left join CTE_Last_Order clo on clo.CustomerID =  c.CustomerID
order by CustomerID desc


-- Recursive CTE
with Series as (
select
	1 as mynumber
union all
select 
	mynumber + 1
from Series
where mynumber < 20
)

--main query
select * 
from Series
--option (maxrecursion 10)

-- Example 2
with CTE_Emp_Hierarchy as
(
	select 
		EmployeeID, 
		FirstName, 
		ManagerID, 
		1 as level
	from Sales.Employees
	where ManagerID is null
	union all
	select
		e.EmployeeID,
		e.FirstName,
		e.ManagerID,
		level + 1
	from Sales.Employees as e
	inner join CTE_Emp_Hierarchy ceh on e.ManagerID = ceh.EmployeeID
)

select * from CTE_Emp_Hierarchy


-- View
-- Find the running total of sales for each month
if OBJECT_ID(' Sales.V_Monthly_Summery', 'V') is not null
	drop view Sales.V_Monthly_Summery;
go

create view Sales.V_Monthly_Summery as(
select 
	DATETRUNC(month, OrderDate) as OrderMonth,
	Sum(Sales) as TotalSales,
	COUNT(OrderID) as TotalOrders,
	SUM(Quantity) as TotalQuantity
from Sales.Orders
group by DATETRUNC(month, OrderDate)
)

drop view V_Monthly_Summery

select 
	OrderMonth, 
	TotalSales, 
	SUM(TotalSales) OVER(order by OrderMonth) 
from Sales.V_Monthly_Summery


-- Provide view that combines details from orders, products, customers and employees
if OBJECT_ID('Sales.V_Order_Details', 'V') is not null
	drop view Sales.V_Order_Details;
go

create view Sales.V_Order_Details as(
select 
	o.OrderID,
	o.OrderDate,
	o.Sales,
	o.Quantity,
	p.Product,
	p.Category,
	coalesce(c.FirstName, '') + ' ' + coalesce(c.LastName, '') as CustomerName,
	c.Country as CustomerCountry,
	coalesce(e.FirstName, '') + ' ' + coalesce(e.LastName, '') as SalesName,
	e.Department
from Sales.Orders o
left join Sales.Products p
on p.ProductID = o.ProductID
left join Sales.Customers c
on c.CustomerID = o.CustomerID
left join Sales.Employees e
on e.EmployeeID = o.SalesPersonID
where c.Country != 'USA'
)

select * from Sales.V_Order_Details


-- Tables
-- CTAS, TEMP(into #TempTableName)
if OBJECT_ID('Sales.MonthlyOrders', 'U') is not null
	drop table MonthlyOrders;
go

select 
	DATENAME(month, OrderDate) OrderMonth,
	COUNT(OrderID) TotalOrders
	into Sales.MonthlyOrders
from Sales.Orders
group by DATENAME(month, OrderDate)

select * from Sales.MonthlyOrders


-- Indexes
select *
into Sales.DBCustomers
from Sales.Customers 

select * from Sales.DBCustomers

create unique clustered index idx_DBCustomers_CustomerID 
on Sales.DBCustomers (CustomerID)

create nonclustered index idx_DBCustomers_LastName
on Sales.DBCustomers (LastName)
where LastName = 'Brown'

create nonclustered index idx_DBCustomers_FirstName
on Sales.DBCustomers (FirstName)

/*create clustered columnstore index idx_ColumnStore_FirstName
on Sales.DBCustomers (FirstName)*/

drop index idx_DBCustomers_CustomerID on Sales.DBCustomers

sp_helpindex 'Sales.DBCustomers'

-- Table Partitioning
create partition function PartitionByYear(date)
as range left for values ('2023-12-31', '2024-12-31', '2025-12-31')

select * from sys.partition_functions

alter database SalesDB add filegroup FG_2023
alter database SalesDB add filegroup FG_2024
alter database SalesDB add filegroup FG_2025
alter database SalesDB add filegroup FG_2026

select * from sys.filegroups
where type = 'FG'

alter database SalesDB add file 
(
	NAME = P_2023, -- Logical name
	FILENAME = 'C:\Test\P_2023.ndf'
) to filegroup FG_2023

alter database SalesDB add file 
(
	NAME = P_2024, -- Logical name
	FILENAME = 'C:\Test\P_2024.ndf'
) to filegroup FG_2024

alter database SalesDB add file 
(
	NAME = P_2025, -- Logical name
	FILENAME = 'C:\Test\P_2025.ndf'
) to filegroup FG_2025

alter database SalesDB add file 
(
	NAME = P_2026, -- Logical name
	FILENAME = 'C:\Test\P_2026.ndf'
) to filegroup FG_2026

select * from sys.destination_data_spaces

-- Scheme
create partition scheme SchemePartitionByYear
as partition PartitionByYear
to (FG_2023, FG_2024, FG_2025, FG_2026)

select * from sys.partition_schemes

-- Create partition table
create table Sales.Orders_Partitioned(
	OrderID int,
	OrderDate date,
	Sales int
) on SchemePartitionByYear (OrderDate)

insert into Sales.Orders_Partitioned values (1, '2023-05-15', 100);
insert into Sales.Orders_Partitioned values (2, '2024-07-12', 50);
insert into Sales.Orders_Partitioned values (3, '2025-01-22', 70);
insert into Sales.Orders_Partitioned values (4, '2026-11-25', 30);


-- Stored Procedure
-- Find the total number of customers and the average score
alter procedure GetCustomerSummary @Country NVARCHAR(50) = 'USA'
as
begin
	begin try

		declare @TotalCustomers int, @AvgScores float;

		if exists(select 1 from Sales.Customers where Score is null and Country = @Country)
		begin
			print('Updating null scores to 0')
			update Sales.Customers
			set Score = 0
			where Score is null and Country = @Country
		end

		else

		begin
			print('No null scores found')
		end;

		select
			@TotalCustomers = count(*),
			@AvgScores = avg(Score)
		from Sales.Customers
		where Country = @Country;

		print 'Total customers from ' + @Country + ': '  + cast(@TotalCustomers as nvarchar);
		print 'Average score from ' + @Country + ': ' + cast(@AvgScores as nvarchar);

		-- Find the total number of orders and the total sales
		select 
			count(OrderID) TotalOrders,
			sum(Sales) TotalSales
		from Sales.Orders o
		join Sales.Customers c
		on o.CustomerID = c.CustomerID
		where c.Country = @Country;

	end try

	begin catch
		print('An error occured.');
		print('Error Message: ' + error_message());
		print('Error Number: ' + cast(error_number() as nvarchar));
		print('Error Number: ' + cast(error_line() as nvarchar));
		print('Error Procude: ' + error_procedure());
	end catch
end
go


exec GetCustomerSummary;
exec GetCustomerSummary @Country = 'Germany';

-- drop procedure GetCustomerSummary