if not exists(select * from msdb.dbo.sysoperators where name='Operator_name')
begin
USE [msdb];
EXEC msdb.dbo.sp_add_operator @name=N'Operator_name', 
		@enabled=1, 
		@pager_days=0, 
		@email_address=N'itdba@wcgclinical.com'
end

DECLARE @listStr VARCHAR(MAX)

SELECT 

@listStr= COALESCE(@listStr+';' ,'') +'USE msdb; EXEC msdb.dbo.sp_update_job @job_id=N'''+cast(j.job_id as varchar(255))+''',@notify_level_email=2,@notify_level_eventlog=2, @notify_email_operator_name=N''Operator_name''' 
FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysoperators o 
ON (j.notify_email_operator_id= o.id)
WHERE j.enabled = 1   
   AND j.notify_level_email NOT IN ( 2, 3)

 --print @listStr
 exec(@listStr)