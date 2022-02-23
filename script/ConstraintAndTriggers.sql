use master 
use LandCompany
go

--------------------------------------------------------------------------
alter table UsageType
add constraint CH_UsageTypeTax check (Tax >= 0)
go

--------------------------------------------------------------------------
alter table Location 
add constraint CH_LocationTax check (Tax >= 0)
go

--------------------------------------------------------------------------
alter table Natural
add constraint CH_NaturalName 
check (Name not like '%[^A-Za-z'' -]%')
go

alter table Natural
add constraint CH_NaturalSurname 
check (Surname not like '%[^A-Za-z'' -]%')
go

alter table Natural
add constraint CH_NaturalDBDate 
check (DBDate like '____-__-__' and DBDate not like '%[a-Z]%')
go

alter table Natural
add constraint CH_Natural_Phone 
check (Phone like '___-___-____' and Phone not like '%[a-Z]%')
go

alter table Natural
add constraint CH_DBDate check (DATEDIFF(yy, DBDate, GETDATE()) >= 18)
go

--------------------------------------------------------------------------
alter table Registrar
add constraint CH_RegistrarName 
check (Name not like '%[^A-Za-z'' -]%')
go

alter table Registrar
add constraint CH_RegistrarSurname 
check (Surname not like '%[^A-Za-z'' -]%')
go

alter table Registrar
add constraint CH_RegistrarPhone 
check (Phone like '___-___-____' and Phone not like '%[a-Z]%')
go

--------------------------------------------------------------------------
alter table Object
add constraint CH_Latitude check (LatitudeL < LatitudeR)
go

alter table Object
add constraint CH_Longtitude check (LongtitudeD < LongtitudeU)
go

alter table Object
add constraint CH_MinMaxCoordinates 
check ((LongtitudeD between -180 and 180) 
and (LatitudeL between -180 and 180))
go

--------------------------------------------------------------------------
create trigger ActOwnerToOwner 
on Act after insert
as begin
	declare @seller int = (select FkSellerID from inserted)
	declare @land int = (select FkLandID from inserted)
	if (select count(*) from Act a 
		where @land = FkLandID) > 1
	begin
		if @seller != (select top 1 FkBuyerID from Act
					   where FkSellerID != @seller
					   and @land = FkLandID
					   order by Date desc)
		begin
			print 'Inserted Seller is not the previous Buyer'
			rollback transaction
		end
	end
end
go

alter table Act
add constraint CH_ActNaturals check (FkBuyerID != FkSellerID)
go

alter table Act
add constraint CH_ActDate check (Date <= GETDATE())
go

--------------------------------------------------------------------------
alter table Resource
add constraint CH_ResourceTax check (Tax >= 0)
go
