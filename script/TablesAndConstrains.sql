CREATE DATABASE LandCompany;
--go
--DROP DATABASE LandCompany
--go
USE master;
USE LandCompany;
go

--------------------------------------------------------------------------
create table UsageType (
	ID int identity(1,1) primary key,
	Name varchar(50) not null,
	Tax float default(0) not null
)
go

--------------------------------------------------------------------------
create table Location (
	ID int identity(1,1) primary key,
	Address varchar(50) not null unique,
	Tax float default(0) not null
)
go

--------------------------------------------------------------------------
create table Natural (
	ID int identity(1,1) primary key,
	Name varchar(20) not null,
	Surname varchar(20) not null,
	DBDate date not null,
	Phone varchar(15) not null unique
)
go

--------------------------------------------------------------------------
create table Registrar (
	ID int identity(1,1) primary key,
    Name varchar(20) not null,
	Surname varchar(20) not null,
    Phone varchar(15) not null unique
)
go

--------------------------------------------------------------------------
create table Utility (
	ID int identity(1,1) primary key,
	Plumbing bit default(0) not null,
	Sanitation bit default(0) not null,
	Heating bit default(0) not null,
	Gas bit default(0) not null,
	Electricity bit default(0) not null
)
go

--------------------------------------------------------------------------
create table Legal (
	ID int identity(1,1) primary key,
    Name varchar(50) not null,
	FkNaturalID int not null foreign key references Natural(ID)
	on update cascade
	on delete cascade
)
go

--------------------------------------------------------------------------
create table Land (
	ID int identity(1,1) primary key,

	FkOwnerID int not null foreign key
	references Natural(ID)
	on update cascade
	on delete cascade,

	FkLocationID int not null unique foreign key 
	references Location(ID)
	on update cascade
	on delete cascade,

	FkUsageTypeID int unique foreign key
	references UsageType(ID)
	on update cascade
	on delete set null,

	FkUtilityID int null unique foreign key
	references Utility(ID)
	on update cascade
	on delete set null
)
go

--------------------------------------------------------------------------
create table Object (
	ID int identity(1,1) primary key,

	FkLandID int not null foreign key
	references Land(ID)
	on update cascade
	on delete cascade,

	LatitudeL float not null,
	LatitudeR float not null,
	LongtitudeD float not null,
	LongtitudeU float not null
)
go

--------------------------------------------------------------------------
create table Act (
	ID int identity(1,1) primary key,

	FkLandID int foreign key
	references Land(ID)
	on update cascade
	on delete set null,

	FkBuyerID int not null foreign key
	references Natural(ID),

	FkSellerID int not null foreign key
	references Natural(ID),

	FkRegistrarID int not null foreign key
	references Registrar(ID)
	on update cascade,

	Date date default(getdate()) not null
)
go

--------------------------------------------------------------------------
create table Resource (
	ID int identity(1,1) primary key,

	FkObjectID int not null foreign key
	references Object(ID)
	on update cascade
	on delete cascade,

    Name varchar(50) not null,
	Tax float DEFAULT(0) not null
)
go

--------------------------------------------------------------------------
SELECT * FROM UsageType
go
SELECT * FROM Location
go
SELECT * FROM Natural 
go
SELECT * FROM Registrar
go
SELECT * FROM Utility
go
SELECT * FROM Legal
go
SELECT * FROM Land
go
SELECT * FROM Object
go
SELECT * FROM Act
go
SELECT * FROM Resource
go

dbcc checkident('Land', reseed, 0)
go