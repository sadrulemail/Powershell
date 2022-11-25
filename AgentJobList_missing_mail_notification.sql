SELECT @@servername as SRV_name, j.name AS JobName FROM msdb.dbo.sysjobs j
LEFT JOIN msdb.dbo.sysoperators o 
ON (j.notify_email_operator_id= o.id)
WHERE j.enabled = 1
   --AND j.notify_level_email NOT IN (1, 2, 3) 1= when success,2=when failed,3=both
   AND j.notify_level_email NOT IN ( 2, 3)

--   SELECT * 
--FROM [msdb].[dbo].[sysoperators]
