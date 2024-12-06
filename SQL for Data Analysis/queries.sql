show tables;
desc sales;

select SaleDate, Amount, Boxes, amount / boxes as PerBox 
from sales;

select * from sales
where GeoID='g1'
order by PID, Amount desc;

select * from sales
where Amount > 10000 and SaleDate >= '2022-01-01';

select SaleDate, Amount 
from sales
where Amount > 10000 and year(SaleDate) = 2022
order by Amount desc;

select * from sales
where Boxes between 1 and 5;

select SaleDate, Amount, Boxes, weekday(SaleDate) as 'Week'
from sales where weekday(SaleDate) = 4;

select * from people
where team = 'Delish' or 'Juices';

select * from people
where salesperson like '%B%';

select * from sales;

select SaleDate, Amount,
case 
	when amount < 1000 then 'Under 1k'
    when amount < 500 then 'Under 5k'
	else '10k or more'
end as 'Amount category'
from sales;

# Joins
select s.SaleDate, s.Amount, p.Salesperson, s.spid
from sales s
join people p
on s.SPID = p.SPID;

select s.SaleDate, s.Amount, s.PID
from sales s
left join products pr
on pr.PID = s.PID;

select s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
from sales s
join people p on s.SPID = p.SPID
join products pr on pr.PID = s.PID
where s.Amount < 500
and p.Team = 'Delish';

select s.SaleDate, s.Amount, p.Salesperson, pr.Product, p.Team
from sales s
join people p on s.SPID = p.SPID
join products pr on pr.PID = s.PID
join geo g on g.geoid = s.geoid
where s.Amount < 500
and p.Team = '' 
and g.Geo in ('New Zeland', 'UK')
order by saleDate;

select geoID, sum(Amount), avg(amount), sum(boxes)
from sales
group by geoID
having sum(Amount) > 7350000
order by geoID;

select g.geo, sum(Amount), avg(amount), sum(boxes)
from sales s
join geo g on s.geoID = g.geoID
group by g.geoID;

select pr.category, p.team, sum(boxes), sum(Amount)
from sales s
join people p on p.spid = s.spid
join products pr on pr.pid = s.pid
where p.team <> ''
group by pr.category, p.team
order by pr.category, p.team;

select pr.Product, sum(s.Amount) as 'Total Aount'
from sales s
join products pr on pr.pid = s.pid
group by  pr.Product
order by sum(s.Amount) desc limit 10;