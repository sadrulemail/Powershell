use master
go
declare @scripts varchar(max);
select 
@scripts=COALESCE(@scripts,'','') +'use [' + db.name+']; exec sp_changedbowner [sa];' 
from sys.databases db left join sys.server_principals sp on db.owner_sid=sp.sid
where sp.name <>'sa' and sp.name not in(SELECT  service_account FROM sys.dm_server_services) --and database_id>4
and db.name not in('master','model','msdb','tempdb','ReportServer','ReportServerTempDB','Distribution',
'DQS_MAIN','DQS_PROJECTS','DQS_STAGING_DATA')
--print @scripts
if len(@scripts)>5
begin
	exec(@scripts)
end
print 'Done'


