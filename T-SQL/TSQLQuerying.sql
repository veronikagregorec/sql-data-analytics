use AdventureWorks2022;

-- Triggers
select 
	*
from HumanResources.Shift

create trigger Demo_Trigger
on HumanResources.Shift
-- after/before insert/update/delete
after insert
as
begin
	print 'insert is not allowed.'
	rollback transaction
end
go

insert into HumanResources.Shift(Name, StartTime, EndTime, ModifiedDate)
values ('Janez', '09:00:00.0000000', '19:00:00.0000000', '2009-04-30 00:00:00.000')

-- Database level trigger
create trigger DB_LevelTrigger
on database
after create_table
as 
begin
	print 'creation of nre tables are not allowed'
	rollback transaction
end
go

create table DemoTable (Coll varchar(10))


-- Stored Precedure
create procedure Test_Proc
as
set nocount on
-- set nocount off
select * from HumanResources.Shift

exec Test_Proc;

-- drop procedure Test_Proc


create procedure Param_Proc
@Param_Name varchar(50)
-- @Param_Name varchar(50) = 'Evening'
as
select * from HumanResources.Shift
where Name = @Param_Name

exec Param_Proc @Param_Name = 'Day'
-- exec Param_Proc @Param_Name


create procedure output_param
@topShift varchar(50) output
as
set @topShift = (select top(1) ShiftID from HumanResources.Shift)

declare @outputResult varchar(50)
exec output_param @outputResult output
select @outputResult


-- User defined functions
select * from Sales.SalesTerritory

create function YTDSales()
returns int
as
begin
	declare @fun int
	select @fun = sum(SalesYTD) from Sales.SalesTerritory
	return @fun
end

declare @funresult as int
select @funresult = dbo.YTDSales()
print @funresult

drop function YTDSales


create function YTDGroup(@group varchar(50))
returns int
as
begin
	declare @param as int
	select @param = sum(SalesYTD) from Sales.SalesTerritory where [Group] = @group
	return @param
end

declare @result int
select @result = dbo.YTDGroup('North America')
print @result


create function table_value(@id int)
returns table
as return
select Name, CountryRegionCode, [Group], SalesYTD from Sales.SalesTerritory 
where TerritoryID = @id

select * from dbo.table_value(7)


-- Transacitions & try and catch
select * from Sales.SalesTerritory

begin transaction
	update Sales.SalesTerritory
	set CostYTD = 1.00
	where TerritoryID = 1
commit transaction


begin try
	begin transaction
		update Sales.SalesTerritory
		set CostYTD = 2.00
		where TerritoryID = 7
	commit transaction
end try

begin catch
	print 'Catch statment entered'
	rollback transaction
end catch


-- CTE
select * from Sales.SalesTerritory

with CTE_Sales
as
(
	select Name, CountryRegionCode from Sales.SalesTerritory
)

select Name from CTE_Sales where CountryRegionCode like 'US'


-- Grouping sets
select Name, CountryRegionCode, [Group], sum(SalesYTD) as SumSalesYTD
from Sales.SalesTerritory
group by grouping sets
(
	(Name),
	(Name, CountryRegionCode),
	(Name, CountryRegionCode, [Group])
)


-- Cube
select Name, CountryRegionCode, [Group], sum(SalesYTD) as SumSalesYTD
from Sales.SalesTerritory
group by cube --rollup
(
	(Name, CountryRegionCode, [Group])
)


-- Ranking
select
	PostalCode,
	ROW_NUMBER() over(order by PostalCode) as RowNumber,
	RANK() over(order by PostalCode) as RankPostalCode,
	DENSE_RANK() over(order by PostalCode) as DenseRankPostalCode,
	NTILE(10) over(order by PostalCode) as NtilePostalCode
from Person.Address
where PostalCode in ('98052', '98027', '98055', '97355')


-- Dynamic query
declare @sqlstring varchar(2000)
set @sqlstring = 'select CountryRegionCode, [Group], '
set @sqlstring = @sqlstring + 'SalesYTD from Sales.SalesTerritory'

print @sqlstring
exec (@sqlstring)