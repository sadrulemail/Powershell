use master
go
select @@SERVERNAME as srv_name, db.name as DBName,sp.name as ownerName
from sys.databases db left join sys.server_principals sp on db.owner_sid=sp.sid
where sp.name <>'sa' and sp.name not in(SELECT  service_account FROM sys.dm_server_services) --and database_id>4
and db.name not in('master','model','msdb','tempdb','ReportServer','ReportServerTempDB','Distribution',
'DQS_MAIN','DQS_PROJECTS','DQS_STAGING_DATA')