use master 
use LandCompany
go

insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (1, 1, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (2, 0, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (3, 0, 1, 1, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (4, 1, 1, 1, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (5, 1, 1, 1, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (6, 0, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (7, 0, 0, 1, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (8, 1, 0, 1, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (9, 0, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (10, 0, 0, 0, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (11, 0, 0, 1, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (12, 1, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (13, 0, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (15, 0, 0, 0, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (16, 1, 1, 1, 0);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (17, 1, 0, 0, 1);
insert into Utility (FkLandID, Plumbing, Sanitation, Heating, Gas) values (20, 1, 0, 0, 1);
go

update Utility set Utility.Electricity = 1 where FkLandID % 2 = 0
go
