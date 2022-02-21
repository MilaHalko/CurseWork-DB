use master
use LandCompany
go

--------------------------------------------------------------------------
--(1) Відображення загальної кількості об’єктів (складова ділянки) для кожної з ділянок
create view landsAndNumberOfObjects as
select la.ID as LandID, lo.Address as LandAddress, COUNT(*) as ObjectsNumber
from Land la
join Object o on o.FkLandID = la.ID
join Location lo on lo.ID = la.FkLocationID
group by la.ID, lo.Address
go

select * from landsAndNumberOfObjects
go

--CHECK
select Land.*, Address, FkLandID
from Land
right join Location on Location.id = Land.FkLocationID
right join Object on FkLandID = Land.ID
order by Land.ID
go


--------------------------------------------------------------------------
--(2) Відображення загальної площі усіх ділянок, що є у базі
create view totalArea as
select (select count(*) from Land) as TotalLandsQuantity, 
	   (select sum((o.LatitudeRL - o.LatitudeLU)*(o.LongtitudeRL - o.LongtitudeLU)) from Object o) as TotalArea
go

select * from totalArea
go

--All areas
select *, (o.LatitudeRL - o.LatitudeLU)*(o.LongtitudeRL - o.LongtitudeLU) as TotalArea
from Object o
order by fklandid
go


--------------------------------------------------------------------------
--(3) Відображення ділянок, власниками яких є юридичні особи
create view LegalLands as
select 
la.ID as LandID, 
n.Surname + ' ' + n.Name as Owner, le.Name as CompanyName
from Natural n
join Legal le on le.FkNaturalID = n.ID 
join Land la on la.FkOwnerID = n.ID
go

select * from LegalLands
go

--All natural + Legal company
select n.ID, n.Surname + ' ' + n.Name as Natural, l.ID as LegalID, l.Name as LegalName
from Legal l
right join Natural n on n.ID = l.FkNaturalID
go


--------------------------------------------------------------------------
--(4) Відображання ділянок,  власниками яких є фізичні особи
create view NaturalLands as
select  
n.ID as NaturalID, n.Surname + ' ' + n.Name as Natural, la.ID as LandID
from Natural n
join Land la on la.FkOwnerID = n.ID
where n.ID not in (select FkNaturalID from Legal)
go

select * from NaturalLands
order by NaturalID
go


--------------------------------------------------------------------------
--(5) Відображення актів, де покупець був юридична особа
create view LegalBuyers as
select 
n.ID as BuyerID, n.Surname + ' ' + n.Name as Buyer, a.id as ActID, l.ID as LegalID, l.Name as LegalName
from Natural n
join Legal l on n.ID = l.FkNaturalID
join Act a on a.FkBuyerID = n.ID
go

select * from LegalBuyers
order by BuyerID
go

--All Buyers
select 
n.ID as BuyerID, n.Surname + ' ' + n.Name as Buyer, a.id as ActID, l.ID as LegalID, l.Name as LegalName
from Natural n
full join Legal l on n.ID = l.FkNaturalID
full join Act a on a.FkBuyerID = n.ID
order by BuyerID
go


--------------------------------------------------------------------------
--(6) Відображення актів, де продавець був фізична особа
create view NaturalBuyer as
select 
n.ID as BuyerID, n.Surname + ' ' + n.Name as Buyer, a.id as ActID
from Natural n
join Act a on a.FkBuyerID = n.ID
where n.ID not in (select FkNaturalID from Legal)
go

select * from NaturalBuyer
order by BuyerID
go


--------------------------------------------------------------------------
--(7) Відображення затверджених актів за останній рік
create view lastYearActs as
select
a.ID as ActID, a.Date as RegDate, l.id
from Act a
join Land l on l.id = a.FkLandID 
where a.Date >= DATEADD(year, -1, GETDATE())
go

select * from lastYearActs
order by RegDate
go


