use master
use LandCompany
go

--------------------------------------------------------------------------
--REGISTRAR USER
--drop user RegistrarUser
create login Registrar with password = '1111'
create user RegistrarUser for login Registrar
go

grant select on Land to RegistrarUser
grant select on Location to RegistrarUser
grant select on UsageType to RegistrarUser
grant select on Object to RegistrarUser
grant select on Resource to RegistrarUser
grant select on Utility to RegistrarUser
grant select on Registrar to RegistrarUser
grant select, insert, update on Legal to RegistrarUser
grant select, insert, update on Natural to RegistrarUser
grant select, insert, update on Act to RegistrarUser
go

grant select on landsAndNumberOfObjects to RegistrarUser
grant select on LegalLands to RegistrarUser
grant select on NaturalLands to RegistrarUser
grant select on LegalBuyers to RegistrarUser
grant select on NaturalSeller to RegistrarUser
grant select on lastYearActs to RegistrarUser
grant select on HistoryByLandID to RegistrarUser
grant execute on ResourcesbyOwnerID to RegistrarUser
grant execute on LandsByOwnersQuantity to RegistrarUser
grant execute on CheckStatusByFullname to RegistrarUser
grant execute on getActsByRegistrarID to RegistrarUser
go


--------------------------------------------------------------------------
--LAND REGISTRAR
create login LandRegistrar with password = '2222'
create user LandRegistrarUser for login LandRegistrar
go

grant select on Registrar to LandRegistrarUser
grant select on Legal to LandRegistrarUser
grant select on Natural to LandRegistrarUser
grant select on Act to LandRegistrarUser
grant select, insert, update on Land to LandRegistrarUser
grant select, insert, update on Location to LandRegistrarUser
grant select, insert, update, delete on UsageType to LandRegistrarUser
grant select, insert, update, delete on Utility to LandRegistrarUser
grant select, insert, update, delete on Object to LandRegistrarUser
grant select, insert, update, delete on Resource to LandRegistrarUser
go

grant select on landsAndNumberOfObjects to LandRegistrarUser
grant select on totalArea to LandRegistrarUser
grant execute on TopOwnersByArea to LandRegistrarUser
grant execute on CheckStatusByFullname to LandRegistrarUser
grant execute on GetBasicAboutLandByLandID to LandRegistrarUser
grant execute on GetObjectsAndResourceInfoByLandID to LandRegistrarUser
go


--------------------------------------------------------------------------
--ADMINISTRATOR
create login Admin with password = '3333'
create user AdminUser for login Admin
go

grant select, insert, update, delete on Registrar to AdminUser
grant select, insert, update, delete on Legal to AdminUser
grant select, insert, update, delete on Natural to AdminUser
grant select, insert, update, delete on Act to AdminUser
grant select, insert, update, delete on Land to AdminUser
grant select, insert, update, delete on Location to AdminUser
grant select, insert, update, delete on UsageType to AdminUser
grant select, insert, update, delete on Utility to AdminUser
grant select, insert, update, delete on Object to AdminUser
grant select, insert, update, delete on Resource to AdminUser
go

grant select on landsAndNumberOfObjects to AdminUser
grant select on totalArea to AdminUser
grant select on LegalLands to AdminUser
grant select on NaturalLands to AdminUser
grant select on LegalBuyers to AdminUser
grant select on NaturalSeller to AdminUser
grant select on lastYearActs to AdminUser
grant select on HistoryByLandID to AdminUser
grant select on LandsByOwners to AdminUser
go

grant execute on ResourcesbyOwnerID to AdminUser
grant execute on TopOwnersByArea to AdminUser
grant execute on LandsByOwnersQuantity to AdminUser
grant execute on CheckStatusByFullname to AdminUser
grant execute on getActsByRegistrarID to AdminUser
grant execute on GetBasicAboutLandByLandID to AdminUser
grant execute on GetObjectsAndResourceInfoByLandID to AdminUser
go