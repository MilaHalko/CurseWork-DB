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
	   (select sum((o.LatitudeR - o.LatitudeL)*(o.LongtitudeU - o.LongtitudeD)) 
	    from Object o) as TotalArea
go

select * from totalArea
go

--CHECK
select *, (o.LatitudeR - o.LatitudeL)*(o.LongtitudeU - o.LongtitudeD) as TotalArea
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

--CHECK
select n.ID, n.Surname + ' ' + n.Name as Natural, l.ID as LegalID, l.Name as LegalName
from Legal l
right join Natural n on n.ID = l.FkNaturalID
select * from Act
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
order by LandID
go

--CHECK
select n.ID, n.Surname + ' ' + n.Name as Natural, l.ID as LegalID, l.Name as LegalName
from Legal l
right join Natural n on n.ID = l.FkNaturalID
select * from Act
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
order by ActID
go

--CHECK
select * from Act
select * from Natural n left join Legal l on l.FkNaturalID = n.ID 
go


--------------------------------------------------------------------------
--(6) Відображення актів, де продавець був фізична особа
create view NaturalSeller as
select 
n.ID as SellerID, n.Surname + ' ' + n.Name as Buyer, a.id as ActID
from Natural n
join Act a on a.FkSellerID = n.ID
where n.ID not in (select FkNaturalID from Legal)
go

select * from NaturalSeller
order by Buyer
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
where r.FkObjectID in (select ID from Object o
					   where o.FkLandID in (select ID from Land l
											where l.FkOwnerID = @ownerID))
order by r.Name
end
go

exec ResourcesbyOwnerID 3
go

--CHECK
select * from Resource order by Name
select * from Object order by ID
select * from Land order by ID
go


--------------------------------------------------------------------------
--(9) Відображення ділянок без інженерних комунікацій
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on u.ID = la.FkUtilityID
where Plumbing = 0 and Sanitation = 0 and Heating = 0 and Gas = 0 and Electricity = 0
go


--------------------------------------------------------------------------
--(10) Відображання осіб з найбільшою площею ділянки
create proc TopOwnersByArea @topNumber int 
as begin
	declare @table table(ID int, name varchar(50), area float)
	declare @id int, @name varchar(50), @surname varchar(50), @area float
	declare cur cursor local
	for select ID, Name, Surname from Natural

	open cur
	fetch next from cur into @id, @name, @surname

	while @@FETCH_STATUS = 0
	begin
		set @area = (select sum((o.LatitudeR - o.LatitudeL)*(o.LongtitudeU - o.LongtitudeD)) from Object o
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
--(11) Відображення усіх ділянок із каналізацією
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on u.ID = la.FkUtilityID
where Sanitation = 1
go


--------------------------------------------------------------------------
--(12) Відображення історії купівлі-продажу ділянки
create function HistoryByLandID (@landID int)
returns table 
as
	return (select * from Act
			where FkLandID = @landID)
go

select * from HistoryByLandID(3) order by Date
go

select * from Act order by FkLandID
go


--------------------------------------------------------------------------
--(13) Відображення ділянок, де є опалення
select la.id, lo.Address
from Land la
join Location lo on lo.ID = la.FkLocationID
join Utility u on u.ID = la.FkUtilityID
where Heating = 1
go


--------------------------------------------------------------------------
--(14) Запит на відображення власників ділянки із електроенергією
select la.id as LandID, n.Surname + ' ' + n.Name as Owner
from Land la
join Natural n on n.ID = la.FkOwnerID 
join Utility u on u.ID = la.FkUtilityID
where Electricity = 1
go


--------------------------------------------------------------------------
--(15) Запит на відображення кількості ділянок із газом
select 'Full number of lands with electricity is ' + 
	   cast((select count(*) 
	   from Land l  
	   join Utility u on u.ID = l.FkUtilityID
	   where Gas = 1) as varchar) as GasQuantity
go

--CHECK
select l.ID, Gas
from land l
join Utility u on u.ID = l.FkUtilityID
order by gas desc
go


--------------------------------------------------------------------------
--(16) Запит на відображання ділянок у яких було X власників
create view LandsByOwners 
	as select FkLandID as LandID,
			  FkBuyerID as OwnerID,
			  Surname as Owner, 
			  count(FkLandID) over(partition by FkLandID) as OwnersQuantity 
	from Act a
	join Natural n on n.ID = FkBuyerID
go

create proc LandsByOwnersQuantity @owners int
as begin
	select LandID, OwnerID, Owner from LandsByOwners
	where OwnersQuantity = @owners
end
go

exec LandsByOwnersQuantity 3
go


--------------------------------------------------------------------------
-- (17) Запит на відображення актів затвердженими реєстратором
select r.ID, r.Surname + ' ' + r.Name as Registrar, a.ID as ActID, a.FkLandID as LandID, lo.Address
from Registrar r
join Act a on a.FkRegistrarID = r.ID
join Location lo on lo.ID = (select FkLocationID from Land la 
							 where a.FkLandID = la.ID)
order by r.ID, a.ID
go


--------------------------------------------------------------------------
--(18) Запит на відображення суми вартості ділянок фізичних осіб
select la.FkOwnerID as OwnerID,
	   n.Surname as Owner,
	   la.ID as LandID, 
	   cast(sum(lo.Tax + u.Tax + r.Tax) as varchar) + ' mln' as TotalTax
from Land la
join Natural n on n.ID = la.FkOwnerID
join Location lo on lo.ID = la.FkLocationID
join UsageType u on u.ID = la.FkUsageTypeID
join Object o on o.FkLandID = la.ID
join Resource r on r.FkObjectID = o.ID
group by FkOwnerID, n.Surname, la.ID
order by FkOwnerID
go


--------------------------------------------------------------------------
--(19) Запит на відображення номеру телефону продавця та його ділянки
select a.FkSellerID as SellerID, n.Surname as Seller, n.Phone, lo.Address
from Act a
join Natural n on n.ID = a.FkSellerID
join Location lo on lo.ID = (select la.FkLocationID from Land la where la.ID = a.FkLandID)
order by FkLandID, Date
go

--------------------------------------------------------------------------
--(20) Запит на відображення кількості актів проведених із ділянкою
select la.ID, lo.Address, count(FkLandID) as ActsQuantity 
from Land la
join Location lo on lo.ID = la.FkLocationID
left join Act a on a.FkLandID = la.ID
group by la.ID, lo.Address
order by ActsQuantity
go