--------------------------------------------------------------------------
--(8) Відображення ресурсів власника ділянки
create proc ResourcesbyOwnerID @ownerID int
as begin
select distinct r.Name as Resources
from Resource r
where r.ID in(select o.FkResourceID from Object o
			  where o.FkLandID in(select l.id from Land l
								  where l.FkOwnerID = @ownerID))
order by r.Name
end
go

exec ResourcesbyOwnerID 3
go

--All Naturals and their resources
select n.id, o.FkLandID, r.ID as ResID, r.Name
from Land l
join Natural n on l.FkOwnerID = n.ID
join Object o on o.FkLandID = l.id
join Resource r on r.ID = o.FkResourceID
--where n.ID = 3
order by n.ID
go


--------------------------------------------------------------------------
--(9) Відображення ділянок без інженерних комунікацій
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on FkLandID = la.id
where Plumbing = 0 and Sanitation = 0 and Heating = 0 and Gas = 0
go


--------------------------------------------------------------------------
--(10) Відображання осіб з найбільшою площею ділянки
alter proc TopOwnersByArea @topNumber int as
begin
	declare @table table(ID int, name varchar(50), area real)
	declare @id int, @name varchar(50), @surname varchar(50), @area real
	declare cur cursor local
	for select ID, Name, Surname from Natural

	open cur
	fetch next from cur into @id, @name, @surname

	while @@FETCH_STATUS = 0
	begin
		set @area = (select sum((o.LatitudeRL - o.LatitudeLU)*(o.LongtitudeRL - o.LongtitudeLU)) from Object o
					 where o.FkLandID in (select ID from Land l
										  where l.FkOwnerID = @id))
		insert into @table (ID, name, area) values (@id, @surname + ' ' + @name, @area)
		fetch next from cur into @id, @name, @surname
	end
	close cur

	select top(@topNumber) * from @table order by area desc
end
go

exec TopOwnersByArea 5
go


--------------------------------------------------------------------------
--(11) Відображення історії купівлі-продажу ділянки

--------------------------------------------------------------------------
--(12) Відображення усіх ділянок із каналізацією
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on FkLandID = la.id
where Sanitation = 1
go


--All utillity for all lands
select la.id, lo.Address, u.*
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on FkLandID = la.id
order by Sanitation desc, la.ID
go

--------------------------------------------------------------------------
--(13) Відображення ділянок, де є опалення
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on FkLandID = la.id
where Heating = 1
go


--All utillity for all lands
select la.id, lo.Address, u.*
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on FkLandID = la.id
order by Heating desc, la.ID
go


--------------------------------------------------------------------------
--(14) Запит на відображення власників ділянки із електроенергією
select la.id as LandID, n.Surname + ' ' + n.Name as Owner
from Land la
join Natural n on n.ID = la.FkOwnerID 
join Utility u on FkLandID = la.id
where Electricity = 1
go

--All utillity for all lands
select la.id, lo.Address, u.Electricity, n.Surname as Owner
from Land la
join Location lo on lo.ID = la.FkLocationID
join Natural n on n.ID = la.FkOwnerID 
join Utility u on FkLandID = la.id
order by Electricity desc, la.ID
go

--------------------------------------------------------------------------
--(15) Запит на відображення кількості ділянок із газом
select 'Full number of lands with electricity is ' + 
	   cast((select count(*) 
	   from Land l  
	   join Utility on fkLandID = l.ID
	   where Gas = 1) as varchar) as GasQuantity
go

--Gas bool for all Lands
select l.ID, Gas
from land l
join Utility on fkLandID = l.ID
order by gas desc, l.id

--------------------------------------------------------------------------
--(16) Запит на відображання ділянок у яких був лише 1 власник

--------------------------------------------------------------------------
-- (17) Запит на відображення актів затвердженими реєстратором

--------------------------------------------------------------------------
--(18) Запит на відображення суми вартості ділянок фізичних осіб

--------------------------------------------------------------------------
--(19) Запит на відображення номеру телефону продавця та його ділянки

--------------------------------------------------------------------------
--(20) Запит на відображення кількості актів проведених із ділянкою