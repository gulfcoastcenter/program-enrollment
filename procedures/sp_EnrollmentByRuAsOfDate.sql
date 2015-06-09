/*
exec sp_EnrollmentByRuAsOfDate '6/8/2015', '5410'
*/

if OBJECT_ID('sp_EnrollmentByRuAsOfDate') is not null
	drop procedure sp_EnrollmentByRuAsOfDate
go
create procedure sp_EnrollmentByRuAsOfDate (
	@asofdate datetime,
	@ru nvarchar(max) = null
) as

select pe.c_id [Client Id]
	, c.LastName + ', ' + c.FirstName [Client Name]
	, pe.c_msa_prog [RU]
	, ru.Name [Program]
	, pe.c_msa_admt [Admit Date] 
	, pe.c_msa_dsch [Discharge Date]

from mis_c_msarec pe
left join Client.Client_Record c
  on c.ClientID = pe.c_id
left join SysFile.RU ru
  on ru.RU = pe.c_msa_prog
where @asofdate between c_msa_admt and coalesce(c_msa_dsch, getdate())
and
	(
	@ru is null
	or
	pe.c_msa_prog in (select data from dbo.Split(@ru, ','))
	)
order by ru.RU, pe.c_id, pe.c_msa_admt