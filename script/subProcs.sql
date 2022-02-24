use master
use LandCompany
go

--------------------------------------------------------------------------
--��������� ��� ���������� ���� ���������� ������ � ���� �� ��������
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

--------------------------------------------------------------------------
--���������� ID ��������� ����� ����� ���������� �������� ��� ���������� ��� ��������
create trigger UpdateLandOwner 
on Act after insert, update
as begin
	declare @owner int = (select FkBuyerID from inserted)
	declare @land int =  (select FkLandID from inserted)
	update Land set FkOwnerID = @owner where ID = @land
end
go