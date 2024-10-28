--BASICS

create table EmployeeDemographics (
	EmployeeID int,
	FirstName varchar(50),
	LastName varchar(50),
	Age int,
	Gender varchar(50)
)

create table EmployeeSalary
(
	EmployeeID int,
	JobTitle varchar(50),
	Salary int
)

insert into EmployeeDemographics values 
(1001,'Jim', 'Halpert', 30, 'Male'),
(1002,'Pam', 'Beasley', 30, 'Female'),
(1003,'Dwight', 'Shrute', 29, 'Male'),
(1004,'Angela', 'Martin', 31, 'Female'),
(1005,'Toby', 'Fienderson', 32, 'Male'),
(1006,'Michael', 'Scott', 35, 'Female'),
(1007,'Meredith', 'Palmer', 32, 'Male'),
(1008,'Stanley', 'Hudson', 38, 'Female'),
(1009,'Kevin', 'Malone', 31, 'Male')

insert into EmployeeSalary values 
(1001, 'Salesman', 45000),
(1002, 'Receptionist', 36000),
(1003, 'Salesman', 63000),
(1004, 'Accountant', 47000),
(1005, 'HR', 50000),
(1006, 'Regional Manager', 65000),
(1007, 'Supplier Relations', 41000),
(1008, 'Salesman', 48000),
(1009, 'Accountant', 42000)

select * 
from EmployeeDemographics

select * 
from EmployeeSalary

select top 5 * 
from EmployeeDemographics

select distinct(Gender) 
from EmployeeDemographics

select max(Salary) as [Max Salary], 
	   min(EmployeeID) as [Min ID], 
	   count(JobTitle) as [Job Title],
	   avg(Salary) as [Average Salary],
	   sum(Salary) as [Sum of Salary]
from EmployeeSalary

select * 
from EmployeeDemographics
where FirstName <> 'Jim' and Age >= 30

select * 
from EmployeeDemographics 
where LastName like '%s%_e'

select * 
from EmployeeDemographics 
where FirstName in ('Jim', 'Pam')

select * 
from EmployeeDemographics 
order by Age DESC

select Gender, count(Gender) as CountGender 
from EmployeeDemographics
where Age > 31
group by Gender

--INTERMEDIATE

select empDem.EmployeeID, empSal.Salary 
from EmployeeDemographics as empDem
inner join EmployeeSalary as empSal
on empDem.EmployeeID = empSal.EmployeeID

select * 
from EmployeeDemographics
full outer join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

select * 
from EmployeeDemographics
left outer join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

select EmployeeDemographics.EmployeeID, FirstName, LastName, Salary 
from EmployeeDemographics
inner join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
where FirstName <> 'Michael'
order by Salary DESC

select JobTitle, avg(Salary) as [Average Salary]
from EmployeeDemographics
inner join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
where JobTitle = 'Salesman'
group by JobTitle

select * 
from EmployeeDemographics
union
select * 
from EmployeeSalary
order by EmployeeID

select FirstName, LastName, Age,
case
	when Age = 38 then 'Stanley'
	when Age > 30 then 'Old'
	when Age between 27 and 30 then 'Young'
	else 'Baby'
end as Text
from EmployeeDemographics
where Age is not null
order by Age

select FirstName, LastName, JobTitle, Salary,
case
	when JobTitle = 'Salesman' then Salary + (Salary * .10)
	else Salary + (Salary * .03)
end as SalaryAfterRaise
from EmployeeDemographics
inner join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID

select JobTitle, count(JobTitle) as CountJobTitle
from EmployeeDemographics
inner join EmployeeSalary 
on EmployeeDemographics.EmployeeID = EmployeeSalary.EmployeeID
group by JobTitle
having count(JobTitle) > 1
order by JobTitle

update EmployeeDemographics
set EmployeeID = 1012 
where FirstName = 'Holly' and LastName = 'Flax'

update EmployeeDemographics
set Age = 31, Gender = 'Female'
where FirstName = 'Holly' and LastName = 'Flax'

delete from EmployeeDemographics 
where EmployeeID = 1012

--ADVANCED

--CTEs are not stored on disk
with CTE_Emplyee as
(
	select * from EmployeeDemographics
)
select * from CTE_Emplyee

--temporary tables are stored on disk
create table #temp_employee(
	JobTitle varchar(50),
	Age int, 
	Salary int
)

DROP TABLE IF EXISTS #temp_employee
Create table #temp_employee (
	JobTitle varchar(50),
	Age int, 
	Salary int
)

Insert into #temp_employee
SELECT JobTitle, Count(JobTitle), Avg(Age), AVG(Salary)
FROM EmployeeDemographics emp
JOIN EmployeeSalary sal
	ON emp.EmployeeID = sal.EmployeeID
group by JobTitle

select * from #temp_employee

-- String Functions

--Trim
select EmployeeID, TRIM(EmployeeID) as IDTrim 
from EmployeeDemographics

--Replace
Select LastName, REPLACE(LastName, '- Fired', '') as LastNameFixed 
from EmployeeDemographics

--Substring
Select LastName, SUBSTRING(FirstName, 1,3) as FirstNameSb
from EmployeeDemographics

--Upper and lower
Select LastName, UPPER(FirstName) as Upper, LOWER(LastName) as lower
from EmployeeDemographics

--Stored Procedures
create procedure Test
as
Select * 
from EmployeeDemographics

exec Test

--Subqueries
select FirstName, (select avg(Age) from EmployeeDemographics) as AvgAge
from EmployeeDemographics

select FirstName, LastName
from EmployeeDemographics
where EmployeeID in 
	(select EmployeeID
	from EmployeeDemographics)
