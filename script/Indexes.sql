use master
use LandCompany
go

select n.ID as NaturalID, n.Surname
from Natural n
where Surname in ('Wemyss', 'Heddy', 'Trench', 'Coyte', 'Soar', 'Sagrott')
go

create index NaturalID on Natural(Surname) 
go

--02471891