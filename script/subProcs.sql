use master
use LandCompany
go

--------------------------------------------------------------------------
--Процедура для обновления всех владельцов земель в базе на текущего
create proc UpdateOwner 
as begin
	declare @owner int
	declare @land int
	declare cur cursor local
	for select FkBuyerID, FkLandID from Act order by FkLandID, Date

	open cur
	fetch next from cur into @owner, @land
	while @@FETCH_STATUS = 0
	begin
		update Land set FkOwnerID = @owner where ID = @land
		fetch next from cur into @owner, @land
	end
	close cur
end
go

exec UpdateOwner
go

--------------------------------------------------------------------------
--Обновление ID владельца земли после заключения договора или обновления его значений
create trigger UpdateLandOwner 
on Act after insert, update
as begin
	declare @owner int = (select FkBuyerID from inserted)
	declare @land int =  (select FkLandID from inserted)
	update Land set FkOwnerID = @owner where ID = @land
end
go

--------------------------------------------------------------------------
--Перевірка по повному імені чи є дана людина реєстратором чи юридичною особою
create proc CheckStatusByFullname @name varchar(20), @surname varchar(20)
as begin
	declare @table table (ID int, Status varchar(20))
	declare @id int

	if (@name in (select Name from Registrar where Surname = @surname))
	begin
		declare @status varchar(10) = 'registrar'
		declare cur cursor for select ID from Registrar 
		where Name = @name and Surname = @surname
		
		open cur
		fetch next from cur into @id
		while @@FETCH_STATUS = 0
		begin
			insert into @table (ID, Status) values
			(@id, @status)
			fetch next from cur into @id
		end
		close cur
		deallocate cur
	end
	else
	begin
		if(@name in (select Name from Natural where Surname = @surname))
		begin
			declare cur cursor local for select ID from Natural
			where Name = @name and Surname = @surname

			open cur
			fetch next from cur into @id
			while @@FETCH_STATUS = 0
			begin
				set @status = 'natural'
				if (@id in (select l.FkNaturalID from Legal l where FkNaturalID = @id))
					set @status = 'legal'

				insert into @table (ID, Status) values
				(@id, @status)
				fetch next from cur into @id
			end
			close cur
			deallocate cur
		end
	end
	if (select count(*) from @table) > 0
		select * from @table
	else
		print 'No person found with name ' + @surname + ' ' + @name
end
go

select * from Natural
exec CheckStatusByFullname @name = 'Rosella', @surname = 'Speak'
go


--------------------------------------------------------------------------
--акты за регистратором
create proc getActsByRegistrarID @regID int 
as begin
	select a.ID as ActID, 
		   a.FkSellerID as SellerID, 
		   (select n.Surname + ' ' + n.Name from Natural n where FkSellerID = n.ID) as Seller,
		   a.FkBuyerID as BuyerID,
		   (select n.Surname + ' ' + n.Name from Natural n where FkBuyerID = n.ID) as Buyer,
		   a.FkLandID as LandID,
		   lo.Address 
	from Act a
	join Location lo on lo.ID = (select la.FkLocationID from Land la where la.ID = a.FkLandID)
	where a.FkRegistrarID = @regID
	order by ActID
end
go

exec getActsByRegistrarID @regID = 3
go


--------------------------------------------------------------------------
--инфа по земле
create proc GetBasicAboutLandByLandID @landID int
as begin
	select la.ID as LandID, 
		   lo.Address,
		   lo.Tax as LocationTax,
		   us.ID as UsID,
		   us.Name as Usage,
		   us.Tax as UsageTax,
		   ut.ID as UtID,
		   ut.Plumbing as Pl,
		   ut.Sanitation as Sa,
		   ut.Heating as He,
		   ut.Gas as Ga,
		   ut.Electricity as El,
		   (select count(o.FkLandID) from Object o where FkLandID = la.ID) as ObjectsQuantity,
		   (select count(r.FkObjectID) from Resource r 
		   where r.FkObjectID in (select o.ID from Object o where FkLandID = la.ID)) as ResourseQuantity
	from Land la
	join Location lo on lo.ID = la.FkLocationID
	join UsageType us on us.ID = la.FkUsageTypeID
	join Utility ut on ut.ID = la.FkUtilityID
	where la.ID = @landID
end 
go

exec GetBasicAboutLandByLandID 16
go


--------------------------------------------------------------------------
--инфа о всех обьектах и ресурсах
create proc GetObjectsAndResourceInfoByLandID @landID int
as begin
	select o.ID as ObjID,
		   r.ID as ResourceID,
		   r.Name as Resource,
		   r.Tax,
		   sum(Tax) over(partition by r.FkObjectID)  as ObjTax
	from Object o
	left join Resource r on r.FkObjectID = o.ID
	where o.FkLandID = @landID
	order by ObjID, ResourceID
end
go

exec GetObjectsAndResourceInfoByLandID 16
go
